import 'package:comparador_cfdis/models/filter_template.dart';
import 'package:equatable/equatable.dart';

abstract class FilterTemplateState extends Equatable {
  const FilterTemplateState();

  @override
  List<Object?> get props => [];
}

class FilterTemplateInitial extends FilterTemplateState {}

class FilterTemplateLoading extends FilterTemplateState {}

class FilterTemplateLoaded extends FilterTemplateState {
  final List<FilterTemplate> templates;
  final List<FilterTemplate> activeTemplates;

  const FilterTemplateLoaded({
    required this.templates,
    required this.activeTemplates,
  });

  @override
  List<Object> get props => [templates, activeTemplates];

  FilterTemplateLoaded copyWith({
    List<FilterTemplate>? templates,
    List<FilterTemplate>? activeTemplates,
  }) {
    return FilterTemplateLoaded(
      templates: templates ?? this.templates,
      activeTemplates: activeTemplates ?? this.activeTemplates,
    );
  }
}

class FilterTemplateError extends FilterTemplateState {
  final String message;

  const FilterTemplateError(this.message);

  @override
  List<Object> get props => [message];
}
