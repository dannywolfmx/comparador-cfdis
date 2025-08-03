import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:comparador_cfdis/bloc/diot_bloc.dart';
import 'package:comparador_cfdis/bloc/diot_event.dart';
import 'package:comparador_cfdis/bloc/diot_state.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/constants/diot_constants.dart';

class DIOTConfigurationPanel extends StatefulWidget {
  final List<CFDI> cfdis;

  const DIOTConfigurationPanel({
    Key? key,
    required this.cfdis,
  }) : super(key: key);

  @override
  State<DIOTConfigurationPanel> createState() => _DIOTConfigurationPanelState();
}

class _DIOTConfigurationPanelState extends State<DIOTConfigurationPanel> {
  final _formKey = GlobalKey<FormState>();
  final _ejercicioController = TextEditingController();
  final _periodoController = TextEditingController();
  final _rfcContribuyenteController = TextEditingController();

  TipoComplemento _tipoComplemento = TipoComplemento.normal;
  bool _incluirOperacionesAlMomento = false;
  bool _incluirOperacionesEnParteProporcionadas = false;
  bool _incluirOperacionesEnParteDeducibles = false;

  @override
  void initState() {
    super.initState();
    // Valores por defecto
    final now = DateTime.now();
    _ejercicioController.text = now.year.toString();
    _periodoController.text = now.month.toString().padLeft(2, '0');
  }

  @override
  void dispose() {
    _ejercicioController.dispose();
    _periodoController.dispose();
    _rfcContribuyenteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DIOTBloc, DIOTState>(
      listener: (context, state) {
        if (state is DIOTBatchGenerated) {
          // Navegar a la pestaña de vista previa
          DefaultTabController.of(context).animateTo(1);
        } else if (state is DIOTError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<DIOTBloc, DIOTState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 16),
                  _buildBasicConfigCard(),
                  const SizedBox(height: 16),
                  _buildComplementoConfigCard(),
                  const SizedBox(height: 16),
                  _buildOperacionesConfigCard(),
                  const SizedBox(height: 24),
                  _buildGenerateButton(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Período',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'CFDIs a procesar: ${widget.cfdis.length}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (widget.cfdis.isNotEmpty) ...[
              Text(
                'Período: ${_getPeriodRange()}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicConfigCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Configuración Básica',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed:
                      widget.cfdis.isNotEmpty ? _autoFillFromAnalysis : null,
                  icon: const Icon(Icons.auto_fix_high, size: 18),
                  label: const Text('Auto-completar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Completa automáticamente basándose en el análisis de CFDIs cargados',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ejercicioController,
                    decoration: InputDecoration(
                      labelText: 'Ejercicio',
                      hintText: '2025',
                      border: const OutlineInputBorder(),
                      suffixIcon: widget.cfdis.isNotEmpty
                          ? IconButton(
                              onPressed: _autoFillPeriodo,
                              icon: const Icon(Icons.auto_awesome, size: 20),
                              tooltip: 'Sugerir período automáticamente',
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Campo requerido';
                      }
                      final year = int.tryParse(value!);
                      if (year == null || year < 2024 || year > 2030) {
                        return 'Año inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _periodoController,
                    decoration: const InputDecoration(
                      labelText: 'Período (MM)',
                      hintText: '01',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Campo requerido';
                      }
                      final month = int.tryParse(value!);
                      if (month == null || month < 1 || month > 12) {
                        return 'Mes inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rfcContribuyenteController,
              decoration: InputDecoration(
                labelText: 'RFC del Contribuyente',
                hintText: 'RFC123456789',
                border: const OutlineInputBorder(),
                suffixIcon: widget.cfdis.isNotEmpty
                    ? IconButton(
                        onPressed: _autoFillRFC,
                        icon: const Icon(Icons.auto_awesome, size: 20),
                        tooltip: 'Sugerir RFC más común',
                      )
                    : null,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Campo requerido';
                }
                if (!RegExp(r'^[A-Z&Ñ]{3,4}[0-9]{6}[A-Z0-9]{3}$')
                    .hasMatch(value!)) {
                  return 'RFC inválido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplementoConfigCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de Complemento',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Column(
              children: TipoComplemento.values.map((tipo) {
                return RadioListTile<TipoComplemento>(
                  title: Text(_getTipoComplementoLabel(tipo)),
                  subtitle: Text(_getTipoComplementoDescription(tipo)),
                  value: tipo,
                  groupValue: _tipoComplemento,
                  onChanged: (value) {
                    setState(() {
                      _tipoComplemento = value!;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperacionesConfigCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración de Operaciones',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona los tipos de operaciones a incluir:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Operaciones al momento'),
              subtitle: const Text('Operaciones pagadas al momento'),
              value: _incluirOperacionesAlMomento,
              onChanged: (value) {
                setState(() {
                  _incluirOperacionesAlMomento = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Operaciones en parte proporcionadas'),
              subtitle: const Text('Operaciones proporcionadas parcialmente'),
              value: _incluirOperacionesEnParteProporcionadas,
              onChanged: (value) {
                setState(() {
                  _incluirOperacionesEnParteProporcionadas = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Operaciones en parte deducibles'),
              subtitle: const Text('Operaciones deducibles parcialmente'),
              value: _incluirOperacionesEnParteDeducibles,
              onChanged: (value) {
                setState(() {
                  _incluirOperacionesEnParteDeducibles = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(DIOTState state) {
    final isLoading = state is DIOTLoading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _generateDIOT,
        child: isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Generando DIOT...'),
                ],
              )
            : const Text('Generar DIOT'),
      ),
    );
  }

  void _generateDIOT() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Crear criterios de filtrado básicos
    const filterCriteria = DIOTFilterCriteria(
      includeOnlyWithIVA: true,
      minAmount: 0.0,
    );

    // Crear preferencias de usuario vacías
    const userPreferences = DIOTUserPreferences();

    final configuration = DIOTConfiguration(
      year: int.parse(_ejercicioController.text),
      month: int.parse(_periodoController.text),
      ejercicio: int.parse(_ejercicioController.text),
      periodo: int.parse(_periodoController.text),
      rfcContribuyente: _rfcContribuyenteController.text.toUpperCase(),
      tipoComplemento: _tipoComplemento,
      incluirOperacionesAlMomento: _incluirOperacionesAlMomento,
      incluirOperacionesEnParteProporcionadas:
          _incluirOperacionesEnParteProporcionadas,
      incluirOperacionesEnParteDeducibles: _incluirOperacionesEnParteDeducibles,
      filterCriteria: filterCriteria,
      userPreferences: userPreferences,
    );

    context.read<DIOTBloc>().add(
          GenerateDIOTBatch(
            cfdis: widget.cfdis,
            configuration: configuration,
          ),
        );
  }

  // Métodos de análisis de CFDIs
  Map<String, int> _analyzeReceptores() {
    final receptorCount = <String, int>{};

    for (final cfdi in widget.cfdis) {
      final rfc = cfdi.receptor?.rfc;
      if (rfc != null && rfc.isNotEmpty) {
        receptorCount[rfc] = (receptorCount[rfc] ?? 0) + 1;
      }
    }

    return receptorCount;
  }

  String? _getMostCommonReceptor() {
    final receptorCount = _analyzeReceptores();
    if (receptorCount.isEmpty) return null;

    return receptorCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  Map<String, dynamic> _analyzePeriodo() {
    final dates = widget.cfdis
        .map((c) => c.fecha)
        .where((fecha) => fecha != null && fecha.isNotEmpty)
        .map((fecha) {
          try {
            return DateTime.parse(fecha!);
          } catch (e) {
            return null;
          }
        })
        .where((date) => date != null)
        .cast<DateTime>()
        .toList()
      ..sort();

    if (dates.isEmpty) return {};

    final startDate = dates.first;
    final endDate = dates.last;

    // Determinar el año más común
    final yearCount = <int, int>{};
    for (final date in dates) {
      yearCount[date.year] = (yearCount[date.year] ?? 0) + 1;
    }

    final mostCommonYear =
        yearCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Determinar el mes más común del año más frecuente
    final monthsInCommonYear = dates
        .where((date) => date.year == mostCommonYear)
        .map((date) => date.month)
        .toList();

    final monthCount = <int, int>{};
    for (final month in monthsInCommonYear) {
      monthCount[month] = (monthCount[month] ?? 0) + 1;
    }

    final mostCommonMonth =
        monthCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return {
      'year': mostCommonYear,
      'month': mostCommonMonth,
      'startDate': startDate,
      'endDate': endDate,
      'totalDocuments': dates.length,
    };
  }

  void _autoFillFromAnalysis() {
    final mostCommonRfc = _getMostCommonReceptor();
    final periodoAnalysis = _analyzePeriodo();

    setState(() {
      if (mostCommonRfc != null) {
        _rfcContribuyenteController.text = mostCommonRfc;
      }

      if (periodoAnalysis.isNotEmpty) {
        _ejercicioController.text = periodoAnalysis['year'].toString();
        _periodoController.text =
            periodoAnalysis['month'].toString().padLeft(2, '0');
      }
    });

    // Mostrar información del análisis
    if (mounted) {
      _showAnalysisInfo(mostCommonRfc, periodoAnalysis);
    }
  }

  void _autoFillRFC() {
    final mostCommonRfc = _getMostCommonReceptor();
    if (mostCommonRfc != null) {
      setState(() {
        _rfcContribuyenteController.text = mostCommonRfc;
      });

      final receptorCount = _analyzeReceptores();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'RFC sugerido: $mostCommonRfc (${receptorCount[mostCommonRfc]} documentos)',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _autoFillPeriodo() {
    final periodoAnalysis = _analyzePeriodo();
    if (periodoAnalysis.isNotEmpty) {
      setState(() {
        _ejercicioController.text = periodoAnalysis['year'].toString();
        _periodoController.text =
            periodoAnalysis['month'].toString().padLeft(2, '0');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Período sugerido: ${periodoAnalysis['month'].toString().padLeft(2, '0')}/${periodoAnalysis['year']} (${periodoAnalysis['totalDocuments']} documentos)',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showAnalysisInfo(String? rfc, Map<String, dynamic> periodoInfo) {
    final receptorCount = _analyzeReceptores();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Análisis de CFDIs'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Análisis completado:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              // RFC más común
              Text(
                'RFC receptor más frecuente:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(rfc ?? 'No se encontró'),
              if (rfc != null && receptorCount[rfc] != null)
                Text(
                  '${receptorCount[rfc]} documentos (${(receptorCount[rfc]! / widget.cfdis.length * 100).toStringAsFixed(1)}%)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 12),

              // Período más común
              if (periodoInfo.isNotEmpty) ...[
                Text(
                  'Período sugerido:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                    '${periodoInfo['month'].toString().padLeft(2, '0')}/${periodoInfo['year']}'),
                Text(
                  'Rango: ${_formatDate(periodoInfo['startDate'])} - ${_formatDate(periodoInfo['endDate'])}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${periodoInfo['totalDocuments']} documentos analizados',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],

              if (receptorCount.length > 1) ...[
                const SizedBox(height: 12),
                Text(
                  'Otros receptores encontrados:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                ...receptorCount.entries
                    .where((entry) => entry.key != rfc)
                    .take(5)
                    .map(
                      (entry) => Text(
                        '${entry.key}: ${entry.value} documentos',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                if (receptorCount.length > 6)
                  Text(
                    'y ${receptorCount.length - 6} más...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ],
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getPeriodRange() {
    if (widget.cfdis.isEmpty) return 'N/A';

    final dates = widget.cfdis
        .map((c) => c.fecha)
        .where((fecha) => fecha != null && fecha.isNotEmpty)
        .map((fecha) {
          try {
            return DateTime.parse(fecha!);
          } catch (e) {
            return null;
          }
        })
        .where((date) => date != null)
        .cast<DateTime>()
        .toList()
      ..sort();

    if (dates.isEmpty) return 'N/A';

    final start = dates.first;
    final end = dates.last;

    if (start.year == end.year && start.month == end.month) {
      return '${start.month.toString().padLeft(2, '0')}/${start.year}';
    }

    return '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year} - ${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}';
  }

  String _getTipoComplementoLabel(TipoComplemento tipo) {
    switch (tipo) {
      case TipoComplemento.normal:
        return 'Normal';
      case TipoComplemento.complementaria:
        return 'Complementaria';
    }
  }

  String _getTipoComplementoDescription(TipoComplemento tipo) {
    switch (tipo) {
      case TipoComplemento.normal:
        return 'Declaración informativa regular';
      case TipoComplemento.complementaria:
        return 'Corrección de declaración anterior';
    }
  }
}
