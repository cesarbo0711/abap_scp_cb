@AbapCatalog.sqlViewName: 'Z_CATEGORIAS_CB'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Categorias y Descripciones'
@Metadata.ignorePropagatedAnnotations: true
define view Z_B_CATEGO_CB as select from ztb_catego_cb
{
    
    key bi_categ as Categoria,
    descripcion as Descripcion 
    
}
