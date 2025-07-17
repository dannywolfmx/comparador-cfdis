import 'package:comparador_cfdis/models/filter.dart';
import 'package:comparador_cfdis/models/filter_template.dart';

abstract class CFDIEvent {}

class LoadCFDIsFromDirectory extends CFDIEvent {}

class LoadCFDIsFromFile extends CFDIEvent {}

class FilterCFDIs extends CFDIEvent {
  final FilterOption filter;

  FilterCFDIs(this.filter);
}

class ClearCFDIs extends CFDIEvent {}

class ClearFilters extends CFDIEvent {}

class ApplyTemplateFilters extends CFDIEvent {
  final List<FilterTemplate> activeTemplates;

  ApplyTemplateFilters(this.activeTemplates);
}
