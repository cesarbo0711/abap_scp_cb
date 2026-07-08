CLASS zcl_libros_prime_cb DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_libros_prime_cb IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: lt_acceso TYPE TABLE OF ztb_acc_categ_cb,
          lt_categorias TYPE TABLE OF ztb_catego_cb,
          lt_clientes TYPE TABLE OF ztb_clientes_cb,
          lt_ids  TYPE TABLE OF ztb_clnts_lib_cb,
          lt_libros TYPE TABLE OF ztb_libros_cb.


          lt_acceso = VALUE #(

                ( bi_categ = '1' tipo_acceso = '1' )
                ( bi_categ = '2' tipo_acceso = '2' )
                ( bi_categ = '3' tipo_acceso = '3' )
                ( bi_categ = '4' tipo_acceso = '4' )

           ).

            DELETE FROM ztb_acc_categ_cb.
            INSERT ztb_acc_categ_cb FROM TABLE @lt_acceso.
            SELECT * FROM ztb_acc_categ_cb INTO TABLE @lt_acceso.
            out->write( sy-dbcnt ).
            out->write( 'ztb_acc_categ_cb data inserted successfully!' ).

          lt_categorias = VALUE #(

               ( bi_categ = '1' descripcion = '1' )
               ( bi_categ = '2' descripcion = '2' )
               ( bi_categ = '3' descripcion = '3' )
               ( bi_categ = '4' descripcion = '4' )

          ).

            DELETE FROM ztb_catego_cb.
            INSERT ztb_catego_cb FROM TABLE @lt_categorias.
            SELECT * FROM ztb_catego_cb INTO TABLE @lt_categorias.
            out->write( sy-dbcnt ).
            out->write( 'ztb_catego_cb data inserted successfully!' ).

            lt_clientes = VALUE #(

               ( id_cliente = '1' tipo_acceso = '1' nombre = 'Cristiano'
               apellidos = 'Ronaldo' email = 'cr7@gmail.com' url = 'link' )
               ( id_cliente = '2' tipo_acceso = '4' nombre = 'Cesar'
               apellidos = 'Borrego' email = 'kikeborregofigue@gmail.com' url = 'link' )
               ( id_cliente = '3' tipo_acceso = '2' nombre = 'Carla'
               apellidos = 'Pachanga' email = 'hernandezcarla@gmail.com' url = 'link' )
               ( id_cliente = '4' tipo_acceso = '3' nombre = 'Leonel'
               apellidos = 'Messi' email = 'messi10@gmail.com' url = 'link' )
               ).

            DELETE FROM ztb_clientes_cb.
            INSERT ztb_clientes_cb FROM TABLE @lt_clientes.
            SELECT * FROM ztb_clientes_cb INTO TABLE @lt_clientes.
            out->write( sy-dbcnt ).
            out->write( 'ztb_clientes_cb data inserted successfully!' ).


             lt_ids  = VALUE #(

               ( id_cliente = '1' id_libro = '14' )
               ( id_cliente = '2' id_libro = '11' )
               ( id_cliente = '3' id_libro = '400' )
               ( id_cliente = '4' id_libro = '1' )   ).

            DELETE FROM ztb_clnts_lib_cb.
            INSERT ztb_clnts_lib_cb FROM TABLE @lt_ids.
            SELECT * FROM ztb_clnts_lib_cb INTO TABLE @lt_ids.
            out->write( sy-dbcnt ).
            out->write( 'ztb_clnts_lib_cb data inserted successfully!' ).


           lt_libros = VALUE #(

                ( id_libro = '14' bi_categ = '1' titulo = 'EGO' autor = 'Yehuda Berg.'
                editorial = 'amazon' idioma = 'E' paginas = '277'
                precio = '19.48' moneda = '$' formato = 'P'
                url = 'https://m.media-amazon.com/images/I/61rhp5qhI4L._SY342_.jpg'   )

                ( id_libro = '11' bi_categ = '2' titulo = 'Los 7 habitos de la gente altamente efec'
                autor = 'Stephen R. Covey' editorial = 'amazon'
                idioma = 'E' paginas = '208' precio = '31.38' moneda = '$' formato = 'P'
                url = 'https://m.media-amazon.com/images/I/71a0vehiXFL._SY342_.jpg'   )

                ( id_libro = '400' bi_categ = '3' titulo = 'La Buena Nota de Estar Sola'
                autor = 'Cesar Landaeta H.' editorial = 'amazon'
                 idioma = 'E' paginas = '160' precio = '15.20' moneda = '$' formato = 'P'
                 url = 'https://m.media-amazon.com/images/I/91BjPWy4fsL._SY342_.jpg'   )

                ( id_libro = '1' bi_categ = '4' titulo = 'Toy Story' autor = 'Pixar'
                editorial = 'Disney' idioma = 'E' paginas = '201' precio = '60.20' moneda = '$' formato = 'E'
                url = 'https://m.media-amazon.com/images/I/81QATsjxgeL._AC_SX342_.jpg'   ) ).

            DELETE FROM ztb_libros_cb.
            INSERT ztb_libros_cb FROM TABLE @lt_libros.
            SELECT * FROM ztb_libros_cb INTO TABLE @lt_libros.
            out->write( sy-dbcnt ).
            out->write( 'ztb_acc_categ_cb data inserted successfully!' ).

  ENDMETHOD.
ENDCLASS.
