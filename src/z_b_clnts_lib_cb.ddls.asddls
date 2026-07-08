@AbapCatalog.sqlViewName: 'Z_CLNTS_LIB_CB'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vista Intermedia Clientes y Libros'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define view z_b_clnts_lib_cb
  as select from ztb_clnts_lib_cb
  association [1..1] to Z_B_CLIENTES_CB as _Cliente on $projection.IdCliente = _Cliente.Clientes
{
  key id_cliente as IdCliente,
  key id_libro   as IdLibro,

  // Campos expuestos mapeados directamente con mayúsculas correctas
  _Cliente.Nombre    as NombreCliente,
  _Cliente.Apellido  as ApellidoCliente,
  _Cliente.Email     as EmailCliente,

  _Cliente
}
