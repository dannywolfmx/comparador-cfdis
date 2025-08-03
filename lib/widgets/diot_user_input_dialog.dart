import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:comparador_cfdis/models/diot_record.dart';
import 'package:comparador_cfdis/constants/diot_constants.dart';

/// Widget para capturar información faltante del usuario para registros DIOT
class DIOTUserInputDialog extends StatefulWidget {
  final DIOTRecord record;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  const DIOTUserInputDialog({
    Key? key,
    required this.record,
    this.onSave,
    this.onCancel,
  }) : super(key: key);

  @override
  State<DIOTUserInputDialog> createState() => _DIOTUserInputDialogState();
}

class _DIOTUserInputDialogState extends State<DIOTUserInputDialog> {
  late TipoTercero _selectedTipoTercero;
  late TipoOperacion _selectedTipoOperacion;
  ClasificacionRegional? _selectedClasificacionRegional;
  ClasificacionIVA? _selectedClasificacionIVA;
  EfectosFiscales _selectedEfectosFiscales = EfectosFiscales.si;

  // Campos para proveedor extranjero
  final TextEditingController _numeroIdentificacionController =
      TextEditingController();
  final TextEditingController _nombreExtranjeroController =
      TextEditingController();
  String? _selectedPais;
  final TextEditingController _jurisdiccionController = TextEditingController();

  // Campos para devoluciones
  final TextEditingController _devolucionesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeFromRecord();
  }

  void _initializeFromRecord() {
    _selectedTipoTercero = widget.record.tipoTercero;
    _selectedTipoOperacion = widget.record.tipoOperacion;
    _selectedClasificacionRegional = widget.record.clasificacionRegional;
    _selectedClasificacionIVA = widget.record.clasificacionIVA;
    _selectedEfectosFiscales = widget.record.efectosFiscales;

    // Inicializar campos de extranjero
    _numeroIdentificacionController.text =
        widget.record.numeroIdentificacionFiscal ?? '';
    _nombreExtranjeroController.text = widget.record.nombreExtranjero ?? '';
    _selectedPais = widget.record.paisResidenciaFiscal;
    _jurisdiccionController.text = widget.record.especificarJurisdiccion ?? '';
  }

  @override
  void dispose() {
    _numeroIdentificacionController.dispose();
    _nombreExtranjeroController.dispose();
    _jurisdiccionController.dispose();
    _devolucionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.edit_note,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Completar Información DIOT',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // RFC Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.business,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'RFC: ${widget.record.rfc}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTipoTerceroSection(),
                      const SizedBox(height: 16),
                      _buildTipoOperacionSection(),
                      const SizedBox(height: 16),
                      if (_selectedTipoTercero == TipoTercero.extranjero) ...[
                        _buildExtranjeroSection(),
                        const SizedBox(height: 16),
                      ],
                      _buildClasificacionSection(),
                      const SizedBox(height: 16),
                      _buildEfectosFiscalesSection(),
                      const SizedBox(height: 16),
                      _buildDevolucionesSection(),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipoTerceroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Tercero',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...TipoTercero.values.map(
          (tipo) => RadioListTile<TipoTercero>(
            title: Text(tipo.description),
            subtitle: Text('Código: ${tipo.code}'),
            value: tipo,
            groupValue: _selectedTipoTercero,
            onChanged: (value) {
              setState(() {
                _selectedTipoTercero = value!;
                // Actualizar tipo de operación válido
                final validOperations =
                    TipoOperacion.getValidForTipoTercero(_selectedTipoTercero);
                if (!validOperations.contains(_selectedTipoOperacion)) {
                  _selectedTipoOperacion = validOperations.first;
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTipoOperacionSection() {
    final validOperations =
        TipoOperacion.getValidForTipoTercero(_selectedTipoTercero);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Operación',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<TipoOperacion>(
          value: _selectedTipoOperacion,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Seleccionar tipo de operación',
          ),
          items: validOperations
              .map(
                (operacion) => DropdownMenuItem(
                  value: operacion,
                  child: Text(
                    '${operacion.description} (${operacion.code})',
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedTipoOperacion = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildExtranjeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información de Proveedor Extranjero',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        // Número de identificación fiscal
        TextFormField(
          controller: _numeroIdentificacionController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Número de Identificación Fiscal *',
            helperText: 'Máximo 40 caracteres',
          ),
          maxLength: DIOTConstants.maxIdentificacionFiscalLength,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo es requerido para proveedores extranjeros';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Nombre del extranjero
        TextFormField(
          controller: _nombreExtranjeroController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Nombre del Extranjero *',
            helperText: 'Máximo 300 caracteres',
          ),
          maxLength: DIOTConstants.maxNombreExtranjeroLength,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo es requerido para proveedores extranjeros';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // País de residencia fiscal
        DropdownButtonFormField<String>(
          value: _selectedPais,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'País de Residencia Fiscal *',
          ),
          items: DIOTConstants.paisesResidenciaFiscal.entries
              .map(
                (entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text('${entry.key} - ${entry.value}'),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedPais = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo es requerido para proveedores extranjeros';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Jurisdicción especial (solo si país es ZZZ)
        if (_selectedPais == 'ZZZ')
          TextFormField(
            controller: _jurisdiccionController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Especificar Jurisdicción *',
              helperText: 'Requerido cuando país es "Otro"',
            ),
            maxLength: DIOTConstants.maxJurisdiccionLength,
            validator: (value) {
              if (_selectedPais == 'ZZZ' && (value == null || value.isEmpty)) {
                return 'Este campo es requerido cuando país es "Otro"';
              }
              return null;
            },
          ),
      ],
    );
  }

  Widget _buildClasificacionSection() {
    // Determinar si las clasificaciones son requeridas
    final bool hasIVAValues = widget.record.valorActos16Porciento > 0 ||
        widget.record.ivaNoAcreditableSinRequisitos16 > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Clasificaciones',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (hasIVAValues) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'REQUERIDO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (hasIVAValues) ...[
          const SizedBox(height: 4),
          Text(
            'Este registro tiene valores de IVA (${widget.record.valorActos16Porciento.toStringAsFixed(2)}), por lo que requiere clasificaciones.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade700,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
        const SizedBox(height: 16),

        // Clasificación regional
        DropdownButtonFormField<ClasificacionRegional>(
          value: _selectedClasificacionRegional,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: hasIVAValues
                ? 'Clasificación Regional *'
                : 'Clasificación Regional',
            helperText: 'Determina la tasa de IVA aplicable',
            errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          items: ClasificacionRegional.values
              .map(
                (clasificacion) => DropdownMenuItem(
                  value: clasificacion,
                  child: Text(clasificacion.description),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedClasificacionRegional = value;
            });
          },
          validator: hasIVAValues
              ? (value) {
                  if (value == null) {
                    return 'Este campo es requerido cuando hay valores de IVA';
                  }
                  return null;
                }
              : null,
        ),
        const SizedBox(height: 16),

        // Clasificación IVA
        DropdownButtonFormField<ClasificacionIVA>(
          value: _selectedClasificacionIVA,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: hasIVAValues
                ? 'Clasificación de IVA *'
                : 'Clasificación de IVA',
            helperText: 'Tipo de acreditamiento del IVA',
            errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          items: ClasificacionIVA.values
              .map(
                (clasificacion) => DropdownMenuItem(
                  value: clasificacion,
                  child: Text(clasificacion.description),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedClasificacionIVA = value;
            });
          },
          validator: hasIVAValues
              ? (value) {
                  if (value == null) {
                    return 'Este campo es requerido cuando hay valores de IVA';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildEfectosFiscalesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Efectos Fiscales',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '¿Se dio efectos fiscales a los comprobantes?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        ...EfectosFiscales.values.map(
          (efecto) => RadioListTile<EfectosFiscales>(
            title: Text(efecto.description),
            value: efecto,
            groupValue: _selectedEfectosFiscales,
            onChanged: (value) {
              setState(() {
                _selectedEfectosFiscales = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDevolucionesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Devoluciones y Descuentos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Si aplica, especifique el monto de devoluciones, descuentos y bonificaciones',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _devolucionesController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Monto de Devoluciones',
            helperText: 'Opcional - Solo números enteros',
            prefixText: '\$ ',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final numero = int.tryParse(value);
              if (numero == null) {
                return 'Debe ser un número válido';
              }
              if (numero > DIOTConstants.maxNumericValue) {
                return 'El valor no puede exceder ${DIOTConstants.maxNumericValue}';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      // Validación adicional: verificar campos requeridos según el contexto
      final List<String> missingFields = [];

      // Verificar extranjero
      if (_selectedTipoTercero == TipoTercero.extranjero) {
        if (_nombreExtranjeroController.text.trim().isEmpty) {
          missingFields.add('Nombre del extranjero');
        }
        if (_selectedPais == null || _selectedPais!.isEmpty) {
          missingFields.add('País de residencia fiscal');
        }
      }

      // Verificar clasificaciones si el record tiene valores de IVA
      final bool hasIVAValues = widget.record.valorActos16Porciento > 0 ||
          widget.record.ivaNoAcreditableSinRequisitos16 > 0;

      if (hasIVAValues) {
        if (_selectedClasificacionRegional == null) {
          missingFields.add('Clasificación Regional');
        }
        if (_selectedClasificacionIVA == null) {
          missingFields.add('Clasificación de IVA');
        }
      }

      // Si faltan campos, mostrar advertencia
      if (missingFields.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Campos Requeridos'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Los siguientes campos son obligatorios:'),
                const SizedBox(height: 8),
                ...missingFields.map((field) => Text('• $field')),
                const SizedBox(height: 16),
                if (hasIVAValues) ...[
                  const Text(
                    'Este registro tiene valores de IVA, por lo que requiere clasificaciones.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
        return;
      }

      final updatedData = <String, dynamic>{
        'tipoTercero': _selectedTipoTercero,
        'tipoOperacion': _selectedTipoOperacion,
        'clasificacionRegional': _selectedClasificacionRegional,
        'clasificacionIVA': _selectedClasificacionIVA,
        'efectosFiscales': _selectedEfectosFiscales,
        'numeroIdentificacionFiscal':
            _numeroIdentificacionController.text.trim(),
        'nombreExtranjero': _nombreExtranjeroController.text.trim(),
        'paisResidenciaFiscal': _selectedPais,
        'especificarJurisdiccion': _jurisdiccionController.text.trim(),
        'devoluciones': _devolucionesController.text.isNotEmpty
            ? double.tryParse(_devolucionesController.text) ?? 0
            : 0,
      };

      // Este callback se implementaría en el widget padre para manejar los datos
      widget.onSave?.call();

      Navigator.of(context).pop(updatedData);
    }
  }
}

/// Widget simplificado para edición rápida de un campo específico
class QuickFieldEditDialog extends StatefulWidget {
  final String title;
  final String currentValue;
  final String fieldType;
  final Function(String) onSave;

  const QuickFieldEditDialog({
    Key? key,
    required this.title,
    required this.currentValue,
    required this.fieldType,
    required this.onSave,
  }) : super(key: key);

  @override
  State<QuickFieldEditDialog> createState() => _QuickFieldEditDialogState();
}

class _QuickFieldEditDialogState extends State<QuickFieldEditDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar ${widget.title}'),
      content: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.title,
          border: const OutlineInputBorder(),
        ),
        keyboardType: widget.fieldType == 'number'
            ? TextInputType.number
            : TextInputType.text,
        inputFormatters: widget.fieldType == 'number'
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_controller.text);
            Navigator.of(context).pop();
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
