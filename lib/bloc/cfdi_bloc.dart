import 'package:comparador_cfdis/models/cfdi_information.dart';
import 'package:comparador_cfdis/models/filter.dart';
import 'package:comparador_cfdis/repositories/cfdi_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cfdi_event.dart';
import 'cfdi_state.dart';
import '../models/cfdi.dart';

class CFDIBloc extends Bloc<CFDIEvent, CFDIState> {
  final CFDIRepository _repository;
  //List of filters options
  final Set<FilterOption> _filters;

  // Constructor factory para implementar singleton

  CFDIBloc(this._repository, this._filters) : super(CFDIInitial()) {
    on<LoadCFDIsFromDirectory>(_onLoadFromDirectory);
    on<LoadCFDIsFromFile>(_onLoadFromFile);
    on<FilterCFDIs>(_onFilter);
    on<ClearCFDIs>(_onClear);
  }

  Future<void> _onFilter(FilterCFDIs event, Emitter<CFDIState> emit) async {
    if (state is CFDILoaded) {
      final filter = event.filter;

      if (_filters.contains(filter)) {
        _filters.remove(filter);
      } else {
        _filters.add(filter);
      }

      // Apply all filters
      List<CFDI> cfdis = await FilterFactory(_filters).apply(_repository.cfdis);
      //GET CFDI information
      final cfdiInformation = calculateTotals(cfdis);
      emit(CFDILoaded(cfdis, cfdiInformation,
          stateManager: (state as CFDILoaded).stateManager));
    }
  }

  Future<void> _onLoadFromDirectory(
    LoadCFDIsFromDirectory event,
    Emitter<CFDIState> emit,
  ) async {
    emit(CFDILoading());

    try {
      final cfdis = await _repository.loadCFDIsFromDirectory();
      if (cfdis.isEmpty) {
        emit(
            CFDIError('No se encontraron CFDIs en el directorio seleccionado'));
      } else {
        final cfdiInformation = calculateTotals(cfdis);
        emit(CFDILoaded(cfdis, cfdiInformation));
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
      final cfdi = await _repository.loadCFDIFromFile();
      if (cfdi != null) {
        final cfdiInformation = calculateTotals([cfdi]);
        emit(CFDILoaded([cfdi], cfdiInformation));
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
    _repository.clearCFDIs();
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

  // calculate the subtotal, discount and total of the CFDIs
  static CFDIInformation calculateTotals(List<CFDI> cfdis) {
    final subtotal = cfdis.fold<double>(0, (prev, cfdi) {
      double tipoCambio = double.tryParse(cfdi.tipoCambio ?? '1') ?? 1;
      double valor = double.tryParse(cfdi.subTotal ?? '0') ?? 0;
      return prev + (tipoCambio > 1 ? valor * tipoCambio : valor);
    });
    final descuento = cfdis.fold<double>(0, (prev, cfdi) {
      double tipoCambio = double.tryParse(cfdi.tipoCambio ?? '1') ?? 1;
      double valor = double.tryParse(cfdi.descuento ?? '0') ?? 0;
      return prev + (tipoCambio > 1 ? valor * tipoCambio : valor);
    });
    final total = cfdis.fold<double>(0, (prev, cfdi) {
      double tipoCambio = double.tryParse(cfdi.tipoCambio ?? '1') ?? 1;
      double valor = double.tryParse(cfdi.total ?? '0') ?? 0;
      return prev + (tipoCambio > 1 ? valor * tipoCambio : valor);
    });

    return CFDIInformation(
        subtotal: subtotal, descuento: descuento, total: total);
  }
}
