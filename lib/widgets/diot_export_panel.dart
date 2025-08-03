import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:comparador_cfdis/bloc/diot_bloc.dart';
import 'package:comparador_cfdis/bloc/diot_state.dart';
import 'package:comparador_cfdis/bloc/diot_event.dart';

class DIOTExportPanel extends StatelessWidget {
  const DIOTExportPanel({Key? key}) : super(key: key);

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

        if (state is DIOTExported) {
          return _ExportedWidget(
            filePath: state.filePath,
            totalRecords: state.totalRecords,
          );
        }

        if (state is DIOTBatchGenerated ||
            state is DIOTBatchLoaded ||
            state is DIOTRecordUpdated ||
            state is DIOTValidated) {
          final batch = _getBatchFromState(state);
          final validationSummary = _getValidationSummaryFromState(state);

          if (batch == null || validationSummary == null) {
            return const _ErrorWidget(
                message: 'Error al obtener datos del lote');
          }

          return _buildExportPanel(context, batch, validationSummary);
        }

        return const _NoDataWidget();
      },
    );
  }

  Widget _buildExportPanel(
      BuildContext context, dynamic batch, dynamic validationSummary) {
    final isReadyForExport = validationSummary.isReadyForExport;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(context, batch, validationSummary),
          const SizedBox(height: 16),
          if (isReadyForExport) ...[
            _buildExportOptionsCard(context, batch),
            const SizedBox(height: 16),
            _buildPreviewCard(context, batch),
          ] else ...[
            _buildNotReadyCard(context, validationSummary),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(
      BuildContext context, dynamic batch, dynamic validationSummary) {
    final theme = Theme.of(context);
    final isReady = validationSummary.isReadyForExport;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado del Lote DIOT',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  isReady ? Icons.check_circle : Icons.warning,
                  color: isReady ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isReady
                            ? 'Listo para exportar'
                            : 'Pendiente de correcciones',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isReady ? Colors.green : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isReady
                            ? 'Todos los registros están validados correctamente'
                            : 'Algunos registros requieren corrección antes de exportar',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatisticsRow(context, validationSummary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsRow(BuildContext context, dynamic validationSummary) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            'Total',
            validationSummary.totalRecords.toString(),
            Colors.blue,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            'Válidos',
            validationSummary.recordsReady.toString(),
            Colors.green,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            'Con Errores',
            validationSummary.recordsWithErrors.toString(),
            Colors.red,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            'Pendientes',
            validationSummary.recordsRequiringInput.toString(),
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildExportOptionsCard(BuildContext context, dynamic batch) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opciones de Exportación',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildExportOption(
              context,
              'Exportar archivo DIOT',
              'Genera el archivo de texto para presentar al SAT',
              Icons.file_download,
              () => _exportDIOTFile(context),
            ),
            const Divider(),
            _buildExportOption(
              context,
              'Vista previa del archivo',
              'Revisa el contenido antes de exportar',
              Icons.preview,
              () => _showPreviewDialog(context, batch),
            ),
            const Divider(),
            _buildExportOption(
              context,
              'Exportar resumen de validación',
              'Genera un reporte de la validación realizada',
              Icons.assessment,
              () => _exportValidationReport(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(description),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }

  Widget _buildPreviewCard(BuildContext context, dynamic batch) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Archivo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Formato:', 'Texto delimitado por pipes (|)'),
            _buildInfoRow('Codificación:', 'UTF-8'),
            _buildInfoRow('Extensión:', '.txt'),
            _buildInfoRow('Registros:', '${batch.records.length}'),
            _buildInfoRow(
                'Tamaño estimado:', _calculateFileSize(batch.records.length)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildNotReadyCard(BuildContext context, dynamic validationSummary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'No se puede exportar',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Antes de exportar el archivo DIOT, es necesario corregir los siguientes problemas:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (validationSummary.recordsWithErrors > 0)
              _buildIssueItem(
                'Registros con errores de validación',
                '${validationSummary.recordsWithErrors} registros',
                Icons.error,
                Colors.red,
              ),
            if (validationSummary.recordsRequiringInput > 0)
              _buildIssueItem(
                'Registros que requieren información adicional',
                '${validationSummary.recordsRequiringInput} registros',
                Icons.input,
                Colors.orange,
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      DefaultTabController.of(context).animateTo(1);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Corregir Registros'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      DefaultTabController.of(context).animateTo(2);
                    },
                    icon: const Icon(Icons.warning),
                    label: const Text('Ver Validaciones'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueItem(
      String title, String subtitle, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _exportDIOTFile(BuildContext context) {
    context.read<DIOTBloc>().add(ExportDIOTFile());
  }

  void _showPreviewDialog(BuildContext context, dynamic batch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vista Previa del Archivo DIOT'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(
              _generatePreviewText(batch),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportDIOTFile(context);
            },
            child: const Text('Exportar'),
          ),
        ],
      ),
    );
  }

  void _exportValidationReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de reporte de validación en desarrollo'),
      ),
    );
  }

  String _generatePreviewText(dynamic batch) {
    // Generar una vista previa simplificada
    final preview = StringBuffer();
    preview.writeln('# Vista previa del archivo DIOT');
    preview.writeln('# Configuración:');
    preview.writeln('# Ejercicio: ${batch.configuration.ejercicio}');
    preview.writeln('# Período: ${batch.configuration.periodo}');
    preview.writeln('# RFC: ${batch.configuration.rfcContribuyente}');
    preview.writeln('');
    preview.writeln('# Primeros registros:');

    for (int i = 0; i < batch.records.length && i < 5; i++) {
      final record = batch.records[i];
      preview.writeln(
          '${record.rfc}|${record.tipoTercero.code}|${record.tipoOperacion.code}|...');
    }

    if (batch.records.length > 5) {
      preview.writeln('... y ${batch.records.length - 5} registros más');
    }

    return preview.toString();
  }

  String _calculateFileSize(int recordCount) {
    // Estimación aproximada: ~200 bytes por registro
    final bytes = recordCount * 200;
    if (bytes < 1024) {
      return '$bytes bytes';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  dynamic _getBatchFromState(DIOTState state) {
    if (state is DIOTBatchGenerated) return state.batch;
    if (state is DIOTBatchLoaded) return state.batch;
    if (state is DIOTRecordUpdated) return state.batch;
    if (state is DIOTValidated) return state.batch;
    return null;
  }

  dynamic _getValidationSummaryFromState(DIOTState state) {
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
            Icons.file_download,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay datos para exportar',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Genera y valida un lote DIOT primero',
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
          Text('Exportando archivo...'),
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
            'Error en exportación',
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

class _ExportedWidget extends StatelessWidget {
  final String filePath;
  final int totalRecords;

  const _ExportedWidget({
    required this.filePath,
    required this.totalRecords,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                'Archivo DIOT exportado exitosamente',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Se exportaron $totalRecords registros',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Archivo guardado en:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                filePath,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Abrir carpeta del archivo
                },
                icon: const Icon(Icons.folder_open),
                label: const Text('Abrir Carpeta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
