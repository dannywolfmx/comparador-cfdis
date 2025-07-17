import 'package:comparador_cfdis/models/cfdi_information.dart';
import 'package:comparador_cfdis/models/filter.dart';
import 'package:comparador_cfdis/models/filter_forma_pago.dart';
import 'package:comparador_cfdis/models/filter_metodo_pago.dart';
import 'package:comparador_cfdis/models/filter_uso_de_cfdi.dart';
import 'package:comparador_cfdis/models/filter_tipo_comprobante.dart';
import 'package:comparador_cfdis/repositories/cfdi_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cfdi_event.dart';
import 'cfdi_state.dart';
import '../models/cfdi.dart';
import 'filter_template_bloc.dart';
import 'filter_template_event.dart';
import 'filter_template_state.dart';
import 'dart:async';

class CFDIBloc extends Bloc<CFDIEvent, CFDIState> {
  final CFDIRepository _repository;
  //List of filters options
  final Set<FilterOption> _filters;
  final FilterTemplateBloc _filterTemplateBloc;
  late StreamSubscription _filterTemplateSubscription;

  // Constructor factory para implementar singleton

  CFDIBloc(this._repository, this._filters, this._filterTemplateBloc)
      : super(CFDIInitial()) {
    on<LoadCFDIsFromDirectory>(_onLoadFromDirectory);
    on<LoadCFDIsFromFile>(_onLoadFromFile);
    on<FilterCFDIs>(_onFilter);
    on<ClearCFDIs>(_onClear);
    on<ClearFilters>(_onClearFilters);
    on<ApplyTemplateFilters>(_onApplyTemplateFilters);

    // Escuchar cambios en las plantillas de filtros
    _filterTemplateSubscription =
        _filterTemplateBloc.stream.listen((templateState) {
      if (templateState is FilterTemplateLoaded) {
        add(ApplyTemplateFilters(templateState.activeTemplates));
      }
    });
  }

  Future<void> _onFilter(FilterCFDIs event, Emitter<CFDIState> emit) async {
    if (state is CFDILoaded) {
      final filter = event.filter;

      // Sincronizar el estado del filtro con la selección
      if (_filters.contains(filter)) {
        _filters.remove(filter);
        // Actualizar el estado de selección
        _updateFilterSelection(filter, false);
      } else {
        _filters.add(filter);
        // Actualizar el estado de selección
        _updateFilterSelection(filter, true);
      }

      // Apply all filters
      List<CFDI> cfdis = await FilterFactory(_filters).apply(_repository.cfdis);
      //GET CFDI information
      final cfdiInformation = calculateTotals(cfdis);
      emit(CFDILoaded(cfdis, cfdiInformation,
          stateManager: (state as CFDILoaded).stateManager));
    }
  }

  void _updateFilterSelection(FilterOption filter, bool selected) {
    if (filter is FormaPago) {
      try {
        final formaPago = formasDePago.firstWhere((f) => f.id == filter.id);
        formaPago.seleccionado = selected;
      } catch (e) {
        // Filtro no encontrado, ignorar
      }
    } else if (filter is MetodoPago) {
      try {
        final metodoPago = metodosDePago.firstWhere((m) => m.id == filter.id);
        metodoPago.seleccionado = selected;
      } catch (e) {
        // Filtro no encontrado, ignorar
      }
    } else if (filter is UsoDeCFDI) {
      try {
        final usoCFDI = usosDeCFDI.firstWhere((u) => u.id == filter.id);
        usoCFDI.seleccionado = selected;
      } catch (e) {
        // Filtro no encontrado, ignorar
      }
    } else if (filter is TipoComprobante) {
      try {
        final tipoComprobante =
            tiposDeComprobante.firstWhere((t) => t.id == filter.id);
        tipoComprobante.seleccionado = selected;
      } catch (e) {
        // Filtro no encontrado, ignorar
      }
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
      final cfdis = await _repository.loadCFDIFromFile();
      if (cfdis.isNotEmpty) {
        final cfdiInformation = calculateTotals(cfdis);
        emit(CFDILoaded(cfdis, cfdiInformation));
      } else {
        emit(CFDIError(
            'No se pudo cargar el CFDI')); // Simplified error handling
      }
    } catch (e) {
      emit(CFDIError('Error al cargar el CFDI: $e'));
    }
  }

  void _onClear(ClearCFDIs event, Emitter<CFDIState> emit) {
    _repository.clearCFDIs();
    emit(CFDIInitial());
  }

  Future<void> _onClearFilters(
      ClearFilters event, Emitter<CFDIState> emit) async {
    if (state is CFDILoaded) {
      // Limpiar todos los filtros
      _filters.clear();

      // Limpiar estado de selección en todas las opciones de filtro
      _clearAllFilterSelections();

      // Desactivar todas las plantillas activas
      _filterTemplateBloc.add(ClearAllTemplates());

      // Mostrar todos los CFDIs sin filtros
      final cfdiInformation = calculateTotals(_repository.cfdis);
      emit(CFDILoaded(_repository.cfdis, cfdiInformation,
          stateManager: (state as CFDILoaded).stateManager));
    }
  }

  void _clearAllFilterSelections() {
    // Limpiar selecciones de forma de pago
    for (var forma in formasDePago) {
      forma.seleccionado = false;
    }
    // Limpiar selecciones de método de pago
    for (var metodo in metodosDePago) {
      metodo.seleccionado = false;
    }
    // Limpiar selecciones de uso de CFDI
    for (var uso in usosDeCFDI) {
      uso.seleccionado = false;
    }
    // Limpiar selecciones de tipo de comprobante
    for (var tipo in tiposDeComprobante) {
      tipo.seleccionado = false;
    }
  }

  Future<void> _onApplyTemplateFilters(
      ApplyTemplateFilters event, Emitter<CFDIState> emit) async {
    if (state is CFDILoaded) {
      // Primero, limpiar todas las selecciones visuales
      _clearAllFilterSelections();

      // Crear un set con todos los filtros activos (manuales + plantillas)
      Set<FilterOption> allFilters = Set.from(_filters);

      // Agregar filtros de plantillas activas y actualizar estado visual
      for (final template in event.activeTemplates) {
        allFilters.addAll(template.filters);
        // Actualizar el estado visual de cada filtro de la plantilla
        for (final filter in template.filters) {
          _updateFilterSelection(filter, true);
        }
      }

      // También actualizar el estado visual de los filtros manuales
      for (final filter in _filters) {
        _updateFilterSelection(filter, true);
      }

      // Aplicar todos los filtros
      List<CFDI> cfdis =
          await FilterFactory(allFilters).apply(_repository.cfdis);
      final cfdiInformation = calculateTotals(cfdis);
      emit(CFDILoaded(cfdis, cfdiInformation,
          stateManager: (state as CFDILoaded).stateManager));
    }
  }

  @override
  Future<void> close() {
    _filterTemplateSubscription.cancel();
    return super.close();
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
