import 'package:equatable/equatable.dart';
import 'diot_record.dart';
import '../constants/diot_constants.dart';

/// Representa un lote completo de DIOT con configuración y records
class DIOTBatch extends Equatable {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DIOTConfiguration configuration;
  final List<DIOTRecord> records;
  final DIOTBatchStatus status;
  final List<DIOTValidationError> globalValidationErrors;
  final DIOTBatchStatistics statistics;

  const DIOTBatch({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.configuration,
    required this.records,
    required this.status,
    this.globalValidationErrors = const [],
    required this.statistics,
  });

  DIOTBatch copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DIOTConfiguration? configuration,
    List<DIOTRecord>? records,
    DIOTBatchStatus? status,
    List<DIOTValidationError>? globalValidationErrors,
    DIOTBatchStatistics? statistics,
  }) {
    return DIOTBatch(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      configuration: configuration ?? this.configuration,
      records: records ?? this.records,
      status: status ?? this.status,
      globalValidationErrors:
          globalValidationErrors ?? this.globalValidationErrors,
      statistics: statistics ?? this.statistics,
    );
  }

  /// Obtiene registros que requieren intervención del usuario
  List<DIOTRecord> get recordsRequiringUserInput =>
      records.where((record) => record.requiresUserInput).toList();

  /// Obtiene registros con errores de validación
  List<DIOTRecord> get recordsWithErrors =>
      records.where((record) => record.validationErrors.isNotEmpty).toList();

  /// Verifica si el lote está listo para exportar
  bool get isReadyForExport =>
      status == DIOTBatchStatus.validated &&
      recordsRequiringUserInput.isEmpty &&
      recordsWithErrors.isEmpty;

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        configuration,
        records,
        status,
        globalValidationErrors,
        statistics,
      ];
}

/// Configuración para la generación de DIOT
class DIOTConfiguration extends Equatable {
  final int year;
  final int month;
  final String? rfcDeclarante;
  final int ejercicio;
  final int periodo;
  final String rfcContribuyente;
  final TipoComplemento tipoComplemento;
  final bool incluirOperacionesAlMomento;
  final bool incluirOperacionesEnParteProporcionadas;
  final bool incluirOperacionesEnParteDeducibles;
  final DIOTFilterCriteria filterCriteria;
  final DIOTUserPreferences userPreferences;

  const DIOTConfiguration({
    required this.year,
    required this.month,
    this.rfcDeclarante,
    required this.ejercicio,
    required this.periodo,
    required this.rfcContribuyente,
    required this.tipoComplemento,
    this.incluirOperacionesAlMomento = true,
    this.incluirOperacionesEnParteProporcionadas = true,
    this.incluirOperacionesEnParteDeducibles = true,
    required this.filterCriteria,
    required this.userPreferences,
  });

  DIOTConfiguration copyWith({
    int? year,
    int? month,
    String? rfcDeclarante,
    int? ejercicio,
    int? periodo,
    String? rfcContribuyente,
    TipoComplemento? tipoComplemento,
    bool? incluirOperacionesAlMomento,
    bool? incluirOperacionesEnParteProporcionadas,
    bool? incluirOperacionesEnParteDeducibles,
    DIOTFilterCriteria? filterCriteria,
    DIOTUserPreferences? userPreferences,
  }) {
    return DIOTConfiguration(
      year: year ?? this.year,
      month: month ?? this.month,
      rfcDeclarante: rfcDeclarante ?? this.rfcDeclarante,
      ejercicio: ejercicio ?? this.ejercicio,
      periodo: periodo ?? this.periodo,
      rfcContribuyente: rfcContribuyente ?? this.rfcContribuyente,
      tipoComplemento: tipoComplemento ?? this.tipoComplemento,
      incluirOperacionesAlMomento:
          incluirOperacionesAlMomento ?? this.incluirOperacionesAlMomento,
      incluirOperacionesEnParteProporcionadas:
          incluirOperacionesEnParteProporcionadas ??
              this.incluirOperacionesEnParteProporcionadas,
      incluirOperacionesEnParteDeducibles:
          incluirOperacionesEnParteDeducibles ??
              this.incluirOperacionesEnParteDeducibles,
      filterCriteria: filterCriteria ?? this.filterCriteria,
      userPreferences: userPreferences ?? this.userPreferences,
    );
  }

  @override
  List<Object?> get props => [
        year,
        month,
        rfcDeclarante,
        ejercicio,
        periodo,
        rfcContribuyente,
        tipoComplemento,
        incluirOperacionesAlMomento,
        incluirOperacionesEnParteProporcionadas,
        incluirOperacionesEnParteDeducibles,
        filterCriteria,
        userPreferences,
      ];
}

/// Criterios de filtrado para CFDIs
class DIOTFilterCriteria extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? includeRfcs;
  final List<String>? excludeRfcs;
  final double? minAmount;
  final double? maxAmount;
  final bool includeOnlyWithIVA;

  const DIOTFilterCriteria({
    this.startDate,
    this.endDate,
    this.includeRfcs,
    this.excludeRfcs,
    this.minAmount,
    this.maxAmount,
    this.includeOnlyWithIVA = true,
  });

  DIOTFilterCriteria copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? includeRfcs,
    List<String>? excludeRfcs,
    double? minAmount,
    double? maxAmount,
    bool? includeOnlyWithIVA,
  }) {
    return DIOTFilterCriteria(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      includeRfcs: includeRfcs ?? this.includeRfcs,
      excludeRfcs: excludeRfcs ?? this.excludeRfcs,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      includeOnlyWithIVA: includeOnlyWithIVA ?? this.includeOnlyWithIVA,
    );
  }

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        includeRfcs,
        excludeRfcs,
        minAmount,
        maxAmount,
        includeOnlyWithIVA,
      ];
}

/// Preferencias del usuario para configuraciones predeterminadas
class DIOTUserPreferences extends Equatable {
  final Map<String, TipoTercero> rfcToTipoTercero;
  final Map<String, TipoOperacion> rfcToTipoOperacion;
  final Map<String, ClasificacionRegional> rfcToClasificacionRegional;
  final Map<String, ClasificacionIVA> rfcToClasificacionIVA;
  final Map<String, EfectosFiscales> rfcToEfectosFiscales;
  final Map<String, ProveedorExtranjeroInfo> rfcToExtranjeroInfo;

  const DIOTUserPreferences({
    this.rfcToTipoTercero = const {},
    this.rfcToTipoOperacion = const {},
    this.rfcToClasificacionRegional = const {},
    this.rfcToClasificacionIVA = const {},
    this.rfcToEfectosFiscales = const {},
    this.rfcToExtranjeroInfo = const {},
  });

  DIOTUserPreferences copyWith({
    Map<String, TipoTercero>? rfcToTipoTercero,
    Map<String, TipoOperacion>? rfcToTipoOperacion,
    Map<String, ClasificacionRegional>? rfcToClasificacionRegional,
    Map<String, ClasificacionIVA>? rfcToClasificacionIVA,
    Map<String, EfectosFiscales>? rfcToEfectosFiscales,
    Map<String, ProveedorExtranjeroInfo>? rfcToExtranjeroInfo,
  }) {
    return DIOTUserPreferences(
      rfcToTipoTercero: rfcToTipoTercero ?? this.rfcToTipoTercero,
      rfcToTipoOperacion: rfcToTipoOperacion ?? this.rfcToTipoOperacion,
      rfcToClasificacionRegional:
          rfcToClasificacionRegional ?? this.rfcToClasificacionRegional,
      rfcToClasificacionIVA:
          rfcToClasificacionIVA ?? this.rfcToClasificacionIVA,
      rfcToEfectosFiscales: rfcToEfectosFiscales ?? this.rfcToEfectosFiscales,
      rfcToExtranjeroInfo: rfcToExtranjeroInfo ?? this.rfcToExtranjeroInfo,
    );
  }

  @override
  List<Object> get props => [
        rfcToTipoTercero,
        rfcToTipoOperacion,
        rfcToClasificacionRegional,
        rfcToClasificacionIVA,
        rfcToEfectosFiscales,
        rfcToExtranjeroInfo,
      ];
}

/// Información específica de proveedores extranjeros
class ProveedorExtranjeroInfo extends Equatable {
  final String numeroIdentificacionFiscal;
  final String nombreExtranjero;
  final String paisResidenciaFiscal;
  final String? especificarJurisdiccion;

  const ProveedorExtranjeroInfo({
    required this.numeroIdentificacionFiscal,
    required this.nombreExtranjero,
    required this.paisResidenciaFiscal,
    this.especificarJurisdiccion,
  });

  @override
  List<Object?> get props => [
        numeroIdentificacionFiscal,
        nombreExtranjero,
        paisResidenciaFiscal,
        especificarJurisdiccion,
      ];
}

/// Estados del lote DIOT
enum DIOTBatchStatus {
  draft('Borrador'),
  processing('Procesando'),
  requiresUserInput('Requiere Intervención'),
  validating('Validando'),
  validated('Validado'),
  exporting('Exportando'),
  completed('Completado'),
  error('Error');

  const DIOTBatchStatus(this.description);
  final String description;
}

/// Estadísticas del lote DIOT
class DIOTBatchStatistics extends Equatable {
  final int totalRecords;
  final int recordsWithErrors;
  final int recordsRequiringInput;
  final int readyForExport;
  final double totalValue;
  final double totalIVA;
  final Map<TipoTercero, int> recordsByTipoTercero;
  final Map<TipoOperacion, int> recordsByTipoOperacion;

  const DIOTBatchStatistics({
    required this.totalRecords,
    required this.recordsWithErrors,
    required this.recordsRequiringInput,
    required this.readyForExport,
    required this.totalValue,
    required this.totalIVA,
    required this.recordsByTipoTercero,
    required this.recordsByTipoOperacion,
  });

  static DIOTBatchStatistics fromRecords(List<DIOTRecord> records) {
    final recordsByTipoTercero = <TipoTercero, int>{};
    final recordsByTipoOperacion = <TipoOperacion, int>{};

    double totalValue = 0;
    double totalIVA = 0;
    int recordsWithErrors = 0;
    int recordsRequiringInput = 0;

    for (final record in records) {
      // Contar por tipo tercero
      recordsByTipoTercero[record.tipoTercero] =
          (recordsByTipoTercero[record.tipoTercero] ?? 0) + 1;

      // Contar por tipo operación
      recordsByTipoOperacion[record.tipoOperacion] =
          (recordsByTipoOperacion[record.tipoOperacion] ?? 0) + 1;

      // Sumar valores
      totalValue += record.valorActos16Porciento +
          record.valorActosFronteraNorte +
          record.valorActosFronteraSur +
          record.valorImportacionTangibles16 +
          record.valorImportacionIntangibles16;

      totalIVA += record.ivaAcreditableExclusivo16 +
          record.ivaAcreditableProporcion16 +
          record.ivaAcreditableExclusivoFronteraNorte +
          record.ivaAcreditableProporcionFronteraNorte +
          record.ivaAcreditableExclusivoFronteraSur +
          record.ivaAcreditableProporcionFronteraSur;

      if (record.validationErrors.isNotEmpty) {
        recordsWithErrors++;
      }

      if (record.requiresUserInput) {
        recordsRequiringInput++;
      }
    }

    return DIOTBatchStatistics(
      totalRecords: records.length,
      recordsWithErrors: recordsWithErrors,
      recordsRequiringInput: recordsRequiringInput,
      readyForExport:
          records.length - recordsWithErrors - recordsRequiringInput,
      totalValue: totalValue,
      totalIVA: totalIVA,
      recordsByTipoTercero: recordsByTipoTercero,
      recordsByTipoOperacion: recordsByTipoOperacion,
    );
  }

  @override
  List<Object> get props => [
        totalRecords,
        recordsWithErrors,
        recordsRequiringInput,
        readyForExport,
        totalValue,
        totalIVA,
        recordsByTipoTercero,
        recordsByTipoOperacion,
      ];
}
