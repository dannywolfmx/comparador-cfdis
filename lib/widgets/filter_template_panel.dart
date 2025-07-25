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
    final theme = Theme.of(context);

    return BlocBuilder<FilterTemplateBloc, FilterTemplateState>(
      builder: (context, state) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 2),
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Encabezado del panel - similar a los filtros expandibles
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list_alt,
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Plantillas de Filtros',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Botones de acción
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botón para crear nueva plantilla
                            IconButton(
                              icon: Icon(
                                Icons.add,
                                color: theme.colorScheme.primary,
                                size: 16,
                              ),
                              onPressed: () =>
                                  _showCreateTemplateDialog(context),
                              tooltip: 'Crear nueva plantilla',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                            // Botón para limpiar todas las plantillas
                            if (state is FilterTemplateLoaded &&
                                state.activeTemplates.isNotEmpty)
                              IconButton(
                                icon: Icon(
                                  Icons.clear_all,
                                  color: theme.colorScheme.error,
                                  size: 16,
                                ),
                                onPressed: () {
                                  final filterTemplateBloc =
                                      context.read<FilterTemplateBloc>();
                                  _clearAllTemplates(
                                      context, filterTemplateBloc);
                                },
                                tooltip: 'Limpiar todas las plantillas',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            // Icono de expansión
                            AnimatedRotation(
                              turns: _isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.expand_more,
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Contenido expandible
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: _isExpanded
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: _buildTemplateContent(context, state),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTemplateContent(
    BuildContext context,
    FilterTemplateState state,
  ) {
    final theme = Theme.of(context);

    if (state is FilterTemplateLoading) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
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
          style: TextStyle(
            color: theme.colorScheme.error,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (state is FilterTemplateLoaded) {
      if (state.templates.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No hay plantillas disponibles',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plantillas activas
          if (state.activeTemplates.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'Activas',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...state.activeTemplates.map(
              (template) => _buildTemplateCard(context, template, true),
            ),
            const SizedBox(height: 8),
          ],

          // Plantillas inactivas
          if (state.templates.where((t) => !t.isActive).isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'Disponibles',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...state.templates.where((t) => !t.isActive).map(
                  (template) => _buildTemplateCard(context, template, false),
                ),
          ],
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTemplateCard(
    BuildContext context,
    FilterTemplate template,
    bool isActive,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
      decoration: BoxDecoration(
        color: isActive
            ? template.color.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
        border: isActive
            ? Border.all(
                color: template.color.withValues(alpha: 0.3),
                width: 1,
              )
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        leading: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: template.color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          template.name,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isActive
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
        subtitle: Text(
          '${template.filters.length} filtros',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Switch para activar/desactivar
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: isActive,
                onChanged: (value) {
                  context.read<FilterTemplateBloc>().add(
                        ToggleFilterTemplate(template.id, value),
                      );
                },
                activeColor: template.color,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            // Menú de opciones
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: theme.colorScheme.onSurfaceVariant,
                size: 14,
              ),
              onSelected: (value) =>
                  _handleTemplateAction(context, template, value),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        size: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Editar',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(
                        Icons.copy,
                        size: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Duplicar',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!template.id.startsWith('predefined_'))
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          size: 14,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Eliminar',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.error,
                          ),
                        ),
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
    BuildContext context,
    FilterTemplate template,
    String action,
  ) {
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

  void _showEditTemplateDialog(
    BuildContext context,
    FilterTemplate template,
    FilterTemplateBloc filterTemplateBloc,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: filterTemplateBloc,
        child: FilterTemplateForm(template: template),
      ),
    );
  }

  void _duplicateTemplate(
    FilterTemplate template,
    FilterTemplateBloc filterTemplateBloc,
  ) {
    final duplicatedTemplate = template.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${template.name} (Copia)',
      isActive: false,
    );

    filterTemplateBloc.add(
      CreateFilterTemplate(duplicatedTemplate),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    FilterTemplate template,
    FilterTemplateBloc filterTemplateBloc,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar la plantilla "${template.name}"?',
        ),
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
    BuildContext context,
    FilterTemplateBloc filterTemplateBloc,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpiar todas las plantillas'),
        content: const Text(
          '¿Estás seguro de que quieres desactivar todas las plantillas activas?',
        ),
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
