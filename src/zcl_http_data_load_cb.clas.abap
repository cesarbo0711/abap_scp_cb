CLASS zcl_http_data_load_cb DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension .

  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA: tablename  TYPE string,
          filename   TYPE string,
          fileext    TYPE string,
          dataoption TYPE string,
          filedata   TYPE string.

    METHODS: get_input_field_value IMPORTING name          TYPE string
                                             dataref       TYPE data
                                   RETURNING VALUE(value)  TYPE string.

    METHODS: get_html RETURNING VALUE(ui_html) TYPE string.
ENDCLASS.



CLASS zcl_http_data_load_cb IMPLEMENTATION.

  METHOD if_http_service_extension~handle_request.
    CASE request->get_method( ).

      " ---------------------------------------------------------
      " CASO GET: Renderiza la interfaz web oscura en el navegador
      " ---------------------------------------------------------
      WHEN CONV string( if_web_http_client=>get ).
        DATA(sap_table_request) = request->get_header_field( 'sap-table-request' ).
        IF sap_table_request IS INITIAL.
          response->set_text( get_html( ) ).
        ENDIF.

      " ---------------------------------------------------------
      " CASO POST: Recibe el JSON, limpia los metadatos e inserta
      " ---------------------------------------------------------
      WHEN CONV string( if_web_http_client=>post ).
        " Limpiar variables globales por cada ejecución
        CLEAR: filedata, filename, fileext, tablename, dataoption.

        " Separar el texto crudo del cuerpo por saltos de línea
        SPLIT request->get_text( ) AT cl_abap_char_utilities=>cr_lf INTO TABLE DATA(content).

        " Extraer el nombre del archivo y la extensión de los metadatos (Línea 2)
        READ TABLE content REFERENCE INTO DATA(content_item) INDEX 2.
        IF sy-subrc = 0.
          SPLIT content_item->* AT ';' INTO TABLE DATA(content_dis).
          READ TABLE content_dis REFERENCE INTO DATA(content_dis_item) INDEX 3.
          IF sy-subrc = 0.
            SPLIT content_dis_item->* AT '=' INTO DATA(fn) filename.
            REPLACE ALL OCCURRENCES OF `"` IN filename WITH space.
            CONDENSE filename NO-GAPS.
            SPLIT filename AT '.' INTO filename fileext.
          ENDIF.
        ENDIF.

        " Quitar las líneas de metadatos del inicio (Multipart Boundary)
        DELETE content FROM 1 TO 4.
        " Quitar las líneas de cierre del Multipart del final
        DELETE content FROM ( lines( content ) - 8 ) TO lines( content ).

        " Reconstruir el JSON puro del archivo en la variable estricta
        LOOP AT content REFERENCE INTO content_item.
          filedata = filedata && content_item->*.
        ENDLOOP.

        " Asignamos manualmente tu tabla física real de libros para evitar fallos del formulario
        tablename = 'ZTB_LIBROS_CB'.

        " Capturar los campos ingresados en el formulario web para las opciones (Append/Replace)
        DATA(ui_data) = request->get_form_field( `filetoupload-data` ).
        DATA(ui_dataref) = /ui2/cl_json=>generate( json = ui_data ).
        IF ui_dataref IS BOUND.
          ASSIGN ui_dataref->* TO FIELD-SYMBOL(<ui_dataref>).
          dataoption = me->get_input_field_value( name = `DATAOPTION` dataref = <ui_dataref> ).
        ENDIF.

        " Validaciones de seguridad
        IF tablename IS INITIAL.
          response->set_status( i_code = if_web_http_status=>bad_request i_reason = 'Table name empty' ).
          response->set_text( 'Error: Escribe un nombre de tabla valido, mano.' ).
          return.
        ENDIF.

        " Forzar a que solo acepte formato .json como pide la guia
        IF fileext <> `json`.
          response->set_status( i_code = if_web_http_status=>bad_request i_reason = 'File type not supported' ).
          response->set_text( 'Error: Solo se admiten archivos con extension .json' ).
          RETURN.
        ENDIF.

        " Generación dinámica de la estructura de la tabla interna
        DATA: dynamic_table TYPE REF TO data.
        FIELD-SYMBOLS: <table_structure> TYPE table.

        TRY.
            CREATE DATA dynamic_table TYPE TABLE OF (tablename).
            ASSIGN dynamic_table->* TO <table_structure>.
          CATCH cx_sy_create_data_error INTO DATA(cd_exception).
            response->set_status( i_code = if_web_http_status=>bad_request i_reason = cd_exception->get_text( ) ).
            response->set_text( cd_exception->get_text( ) ).
            RETURN.
        ENDTRY.


        " Mapear el JSON directo forzando minúsculas del usuario
        /ui2/cl_json=>deserialize( EXPORTING json        = filedata
                                             pretty_name = /ui2/cl_json=>pretty_mode-user_low_case
                                   CHANGING  data        = <table_structure> ).

        " Si en las opciones marcaron 'Replace' (Valor '1' en el HTML), limpia la DB
        IF dataoption = `1` OR dataoption = `REPLACE`.
          DELETE FROM (tablename).
        ENDIF.

        " Intentar el volcado de datos final
        TRY.
            INSERT (tablename) FROM TABLE @<table_structure>.
            IF sy-subrc = 0.
              response->set_status( i_code = if_web_http_status=>ok i_reason = 'Success' ).
              response->set_text( '¡Tabla actualizada con exito, mano!' ).
            ELSE.
              response->set_status( i_code = if_web_http_status=>bad_request i_reason = 'Insert failed' ).
              response->set_text( 'Error: Llaves duplicadas detectadas en el JSON.' ).
            ENDIF.
          CATCH cx_sy_open_sql_db INTO DATA(db_exception).
            response->set_status( i_code = if_web_http_status=>bad_request i_reason = db_exception->get_text( ) ).
            response->set_text( db_exception->get_text( ) ).
            RETURN.
        ENDTRY.

    ENDCASE.
  ENDMETHOD.


  METHOD get_input_field_value.
    FIELD-SYMBOLS: <value> TYPE data,
                   <field> TYPE any.
    ASSIGN COMPONENT name OF STRUCTURE dataref TO <field>.
    IF <field> IS ASSIGNED.
      ASSIGN <field>->* TO <value>.
      value = condense( <value> ).
    ENDIF.
  ENDMETHOD.


  METHOD get_html.
    " Devuelve el bloque HTML maquetado con soporte JSON directo
    ui_html = `<!DOCTYPE html>` &&
              `<html>` &&
              `<head>` &&
              `    <meta charset="UTF-8">` &&
              `    <title>ABAP File Uploader</title>` &&
              `    <style>` &&
              `        body { font-family: 'Segoe UI', Arial, sans-serif; background-color: #1a1a1a; color: #ffffff; margin: 0; padding: 40px; }` &&
              `        .container { max-width: 600px; background-color: #262626; padding: 30px; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.5); }` &&
              `        h2 { margin-top: 0; border-bottom: 2px solid #3a3a3a; padding-bottom: 10px; color: #3498db; }` &&
              `        .form-group { margin-bottom: 20px; }` &&
              `        label { display: block; margin-bottom: 8px; font-weight: bold; color: #cccccc; }` &&
              `        input[type="text"] { width: 100%; padding: 10px; box-sizing: border-box; background-color: #333333; border: 1px solid #444444; color: #fff; border-radius: 4px; }` &&
              `        input[type="file"] { display: block; margin-top: 5px; }` &&
              `        .radio-group { margin-top: 10px; }` &&
              `        .radio-group label { display: inline; font-weight: normal; margin-right: 20px; cursor: pointer; }` &&
              `        button { background-color: #3498db; color: white; border: none; padding: 12px 20px; font-size: 16px; border-radius: 4px; cursor: pointer; width: 100%; transition: background 0.3s; }` &&
              `        button:hover { background-color: #2980b9; }` &&
              `    </style>` &&
              `</head>` &&
              `<body>` &&
              `    <div class="container">` &&
              `        <h2>ABAP File Uploader</h2>` &&
              `        <form method="POST" enctype="multipart/form-data">` &&
              `            <div class="form-group">` &&
              `                <label for="tableName">Target ABAP Table</label>` &&
              `                <input type="text" id="tableName" name="tableName" value="ZTB_LIBROS_CB" disabled style="opacity: 0.7; cursor: not-allowed;">` &&
              `            </div>` &&
              `            <div class="form-group">` &&
              `                <label for="fileUpload">Choose File for Upload...</label>` &&
              `                <input type="file" id="fileUpload" name="fileUpload" accept=".json" required>` &&
              `            </div>` &&
              `            <div class="form-group">` &&
              `                <label>Data Upload Options</label>` &&
              `                <div class="radio-group">` &&
              `                    <input type="radio" id="append" name="uploadOption" value="APPEND" checked>` &&
              `                    <label for="append">Append</label>` &&
              `                    <input type="radio" id="replace" name="uploadOption" value="REPLACE">` &&
              `                    <label for="replace">Replace</label>` &&
              `                </div>` &&
              `            </div>` &&
              `            <button type="submit">Upload File</button>` &&
              `        </form>` &&
              `    </div>` &&
              `</body>` &&
              `</html>`.
  ENDMETHOD.

ENDCLASS.
