import 'package:comparador_cfdis/models/filter_template.dart';
import 'package:equatable/equatable.dart';

abstract class FilterTemplateEvent extends Equatable {
  const FilterTemplateEvent();

  @override
  List<Object?> get props => [];
}

class LoadFilterTemplates extends FilterTemplateEvent {}

class CreateFilterTemplate extends FilterTemplateEvent {
  final FilterTemplate template;

  const CreateFilterTemplate(this.template);

  @override
  List<Object> get props => [template];
}

class UpdateFilterTemplate extends FilterTemplateEvent {
  final FilterTemplate template;

  const UpdateFilterTemplate(this.template);

  @override
  List<Object> get props => [template];
}

class DeleteFilterTemplate extends FilterTemplateEvent {
  final String templateId;

  const DeleteFilterTemplate(this.templateId);

  @override
  List<Object> get props => [templateId];
}

class ToggleFilterTemplate extends FilterTemplateEvent {
  final String templateId;
  final bool isActive;

  const ToggleFilterTemplate(this.templateId, this.isActive);

  @override
  List<Object> get props => [templateId, isActive];
}

class ApplyFilterTemplate extends FilterTemplateEvent {
  final String templateId;

  const ApplyFilterTemplate(this.templateId);

  @override
  List<Object> get props => [templateId];
}

class ClearAllTemplates extends FilterTemplateEvent {}
