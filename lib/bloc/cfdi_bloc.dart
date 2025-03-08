import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/cfdi_parser.dart';
import 'cfdi_event.dart';
import 'cfdi_state.dart';

class CFDIBloc extends Bloc<CFDIEvent, CFDIState> {
  CFDIBloc() : super(CFDIInitial()) {
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
        // Si ya hay CFDIs cargados, añadir el nuevo
        if (state is CFDILoaded) {
          final currentCfdis = (state as CFDILoaded).cfdis;
          emit(CFDILoaded([...currentCfdis, cfdi]));
        } else {
          emit(CFDILoaded([cfdi]));
        }
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
}
