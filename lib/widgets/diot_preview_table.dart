import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:comparador_cfdis/bloc/diot_bloc.dart';
import 'package:comparador_cfdis/bloc/diot_state.dart';
import 'package:comparador_cfdis/bloc/diot_event.dart';
import 'package:comparador_cfdis/models/diot_record.dart';
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
              message: 'No se ha generado ningún lote DIOT');
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
                message: 'Error al obtener los datos del lote');
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
        child: Row(
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
                    'Mostrando $filteredRecords de $totalRecords registros',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
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
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columnSpacing: 16,
      horizontalMargin: 16,
      columns: [
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
      rowColor = Colors.red.withOpacity(0.1);
    } else if (requiresInput) {
      rowColor = Colors.orange.withOpacity(0.1);
    }

    return DataRow(
      color: rowColor != null ? WidgetStateProperty.all(rowColor) : null,
      cells: [
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
      return Chip(
        label: const Text('Pendiente'),
        backgroundColor: Colors.orange.withOpacity(0.2),
        avatar: const Icon(Icons.warning, size: 16, color: Colors.orange),
      );
    }

    return Chip(
      label: const Text('Válido'),
      backgroundColor: Colors.green.withOpacity(0.2),
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
