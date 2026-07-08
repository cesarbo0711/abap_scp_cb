@AbapCatalog.sqlViewName: 'Z_LIBROS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Libros'
@Metadata.ignorePropagatedAnnotations: true
define view Z_B_LIBROS_CB as select from ztb_libros_cb

{
    
    key id_libro as IdLibro,
    key bi_categ as Categoria,
    titulo as Titulo,
    autor as Autor,
    editorial as Editorial,
    idioma as Idioma,
    paginas as Paginas,
    precio as Precio,
    moneda as Moneda,
    formato as Formato, 
    url as Imagen
    
}
