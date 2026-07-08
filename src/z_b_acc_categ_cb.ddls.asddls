@AbapCatalog.sqlViewName: 'Z_ACC_CATEG_CB'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Acceso y Categorias'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view z_b_acc_categ_cb as select from ztb_acc_categ_cb
{
    
    key bi_categ as Categoria,
    tipo_acceso as TipoAcceso
}
