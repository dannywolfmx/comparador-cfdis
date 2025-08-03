import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:comparador_cfdis/bloc/diot_event.dart';
import 'package:comparador_cfdis/bloc/diot_state.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/models/diot_record.dart';
import 'package:comparador_cfdis/services/diot_mapping_service.dart';
import 'package:comparador_cfdis/services/diot_validation_service.dart';
import 'package:comparador_cfdis/services/diot_export_service.dart';

class DIOTBloc extends Bloc<DIOTEvent, DIOTState> {
  final List<CFDI> _cfdis;
  DIOTBatch? _currentBatch;

  DIOTBloc(this._cfdis) : super(DIOTInitial()) {
    on<CreateDIOTBatch>(_onCreateDIOTBatch);
    on<GenerateDIOTBatch>(_onGenerateDIOTBatch);
    on<LoadDIOTBatch>(_onLoadDIOTBatch);
    on<UpdateRecordUserInput>(_onUpdateRecordUserInput);
    on<ValidateBatch>(_onValidateBatch);
    on<ExportDIOTFile>(_onExportDIOTFile);
    on<ApplyBulkClassification>(_onApplyBulkClassification);
    on<SaveUserPreferences>(_onSaveUserPreferences);
    on<ClearDIOTBatch>(_onClearDIOTBatch);
  }

  Future<void> _onCreateDIOTBatch(
    CreateDIOTBatch event,
    Emitter<DIOTState> emit,
  ) async {
    emit(const DIOTLoading(message: 'Creando lote DIOT...'));

    try {
      // Filtrar CFDIs según criterios de configuración
      final filteredCfdis =
          _filterCFDIs(_cfdis, event.configuration.filterCriteria);

      if (filteredCfdis.isEmpty) {
        emit(
          const DIOTError(
            'No se encontraron CFDIs que cumplan con los criterios especificados',
          ),
        );
        return;
      }

      // Mapear CFDIs a registros DIOT
      emit(const DIOTLoading(message: 'Procesando CFDIs...'));
      final records = DIOTMappingService.mapCFDIsToRecords(
        filteredCfdis,
        event.configuration,
      );

      // Crear el lote
      final batch = DIOTBatch(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        configuration: event.configuration,
        records: records,
        status: DIOTBatchStatus.processing,
        statistics: DIOTBatchStatistics.fromRecords(records),
      );

      // Validar el lote inicial
      emit(const DIOTLoading(message: 'Validando datos...'));
      final validatedBatch = await _validateAndUpdateBatch(batch);
      _currentBatch = validatedBatch;

      final validationSummary =
          DIOTValidationService.getValidationSummary(validatedBatch);
      final recordsRequiringInput =
          validatedBatch.recordsRequiringUserInput.length;

      if (recordsRequiringInput > 0) {
        emit(
          DIOTBatchCreated(
            validatedBatch,
            validationSummary,
            recordsRequiringInput,
          ),
        );
      } else if (validationSummary.totalErrors > 0) {
        emit(DIOTValidated(validatedBatch, validationSummary, false));
      } else {
        emit(DIOTValidated(validatedBatch, validationSummary, true));
      }
    } catch (e) {
      emit(DIOTError('Error al crear el lote DIOT: ${e.toString()}'));
    }
  }

  Future<void> _onGenerateDIOTBatch(
    GenerateDIOTBatch event,
    Emitter<DIOTState> emit,
  ) async {
    emit(const DIOTLoading(message: 'Generando lote DIOT...'));

    try {
      // Crear criterios de filtrado por defecto
      const filterCriteria = DIOTFilterCriteria(
        includeOnlyWithIVA: true,
        minAmount: 0.0,
      );

      // Crear preferencias de usuario por defecto
      const userPreferences = DIOTUserPreferences();

      // Crear configuración completa
      final completeConfiguration = event.configuration.copyWith(
        filterCriteria: filterCriteria,
        userPreferences: userPreferences,
      );

      // Mapear CFDIs a registros DIOT
      emit(const DIOTLoading(message: 'Procesando CFDIs...'));
      final records = DIOTMappingService.mapCFDIsToRecords(
        event.cfdis,
        completeConfiguration,
      );

      // Crear el lote
      final batch = DIOTBatch(
        id: const Uuid().v4(),
        createdAt: DateTime.now(),
        configuration: completeConfiguration,
        records: records,
        status: DIOTBatchStatus.processing,
        statistics: DIOTBatchStatistics.fromRecords(records),
      );

      _currentBatch = batch;

      // Validar el lote
      emit(const DIOTLoading(message: 'Validando registros...'));
      final validationSummary =
          DIOTValidationService.getValidationSummary(batch);
      final recordsRequiringInput = batch.recordsRequiringUserInput.length;

      emit(DIOTBatchGenerated(batch, validationSummary, recordsRequiringInput));
    } catch (e) {
      emit(DIOTError('Error al generar el lote DIOT: ${e.toString()}'));
    }
  }

  Future<void> _onLoadDIOTBatch(
    LoadDIOTBatch event,
    Emitter<DIOTState> emit,
  ) async {
    emit(const DIOTLoading(message: 'Cargando lote DIOT...'));

    try {
      // Aquí se implementaría la carga desde almacenamiento persistente
      // Por ahora, usamos el lote actual si existe
      if (_currentBatch?.id == event.batchId) {
        final validationSummary =
            DIOTValidationService.getValidationSummary(_currentBatch!);
        emit(DIOTBatchLoaded(_currentBatch!, validationSummary));
      } else {
        emit(const DIOTError('Lote no encontrado'));
      }
    } catch (e) {
      emit(DIOTError('Error al cargar el lote: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateRecordUserInput(
    UpdateRecordUserInput event,
    Emitter<DIOTState> emit,
  ) async {
    if (_currentBatch == null) {
      emit(const DIOTError('No hay lote activo'));
      return;
    }

    emit(const DIOTLoading(message: 'Actualizando registro...'));

    print(
      '🔍 DEBUG BLoC: Recibido UpdateRecordUserInput para RFC: ${event.recordRfc}',
    );
    print('🔍 DEBUG BLoC: Datos recibidos:');
    event.userInput.forEach((key, value) {
      print('   $key: $value');
    });

    try {
      // Encontrar el registro a actualizar
      final recordIndex = _currentBatch!.records.indexWhere(
        (record) => record.rfc == event.recordRfc,
      );

      if (recordIndex == -1) {
        print(
          '🔍 DEBUG BLoC: ERROR - Registro con RFC ${event.recordRfc} no encontrado',
        );
        emit(DIOTError('Registro con RFC ${event.recordRfc} no encontrado'));
        return;
      }

      print('🔍 DEBUG BLoC: Registro encontrado en índice: $recordIndex');

      // Actualizar el registro
      final updatedRecord = DIOTMappingService.updateRecordWithUserInput(
        _currentBatch!.records[recordIndex],
        event.userInput,
      );

      // Validar el registro actualizado
      final validationErrors =
          DIOTValidationService.validateRecord(updatedRecord);

      // Verificar si el registro aún requiere entrada del usuario
      // (no simplemente marcarlo como false automáticamente)
      final stillRequiresInput = _stillRequiresUserInput(updatedRecord);

      print('🔍 DEBUG BLoC: Después de actualización:');
      print('   Validation errors: ${validationErrors.length}');
      print('   Still requires input: $stillRequiresInput');

      final finalRecord = updatedRecord.copyWith(
        validationErrors: validationErrors,
        requiresUserInput: stillRequiresInput,
      );

      print('🔍 DEBUG BLoC: Record final:');
      print('   RFC: ${finalRecord.rfc}');
      print('   Nombre extranjero: ${finalRecord.nombreExtranjero}');
      print('   País: ${finalRecord.paisResidenciaFiscal}');
      print('   Clasificación Regional: ${finalRecord.clasificacionRegional}');
      print('   Clasificación IVA: ${finalRecord.clasificacionIVA}');
      print('   Requires User Input: ${finalRecord.requiresUserInput}');

      // Crear nueva lista de registros
      final updatedRecords = List<DIOTRecord>.from(_currentBatch!.records);
      updatedRecords[recordIndex] = finalRecord;

      // Crear nuevo lote
      final updatedBatch = _currentBatch!.copyWith(
        records: updatedRecords,
        updatedAt: DateTime.now(),
        statistics: DIOTBatchStatistics.fromRecords(updatedRecords),
      );

      _currentBatch = updatedBatch;
      final validationSummary =
          DIOTValidationService.getValidationSummary(updatedBatch);

      emit(DIOTRecordUpdated(updatedBatch, validationSummary, event.recordRfc));

      // Verificar si todos los registros están completos y validar automáticamente
      final recordsRequiringInput = updatedBatch.records
          .where((record) => record.requiresUserInput)
          .toList();

      final recordsWithErrors = updatedBatch.records
          .where((record) => record.validationErrors.isNotEmpty)
          .toList();

      // Si no hay registros pendientes ni errores, validar automáticamente el lote
      if (recordsRequiringInput.isEmpty && recordsWithErrors.isEmpty) {
        // Validar el lote automáticamente
        final validatedBatch = await _validateAndUpdateBatch(updatedBatch);
        _currentBatch = validatedBatch;

        final newValidationSummary =
            DIOTValidationService.getValidationSummary(validatedBatch);

        // Determinar si está listo para exportar
        final isReadyForExport = validatedBatch.isReadyForExport;

        // Emitir estado de validación automática
        emit(DIOTValidated(
            validatedBatch, newValidationSummary, isReadyForExport));
      }
    } catch (e) {
      emit(DIOTError('Error al actualizar el registro: ${e.toString()}'));
    }
  }

  Future<void> _onValidateBatch(
    ValidateBatch event,
    Emitter<DIOTState> emit,
  ) async {
    if (_currentBatch == null) {
      emit(const DIOTError('No hay lote activo'));
      return;
    }

    emit(const DIOTLoading(message: 'Validando lote...'));

    try {
      final validatedBatch = await _validateAndUpdateBatch(_currentBatch!);
      _currentBatch = validatedBatch;

      final validationSummary =
          DIOTValidationService.getValidationSummary(validatedBatch);
      final isReadyForExport = validationSummary.isReadyForExport;

      emit(DIOTValidated(validatedBatch, validationSummary, isReadyForExport));
    } catch (e) {
      emit(DIOTError('Error al validar el lote: ${e.toString()}'));
    }
  }

  Future<void> _onExportDIOTFile(
    ExportDIOTFile event,
    Emitter<DIOTState> emit,
  ) async {
    if (_currentBatch == null) {
      emit(const DIOTError('No hay lote activo'));
      return;
    }

    if (!_currentBatch!.isReadyForExport) {
      emit(
        const DIOTError(
          'El lote no está listo para exportar. Hay errores o registros pendientes.',
        ),
      );
      return;
    }

    emit(const DIOTLoading(message: 'Exportando archivo DIOT...'));

    try {
      final filePath = await DIOTExportService.exportToFile(
        _currentBatch!,
        customPath: event.filePath,
      );

      // Actualizar estado del lote
      final exportedBatch = _currentBatch!.copyWith(
        status: DIOTBatchStatus.completed,
        updatedAt: DateTime.now(),
      );
      _currentBatch = exportedBatch;

      emit(DIOTExported(filePath, _currentBatch!.records.length));
    } catch (e) {
      emit(DIOTError('Error al exportar el archivo: ${e.toString()}'));
    }
  }

  Future<void> _onApplyBulkClassification(
    ApplyBulkClassification event,
    Emitter<DIOTState> emit,
  ) async {
    if (_currentBatch == null) {
      emit(const DIOTError('No hay lote activo'));
      return;
    }

    emit(const DIOTLoading(message: 'Aplicando clasificación masiva...'));

    try {
      final updatedRecords = _currentBatch!.records.map((record) {
        if (event.rfcs.contains(record.rfc)) {
          return record.copyWith(
            tipoTercero: event.tipoTercero ?? record.tipoTercero,
            tipoOperacion: event.tipoOperacion ?? record.tipoOperacion,
            clasificacionRegional:
                event.clasificacionRegional ?? record.clasificacionRegional,
            clasificacionIVA: event.clasificacionIVA ?? record.clasificacionIVA,
          );
        }
        return record;
      }).toList();

      final updatedBatch = _currentBatch!.copyWith(
        records: updatedRecords,
        updatedAt: DateTime.now(),
        statistics: DIOTBatchStatistics.fromRecords(updatedRecords),
      );

      final validatedBatch = await _validateAndUpdateBatch(updatedBatch);
      _currentBatch = validatedBatch;

      final validationSummary =
          DIOTValidationService.getValidationSummary(validatedBatch);
      emit(DIOTBatchLoaded(validatedBatch, validationSummary));
    } catch (e) {
      emit(DIOTError('Error al aplicar clasificación masiva: ${e.toString()}'));
    }
  }

  Future<void> _onSaveUserPreferences(
    SaveUserPreferences event,
    Emitter<DIOTState> emit,
  ) async {
    if (_currentBatch == null) {
      emit(const DIOTError('No hay lote activo'));
      return;
    }

    try {
      // Aquí se implementaría el guardado persistente de preferencias
      // Por ahora, actualizamos la configuración del lote actual

      final updatedConfiguration = _currentBatch!.configuration.copyWith(
        userPreferences: event.preferences,
      );

      final updatedBatch = _currentBatch!.copyWith(
        configuration: updatedConfiguration,
        updatedAt: DateTime.now(),
      );

      _currentBatch = updatedBatch;

      final validationSummary =
          DIOTValidationService.getValidationSummary(updatedBatch);
      emit(DIOTBatchLoaded(updatedBatch, validationSummary));
    } catch (e) {
      emit(DIOTError('Error al guardar preferencias: ${e.toString()}'));
    }
  }

  Future<void> _onClearDIOTBatch(
    ClearDIOTBatch event,
    Emitter<DIOTState> emit,
  ) async {
    _currentBatch = null;
    emit(DIOTInitial());
  }

  /// Filtra CFDIs según criterios especificados
  List<CFDI> _filterCFDIs(List<CFDI> cfdis, DIOTFilterCriteria criteria) {
    return cfdis.where((cfdi) {
      // Filtro por fecha
      if (criteria.startDate != null || criteria.endDate != null) {
        final cfdiDate = DateTime.tryParse(cfdi.fecha ?? '');
        if (cfdiDate != null) {
          if (criteria.startDate != null &&
              cfdiDate.isBefore(criteria.startDate!)) {
            return false;
          }
          if (criteria.endDate != null && cfdiDate.isAfter(criteria.endDate!)) {
            return false;
          }
        }
      }

      // Filtro por RFC
      if (criteria.includeRfcs != null && criteria.includeRfcs!.isNotEmpty) {
        final rfc = cfdi.emisor?.rfc ?? '';
        if (!criteria.includeRfcs!.contains(rfc)) {
          return false;
        }
      }

      if (criteria.excludeRfcs != null && criteria.excludeRfcs!.isNotEmpty) {
        final rfc = cfdi.emisor?.rfc ?? '';
        if (criteria.excludeRfcs!.contains(rfc)) {
          return false;
        }
      }

      // Filtro por monto
      if (criteria.minAmount != null || criteria.maxAmount != null) {
        final total = double.tryParse(cfdi.total ?? '0') ?? 0;
        if (criteria.minAmount != null && total < criteria.minAmount!) {
          return false;
        }
        if (criteria.maxAmount != null && total > criteria.maxAmount!) {
          return false;
        }
      }

      // Filtro por IVA
      if (criteria.includeOnlyWithIVA) {
        // Verificar si el CFDI tiene IVA
        bool hasIVA = false;
        if (cfdi.conceptos?.concepto != null) {
          for (final concepto in cfdi.conceptos!.concepto!) {
            for (final traslado in concepto.traslados) {
              if (traslado.impuesto == '002' && traslado.importe > 0) {
                hasIVA = true;
                break;
              }
            }
            if (hasIVA) break;
          }
        }
        if (!hasIVA) return false;
      }

      return true;
    }).toList();
  }

  /// Valida y actualiza un lote con validaciones
  Future<DIOTBatch> _validateAndUpdateBatch(DIOTBatch batch) async {
    // Validar cada registro
    final updatedRecords = <DIOTRecord>[];

    for (final record in batch.records) {
      final validationErrors = DIOTValidationService.validateRecord(record);
      final updatedRecord = record.copyWith(
        validationErrors: validationErrors,
      );
      updatedRecords.add(updatedRecord);
    }

    // Validar el lote completo
    final globalValidationErrors = DIOTValidationService.validateBatch(batch);

    // Determinar estado del lote
    DIOTBatchStatus status = DIOTBatchStatus.validated;
    if (globalValidationErrors
        .any((e) => e.severity == DIOTValidationSeverity.error)) {
      status = DIOTBatchStatus.error;
    } else if (updatedRecords.any((r) => r.requiresUserInput)) {
      status = DIOTBatchStatus.requiresUserInput;
    }

    return batch.copyWith(
      records: updatedRecords,
      status: status,
      globalValidationErrors: globalValidationErrors,
      statistics: DIOTBatchStatistics.fromRecords(updatedRecords),
      updatedAt: DateTime.now(),
    );
  }

  /// Verifica si un registro aún requiere entrada del usuario
  bool _stillRequiresUserInput(DIOTRecord record) {
    // Si es extranjero y no tiene información completa
    if (record.tipoTercero == TipoTercero.extranjero) {
      if (record.nombreExtranjero == null ||
          record.nombreExtranjero!.isEmpty ||
          record.paisResidenciaFiscal == null ||
          record.paisResidenciaFiscal!.isEmpty) {
        return true;
      }
    }

    // Si tiene valores de IVA pero no tiene clasificación regional
    if (record.safeValorActos16Porciento > 0 ||
        record.safeIvaNoAcreditableSinRequisitos16 > 0) {
      if (record.clasificacionRegional == null) {
        return true;
      }
    }

    // Si no tiene clasificación de IVA cuando es necesaria
    if (record.safeValorActos16Porciento > 0 && record.clasificacionIVA == null) {
      return true;
    }

    return false;
  }
}
