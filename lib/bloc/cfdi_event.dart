import 'package:comparador_cfdis/models/filter.dart';

abstract class CFDIEvent {}

class LoadCFDIsFromDirectory extends CFDIEvent {}

class LoadCFDIsFromFile extends CFDIEvent {}

class FilterCFDIs extends CFDIEvent {
  final FilterOption filter;

  FilterCFDIs(this.filter);
}

class ClearCFDIs extends CFDIEvent {}
