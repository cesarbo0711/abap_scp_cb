@AbapCatalog.sqlViewName: 'Z_CLIENTES_CB'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Clientes'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define view Z_B_CLIENTES_CB as select from ztb_clientes_cb
{
    
    key id_cliente as Clientes,
    key tipo_acceso as TipoAcceso,
    nombre as Nombre,
    apellidos as Apellido,
    email as Email,
    url as Url
    
    
}
