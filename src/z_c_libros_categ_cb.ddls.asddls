@AbapCatalog.sqlViewName: 'ZSQL_LI_V2_CB'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vista Principal de Libros'
@Metadata.allowExtensions: true

// Habilita la barra de búsqueda general (Searchable)
@Search.searchable: true

@UI.headerInfo: {
    typeName: 'Libro',
    typeNamePlural: 'Libros',
    title: { type: #STANDARD, value: 'titulo' },
    description: { type: #STANDARD, value: 'autor' },
    imageUrl: 'url'
}
define root view Z_C_LIBROS_CATEG_CB
  as select from ztb_libros_cb as Libros
  association [1..1] to ztb_catego_cb as _InfoLibros    on Libros.bi_categ = _InfoLibros.bi_categ
  association [0..*] to z_b_clnts_lib_cb as _ClientesLibro on Libros.id_libro = _ClientesLibro.IdLibro
{
  // ==========================================
  // CONFIGURACIÓN DE FACETS (PUNTO 2)
  // ==========================================
  @UI.facet: [
      { id: 'idHeader', purpose: #STANDARD, type: #COLLECTION, label: 'Información General', position: 10 },
      { id: 'idDetallesLibro', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'Datos del Libro', parentId: 'idHeader', position: 10 },
      { id: 'idClientesFacet', purpose: #STANDARD, type: #LINEITEM_REFERENCE, label: 'Clientes', position: 20, targetElement: '_ClientesLibro' }
  ]

  // ==========================================
  // CAMPOS Y ANOTACIONES DE BÚSQUEDA / FILTROS (PUNTO 1)
  // ==========================================
  
  // Filtro 3: Value Help de Categorías apuntando a la tabla ZTB_CATEGO
  @UI.lineItem: [ { position: 30, label: 'Categoría' } ]
  @UI.selectionField: [ { position: 30 } ]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'Z_B_CATEGO_CB', element: 'bi_categ' } }]
  @ObjectModel.text.element: ['NombreCategoria']
  key bi_categ,

  @UI.lineItem: [ { position: 20, label: 'Id del Libro' } ]
  @UI.identification: [ { position: 20, label: 'Id del Libro' } ] 
  key id_libro,

  // Filtro 1: Filtro directo individual (SelectionField) sobre Título
  @UI.lineItem: [ { position: 10, label: 'Título' } ]
  @UI.identification: [ { position: 10, label: 'Título' } ]
  @UI.selectionField: [ { position: 10 } ]
  titulo,

  // Filtro 2: Campo habilitado para la barra de búsqueda global (Searchable)
  @UI.lineItem: [ { position: 35, label: 'Editorial' } ]
  @UI.identification: [ { position: 35, label: 'Editorial' } ]
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  editorial,

  @UI.lineItem: [ { position: 40, label: 'Autor' } ]
  @UI.identification: [ { position: 40, label: 'Autor' } ]
  autor,

  // Criticidad: Informa las ventas por colores (Punto 1.4)
  // 3 = Verde (Ventas Altas), 2 = Amarillo (Ventas Medias), 1 = Rojo (Pocas Ventas), 0 = Gris (Sin Ventas)
  @UI.lineItem: [ { position: 50, label: 'Precio', criticality: 'VisualPrecio' } ]
  @UI.identification: [ { position: 50, label: 'Precio de Venta' } ]
  precio,
      
  moneda,
  paginas,
  url,

  _InfoLibros.descripcion as NombreCategoria,

  // Lógica del campo de criticidad basado en las ventas/precios
  case 
    when precio <= 0 then 0       // Sin ventas (Gris)
    when precio < 20 then 1       // Pocas ventas (Rojo)
    when precio between 20 and 40 then 2 // Ventas medias (Amarillo)
    else 3                        // Ventas altas (Verde)
  end                     as VisualPrecio,

  _InfoLibros,
  _ClientesLibro
}
