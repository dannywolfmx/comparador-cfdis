import 'package:comparador_cfdis/widgets/filter.dart';
import 'package:comparador_cfdis/widgets/load_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import '../bloc/cfdi_bloc.dart';
import '../bloc/cfdi_event.dart';
import '../bloc/cfdi_state.dart';
import '../models/cfdi.dart';
import '../providers/column_visibility_provider.dart';
import 'package:provider/provider.dart';
import 'cfdi_detail_screen.dart';

class CFDIListScreen extends StatelessWidget {
  const CFDIListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ColumnVisibilityProvider(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Tabla de CFDIs'),
            // Acciones de la AppBar (estas estarán arriva a la derecha)
            actions: [
              // Botón para abrir el drawer de filtros
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filtros',
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
              // Menú para configurar columnas
              BlocBuilder<CFDIBloc, CFDIState>(builder: (context, state) {
                if (state is CFDILoaded) {
                  // Usamos Consumer en lugar de acceder directamente al Provider
                  return Consumer<ColumnVisibilityProvider>(
                      builder: (context, columnProvider, _) {
                    return PopupMenuButton<String>(
                      icon: const Icon(Icons.view_column),
                      tooltip: 'Configurar columnas',
                      onSelected: (value) {
                        // Si se selecciona "reset", restauramos la visibilidad predeterminada
                        if (value == 'reset') {
                          Provider.of<ColumnVisibilityProvider>(context,
                                  listen: false)
                              .resetToDefault();
                          return;
                        }
                        // Alternamos la visibilidad de la columna seleccionada
                        Provider.of<ColumnVisibilityProvider>(context,
                                listen: false)
                            .toggleVisibility(value);
                      },
                      itemBuilder: (context) {
                        // Ya no necesitamos obtener el provider aquí
                        // porque lo tenemos disponible desde el Consumer

                        return [
                          // Opción para emisor
                          CheckedPopupMenuItem(
                            checked: columnProvider.isVisible('emisor'),
                            value: 'emisor',
                            child: const Text('Emisor'),
                          ),
                          // Opción para receptor
                          CheckedPopupMenuItem(
                            checked: columnProvider.isVisible('receptor'),
                            value: 'receptor',
                            child: const Text('Receptor'),
                          ),
                          // Opción para fecha
                          CheckedPopupMenuItem(
                            checked: columnProvider.isVisible('fecha'),
                            value: 'fecha',
                            child: const Text('Fecha'),
                          ),
                          // Opción para total
                          CheckedPopupMenuItem(
                            checked: columnProvider.isVisible('total'),
                            value: 'total',
                            child: const Text('Total'),
                          ),
                          // Opción para tipo
                          CheckedPopupMenuItem(
                            checked: columnProvider.isVisible('tipo'),
                            value: 'tipo',
                            child: const Text('Tipo'),
                          ),
                          // Opción para UUID
                          CheckedPopupMenuItem(
                            checked: columnProvider.isVisible('uuid'),
                            value: 'uuid',
                            child: const Text('UUID'),
                          ),
                          // Separador
                          const PopupMenuDivider(),
                          // Opción para restaurar valores predeterminados
                          const PopupMenuItem(
                            value: 'reset',
                            child: Text('Restaurar columnas'),
                          ),
                        ];
                      },
                    );
                  });
                }
                return Container();
              }),
            ],
          ),
          //Pantalla central
          body: BlocBuilder<CFDIBloc, CFDIState>(builder: (context, state) {
            if (state is CFDIInitial) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No hay CFDIs cargados',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    LoadButtons(),
                  ],
                ),
              );
            } else if (state is CFDILoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is CFDILoaded) {
              return AdaptiveCFDIView(cfdis: state.cfdis);
            } else if (state is CFDIError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const LoadButtons(),
                  ],
                ),
              );
            }
            return Container();
          }),
          floatingActionButton:
              BlocBuilder<CFDIBloc, CFDIState>(builder: (context, state) {
            if (state is CFDILoaded) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: 'addFile',
                    onPressed: () {
                      context.read<CFDIBloc>().add(LoadCFDIsFromFile());
                    },
                    tooltip: 'Añadir archivo CFDI',
                    child: const Icon(Icons.add_to_photos),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: 'addDirectory',
                    onPressed: () {
                      context.read<CFDIBloc>().add(LoadCFDIsFromDirectory());
                    },
                    tooltip: 'Cargar directorio',
                    child: const Icon(Icons.create_new_folder),
                  ),
                ],
              );
            }
            return Container();
          }),
        ),
      ),
    );
  }
}

// Nuevo widget adaptativo que elige entre tabla y lista según el tamaño
class AdaptiveCFDIView extends StatelessWidget {
  final List<CFDI> cfdis;

  const AdaptiveCFDIView({Key? key, required this.cfdis}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usamos LayoutBuilder para obtener las restricciones de tamaño disponible
    return LayoutBuilder(
      builder: (context, constraints) {
        // Si el ancho es menor que un umbral (por ejemplo, 600), mostramos lista
        if (constraints.maxWidth < 600) {
          return CFDIListView(cfdis: cfdis);
        } else {
          // Si hay espacio suficiente, mostramos la tabla
          return CFDITableView(cfdis: cfdis);
        }
      },
    );
  }
}

// Widget para mostrar CFDIs en formato de lista (para pantallas pequeñas)
class CFDIListView extends StatelessWidget {
  final List<CFDI> cfdis;

  const CFDIListView({Key? key, required this.cfdis}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: cfdis.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final cfdi = cfdis[index];
        final emisor = cfdi.emisor;
        final receptor = cfdi.receptor;
        final timbreFiscal = cfdi.timbreFiscalDigital;

        // Formato de fecha
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

        // Formatear el tipo de comprobante
        final tipoComprobante = _formatTipoComprobante(cfdi.tipoDeComprobante);
        final tipoColor = _getColorForTipoComprobante(cfdi.tipoDeComprobante);

        return ListTile(
          title: Row(
            children: [
              Text(emisor?.nombre ?? 'Sin emisor'),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tipoColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: tipoColor),
                ),
                child: Text(
                  tipoComprobante,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: tipoColor,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (receptor?.nombre != null) Text('Para: ${receptor!.nombre}'),
              if (fechaFormateada != null) Text('Fecha: $fechaFormateada'),
              if (cfdi.total != null)
                Text('Total: \$${cfdi.total}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              if (timbreFiscal?.uuid != null)
                Text('UUID: ${timbreFiscal!.uuid}',
                    style: const TextStyle(fontSize: 12)),
            ],
          ),
          leading: CircleAvatar(
            backgroundColor: tipoColor.withOpacity(0.8),
            child: Text(tipoComprobante.substring(0, 1)),
          ),
          isThreeLine: true,
          onTap: () => _mostrarDetalles(cfdi, context),
        );
      },
    );
  }

  // Método para formatear el tipo de comprobante de forma más legible
  String _formatTipoComprobante(String? tipo) {
    if (tipo == null) return 'N/A';

    switch (tipo.toUpperCase()) {
      case 'I':
        return 'Ingreso';
      case 'E':
        return 'Egreso';
      case 'T':
        return 'Traslado';
      case 'N':
        return 'Nómina';
      case 'P':
        return 'Pago';
      default:
        return tipo;
    }
  }

  // Método para asignar un color según el tipo de comprobante
  Color _getColorForTipoComprobante(String? tipo) {
    if (tipo == null) return Colors.grey;

    switch (tipo.toUpperCase()) {
      case 'I':
        return Colors.green;
      case 'E':
        return Colors.red;
      case 'T':
        return Colors.blue;
      case 'N':
        return Colors.purple;
      case 'P':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class CFDITableView extends StatefulWidget {
  final List<CFDI> cfdis;

  const CFDITableView({Key? key, required this.cfdis}) : super(key: key);

  @override
  State<CFDITableView> createState() => _CFDITableViewState();
}

class _CFDITableViewState extends State<CFDITableView> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  late List<CFDI> _sortedCfdis;
  final Set<CFDI> _selectedCfdis = {}; // Conjunto para CFDIs seleccionados

  // Opciones para paginación
  int _rowsPerPage = 10;
  final TextEditingController _searchController = TextEditingController();
  List<CFDI> _filteredCfdis = [];
  bool _isSearching = false;

  // Lista de opciones para el número de filas por página
  final List<int> _rowsPerPageOptions = [5, 10, 15, 20, 50, 100];

  @override
  void initState() {
    super.initState();
    _sortedCfdis = List.from(widget.cfdis);
    _filteredCfdis = _sortedCfdis;
    _sortData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CFDITableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cfdis != oldWidget.cfdis) {
      _sortedCfdis = List.from(widget.cfdis);
      _applySearchFilter(); // Aplica el filtro actual a los nuevos datos
      _sortData();
    }
  }

  void _onSearchChanged() {
    _applySearchFilter();
  }

  void _applySearchFilter() {
    final searchTerm = _searchController.text.toLowerCase().trim();
    setState(() {
      _isSearching = searchTerm.isNotEmpty;
      if (_isSearching) {
        _filteredCfdis = _sortedCfdis.where((cfdi) {
          final emisorMatch =
              cfdi.emisor?.nombre?.toLowerCase().contains(searchTerm) ?? false;
          final receptorMatch =
              cfdi.receptor?.nombre?.toLowerCase().contains(searchTerm) ??
                  false;
          final uuidMatch = cfdi.timbreFiscalDigital?.uuid
                  ?.toLowerCase()
                  .contains(searchTerm) ??
              false;
          final tipoMatch = _formatTipoComprobante(cfdi.tipoDeComprobante)
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
        _filteredCfdis = _sortedCfdis;
      }
    });
  }

  void _sortData() {
    _sortedCfdis.sort((a, b) {
      switch (_sortColumnIndex) {
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
        case 4: // Tipo de Comprobante
          return _compareNullableStrings(
              a.tipoDeComprobante, b.tipoDeComprobante, _sortAscending);
        case 5: // UUID
          return _compareNullableStrings(a.timbreFiscalDigital?.uuid,
              b.timbreFiscalDigital?.uuid, _sortAscending);
        default:
          return 0;
      }
    });

    // Después de ordenar, aplicamos el filtro de búsqueda si es necesario
    _applySearchFilter();
  }

  int _compareNullableStrings(String? a, String? b, bool ascending) {
    if (a == null && b == null) return 0;
    if (a == null) return ascending ? -1 : 1;
    if (b == null) return ascending ? 1 : -1;
    return ascending ? a.compareTo(b) : b.compareTo(a);
  }

  int _compareNullableNumeric(String? a, String? b, bool ascending) {
    if (a == null && b == null) return 0;
    if (a == null) return ascending ? -1 : 1;
    if (b == null) return ascending ? 1 : -1;

    double valA, valB;
    try {
      valA = double.parse(a);
      valB = double.parse(b);
      return ascending ? valA.compareTo(valB) : valB.compareTo(valA);
    } catch (e) {
      return ascending ? a.compareTo(b) : b.compareTo(a);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el provider de visibilidad de columnas
    final columnProvider = Provider.of<ColumnVisibilityProvider>(context);

    // Crear la lista de columnas visibles
    final List<DataColumn> visibleColumns = [
      // Columna de selección (checkbox)
      DataColumn(
        label: Checkbox(
          value: _selectedCfdis.isNotEmpty &&
              _selectedCfdis.length == _sortedCfdis.length,
          tristate: _selectedCfdis.isNotEmpty &&
              _selectedCfdis.length < _sortedCfdis.length,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                // Seleccionar todos
                _selectedCfdis.addAll(_sortedCfdis);
              } else {
                // Deseleccionar todos
                _selectedCfdis.clear();
              }
            });
          },
        ),
      ),
    ];

    // Agregar el resto de columnas visibles
    if (columnProvider.isVisible('emisor')) {
      visibleColumns.add(
        DataColumn(
          label: const Text('Emisor'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = 0;
              _sortAscending = ascending;
              _sortData();
            });
          },
        ),
      );
    }

    // Columna Receptor
    if (columnProvider.isVisible('receptor')) {
      visibleColumns.add(
        DataColumn(
          label: const Text('Receptor'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = 1;
              _sortAscending = ascending;
              _sortData();
            });
          },
        ),
      );
    }

    // Columna Fecha
    if (columnProvider.isVisible('fecha')) {
      visibleColumns.add(
        DataColumn(
          label: const Text('Fecha'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = 2;
              _sortAscending = ascending;
              _sortData();
            });
          },
        ),
      );
    }

    // Columna Total
    if (columnProvider.isVisible('total')) {
      visibleColumns.add(
        DataColumn(
          label: const Text('Total'),
          numeric: true,
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = 3;
              _sortAscending = ascending;
              _sortData();
            });
          },
        ),
      );
    }

    // Columna Tipo
    if (columnProvider.isVisible('tipo')) {
      visibleColumns.add(
        DataColumn(
          label: const Text('Tipo'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = 4;
              _sortAscending = ascending;
              _sortData();
            });
          },
        ),
      );
    }

    // Columna UUID
    if (columnProvider.isVisible('uuid')) {
      visibleColumns.add(
        DataColumn(
          label: const Text('UUID'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = 5;
              _sortAscending = ascending;
              _sortData();
            });
          },
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(flex: 2, child: FilterColumn()),
        // Tabla principal (ahora con PaginatedDataTable para mejorar rendimiento)
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildPaginatedDataTable(context, columnProvider),
          ),
        ),
        // Panel lateral (solo visible cuando hay elementos seleccionados)
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

  Widget _buildPaginatedDataTable(
      BuildContext context, ColumnVisibilityProvider columnProvider) {
    // Crear la lista de columnas visibles para usar en este método
    final List<DataColumn> visibleColumns = [
      // Columna de selección (checkbox)
      DataColumn(
        label: Checkbox(
          value: _selectedCfdis.isNotEmpty &&
              _selectedCfdis.length == _sortedCfdis.length,
          tristate: _selectedCfdis.isNotEmpty &&
              _selectedCfdis.length < _sortedCfdis.length,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                // Seleccionar todos
                _selectedCfdis.addAll(_sortedCfdis);
              } else {
                // Deseleccionar todos
                _selectedCfdis.clear();
              }
            });
          },
        ),
      ),
    ];

    // Agregar el resto de columnas visibles
    if (columnProvider.isVisible('emisor')) {
      visibleColumns.add(
        DataColumn(
          label: const Text('Emisor'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = 0;
              _sortAscending = ascending;
              _sortData();
            });
          },
        ),
      );
    }

    // Columna Receptor
    if (columnProvider.isVisible('receptor')) {
      visibleColumns.add(
        DataColumn(
          label: const Text('Receptor'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = 1;
              _sortAscending = ascending;
              _sortData();
            });
          },
        ),
      );
    }

    // Columna Fecha
    if (columnProvider.isVisible('fecha')) {
      visibleColumns.add(
        DataColumn(
          label: const Text('Fecha'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = 2;
              _sortAscending = ascending;
              _sortData();
            });
          },
        ),
      );
    }

    // Columna Total
    if (columnProvider.isVisible('total')) {
      visibleColumns.add(
        DataColumn(
          label: const Text('Total'),
          numeric: true,
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = 3;
              _sortAscending = ascending;
              _sortData();
            });
          },
        ),
      );
    }

    // Columna Tipo
    if (columnProvider.isVisible('tipo')) {
      visibleColumns.add(
        DataColumn(
          label: const Text('Tipo'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = 4;
              _sortAscending = ascending;
              _sortData();
            });
          },
        ),
      );
    }

    // Columna UUID
    if (columnProvider.isVisible('uuid')) {
      visibleColumns.add(
        DataColumn(
          label: const Text('UUID'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = 5;
              _sortAscending = ascending;
              _sortData();
            });
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Barra de herramientas con búsqueda y controles
        Card(
          elevation: 2.0,
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Campo de búsqueda
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por emisor, receptor, UUID, etc...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Dropdown para seleccionar filas por página
                DropdownButton<int>(
                  value: _rowsPerPage,
                  items: _rowsPerPageOptions.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value filas'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _rowsPerPage = newValue;
                      });
                    }
                  },
                  hint: const Text('Filas por página'),
                ),
              ],
            ),
          ),
        ),

        // Información sobre los resultados
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isSearching
                    ? 'Mostrando ${_filteredCfdis.length} de ${_sortedCfdis.length} CFDIs'
                    : 'Total: ${_sortedCfdis.length} CFDIs',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_selectedCfdis.isNotEmpty)
                Text(
                  '${_selectedCfdis.length} CFDIs seleccionados',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),

        // Tabla paginada con scroll
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              // Aseguramos un ancho mínimo para evitar contenido apretado
              width: max(MediaQuery.of(context).size.width * 0.7, 800),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: PaginatedDataTable(
                  header: null, // Ya mostramos información en nuestra propia UI
                  rowsPerPage: _rowsPerPage,
                  availableRowsPerPage: const [5, 10, 15, 20, 50, 100],
                  onRowsPerPageChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _rowsPerPage = value;
                      });
                    }
                  },
                  sortColumnIndex: _sortColumnIndex < visibleColumns.length - 1
                      ? _sortColumnIndex +
                          1 // +1 porque la primera columna es el checkbox
                      : null,
                  sortAscending: _sortAscending,
                  columns: visibleColumns,
                  source: _CFDIDataSource(
                    _isSearching ? _filteredCfdis : _sortedCfdis,
                    _selectedCfdis,
                    context,
                    columnProvider,
                    _mostrarDetalles,
                    (cfdi, selected) {
                      // Callback para manejar la selección/deselección
                      setState(() {
                        if (selected) {
                          _selectedCfdis.add(cfdi);
                        } else {
                          _selectedCfdis.remove(cfdi);
                        }
                      });
                    },
                  ),
                  showCheckboxColumn: false,
                  showFirstLastButtons: true,
                  horizontalMargin: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CFDIDataSource extends DataTableSource {
  final List<CFDI> _cfdis;
  final Set<CFDI> _selectedCfdis;
  final BuildContext _context;
  final ColumnVisibilityProvider _columnProvider;
  final Function(CFDI, BuildContext) _mostrarDetalles;
  final Function(CFDI, bool) _onSelectChanged;

  _CFDIDataSource(
    this._cfdis,
    this._selectedCfdis,
    this._context,
    this._columnProvider,
    this._mostrarDetalles,
    this._onSelectChanged,
  );

  @override
  DataRow? getRow(int index) {
    if (index >= _cfdis.length) return null;
    final cfdi = _cfdis[index];

    String? fechaFormateada;
    if (cfdi.fecha != null) {
      try {
        final fechaObj = DateTime.parse(cfdi.fecha!);
        fechaFormateada = '${fechaObj.day}/${fechaObj.month}/${fechaObj.year}';
      } catch (_) {
        fechaFormateada = cfdi.fecha;
      }
    }

    // Convertir el tipo de comprobante a un formato más legible
    String tipoComprobante = _formatTipoComprobante(cfdi.tipoDeComprobante);

    // Crear la lista de celdas visibles, empezando con el checkbox
    final List<DataCell> visibleCells = [
      DataCell(
        Checkbox(
          value: _selectedCfdis.contains(cfdi),
          onChanged: (bool? selected) {
            if (selected != null) {
              _onSelectChanged(cfdi, selected);
              notifyListeners();
            }
          },
        ),
      ),
    ];

    // Agregar el resto de las celdas de forma eficiente
    if (_columnProvider.isVisible('emisor')) {
      visibleCells.add(
        DataCell(
          Text(cfdi.emisor?.nombre ?? 'N/A'),
          onTap: () => _mostrarDetalles(cfdi, _context),
        ),
      );
    }

    // Celda Receptor
    if (_columnProvider.isVisible('receptor')) {
      visibleCells.add(
        DataCell(
          Text(cfdi.receptor?.nombre ?? 'N/A'),
          onTap: () => _mostrarDetalles(cfdi, _context),
        ),
      );
    }

    // Celda Fecha
    if (_columnProvider.isVisible('fecha')) {
      visibleCells.add(
        DataCell(
          Text(fechaFormateada ?? 'N/A'),
          onTap: () => _mostrarDetalles(cfdi, _context),
        ),
      );
    }

    // Celda Total
    if (_columnProvider.isVisible('total')) {
      visibleCells.add(
        DataCell(
          Text(cfdi.total != null ? '\$${cfdi.total}' : 'N/A'),
          onTap: () => _mostrarDetalles(cfdi, _context),
        ),
      );
    }

    // Celda Tipo con estilos de color según el tipo
    if (_columnProvider.isVisible('tipo')) {
      final tipoColor = _getColorForTipoComprobante(cfdi.tipoDeComprobante);
      visibleCells.add(
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: tipoColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              tipoComprobante,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: tipoColor,
              ),
            ),
          ),
          onTap: () => _mostrarDetalles(cfdi, _context),
        ),
      );
    }

    // Celda UUID
    if (_columnProvider.isVisible('uuid')) {
      visibleCells.add(
        DataCell(
          Text(
            cfdi.timbreFiscalDigital?.uuid ?? 'N/A',
            style: const TextStyle(fontSize: 12),
          ),
          onTap: () => _mostrarDetalles(cfdi, _context),
        ),
      );
    }

    // Utilizamos DataRow.byIndex para mejor rendimiento
    return DataRow.byIndex(
      index: index,
      cells: visibleCells,
      selected: _selectedCfdis.contains(cfdi),
      onSelectChanged: (selected) {
        if (selected != null) {
          _onSelectChanged(cfdi, selected);
          notifyListeners();
        }
      },
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Theme.of(_context).colorScheme.primary.withOpacity(0.1);
          }
          return null;
        },
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _cfdis.length;

  @override
  int get selectedRowCount => _selectedCfdis.length;
}

// Funciones auxiliares que pueden ser compartidas entre ambas vistas
String _formatTipoComprobante(String? tipo) {
  if (tipo == null) return 'N/A';

  switch (tipo.toUpperCase()) {
    case 'I':
      return 'Ingreso';
    case 'E':
      return 'Egreso';
    case 'T':
      return 'Traslado';
    case 'N':
      return 'Nómina';
    case 'P':
      return 'Pago';
    default:
      return tipo;
  }
}

Color _getColorForTipoComprobante(String? tipo) {
  if (tipo == null) return Colors.grey;

  switch (tipo.toUpperCase()) {
    case 'I':
      return Colors.green;
    case 'E':
      return Colors.red;
    case 'T':
      return Colors.blue;
    case 'N':
      return Colors.purple;
    case 'P':
      return Colors.orange;
    default:
      return Colors.grey;
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
