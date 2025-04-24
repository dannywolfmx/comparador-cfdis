import 'package:comparador_cfdis/models/format_tipo_comprobante.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart'; // Necesario para el tema
import 'package:comparador_cfdis/widgets/filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cfdi_bloc.dart';
import '../models/cfdi.dart';
import '../providers/column_visibility_provider.dart';
import 'package:provider/provider.dart';
import 'cfdi_detail_screen.dart';

class CFDITableView extends StatefulWidget {
  final List<CFDI> cfdis;

  const CFDITableView({Key? key, required this.cfdis}) : super(key: key);

  @override
  State<CFDITableView> createState() => _CFDITableViewState();
}

class _CFDITableViewState extends State<CFDITableView> {
  final int _sortColumnIndex = 0;
  final bool _sortAscending = true;
  late List<CFDI> _sortedCfdis;
  final Set<CFDI> _selectedCfdis = {}; // Conjunto para CFDIs seleccionados
  late _CFDIDataGridSource _cfdiDataGridSource;
  final DataGridController _dataGridController = DataGridController();
  // Quitar final de _rowsPerPage para poder cambiarlo
  int _rowsPerPage = 10;
  // Lista de opciones para el número de filas por página
  final List<int> _rowsPerPageOptions = [5, 10, 15, 20, 50, 100];

  // Controlador para el SfDataPager
  final DataPagerController _dataPagerController = DataPagerController();

  final TextEditingController _searchController = TextEditingController();
  List<CFDI> _filteredCfdis = [];
  bool _isSearching = false;

  // Mapa para almacenar los anchos personalizados de las columnas
  final Map<String, double> _columnWidths = {
    'emisor': 150.0,
    'receptor': 150.0,
    'fecha': 100.0,
    'total': 80.0,
    'tipo': 90.0,
    'uuid': 250.0, // UUID necesita más espacio por ser más largo
  };

  @override
  void initState() {
    super.initState();
    _sortedCfdis = List.from(widget.cfdis);
    _filteredCfdis = _sortedCfdis;
    _cfdiDataGridSource = _CFDIDataGridSource(
      cfdis: _isSearching ? _filteredCfdis : _sortedCfdis,
      selectedCfdis: _selectedCfdis,
      context: context,
      columnProvider:
          Provider.of<ColumnVisibilityProvider>(context, listen: false),
      rowsPerPage: _rowsPerPage, // Pasar rowsPerPage inicial
    );
    _sortData(); // Orden inicial
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _dataGridController.dispose();
    _dataPagerController.dispose(); // Dispose del pager controller
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CFDITableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cfdis != oldWidget.cfdis) {
      _sortedCfdis = List.from(widget.cfdis);
      // Recrear la fuente de datos con la nueva lista y rowsPerPage actual
      _cfdiDataGridSource = _CFDIDataGridSource(
        cfdis: _isSearching ? _filteredCfdis : _sortedCfdis,
        selectedCfdis: _selectedCfdis,
        context: context,
        columnProvider:
            Provider.of<ColumnVisibilityProvider>(context, listen: false),
        rowsPerPage: _rowsPerPage, // Pasar rowsPerPage actual
      );
      _sortData();
      // Resetear el paginador a la primera página si los datos cambian
      _dataPagerController.selectedPageIndex = 0;
    }
  }

  void _onSearchChanged() {
    _applySearchFilter();
    // Resetear el paginador a la primera página al buscar
    _dataPagerController.selectedPageIndex = 0;
  }

  void _applySearchFilter() {
    final searchTerm = _searchController.text.toLowerCase().trim();
    setState(() {
      _isSearching = searchTerm.isNotEmpty;
      if (_isSearching) {
        _filteredCfdis = _sortedCfdis.where((cfdi) {
          var formatoTipoComprobante =
              FormatTipoComprobante(cfdi.tipoDeComprobante);
          final emisorMatch =
              cfdi.emisor?.nombre?.toLowerCase().contains(searchTerm) ?? false;
          final receptorMatch =
              cfdi.receptor?.nombre?.toLowerCase().contains(searchTerm) ??
                  false;
          final uuidMatch = cfdi.timbreFiscalDigital?.uuid
                  ?.toLowerCase()
                  .contains(searchTerm) ??
              false;
          final tipoMatch = formatoTipoComprobante.tipoComprobante
              .toLowerCase()
              .contains(searchTerm);
          final totalMatch = cfdi.total?.contains(searchTerm) ?? false;
          return emisorMatch ||
              receptorMatch ||
              uuidMatch ||
              tipoMatch ||
              totalMatch;
        }).toList();
      } else {
        _filteredCfdis = List.from(_sortedCfdis);
      }
      // Actualizar la fuente de datos con los datos filtrados
      // La fuente de datos ahora necesita saber el total para el paginador
      _cfdiDataGridSource.updateDataSource(newData: _filteredCfdis);
      // Notificar al paginador sobre el cambio en el número total de filas
      _cfdiDataGridSource.handlePageChange(
          0, _rowsPerPage); // Volver a la página 0
    });
  }

  void _sortData() {
    // Ordena la lista base
    _sortedCfdis.sort((a, b) {
      var formatoTipoComprobanteA = FormatTipoComprobante(a.tipoDeComprobante);
      var formatoTipoComprobanteB = FormatTipoComprobante(b.tipoDeComprobante);

      // Asegurarse que los índices coincidan con _buildGridColumns
      int effectiveSortIndex =
          _sortColumnIndex; // Ajustar si hay columna de checkbox implícita

      switch (effectiveSortIndex) {
        case 0: // Emisor
          return _compareNullableStrings(
              a.emisor?.nombre, b.emisor?.nombre, _sortAscending);
        case 1: // Receptor
          return _compareNullableStrings(
              a.receptor?.nombre, b.receptor?.nombre, _sortAscending);
        case 2: // Fecha
          return _compareNullableStrings(a.fecha, b.fecha, _sortAscending);
        case 3: // Total
          return _compareNullableNumeric(a.total, b.total, _sortAscending);
        case 4: // Tipo
          return _compareNullableStrings(
              formatoTipoComprobanteA.tipoComprobante,
              formatoTipoComprobanteB.tipoComprobante,
              _sortAscending);
        case 5: // UUID
          return _compareNullableStrings(a.timbreFiscalDigital?.uuid,
              b.timbreFiscalDigital?.uuid, _sortAscending);
        default:
          return 0;
      }
    });
    // Actualizar la fuente de datos después de ordenar la lista base
    // y reaplicar el filtro actual a la lista ordenada.
    _applySearchFilter();
    // Resetear el paginador a la primera página al ordenar
    _dataPagerController.selectedPageIndex = 0;
  }

  int _compareNullableStrings(String? a, String? b, bool ascending) {
    if (a == null && b == null) return 0;
    if (a == null) return ascending ? -1 : 1;
    if (b == null) return ascending ? 1 : -1;
    int result = a.compareTo(b);
    return ascending ? result : -result;
  }

  int _compareNullableNumeric(String? a, String? b, bool ascending) {
    if (a == null && b == null) return 0;
    if (a == null) return ascending ? -1 : 1;
    if (b == null) return ascending ? 1 : -1;

    double? valA = double.tryParse(a);
    double? valB = double.tryParse(b);

    if (valA == null && valB == null)
      return 0; // Ambos no son numéricos, comparar como string
    if (valA == null) return ascending ? -1 : 1; // A no es numérico
    if (valB == null) return ascending ? 1 : -1; // B no es numérico

    int result = valA.compareTo(valB);
    return ascending ? result : -result;
  }

  @override
  Widget build(BuildContext context) {
    final columnProvider = Provider.of<ColumnVisibilityProvider>(context);
    List<GridColumn> gridColumns = _buildGridColumns(columnProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(flex: 2, child: FilterColumn()),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText:
                                  'Buscar por emisor, receptor, UUID, etc...',
                              hintStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.search, size: 18),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                          maxHeight: 32, maxWidth: 32),
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 10.0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Dropdown para filas por página (sin funcionalidad por ahora)
                        DropdownButton<int>(
                          value: _rowsPerPage,
                          isDense: true,
                          items: _rowsPerPageOptions.map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value filas',
                                  style: const TextStyle(fontSize: 12)),
                            );
                          }).toList(),
                          onChanged:
                              null, // Deshabilitado hasta implementar SfDataPager
                          /* (int? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _rowsPerPage = newValue;
                                // Aquí iría la lógica para actualizar SfDataPager
                              });
                            }
                          }, */
                          hint: const Text('Filas',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isSearching
                            ? 'Mostrando ${_cfdiDataGridSource.effectiveRows.length} de ${_sortedCfdis.length} CFDIs'
                            : 'Total: ${_cfdiDataGridSource.effectiveRows.length} CFDIs',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      if (_selectedCfdis.isNotEmpty)
                        Text(
                          '${_selectedCfdis.length} seleccionados',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    // Envolver SfDataGrid y SfDataPager en una columna
                    children: [
                      Expanded(
                        child: SfDataGridTheme(
                          data: const SfDataGridThemeData(
                              // headerColor: Colors.grey[200],
                              ),
                          child: SfDataGrid(
                            source: _cfdiDataGridSource,
                            controller: _dataGridController,
                            columns: gridColumns,
                            columnWidthMode: ColumnWidthMode.fill,
                            allowColumnsResizing: true,
                            columnResizeMode: ColumnResizeMode.onResizeEnd,
                            allowSorting: true,
                            selectionMode: SelectionMode.multiple,
                            navigationMode: GridNavigationMode.cell,
                            gridLinesVisibility: GridLinesVisibility.both,
                            headerGridLinesVisibility: GridLinesVisibility.both,
                            onColumnResizeUpdate:
                                (ColumnResizeUpdateDetails details) {
                              setState(() {
                                // Guardar el nuevo ancho de la columna en nuestro mapa
                                _columnWidths[details.column.columnName] =
                                    details.width;
                              });
                              return true; // Permitir el redimensionamiento
                            },
                            // --- Eventos ---
                            onCellTap: (DataGridCellTapDetails details) {
                              // Ignorar taps en el encabezado
                              if (details.rowColumnIndex.rowIndex == 0) return;
                              // Obtener el índice de la fila de datos (restando 1 por el encabezado)
                              int dataRowIndex =
                                  details.rowColumnIndex.rowIndex - 1;
                              // Obtener la DataGridRow correspondiente a la página actual
                              if (dataRowIndex <
                                  _cfdiDataGridSource.rows.length) {
                                final DataGridRow dataRow =
                                    _cfdiDataGridSource.rows[dataRowIndex];
                                // Obtener el CFDI de la fila usando el método robusto
                                final cfdi =
                                    _cfdiDataGridSource.getCFDIFromRow(dataRow);
                                if (cfdi != null) {
                                  _mostrarDetalles(cfdi, context);
                                }
                              }
                            },
                            onSelectionChanged: (List<DataGridRow> addedRows,
                                List<DataGridRow> removedRows) {
                              setState(() {
                                for (var row in addedRows) {
                                  // Usar getCFDIFromRow que es más fiable con paginación
                                  final cfdi =
                                      _cfdiDataGridSource.getCFDIFromRow(row);
                                  if (cfdi != null) _selectedCfdis.add(cfdi);
                                }
                                for (var row in removedRows) {
                                  // Usar getCFDIFromRow que es más fiable con paginación
                                  final cfdi =
                                      _cfdiDataGridSource.getCFDIFromRow(row);
                                  if (cfdi != null) _selectedCfdis.remove(cfdi);
                                }
                              });
                            },
                            // --- Ordenación (Manejada por SfDataGrid y DataGridSource) ---
                            // onSortColumnsChanged: (List<SortColumnDetails> added, List<SortColumnDetails> removed) {
                            //   // Opcional: Lógica adicional si se necesita al cambiar la ordenación
                            // },
                          ),
                        ),
                      ),
                      // Añadir SfDataPager
                      SfDataPager(
                        controller: _dataPagerController, // Usar el controller
                        delegate:
                            _cfdiDataGridSource, // Conectar con la fuente de datos
                        // Calcular pageCount basado en el total de filas de la fuente
                        pageCount:
                            (_cfdiDataGridSource.getRowCount() / _rowsPerPage)
                                .ceilToDouble(),
                        direction: Axis.horizontal,
                        // rowsPerPage: _rowsPerPage, // No es un parámetro directo del constructor
                        availableRowsPerPage:
                            _rowsPerPageOptions, // Opciones disponibles
                        onRowsPerPageChanged: (int? newRowsPerPage) {
                          if (newRowsPerPage != null) {
                            setState(() {
                              _rowsPerPage = newRowsPerPage;
                              // Notificar a la fuente de datos sobre el cambio
                              // El delegate (handlePageChange) será llamado por el SfDataPager
                              // pero necesitamos actualizar la fuente con el nuevo rowsPerPage
                              _cfdiDataGridSource
                                  .updateRowsPerPage(_rowsPerPage);
                              // Actualizar el paginador volviendo a la página 0
                              _dataPagerController.selectedPageIndex = 0;
                              // _dataPagerController.rowsPerPage = _rowsPerPage; // No existe esta propiedad
                              // SfDataPager se actualizará visualmente debido a setState y al delegate
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Panel lateral (sin cambios)
        if (_selectedCfdis.isNotEmpty)
          Container(
            width: 400,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1.0,
                ),
              ),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              children: [
                // Encabezado del panel
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedCfdis.length} seleccionado(s)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedCfdis.clear();
                          });
                        },
                        tooltip: 'Cerrar panel',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Contenido del panel
                Expanded(
                  child: CFDIDetailScreen(cfdi: _selectedCfdis.first),
                ),
                // Botones de acción
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _selectedCfdis.length == 1
                            ? () =>
                                _mostrarDetalles(_selectedCfdis.first, context)
                            : null,
                        icon: const Icon(Icons.fullscreen),
                        label: const Text('Expandir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedCfdis.clear();
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Deseleccionar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Método para construir las columnas del SfDataGrid
  List<GridColumn> _buildGridColumns(ColumnVisibilityProvider columnProvider) {
    List<GridColumn> columns = [];

    // Columna de Checkbox (manejada por SfDataGrid con showCheckboxColumn)
    // O se puede crear una columna personalizada si se necesita más control

    if (columnProvider.isVisible('emisor')) {
      columns.add(GridColumn(
          columnName: 'emisor',
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: const Text('Emisor', overflow: TextOverflow.ellipsis)),
          allowSorting: true,
          width: _columnWidths['emisor'] ?? 150.0));
    }
    if (columnProvider.isVisible('receptor')) {
      columns.add(GridColumn(
          columnName: 'receptor',
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: const Text('Receptor', overflow: TextOverflow.ellipsis)),
          allowSorting: true,
          width: _columnWidths['receptor'] ?? 150.0));
    }
    if (columnProvider.isVisible('fecha')) {
      columns.add(GridColumn(
          columnName: 'fecha',
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: const Text('Fecha', overflow: TextOverflow.ellipsis)),
          allowSorting: true,
          width: _columnWidths['fecha'] ?? 100.0));
    }
    if (columnProvider.isVisible('total')) {
      columns.add(GridColumn(
          columnName: 'total',
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: const Text('Total', overflow: TextOverflow.ellipsis)),
          allowSorting: true,
          width: _columnWidths['total'] ?? 80.0));
    }
    if (columnProvider.isVisible('tipo')) {
      columns.add(GridColumn(
          columnName: 'tipo',
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: const Text('Tipo', overflow: TextOverflow.ellipsis)),
          allowSorting: true,
          width: _columnWidths['tipo'] ?? 90.0));
    }
    if (columnProvider.isVisible('uuid')) {
      columns.add(GridColumn(
          columnName: 'uuid',
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: const Text('UUID', overflow: TextOverflow.ellipsis)),
          allowSorting: true,
          width: _columnWidths['uuid'] ?? 250.0));
    }

    return columns;
  }
}

// --- _CFDIDataGridSource ---
class _CFDIDataGridSource extends DataGridSource {
  late List<DataGridRow> _paginatedRows; // Filas para la página actual
  List<CFDI> _cfdis; // Lista completa (filtrada/ordenada)
  final Set<CFDI> _selectedCfdis;
  final BuildContext _context;
  final ColumnVisibilityProvider _columnProvider;
  int _rowsPerPage; // Guardar rowsPerPage

  _CFDIDataGridSource({
    required List<CFDI> cfdis,
    required Set<CFDI> selectedCfdis,
    required BuildContext context,
    required ColumnVisibilityProvider columnProvider,
    required int rowsPerPage,
  })  : _cfdis = cfdis,
        _selectedCfdis = selectedCfdis,
        _context = context,
        _columnProvider = columnProvider,
        _rowsPerPage = rowsPerPage,
        // Inicializar directamente usando la función auxiliar estática
        _paginatedRows =
            _buildInitialRows(cfdis, columnProvider, 0, rowsPerPage) {
    // El cuerpo del constructor ahora está vacío o puede contener otra lógica si es necesario
  }
  // Función auxiliar estática para construir las filas iniciales (o cualquier página)
  static List<DataGridRow> _buildInitialRows(
      List<CFDI> sourceCfdis,
      ColumnVisibilityProvider columnProvider,
      int startIndex,
      int rowsPerPage) {
    // Verificar que el índice inicial esté dentro del rango válido
    if (sourceCfdis.isEmpty) {
      return []; // Si la lista está vacía, devolver una lista vacía de filas
    }

    // Asegurarse de que startIndex esté dentro del rango válido
    startIndex = startIndex.clamp(0, sourceCfdis.length - 1);

    int endIndex = startIndex + rowsPerPage;
    if (endIndex > sourceCfdis.length) {
      endIndex = sourceCfdis.length;
    }

    // Solo obtener el rango si hay elementos para mostrar
    List<CFDI> currentPageCfdis = startIndex < endIndex
        ? sourceCfdis.getRange(startIndex, endIndex).toList()
        : [];

    return currentPageCfdis.map<DataGridRow>((cfdi) {
      var formatoTipoComprobante =
          FormatTipoComprobante(cfdi.tipoDeComprobante);
      // Formateo de datos (usando las funciones globales)
      String? fechaFormateada;
      if (cfdi.fecha != null) {
        try {
          final fechaObj = DateTime.parse(cfdi.fecha!);
          fechaFormateada =
              '${fechaObj.day}/${fechaObj.month}/${fechaObj.year}';
        } catch (_) {
          fechaFormateada = cfdi.fecha;
        }
      }

      // Crear celdas basadas en columnas visibles
      List<DataGridCell> cells = [];
      if (columnProvider.isVisible('emisor')) {
        cells.add(DataGridCell<String>(
            columnName: 'emisor', value: cfdi.emisor?.nombre ?? 'N/A'));
      }
      if (columnProvider.isVisible('receptor')) {
        cells.add(DataGridCell<String>(
            columnName: 'receptor', value: cfdi.receptor?.nombre ?? 'N/A'));
      }
      if (columnProvider.isVisible('fecha')) {
        cells.add(DataGridCell<String>(
            columnName: 'fecha', value: fechaFormateada ?? 'N/A'));
      }
      if (columnProvider.isVisible('total')) {
        double? totalValue =
            cfdi.total != null ? double.tryParse(cfdi.total!) : null;
        cells
            .add(DataGridCell<double?>(columnName: 'total', value: totalValue));
      }
      if (columnProvider.isVisible('tipo')) {
        cells.add(DataGridCell<String>(
            columnName: 'tipo', value: formatoTipoComprobante.tipoComprobante));
      }
      if (columnProvider.isVisible('uuid')) {
        cells.add(DataGridCell<String>(
            columnName: 'uuid',
            value: cfdi.timbreFiscalDigital?.uuid ?? 'N/A'));
      }

      return DataGridRow(cells: cells);
    }).toList();
  }

  // Método para actualizar las filas paginadas (llamado por handlePageChange)
  void _updatePaginatedRows(int startIndex, int rowsPerPage) {
    _paginatedRows =
        _buildInitialRows(_cfdis, _columnProvider, startIndex, rowsPerPage);
  }

  // Actualiza la fuente de datos y reconstruye las filas paginadas
  void updateDataSource({List<CFDI>? newData}) {
    if (newData != null) {
      _cfdis = newData;
    }
    // Reconstruir para la primera página por defecto al actualizar datos
    // Llama a _updatePaginatedRows y notifyListeners
    handlePageChange(0, 0);
  }

  // Método para actualizar rowsPerPage desde el State
  void updateRowsPerPage(int newRowsPerPage) {
    _rowsPerPage = newRowsPerPage;
    // Reconstruir para la primera página con el nuevo tamaño
    // Llama a _updatePaginatedRows y notifyListeners
    handlePageChange(0, 0);
  }

  // Devuelve las filas de la página actual (ahora garantizado que está inicializado)
  @override
  List<DataGridRow> get rows => _paginatedRows;

  // Método para obtener el número total de filas (para el paginador)
  int getRowCount() {
    return _cfdis.length;
  }

  // Obtener CFDI desde DataGridRow (más fiable con paginación)
  CFDI? getCFDIFromRow(DataGridRow row) {
    // Asumiendo que UUID es único y está presente en las celdas
    final uuidCell = row.getCells().firstWhere(
        (cell) => cell.columnName == 'uuid',
        orElse: () => const DataGridCell(columnName: 'uuid', value: null));
    final uuid = uuidCell.value as String?;
    if (uuid != null && uuid != 'N/A') {
      // Asegurarse que no sea el valor por defecto 'N/A'
      try {
        // Buscar en la lista completa (_cfdis)
        return _cfdis
            .firstWhere((cfdi) => cfdi.timbreFiscalDigital?.uuid == uuid);
      } catch (e) {
        // No encontrado en la lista completa (esto no debería pasar si los datos son consistentes)
        print('Error: CFDI con UUID $uuid no encontrado en la lista completa.');
        return null;
      }
    }
    print('Advertencia: No se pudo obtener UUID de la fila para buscar CFDI.');
    return null; // No se pudo encontrar por UUID
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final cfdi = getCFDIFromRow(row);
    if (cfdi == null) {
      // Si no podemos encontrar el CFDI, mostrar una fila con celdas de error
      // Corregir la generación de la lista de celdas de error
      return DataGridRowAdapter(
          cells: List.generate(
              row.getCells().length,
              (index) => Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.red
                        .withOpacity(0.1), // Indicar error visualmente
                    child: const Text('Error',
                        style: TextStyle(color: Colors.red, fontSize: 10)),
                  )));
    }

    // --- El resto de la lógica de buildRow usa el 'cfdi' obtenido ---
    final bool isSelected = _selectedCfdis.contains(cfdi);
    var formatoTipoComprobante = FormatTipoComprobante(cfdi.tipoDeComprobante);
    Color? rowColor = isSelected
        ? Theme.of(_context).colorScheme.primary.withOpacity(0.1)
        : null;
    const cellTextStyle = TextStyle(fontSize: 12);

    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      String displayValue = dataGridCell.value?.toString() ?? 'N/A';
      Alignment alignment = Alignment.centerLeft;
      Widget cellWidget = Text(displayValue,
          style: cellTextStyle, overflow: TextOverflow.ellipsis);
      Color? cellColor = rowColor; // Aplicar color de fila por defecto

      if (dataGridCell.columnName == 'total') {
        alignment = Alignment.centerRight;
        // Formatear el valor numérico para mostrar
        displayValue = dataGridCell.value != null
            ? '\$${(dataGridCell.value as double).toStringAsFixed(2)}'
            : 'N/A';
        cellWidget = Text(displayValue,
            style: cellTextStyle, overflow: TextOverflow.ellipsis);
      } else if (dataGridCell.columnName == 'tipo') {
        alignment = Alignment.center;
        final tipoColor = formatoTipoComprobante.color;
        cellWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          constraints: const BoxConstraints(maxWidth: 60),
          decoration: BoxDecoration(
            color: tipoColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            displayValue,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: tipoColor,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        );
      } else if (dataGridCell.columnName == 'uuid') {
        cellWidget = Text(displayValue,
            style: const TextStyle(fontSize: 10),
            overflow: TextOverflow.ellipsis);
      }

      return Container(
        color: cellColor,
        alignment: alignment,
        padding: const EdgeInsets.all(8.0),
        child: cellWidget,
      );
    }).toList());
  }

  // --- Manejo de Paginación ---
  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    int startIndex = newPageIndex * _rowsPerPage;
    // Usar el método renombrado para actualizar las filas
    _updatePaginatedRows(startIndex, _rowsPerPage);
    notifyListeners(); // Notifica a SfDataGrid y SfDataPager
    return true;
  }
}

// Modify the _mostrarDetalles function to pass the full list of CFDIs
void _mostrarDetalles(CFDI cfdi, BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, animation, secondaryAnimation) {
        // Pass the complete list of CFDIs along with the selected CFDI
        return BlocProvider.value(
          value: BlocProvider.of<CFDIBloc>(context),
          child: CFDIDetailScreen(
            cfdi: cfdi,
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final curvedAnimation =
            CurvedAnimation(parent: animation, curve: Curves.ease);
        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    ),
  );
}

class MostrarDetalles extends StatelessWidget {
  const MostrarDetalles({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
