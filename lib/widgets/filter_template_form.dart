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
  final _searchController = TextEditingController();

  late Color _selectedColor;
  late Set<FilterOption> _selectedFilters;
  String _searchQuery = '';

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 800;
    final isExtraLargeScreen = screenSize.width > 1200;

    // Dimensionamiento más inteligente y responsivo
    final double maxWidth;
    if (isExtraLargeScreen) {
      // En pantallas muy grandes, usar hasta 900px pero no más del 70% del ancho
      maxWidth = (screenSize.width * 0.7).clamp(600.0, 900.0);
    } else if (isLargeScreen) {
      // En pantallas grandes, usar entre 600-800px o el 80% del ancho
      maxWidth = (screenSize.width * 0.8).clamp(600.0, 800.0);
    } else {
      // En pantallas pequeñas, usar el 95% del ancho con un mínimo de 300px
      maxWidth = (screenSize.width * 0.95).clamp(300.0, 600.0);
    }

    final maxHeight = (screenSize.height * 0.85).clamp(400.0, 800.0);

    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.template != null ? Icons.edit : Icons.add,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.template != null
                          ? 'Editar Plantilla'
                          : 'Crear Plantilla',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Form(
                key: _formKey,
                child: maxWidth > 650
                    ? _buildLargeScreenLayout()
                    : _buildCompactLayout(),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed:
                        _selectedFilters.isNotEmpty ? _saveTemplate : null,
                    child:
                        Text(widget.template != null ? 'Actualizar' : 'Crear'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeScreenLayout() {
    final screenSize = MediaQuery.of(context).size;
    final isExtraWide = screenSize.width > 1000;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel izquierdo - Información básica
          Expanded(
            flex: isExtraWide ? 2 : 1,
            child: Container(
              constraints: const BoxConstraints(minWidth: 200),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildColorSection(),
                    const SizedBox(height: 24),
                    _buildSelectedFiltersSection(),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(width: isExtraWide ? 32 : 24),

          // Panel derecho - Selección de filtros
          Expanded(
            flex: isExtraWide ? 3 : 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seleccionar Filtros:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: _buildFilterSections(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfoSection(),
          const SizedBox(height: 24),
          _buildColorSection(),
          const SizedBox(height: 24),
          Text(
            'Seleccionar Filtros:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView(
              shrinkWrap: true,
              children: _buildFilterSections(),
            ),
          ),
          const SizedBox(height: 24),
          _buildSelectedFiltersSection(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información Básica:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre de la plantilla',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.label),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es requerido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La descripción es requerida';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    final screenSize = MediaQuery.of(context).size;
    final isWideDialog = screenSize.width > 1000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color de la Plantilla:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: isWideDialog ? 16 : 12,
          runSpacing: isWideDialog ? 16 : 12,
          children: _availableColors.map((color) {
            final isSelected = _selectedColor == color;
            final colorSize = isWideDialog ? 52.0 : 48.0;

            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                width: colorSize,
                height: colorSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: isWideDialog ? 28 : 24,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSelectedFiltersSection() {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: _selectedColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filtros Seleccionados',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _selectedColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedFilters.length}',
                    style: TextStyle(
                      color: _selectedColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedFilters.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _selectedFilters.map((filter) {
                        return Material(
                          color: _selectedColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              setState(() {
                                _selectedFilters.remove(filter);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color:
                                          _selectedColor.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      filter.id,
                                      style: TextStyle(
                                        color: _selectedColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    filter.nombre,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.close,
                                    size: 14,
                                    color: _selectedColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Selecciona al menos un filtro para crear la plantilla',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFilterSections() {
    final theme = Theme.of(context);
    final sections = <String, List<FilterOption>>{
      'Tipos de Comprobante':
          _availableFilters.whereType<TipoComprobante>().toList(),
      'Formas de Pago': _availableFilters.whereType<FormaPago>().toList(),
      'Métodos de Pago': _availableFilters.whereType<MetodoPago>().toList(),
      'Usos de CFDI': _availableFilters.whereType<UsoDeCFDI>().toList(),
    };

    return [
      // Campo de búsqueda
      Card(
        color: theme.colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Buscar filtros...',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              isDense: true,
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      // Secciones de filtros
      ...sections.entries.map((entry) {
        // Filtrar los elementos según la búsqueda
        final filteredItems = entry.value
            .where(
              (filter) =>
                  _searchQuery.isEmpty ||
                  filter.nombre.toLowerCase().contains(_searchQuery) ||
                  filter.id.toLowerCase().contains(_searchQuery),
            )
            .toList();

        // Solo mostrar la sección si hay elementos que coincidan con la búsqueda
        if (filteredItems.isEmpty && _searchQuery.isNotEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: theme.colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: ExpansionTile(
            title: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _selectedColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${filteredItems.where((f) => _selectedFilters.contains(f)).length}/${filteredItems.length}',
                    style: TextStyle(
                      color: _selectedColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            childrenPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            initiallyExpanded:
                filteredItems.any((f) => _selectedFilters.contains(f)) ||
                    _searchQuery.isNotEmpty,
            children: [
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: Scrollbar(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final filter = filteredItems[index];
                      final isSelected = _selectedFilters.contains(filter);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 1, horizontal: 4),
                        color: isSelected
                            ? _selectedColor.withValues(alpha: 0.1)
                            : theme.colorScheme.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: isSelected
                              ? BorderSide(
                                  color: _selectedColor.withValues(alpha: 0.3),
                                  width: 1,
                                )
                              : BorderSide(
                                  color: theme.colorScheme.outline
                                      .withValues(alpha: 0.1),
                                  width: 1,
                                ),
                        ),
                        child: CheckboxListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _selectedColor.withValues(alpha: 0.2)
                                      : theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  filter.id,
                                  style: TextStyle(
                                    color: isSelected
                                        ? _selectedColor
                                        : theme
                                            .colorScheme.onSecondaryContainer,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  filter.nombre,
                                  style: TextStyle(
                                    color: isSelected
                                        ? theme.colorScheme.onSurface
                                        : theme.colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          value: isSelected,
                          activeColor: _selectedColor,
                          checkColor: theme.colorScheme.onPrimary,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedFilters.add(filter);
                              } else {
                                _selectedFilters.remove(filter);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ];
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
