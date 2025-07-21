import 'package:comparador_cfdis/models/cfdi_information.dart';
import 'package:comparador_cfdis/models/filter.dart';
import 'package:comparador_cfdis/models/filter_forma_pago.dart';
import 'package:comparador_cfdis/models/filter_metodo_pago.dart';
import 'package:comparador_cfdis/models/filter_uso_de_cfdi.dart';
import 'package:comparador_cfdis/models/filter_tipo_comprobante.dart';
import 'package:comparador_cfdis/models/filter_date_range.dart';
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
  final Set<FilterOption> _manualFilters;
  final FilterTemplateBloc _filterTemplateBloc;
  late StreamSubscription _filterTemplateSubscription;
  DateTime? _startDate;
  DateTime? _endDate;

  CFDIBloc(this._repository, this._manualFilters, this._filterTemplateBloc)
      : super(CFDIInitial()) {
    on<LoadCFDIsFromDirectory>(_onLoadFromDirectory);
    on<LoadCFDIsFromFile>(_onLoadFromFile);
    on<FilterCFDIs>(_onFilter);
    on<ClearCFDIs>(_onClear);
    on<ClearFilters>(_onClearFilters);
    on<ApplyTemplateFilters>(_onApplyTemplateFilters);
    on<ApplyDateRangeFilter>(_onApplyDateRangeFilter);
    on<UpdateStateManager>(_onUpdateStateManager);

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
      if (_manualFilters.contains(filter)) {
        _manualFilters.remove(filter);
      } else {
        _manualFilters.add(filter);
      }
      await _applyAllFilters(emit);
    }
  }

  Future<void> _onApplyTemplateFilters(
    ApplyTemplateFilters event,
    Emitter<CFDIState> emit,
  ) async {
    if (state is CFDILoaded) {
      await _applyAllFilters(emit);
    }
  }

  Future<void> _onApplyDateRangeFilter(
    ApplyDateRangeFilter event,
    Emitter<CFDIState> emit,
  ) async {
    if (state is CFDILoaded) {
      _startDate = event.startDate;
      _endDate = event.endDate;
      await _applyAllFilters(emit);
    }
  }

  Future<void> _applyAllFilters(Emitter<CFDIState> emit) async {
    if (state is! CFDILoaded) return;

    final currentState = state as CFDILoaded;
    final allFilters = _getAllActiveFilters();

    _updateAllFilterSelections(allFilters);

    final filterFactory = FilterFactory(allFilters);
    filterFactory.chains
        .add(DateRangeFilter(startDate: _startDate, endDate: _endDate));

    final filteredCFDIs = await filterFactory.apply(_repository.cfdis);
    final cfdiInformation = calculateTotals(filteredCFDIs);

    emit(
      CFDILoaded(
        filteredCFDIs,
        cfdiInformation,
        allFilters,
        stateManager: currentState.stateManager,
      ),
    );
  }

  Set<FilterOption> _getAllActiveFilters() {
    final templateState = _filterTemplateBloc.state;
    final Set<FilterOption> allFilters = Set.from(_manualFilters);
    if (templateState is FilterTemplateLoaded) {
      for (final template in templateState.activeTemplates) {
        allFilters.addAll(template.filters);
      }
    }
    return allFilters;
  }

  void _updateAllFilterSelections(Set<FilterOption> allFilters) {
    _clearAllFilterSelections();
    for (final filter in allFilters) {
      _updateFilterSelection(filter, true);
    }
  }

  void _updateFilterSelection(FilterOption filter, bool selected) {
    // ... (existing implementation)
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
        emit(CFDILoaded(cfdis, cfdiInformation, {}));
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
        emit(CFDILoaded(cfdis, cfdiInformation, {}));
      } else {
        emit(CFDIError('No se pudo cargar el CFDI'));
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
    ClearFilters event,
    Emitter<CFDIState> emit,
  ) async {
    if (state is CFDILoaded) {
      _manualFilters.clear();
      _startDate = null;
      _endDate = null;
      _filterTemplateBloc.add(ClearAllTemplates());
      await _applyAllFilters(emit);
    }
  }

  void _clearAllFilterSelections() {
    for (var forma in formasDePago) {
      forma.seleccionado = false;
    }
    for (var metodo in metodosDePago) {
      metodo.seleccionado = false;
    }
    for (var uso in usosDeCFDI) {
      uso.seleccionado = false;
    }
    for (var tipo in tiposDeComprobante) {
      tipo.seleccionado = false;
    }
  }

  Future<void> _onUpdateStateManager(
    UpdateStateManager event,
    Emitter<CFDIState> emit,
  ) async {
    if (state is CFDILoaded) {
      final currentState = state as CFDILoaded;
      emit(
        CFDILoaded(
          currentState.cfdis,
          currentState.cfdiInformation,
          currentState.activeFilters,
          stateManager: event.stateManager,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _filterTemplateSubscription.cancel();
    return super.close();
  }

  static CFDI? findCFDIByUUID(String uuid, List<CFDI> cfdis) {
    final normalizedUuid = uuid.trim().toUpperCase();
    return cfdis.firstWhere(
      (cfdi) => cfdi.timbreFiscalDigital?.uuid?.toUpperCase() == normalizedUuid,
      orElse: () => CFDI(),
    );
  }

  static CFDIInformation calculateTotals(List<CFDI> cfdis) {
    final subtotal = cfdis.fold<double>(0, (prev, cfdi) {
      final double tipoCambio = double.tryParse(cfdi.tipoCambio ?? '1') ?? 1;
      final double valor = double.tryParse(cfdi.subTotal ?? '0') ?? 0;
      return prev + (tipoCambio > 1 ? valor * tipoCambio : valor);
    });
    final descuento = cfdis.fold<double>(0, (prev, cfdi) {
      final double tipoCambio = double.tryParse(cfdi.tipoCambio ?? '1') ?? 1;
      final double valor = double.tryParse(cfdi.descuento ?? '0') ?? 0;
      return prev + (tipoCambio > 1 ? valor * tipoCambio : valor);
    });
    final total = cfdis.fold<double>(0, (prev, cfdi) {
      final double tipoCambio = double.tryParse(cfdi.tipoCambio ?? '1') ?? 1;
      final double valor = double.tryParse(cfdi.total ?? '0') ?? 0;
      return prev + (tipoCambio > 1 ? valor * tipoCambio : valor);
    });

    return CFDIInformation(
      subtotal: subtotal,
      descuento: descuento,
      total: total,
    );
  }
}
