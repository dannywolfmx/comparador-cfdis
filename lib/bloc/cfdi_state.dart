import '../models/cfdi.dart';

abstract class CFDIState {}

class CFDIInitial extends CFDIState {}

class CFDILoading extends CFDIState {}

class CFDILoaded extends CFDIState {
  final List<CFDI> cfdis;

  CFDILoaded(this.cfdis);
}

class CFDIError extends CFDIState {
  final String message;

  CFDIError(this.message);
}
