import 'package:comparador_cfdis/bloc/filter_template_bloc.dart';
import 'package:comparador_cfdis/bloc/filter_template_event.dart';
import 'package:comparador_cfdis/models/filter_template.dart';
import 'package:comparador_cfdis/models/filter.dart';
import 'package:comparador_cfdis/models/filter_forma_pago.dart';
import 'package:comparador_cfdis/models/filter_metodo_pago.dart';
import 'package:comparador_cfdis/models/filter_tipo_comprobante.dart';
import 'package:comparador_cfdis/models/filter_uso_de_cfdi.dart';
import 'package:comparador_cfdis/services/filter_template_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterTemplateForm extends StatefulWidget {
  final FilterTemplate? template;

  const FilterTemplateForm({super.key, this.template});

  @override
  State<FilterTemplateForm> createState() => _FilterTemplateFormState();
}

class _FilterTemplateFormState extends State<FilterTemplateForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  late Color _selectedColor;
  late Set<FilterOption> _selectedFilters;

  // Opciones de filtros disponibles
  final List<FilterOption> _availableFilters = [
    // Tipos de comprobante
    TipoComprobante('I', 'Ingreso'),
    TipoComprobante('E', 'Egreso'),
    TipoComprobante('T', 'Traslado'),
    TipoComprobante('N', 'Nómina'),
    TipoComprobante('P', 'Pago'),

    // Formas de pago más comunes
    FormaPago('01', 'Efectivo'),
    FormaPago('02', 'Cheque nominativo'),
    FormaPago('03', 'Transferencia electrónica'),
    FormaPago('04', 'Tarjeta de crédito'),
    FormaPago('05', 'Monedero electrónico'),
    FormaPago('99', 'Por definir'),

    // Métodos de pago
    MetodoPago('PUE', 'Pago en una sola exhibición'),
    MetodoPago('PPD', 'Pago en parcialidades o diferido'),

    // Usos de CFDI más comunes
    UsoDeCFDI('G01', 'Adquisición de mercancías'),
    UsoDeCFDI('G02', 'Devoluciones, descuentos o bonificaciones'),
    UsoDeCFDI('G03', 'Gastos en general'),
    UsoDeCFDI('I01', 'Construcciones'),
    UsoDeCFDI('I02', 'Mobilario y equipo de oficina'),
    UsoDeCFDI('I03', 'Equipo de transporte'),
    UsoDeCFDI('P01', 'Por definir'),
  ];

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilters = <FilterOption>{};
    _selectedColor = Colors.blue;

    if (widget.template != null) {
      _nameController.text = widget.template!.name;
      _descriptionController.text = widget.template!.description;
      _selectedColor = widget.template!.color;
      _selectedFilters = Set.from(widget.template!.filters);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.template != null ? 'Editar Plantilla' : 'Crear Plantilla',
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la plantilla',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Descripción
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La descripción es requerida';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Color
                const Text(
                  'Color:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableColors.map((color) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColor == color
                                ? Colors.black
                                : Colors.grey,
                            width: _selectedColor == color ? 3 : 1,
                          ),
                        ),
                        child: _selectedColor == color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Filtros
                const Text(
                  'Filtros:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView(
                    shrinkWrap: true,
                    children: _buildFilterSections(),
                  ),
                ),

                const SizedBox(height: 16),

                // Resumen de filtros seleccionados
                if (_selectedFilters.isNotEmpty) ...[
                  const Text(
                    'Filtros seleccionados:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: _selectedFilters.map((filter) {
                      return Chip(
                        label: Text(
                          filter.nombre,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: _selectedColor.withValues(alpha: 0.2),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _selectedFilters.remove(filter);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _selectedFilters.isNotEmpty ? _saveTemplate : null,
          child: Text(widget.template != null ? 'Actualizar' : 'Crear'),
        ),
      ],
    );
  }

  List<Widget> _buildFilterSections() {
    final sections = <String, List<FilterOption>>{
      'Tipos de Comprobante':
          _availableFilters.whereType<TipoComprobante>().toList(),
      'Formas de Pago': _availableFilters.whereType<FormaPago>().toList(),
      'Métodos de Pago': _availableFilters.whereType<MetodoPago>().toList(),
      'Usos de CFDI': _availableFilters.whereType<UsoDeCFDI>().toList(),
    };

    return sections.entries.map((entry) {
      return ExpansionTile(
        title: Text(
          entry.key,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: entry.value.any((f) => _selectedFilters.contains(f)),
        children: entry.value.map((filter) {
          return CheckboxListTile(
            title: Text(filter.nombre),
            subtitle: Text(filter.id),
            value: _selectedFilters.contains(filter),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedFilters.add(filter);
                } else {
                  _selectedFilters.remove(filter);
                }
              });
            },
          );
        }).toList(),
      );
    }).toList();
  }

  void _saveTemplate() {
    if (_formKey.currentState!.validate()) {
      final templateService = FilterTemplateService();

      final FilterTemplate template;
      if (widget.template != null) {
        template = widget.template!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          filters: _selectedFilters,
          color: _selectedColor,
        );
        context.read<FilterTemplateBloc>().add(UpdateFilterTemplate(template));
      } else {
        template = templateService.createTemplate(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          filters: _selectedFilters,
          color: _selectedColor,
        );
        context.read<FilterTemplateBloc>().add(CreateFilterTemplate(template));
      }

      Navigator.of(context).pop();
    }
  }
}
