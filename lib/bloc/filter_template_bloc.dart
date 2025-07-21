import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:comparador_cfdis/bloc/filter_template_event.dart';
import 'package:comparador_cfdis/bloc/filter_template_state.dart';
import 'package:comparador_cfdis/services/filter_template_service.dart';

class FilterTemplateBloc
    extends Bloc<FilterTemplateEvent, FilterTemplateState> {
  final FilterTemplateService _templateService;

  FilterTemplateBloc(this._templateService) : super(FilterTemplateInitial()) {
    on<LoadFilterTemplates>(_onLoadFilterTemplates);
    on<CreateFilterTemplate>(_onCreateFilterTemplate);
    on<UpdateFilterTemplate>(_onUpdateFilterTemplate);
    on<DeleteFilterTemplate>(_onDeleteFilterTemplate);
    on<ToggleFilterTemplate>(_onToggleFilterTemplate);
    on<ApplyFilterTemplate>(_onApplyFilterTemplate);
    on<ClearAllTemplates>(_onClearAllTemplates);
  }

  Future<void> _onLoadFilterTemplates(
    LoadFilterTemplates event,
    Emitter<FilterTemplateState> emit,
  ) async {
    emit(FilterTemplateLoading());
    try {
      final templates = await _templateService.loadTemplates();
      final activeTemplates = templates.where((t) => t.isActive).toList();
      emit(
        FilterTemplateLoaded(
          templates: templates,
          activeTemplates: activeTemplates,
        ),
      );
    } catch (e) {
      emit(FilterTemplateError('Error cargando plantillas: ${e.toString()}'));
    }
  }

  Future<void> _onCreateFilterTemplate(
    CreateFilterTemplate event,
    Emitter<FilterTemplateState> emit,
  ) async {
    if (state is FilterTemplateLoaded) {
      try {
        await _templateService.saveTemplate(event.template);
        add(LoadFilterTemplates());
      } catch (e) {
        emit(FilterTemplateError('Error creando plantilla: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateFilterTemplate(
    UpdateFilterTemplate event,
    Emitter<FilterTemplateState> emit,
  ) async {
    if (state is FilterTemplateLoaded) {
      try {
        await _templateService.saveTemplate(event.template);
        add(LoadFilterTemplates());
      } catch (e) {
        emit(
          FilterTemplateError(
            'Error actualizando plantilla: ${e.toString()}',
          ),
        );
      }
    }
  }

  Future<void> _onDeleteFilterTemplate(
    DeleteFilterTemplate event,
    Emitter<FilterTemplateState> emit,
  ) async {
    if (state is FilterTemplateLoaded) {
      try {
        await _templateService.deleteTemplate(event.templateId);
        add(LoadFilterTemplates());
      } catch (e) {
        emit(
          FilterTemplateError('Error eliminando plantilla: ${e.toString()}'),
        );
      }
    }
  }

  Future<void> _onToggleFilterTemplate(
    ToggleFilterTemplate event,
    Emitter<FilterTemplateState> emit,
  ) async {
    if (state is FilterTemplateLoaded) {
      try {
        await _templateService.toggleTemplate(event.templateId, event.isActive);
        add(LoadFilterTemplates());
      } catch (e) {
        emit(
          FilterTemplateError(
            'Error cambiando estado de plantilla: ${e.toString()}',
          ),
        );
      }
    }
  }

  Future<void> _onApplyFilterTemplate(
    ApplyFilterTemplate event,
    Emitter<FilterTemplateState> emit,
  ) async {
    if (state is FilterTemplateLoaded) {
      final currentState = state as FilterTemplateLoaded;
      // TODO: Implementar la aplicación de filtros de plantilla
      // Se necesita integración con CFDIBloc

      // Por ahora, mantener el estado actual
      emit(currentState);
    }
  }

  Future<void> _onClearAllTemplates(
    ClearAllTemplates event,
    Emitter<FilterTemplateState> emit,
  ) async {
    if (state is FilterTemplateLoaded) {
      final currentState = state as FilterTemplateLoaded;
      try {
        // Desactivar todas las plantillas activas
        for (final template in currentState.activeTemplates) {
          await _templateService.toggleTemplate(template.id, false);
        }
        add(LoadFilterTemplates());
      } catch (e) {
        emit(
          FilterTemplateError('Error limpiando plantillas: ${e.toString()}'),
        );
      }
    }
  }
}
