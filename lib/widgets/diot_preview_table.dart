import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:comparador_cfdis/bloc/diot_bloc.dart';
import 'package:comparador_cfdis/bloc/diot_state.dart';
import 'package:comparador_cfdis/bloc/diot_event.dart';
import 'package:comparador_cfdis/models/diot_record.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/widgets/diot_user_input_dialog.dart';

class DIOTPreviewTable extends StatefulWidget {
  const DIOTPreviewTable({Key? key}) : super(key: key);

  @override
  State<DIOTPreviewTable> createState() => _DIOTPreviewTableState();
}

class _DIOTPreviewTableState extends State<DIOTPreviewTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  String _searchFilter = '';
  final TextEditingController _searchController = TextEditingController();

  // Variables para selección múltiple
  final Set<String> _selectedRecords = <String>{};
  bool _isSelectionMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DIOTBloc, DIOTState>(
      builder: (context, state) {
        if (state is DIOTInitial) {
          return const _NoDataWidget(
            message: 'No se ha generado ningún lote DIOT',
          );
        }

        if (state is DIOTLoading) {
          return const _LoadingWidget();
        }

        if (state is DIOTError) {
          return _ErrorWidget(message: state.message);
        }

        if (state is DIOTBatchGenerated ||
            state is DIOTBatchLoaded ||
            state is DIOTRecordUpdated ||
            state is DIOTValidated) {
          final batch = _getBatchFromState(state);
          if (batch == null) {
            return const _NoDataWidget(
              message: 'Error al obtener los datos del lote',
            );
          }

          return _buildPreviewTable(batch.records);
        }

        return const _NoDataWidget(message: 'Estado no reconocido');
      },
    );
  }

  Widget _buildPreviewTable(List<DIOTRecord> records) {
    final filteredRecords = _filterRecords(records);

    return Column(
      children: [
        _buildHeader(records.length, filteredRecords.length),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            child: Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: _buildDataTable(filteredRecords),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int totalRecords, int filteredRecords) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vista Previa de Registros DIOT',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isSelectionMode
                            ? '${_selectedRecords.length} registros seleccionados'
                            : 'Mostrando $filteredRecords de $totalRecords registros',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (_isSelectionMode) ...[
                  ElevatedButton.icon(
                    onPressed: _selectedRecords.isNotEmpty
                        ? _showBulkEditDialog
                        : null,
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Editar Selección'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _exitSelectionMode,
                    icon: const Icon(Icons.close),
                    label: const Text('Cancelar'),
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.checklist),
                    onPressed: _enterSelectionMode,
                    tooltip: 'Selección múltiple',
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {
                        _searchFilter = '';
                        _searchController.clear();
                      });
                    },
                    tooltip: 'Limpiar filtros',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Buscar por RFC o Nombre',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchFilter.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchFilter = '';
                      _searchController.clear();
                    });
                  },
                )
              : null,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _searchFilter = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildDataTable(List<DIOTRecord> records) {
    return DataTable(
      sortColumnIndex:
          _isSelectionMode && _sortColumnIndex == 0 ? 1 : _sortColumnIndex,
      sortAscending: _sortAscending,
      columnSpacing: 16,
      horizontalMargin: 16,
      columns: [
        if (_isSelectionMode)
          DataColumn(
            label: Checkbox(
              value: _selectedRecords.length == records.length &&
                  records.isNotEmpty,
              tristate: true,
              onChanged: (_) => _selectAllRecords(records),
            ),
          ),
        DataColumn(
          label: const Text('RFC'),
          onSort: (columnIndex, ascending) =>
              _sort(columnIndex, ascending, 'rfc'),
        ),
        DataColumn(
          label: const Text('Nombre/Razón Social'),
          onSort: (columnIndex, ascending) =>
              _sort(columnIndex, ascending, 'nombre'),
        ),
        DataColumn(
          label: const Text('Tipo Tercero'),
          onSort: (columnIndex, ascending) =>
              _sort(columnIndex, ascending, 'tipoTercero'),
        ),
        DataColumn(
          label: const Text('Tipo Operación'),
          onSort: (columnIndex, ascending) =>
              _sort(columnIndex, ascending, 'tipoOperacion'),
        ),
        DataColumn(
          label: const Text('Base IVA 16%'),
          numeric: true,
          onSort: (columnIndex, ascending) =>
              _sort(columnIndex, ascending, 'baseIVA16'),
        ),
        DataColumn(
          label: const Text('IVA 16%'),
          numeric: true,
          onSort: (columnIndex, ascending) =>
              _sort(columnIndex, ascending, 'ivaNoAcred16'),
        ),
        DataColumn(
          label: const Text('Estado'),
          onSort: (columnIndex, ascending) =>
              _sort(columnIndex, ascending, 'status'),
        ),
        if (!_isSelectionMode)
          const DataColumn(
            label: Text('Acciones'),
          ),
      ],
      rows: records.map((record) => _buildDataRow(record)).toList(),
    );
  }

  DataRow _buildDataRow(DIOTRecord record) {
    final hasErrors = record.validationErrors.isNotEmpty;
    final requiresInput = record.requiresUserInput;

    Color? rowColor;
    if (hasErrors) {
      rowColor = Colors.red.withAlpha((255 * 0.1).round());
    } else if (requiresInput) {
      rowColor = Colors.orange.withOpacity(0.1);
    }

    return DataRow(
      color: rowColor != null ? WidgetStateProperty.all(rowColor) : null,
      cells: [
        if (_isSelectionMode)
          DataCell(
            Checkbox(
              value: _selectedRecords.contains(record.rfc),
              onChanged: (bool? value) => _toggleRecordSelection(record.rfc),
            ),
          ),
        DataCell(
          Text(
            record.rfc,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: hasErrors ? Colors.red : null,
            ),
          ),
        ),
        DataCell(
          Text(
            record.nombreExtranjero ?? 'Sin nombre',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Text(
            record.tipoTercero.description,
          ),
        ),
        DataCell(
          Text(
            record.tipoOperacion.description,
          ),
        ),
        DataCell(
          Text(
            _formatCurrency(record.valorActos16Porciento),
          ),
        ),
        DataCell(
          Text(
            _formatCurrency(record.ivaNoAcreditableSinRequisitos16),
          ),
        ),
        DataCell(
          _buildStatusChip(record),
        ),
        if (!_isSelectionMode)
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(record),
                  tooltip: 'Editar registro',
                ),
                if (hasErrors)
                  IconButton(
                    icon: const Icon(Icons.warning, color: Colors.red),
                    onPressed: () => _showErrorsDialog(record),
                    tooltip: 'Ver errores de validación',
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChip(DIOTRecord record) {
    if (record.validationErrors.isNotEmpty) {
      return Chip(
        label: const Text('Error'),
        backgroundColor: Colors.red.withOpacity(0.2),
        avatar: const Icon(Icons.error, size: 16, color: Colors.red),
      );
    }

    if (record.requiresUserInput) {
      final String pendingReason = _getPendingReason(record);
      return Chip(
        label: Text('Pendiente: $pendingReason'),
        backgroundColor: Colors.orange.withOpacity(0.2),
        avatar: const Icon(Icons.warning, size: 16, color: Colors.orange),
      );
    }

    return Chip(
      label: const Text('Válido'),
      backgroundColor: Colors.green.withAlpha((255 * 0.2).round()),
      avatar: const Icon(Icons.check, size: 16, color: Colors.green),
    );
  }

  void _sort(int columnIndex, bool ascending, String field) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  List<DIOTRecord> _filterRecords(List<DIOTRecord> records) {
    if (_searchFilter.isEmpty) {
      return records;
    }

    return records.where((record) {
      final rfc = record.rfc.toLowerCase();
      final nombre = (record.nombreExtranjero ?? '').toLowerCase();
      return rfc.contains(_searchFilter) || nombre.contains(_searchFilter);
    }).toList();
  }

  String _formatCurrency(double? value) {
    if (value == null) return '\$0.00';
    return '\$${value.toStringAsFixed(2)}';
  }

  void _showEditDialog(DIOTRecord record) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => DIOTUserInputDialog(
        record: record,
        onSave: () {
          // El DIOTUserInputDialog ya maneja el Navigator.pop()
          // Solo necesitamos refrescar la vista si es necesario
        },
        onCancel: () {
          Navigator.of(dialogContext).pop();
        },
      ),
    );

    // Si se recibieron datos actualizados, enviarlos al BLoC
    if (result != null && mounted) {
      context.read<DIOTBloc>().add(
            UpdateRecordUserInput(
              record.rfc,
              result,
            ),
          );
    }
  }

  void _showErrorsDialog(DIOTRecord record) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Errores de Validación - ${record.rfc}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: record.validationErrors.map((error) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(error.message)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _showEditDialog(record);
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  dynamic _getBatchFromState(DIOTState state) {
    if (state is DIOTBatchGenerated) return state.batch;
    if (state is DIOTBatchLoaded) return state.batch;
    if (state is DIOTRecordUpdated) return state.batch;
    if (state is DIOTValidated) return state.batch;
    return null;
  }

  // Métodos para selección múltiple
  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _selectedRecords.clear();
      // Reset sort when entering selection mode to avoid column index issues
      _sortColumnIndex =
          _isSelectionMode ? 1 : 0; // Account for checkbox column
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedRecords.clear();
      // Reset sort when exiting selection mode
      _sortColumnIndex = 0;
    });
  }

  void _toggleRecordSelection(String rfc) {
    setState(() {
      if (_selectedRecords.contains(rfc)) {
        _selectedRecords.remove(rfc);
      } else {
        _selectedRecords.add(rfc);
      }
    });
  }

  void _selectAllRecords(List<DIOTRecord> records) {
    setState(() {
      if (_selectedRecords.length == records.length) {
        _selectedRecords.clear();
      } else {
        _selectedRecords.clear();
        _selectedRecords.addAll(records.map((r) => r.rfc));
      }
    });
  }

  Future<void> _showBulkEditDialog() async {
    // Obtener el estado actual del BLoC para acceder a los records
    final diotState = context.read<DIOTBloc>().state;

    // Determinar el batch dependiendo del estado
    DIOTBatch? batch;
    if (diotState is DIOTBatchLoaded) {
      batch = diotState.batch;
    } else if (diotState is DIOTBatchCreated) {
      batch = diotState.batch;
    } else if (diotState is DIOTBatchGenerated) {
      batch = diotState.batch;
    } else if (diotState is DIOTRecordUpdated) {
      batch = diotState.batch;
    } else if (diotState is DIOTValidated) {
      batch = diotState.batch;
    }

    if (batch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: No se pueden cargar los registros. Estado actual: ${diotState.runtimeType}',
          ),
        ),
      );
      return;
    }

    print('🔍 DEBUG: Estado del BLoC: ${diotState.runtimeType}');
    print('🔍 DEBUG: Records seleccionados: ${_selectedRecords.length}');

    // Determinar si alguno de los records seleccionados tiene valores de IVA
    final selectedRecordObjects = batch.records
        .where((record) => _selectedRecords.contains(record.rfc))
        .toList();

    final hasAnyIVAValues = selectedRecordObjects.any(
      (record) =>
          (record.valorActos16Porciento ?? 0) > 0 ||
          (record.ivaNoAcreditableSinRequisitos16 ?? 0) > 0,
    );

    print('🔍 DEBUG: Records con valores de IVA: $hasAnyIVAValues');

    // Crear un registro temporal que refleje si hay valores de IVA en la selección
    final tempRecord = DIOTRecord(
      rfc: '',
      tipoTercero: TipoTercero.nacional,
      tipoOperacion: TipoOperacion.prestacionServicios,
      efectosFiscales: EfectosFiscales.si,
      // Asignar valores de IVA si algún record seleccionado los tiene
      valorActos16Porciento: hasAnyIVAValues ? 1000.0 : 0.0,
      ivaNoAcreditableSinRequisitos16: 0.0,
    );

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => DIOTUserInputDialog(
        record: tempRecord,
        onSave: () {
          // El diálogo manejará el Navigator.pop()
        },
        onCancel: () {
          Navigator.of(dialogContext).pop();
        },
      ),
    );

    // Si se recibieron datos, aplicarlos a todos los registros seleccionados
    if (result != null && mounted) {
      for (final rfc in _selectedRecords) {
        context.read<DIOTBloc>().add(
              UpdateRecordUserInput(rfc, result),
            );
      }

      // Salir del modo de selección
      _exitSelectionMode();

      // Mostrar mensaje de confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Se actualizaron ${_selectedRecords.length} registros exitosamente',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _getPendingReason(DIOTRecord record) {
    final List<String> missingItems = [];

    // Si es extranjero y no tiene información completa
    if (record.tipoTercero == TipoTercero.extranjero) {
      if (record.nombreExtranjero == null || record.nombreExtranjero!.isEmpty) {
        missingItems.add('Nombre');
      }
      if (record.paisResidenciaFiscal == null ||
          record.paisResidenciaFiscal!.isEmpty) {
        missingItems.add('País');
      }
    }

    // Si no tiene tipo de operación definido
    if (record.tipoOperacion == TipoOperacion.prestacionServicios &&
        record.valorActos16Porciento == 0) {
      missingItems.add('Tipo de operación');
    }

    if (missingItems.isEmpty) {
      return 'Completar datos';
    }

    return missingItems.join(', ');
  }
}

class _NoDataWidget extends StatelessWidget {
  final String message;

  const _NoDataWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_view,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando vista previa...'),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;

  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 64,
            color: Colors.red.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
