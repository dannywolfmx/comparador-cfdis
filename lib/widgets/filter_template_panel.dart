import 'package:comparador_cfdis/bloc/filter_template_bloc.dart';
import 'package:comparador_cfdis/bloc/filter_template_event.dart';
import 'package:comparador_cfdis/bloc/filter_template_state.dart';
import 'package:comparador_cfdis/models/filter_template.dart';
import 'package:comparador_cfdis/widgets/filter_template_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterTemplatePanel extends StatefulWidget {
  const FilterTemplatePanel({super.key});

  @override
  State<FilterTemplatePanel> createState() => _FilterTemplatePanelState();
}

class _FilterTemplatePanelState extends State<FilterTemplatePanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterTemplateBloc, FilterTemplateState>(
      builder: (context, state) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          elevation: 0,
          color: Colors.white.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              // Encabezado del panel
              ListTile(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(
                  Icons.filter_list_alt,
                  color: Colors.white,
                  size: 20,
                ),
                title: const Text(
                  'Plantillas de Filtros',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: state is FilterTemplateLoaded
                    ? Text(
                        '${state.activeTemplates.length} activas de ${state.templates.length}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      )
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón para crear nueva plantilla
                    IconButton(
                      icon:
                          const Icon(Icons.add, color: Colors.white, size: 18),
                      onPressed: () => _showCreateTemplateDialog(context),
                      tooltip: 'Crear nueva plantilla',
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    // Botón para limpiar todas las plantillas
                    if (state is FilterTemplateLoaded &&
                        state.activeTemplates.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear_all,
                            color: Colors.white, size: 18),
                        onPressed: () {
                          final filterTemplateBloc =
                              context.read<FilterTemplateBloc>();
                          _clearAllTemplates(context, filterTemplateBloc);
                        },
                        tooltip: 'Limpiar todas las plantillas',
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    // Icono de expansión
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),

              // Contenido expandible
              if (_isExpanded)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: _buildTemplateContent(context, state),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTemplateContent(
      BuildContext context, FilterTemplateState state) {
    if (state is FilterTemplateLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    if (state is FilterTemplateError) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          state.message,
          style: const TextStyle(color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (state is FilterTemplateLoaded) {
      if (state.templates.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No hay plantillas disponibles',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Plantillas activas
            if (state.activeTemplates.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Activas',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ...state.activeTemplates.map(
                  (template) => _buildTemplateCard(context, template, true)),
              const SizedBox(height: 8),
            ],

            // Plantillas inactivas
            if (state.templates.where((t) => !t.isActive).isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Disponibles',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ...state.templates.where((t) => !t.isActive).map(
                  (template) => _buildTemplateCard(context, template, false)),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTemplateCard(
      BuildContext context, FilterTemplate template, bool isActive) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: isActive
          ? template.color.withValues(alpha: 0.2)
          : Colors.white.withValues(alpha: 0.05),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: template.color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        title: Text(
          template.name,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          '${template.filters.length} filtros',
          style: TextStyle(
            color: isActive ? Colors.white70 : Colors.white54,
            fontSize: 11,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Switch para activar/desactivar
            Switch(
              value: isActive,
              onChanged: (value) {
                context.read<FilterTemplateBloc>().add(
                      ToggleFilterTemplate(template.id, value),
                    );
              },
              activeColor: template.color,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            // Menú de opciones
            PopupMenuButton<String>(
              icon:
                  const Icon(Icons.more_vert, color: Colors.white54, size: 16),
              onSelected: (value) =>
                  _handleTemplateAction(context, template, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 16),
                      SizedBox(width: 8),
                      Text('Duplicar'),
                    ],
                  ),
                ),
                if (!template.id.startsWith('predefined_'))
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleTemplateAction(
      BuildContext context, FilterTemplate template, String action) {
    final filterTemplateBloc = context.read<FilterTemplateBloc>();

    switch (action) {
      case 'edit':
        _showEditTemplateDialog(context, template, filterTemplateBloc);
        break;
      case 'duplicate':
        _duplicateTemplate(template, filterTemplateBloc);
        break;
      case 'delete':
        _showDeleteConfirmation(context, template, filterTemplateBloc);
        break;
    }
  }

  void _showCreateTemplateDialog(BuildContext context) {
    final filterTemplateBloc = context.read<FilterTemplateBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: filterTemplateBloc,
        child: const FilterTemplateForm(),
      ),
    );
  }

  void _showEditTemplateDialog(BuildContext context, FilterTemplate template,
      FilterTemplateBloc filterTemplateBloc) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: filterTemplateBloc,
        child: FilterTemplateForm(template: template),
      ),
    );
  }

  void _duplicateTemplate(
      FilterTemplate template, FilterTemplateBloc filterTemplateBloc) {
    final duplicatedTemplate = template.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${template.name} (Copia)',
      isActive: false,
    );

    filterTemplateBloc.add(
      CreateFilterTemplate(duplicatedTemplate),
    );
  }

  void _showDeleteConfirmation(BuildContext context, FilterTemplate template,
      FilterTemplateBloc filterTemplateBloc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
            '¿Estás seguro de que quieres eliminar la plantilla "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              filterTemplateBloc.add(
                DeleteFilterTemplate(template.id),
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _clearAllTemplates(
      BuildContext context, FilterTemplateBloc filterTemplateBloc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpiar todas las plantillas'),
        content: const Text(
            '¿Estás seguro de que quieres desactivar todas las plantillas activas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              filterTemplateBloc.add(ClearAllTemplates());
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}
