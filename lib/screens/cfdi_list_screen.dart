import 'package:comparador_cfdis/models/format_tipo_comprobante.dart';
import 'package:comparador_cfdis/widgets/table_cfdi.dart';
import 'package:comparador_cfdis/widgets/filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cfdi_bloc.dart';
import '../models/cfdi.dart';
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

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CFDITableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cfdis != oldWidget.cfdis) {
      _sortedCfdis = List.from(widget.cfdis);
      // Recrear la fuente de datos con la nueva lista y rowsPerPage actual
      _sortData();
    }
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

    // Ambos no son numéricos, comparar como string
    if (valA == null && valB == null) return 0;
    if (valA == null) return ascending ? -1 : 1; // A no es numérico
    if (valB == null) return ascending ? 1 : -1; // B no es numérico

    int result = valA.compareTo(valB);
    return ascending ? result : -result;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(flex: 2, child: FilterColumn()),
        Expanded(
          flex: 6,
          child: TableCFDI(cfdis: widget.cfdis),
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
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
}
