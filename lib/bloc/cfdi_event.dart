import 'package:comparador_cfdis/models/filter.dart';
import 'package:comparador_cfdis/models/filter_template.dart';
import 'package:pluto_grid/pluto_grid.dart';

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

class ApplyDateRangeFilter extends CFDIEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  ApplyDateRangeFilter(this.startDate, this.endDate);
}

class UpdateStateManager extends CFDIEvent {
  final PlutoGridStateManager stateManager;

  UpdateStateManager(this.stateManager);
}

class SearchGlobal extends CFDIEvent {
  final String query;

  SearchGlobal(this.query);
}

class ClearGlobalSearch extends CFDIEvent {}