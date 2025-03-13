import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/cfdi_parser.dart';
import 'cfdi_event.dart';
import 'cfdi_state.dart';
import '../models/cfdi.dart';

class CFDIBloc extends Bloc<CFDIEvent, CFDIState> {
  // Instancia singleton
  static CFDIBloc? _instance;

  // Constructor factory para implementar singleton
  factory CFDIBloc() {
    _instance ??= CFDIBloc._internal();
    return _instance!;
  }

  // Constructor privado interno
  CFDIBloc._internal() : super(CFDIInitial()) {
    on<LoadCFDIsFromDirectory>(_onLoadFromDirectory);
    on<LoadCFDIsFromFile>(_onLoadFromFile);
    on<ClearCFDIs>(_onClear);
  }

  Future<void> _onLoadFromDirectory(
    LoadCFDIsFromDirectory event,
    Emitter<CFDIState> emit,
  ) async {
    emit(CFDILoading());

    try {
      final cfdis = await CFDIParser.parseDirectoryCFDIs();
      if (cfdis.isEmpty) {
        emit(
            CFDIError('No se encontraron CFDIs en el directorio seleccionado'));
      } else {
        emit(CFDILoaded(cfdis));
      }
    } catch (e) {
      emit(CFDIError('Error al cargar los CFDIs: $e'));
    }
  }

  Future<void> _onLoadFromFile(
    LoadCFDIsFromFile event,
    Emitter<CFDIState> emit,
  ) async {
    emit(CFDILoading());

    try {
      final cfdi = await CFDIParser.pickAndParseXml();
      if (cfdi != null) {
        emit(CFDILoaded([cfdi]));
      } else {
        if (state is CFDILoaded) {
          // Mantener el estado actual si ya hay CFDIs cargados
          emit(state);
        } else {
          emit(CFDIError('No se pudo cargar el CFDI'));
        }
      }
    } catch (e) {
      emit(CFDIError('Error al cargar el CFDI: $e'));
    }
  }

  void _onClear(ClearCFDIs event, Emitter<CFDIState> emit) {
    emit(CFDIInitial());
  }

  // Método para buscar un CFDI por UUID en la lista singleton
  static CFDI? findCFDIByUUID(String uuid, List<CFDI> cfdis) {
    final normalizedUuid = uuid.trim().toUpperCase();
    return cfdis.firstWhere(
      (cfdi) => cfdi.timbreFiscalDigital?.uuid?.toUpperCase() == normalizedUuid,
      orElse: () => CFDI(),
    );
  }
}
