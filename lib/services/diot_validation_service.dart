import 'package:comparador_cfdis/models/diot_record.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/services/diot_2025_validation_service.dart';

/// Servicio para validar registros DIOT según las reglas del SAT
/// Actualizado para cumplir con especificación DIOT 2025
class DIOTValidationService {
  /// Valida un registro DIOT individual usando validaciones DIOT 2025
  static List<DIOTValidationError> validateRecord(DIOTRecord record) {
    // Usar directamente las validaciones DIOT 2025 que son más completas
    return DIOT2025ValidationService.validateRecord2025(record);
  }

  /// Valida un lote completo de DIOT usando validaciones DIOT 2025
  static List<DIOTValidationError> validateBatch(DIOTBatch batch) {
    final List<DIOTValidationError> globalErrors = [];

    // Usar validaciones DIOT 2025 para el lote completo
    globalErrors.addAll(DIOT2025ValidationService.validateBatch2025(batch));

    // Validaciones adicionales específicas del lote
    globalErrors.addAll(_validateBatchSpecificRules(batch));

    return globalErrors;
  }

  /// Validaciones específicas del lote que complementan DIOT 2025
  static List<DIOTValidationError> _validateBatchSpecificRules(
    DIOTBatch batch,
  ) {
    final List<DIOTValidationError> errors = [];

    // Validar que hay registros
    if (batch.records.isEmpty) {
      errors.add(
        const DIOTValidationError(
          field: 'records',
          message: 'El lote DIOT debe contener al menos un registro',
          severity: DIOTValidationSeverity.error,
        ),
      );
    }

    // Validar duplicados por RFC
    errors.addAll(_validateDuplicateRFCs(batch.records));

    // Validar totales del lote
    errors.addAll(_validateBatchTotals(batch));

    return errors;
  }

  /// Valida RFCs duplicados en el lote
  static List<DIOTValidationError> _validateDuplicateRFCs(
    List<DIOTRecord> records,
  ) {
    final List<DIOTValidationError> errors = [];
    final Set<String> seenRFCs = {};

    for (final record in records) {
      if (record.rfc.isNotEmpty) {
        if (seenRFCs.contains(record.rfc)) {
          errors.add(
            DIOTValidationError(
              field: 'rfc',
              message: 'RFC duplicado: ${record.rfc}',
              severity: DIOTValidationSeverity.error,
            ),
          );
        } else {
          seenRFCs.add(record.rfc);
        }
      }
    }

    return errors;
  }

  /// Valida totales del lote
  static List<DIOTValidationError> _validateBatchTotals(DIOTBatch batch) {
    final List<DIOTValidationError> errors = [];

    // Validar que los totales sean consistentes
    double calculatedTotal = 0;
    for (final record in batch.records) {
      calculatedTotal += (record.valorActos16Porciento ?? 0) +
          (record.valorActosFronteraNorte ?? 0) +
          (record.valorActosFronteraSur ?? 0);
    }

    if ((calculatedTotal - batch.statistics.totalValue).abs() > 0.01) {
      errors.add(
        const DIOTValidationError(
          field: 'totals',
          message:
              'Los totales calculados no coinciden con las estadísticas del lote',
          severity: DIOTValidationSeverity.warning,
        ),
      );
    }

    return errors;
  }

  /// Valida un registro antes de permitir su exportación (usando DIOT 2025)
  static bool isRecordReadyForExport(DIOTRecord record) {
    return DIOT2025ValidationService.isRecord2025ReadyForExport(record);
  }

  /// Obtiene un resumen de validación para mostrar al usuario
  static DIOTValidationSummary getValidationSummary(DIOTBatch batch) {
    int totalErrors = 0;
    int totalWarnings = 0;
    int recordsWithErrors = 0;
    int recordsRequiringInput = 0;

    // Contar errores globales
    for (final error in batch.globalValidationErrors) {
      if (error.severity == DIOTValidationSeverity.error) {
        totalErrors++;
      } else if (error.severity == DIOTValidationSeverity.warning) {
        totalWarnings++;
      }
    }

    // Contar errores de registros usando validaciones DIOT 2025
    for (final record in batch.records) {
      bool hasErrors = false;
      final recordErrors = validateRecord(record); // Usa DIOT 2025

      for (final error in recordErrors) {
        if (error.severity == DIOTValidationSeverity.error) {
          totalErrors++;
          hasErrors = true;
        } else if (error.severity == DIOTValidationSeverity.warning) {
          totalWarnings++;
        }
      }

      if (hasErrors) recordsWithErrors++;
      if (record.requiresUserInput) recordsRequiringInput++;
    }

    return DIOTValidationSummary(
      totalRecords: batch.records.length,
      totalErrors: totalErrors,
      totalWarnings: totalWarnings,
      recordsWithErrors: recordsWithErrors,
      recordsRequiringInput: recordsRequiringInput,
      isReadyForExport: totalErrors == 0 && recordsRequiringInput == 0,
    );
  }
}

/// Resumen de validación para mostrar al usuario
class DIOTValidationSummary {
  final int totalRecords;
  final int totalErrors;
  final int totalWarnings;
  final int recordsWithErrors;
  final int recordsRequiringInput;
  final bool isReadyForExport;

  const DIOTValidationSummary({
    required this.totalRecords,
    required this.totalErrors,
    required this.totalWarnings,
    required this.recordsWithErrors,
    required this.recordsRequiringInput,
    required this.isReadyForExport,
  });

  int get recordsReady =>
      totalRecords - recordsWithErrors - recordsRequiringInput;
}
