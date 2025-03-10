import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      child: BlocProvider(
        create: (context) => CFDIBloc(),
        child: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Tabla de CFDIs'),
              actions: [
                // Menú para configurar columnas
                BlocBuilder<CFDIBloc, CFDIState>(
                  builder: (context, state) {
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
                  },
                ),
                // Botón para limpiar la tabla (existente)
                BlocBuilder<CFDIBloc, CFDIState>(
                  builder: (context, state) {
                    if (state is CFDILoaded) {
                      return IconButton(
                        icon: const Icon(Icons.clear_all),
                        tooltip: 'Limpiar tabla',
                        onPressed: () {
                          context.read<CFDIBloc>().add(ClearCFDIs());
                        },
                      );
                    }
                    return Container();
                  },
                ),
              ],
            ),
            body: BlocBuilder<CFDIBloc, CFDIState>(
              builder: (context, state) {
                if (state is CFDIInitial) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No hay CFDIs cargados',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            context
                                .read<CFDIBloc>()
                                .add(LoadCFDIsFromDirectory());
                          },
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Abrir directorio'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<CFDIBloc>().add(LoadCFDIsFromFile());
                          },
                          icon: const Icon(Icons.file_open),
                          label: const Text('Abrir archivo CFDI'),
                        ),
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
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<CFDIBloc>()
                                .add(LoadCFDIsFromDirectory());
                          },
                          child: const Text('Intentar de nuevo'),
                        ),
                      ],
                    ),
                  );
                }
                return Container();
              },
            ),
            floatingActionButton: BlocBuilder<CFDIBloc, CFDIState>(
              builder: (context, state) {
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
                          context
                              .read<CFDIBloc>()
                              .add(LoadCFDIsFromDirectory());
                        },
                        tooltip: 'Cargar directorio',
                        child: const Icon(Icons.create_new_folder),
                      ),
                    ],
                  );
                }
                return Container();
              },
            ),
          ),
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

  void _mostrarDetalles(CFDI cfdi, BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return CFDIDetailScreen(cfdi: cfdi);
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

  @override
  void initState() {
    super.initState();
    _sortedCfdis = List.from(widget.cfdis);
    _sortData();
  }

  @override
  void didUpdateWidget(covariant CFDITableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cfdis != oldWidget.cfdis) {
      _sortedCfdis = List.from(widget.cfdis);
      _sortData();
    }
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

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: DataTable(
            sortColumnIndex: _sortColumnIndex <
                    visibleColumns.length -
                        1 // Ajuste para la columna de checkbox
                ? _sortColumnIndex +
                    1 // +1 porque la primera columna es el checkbox
                : null,
            sortAscending: _sortAscending,
            columnSpacing: 20.0,
            horizontalMargin: 10.0,
            columns: visibleColumns,
            rows: _sortedCfdis
                .map((cfdi) => _buildDataRow(cfdi, context, columnProvider))
                .toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(CFDI cfdi, BuildContext context,
      ColumnVisibilityProvider columnProvider) {
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
            setState(() {
              if (selected == true) {
                _selectedCfdis.add(cfdi);
              } else {
                _selectedCfdis.remove(cfdi);
              }
            });
          },
        ),
      ),
    ];

    // Agregar el resto de las celdas
    if (columnProvider.isVisible('emisor')) {
      visibleCells.add(
        DataCell(
          Text(cfdi.emisor?.nombre ?? 'N/A'),
          onTap: () => _mostrarDetalles(cfdi, context),
        ),
      );
    }

    // Celda Receptor
    if (columnProvider.isVisible('receptor')) {
      visibleCells.add(
        DataCell(
          Text(cfdi.receptor?.nombre ?? 'N/A'),
          onTap: () => _mostrarDetalles(cfdi, context),
        ),
      );
    }

    // Celda Fecha
    if (columnProvider.isVisible('fecha')) {
      visibleCells.add(
        DataCell(
          Text(fechaFormateada ?? 'N/A'),
          onTap: () => _mostrarDetalles(cfdi, context),
        ),
      );
    }

    // Celda Total
    if (columnProvider.isVisible('total')) {
      visibleCells.add(
        DataCell(
          Text(cfdi.total != null ? '\$${cfdi.total}' : 'N/A'),
          onTap: () => _mostrarDetalles(cfdi, context),
        ),
      );
    }

    // Celda Tipo
    if (columnProvider.isVisible('tipo')) {
      visibleCells.add(
        DataCell(
          Text(tipoComprobante,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getColorForTipoComprobante(cfdi.tipoDeComprobante),
              )),
          onTap: () => _mostrarDetalles(cfdi, context),
        ),
      );
    }

    // Celda UUID
    if (columnProvider.isVisible('uuid')) {
      visibleCells.add(
        DataCell(
          Text(cfdi.timbreFiscalDigital?.uuid ?? 'N/A',
              style: const TextStyle(fontSize: 12)),
          onTap: () => _mostrarDetalles(cfdi, context),
        ),
      );
    }

    return DataRow(
      cells: visibleCells,
    );
  }
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

void _mostrarDetalles(CFDI cfdi, BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return CFDIDetailScreen(cfdi: cfdi);
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
