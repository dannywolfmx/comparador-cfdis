import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:comparador_cfdis/bloc/diot_bloc.dart';
import 'package:comparador_cfdis/bloc/diot_state.dart';
import 'package:comparador_cfdis/bloc/diot_event.dart';
import 'package:comparador_cfdis/services/diot_validation_service.dart';

class DIOTValidationPanel extends StatelessWidget {
  const DIOTValidationPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DIOTBloc, DIOTState>(
      builder: (context, state) {
        if (state is DIOTInitial) {
          return const _NoDataWidget();
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
          final validationSummary = _getValidationSummaryFromState(state);
          if (validationSummary == null) {
            return const _ErrorWidget(
                message: 'Error al obtener resumen de validación');
          }

          return _buildValidationPanel(context, validationSummary, state);
        }

        return const _NoDataWidget();
      },
    );
  }

  Widget _buildValidationPanel(
      BuildContext context, DIOTValidationSummary summary, DIOTState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(context, summary),
          const SizedBox(height: 16),
          _buildValidationActions(context),
          const SizedBox(height: 16),
          if (summary.recordsRequiringInput > 0) ...[
            _buildInputRequiredCard(context, summary),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, DIOTValidationSummary summary) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de Validación',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total de Registros',
                    summary.totalRecords.toString(),
                    Icons.table_rows,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Registros Válidos',
                    summary.recordsReady.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Con Errores',
                    summary.recordsWithErrors.toString(),
                    Icons.error,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Requieren Entrada',
                    summary.recordsRequiringInput.toString(),
                    Icons.input,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildReadinessIndicator(context, summary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessIndicator(
      BuildContext context, DIOTValidationSummary summary) {
    final isReady = summary.isReadyForExport;
    final color = isReady ? Colors.green : Colors.orange;
    final icon = isReady ? Icons.check_circle : Icons.warning;
    final text = isReady ? 'Listo para exportar' : 'Requiere correcciones';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones de Validación',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<DIOTBloc>().add(ValidateBatch());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Re-validar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showValidationDetailsDialog(context);
                    },
                    icon: const Icon(Icons.info),
                    label: const Text('Ver Detalles'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRequiredCard(
      BuildContext context, DIOTValidationSummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.input, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Registros que Requieren Entrada',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Hay ${summary.recordsRequiringInput} registros que necesitan información adicional del usuario.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Navegar a la vista previa para editar registros
                DefaultTabController.of(context).animateTo(1);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Completar Información'),
            ),
          ],
        ),
      ),
    );
  }

  void _showValidationDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles de Validación'),
        content: const SingleChildScrollView(
          child: Text(
            'La validación verifica:\n\n'
            '• Formato de RFC\n'
            '• Clasificaciones requeridas\n'
            '• Valores numéricos válidos\n'
            '• Consistencia de datos\n'
            '• Cumplimiento de reglas SAT\n'
            '• Información de proveedores extranjeros\n\n'
            'Los registros deben estar libres de errores para poder exportar la DIOT.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  DIOTValidationSummary? _getValidationSummaryFromState(DIOTState state) {
    if (state is DIOTBatchGenerated) return state.validationSummary;
    if (state is DIOTBatchLoaded) return state.validationSummary;
    if (state is DIOTRecordUpdated) return state.validationSummary;
    if (state is DIOTValidated) return state.validationSummary;
    return null;
  }
}

class _NoDataWidget extends StatelessWidget {
  const _NoDataWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fact_check,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay datos para validar',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Genera un lote DIOT primero',
            style: Theme.of(context).textTheme.bodyMedium,
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
          Text('Validando...'),
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
            'Error en validación',
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
