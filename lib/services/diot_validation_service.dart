import 'package:comparador_cfdis/models/diot_record.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/constants/diot_constants.dart';

/// Servicio para validar registros DIOT según las reglas del SAT
class DIOTValidationService {
  /// Valida un registro DIOT individual
  static List<DIOTValidationError> validateRecord(DIOTRecord record) {
    final List<DIOTValidationError> errors = [];

    // Validaciones de tipo de tercero y RFC
    errors.addAll(_validateTipoTerceroAndRFC(record));

    // Validaciones para proveedor extranjero
    if (record.tipoTercero == TipoTercero.extranjero) {
      errors.addAll(_validateProveedorExtranjero(record));
    }

    // Validaciones de tipo de operación
    errors.addAll(_validateTipoOperacion(record));

    // Validaciones de valores numéricos
    errors.addAll(_validateNumericValues(record));

    // Validaciones de consistencia de IVA
    errors.addAll(_validateIVAConsistency(record));

    // Validaciones de efectos fiscales
    errors.addAll(_validateEfectosFiscales(record));

    return errors;
  }

  /// Valida un lote completo de DIOT
  static List<DIOTValidationError> validateBatch(DIOTBatch batch) {
    final List<DIOTValidationError> globalErrors = [];

    // Validar configuración del lote
    globalErrors.addAll(_validateConfiguration(batch.configuration));

    // Validar que hay registros
    if (batch.records.isEmpty) {
      globalErrors.add(
        const DIOTValidationError(
          field: 'records',
          message: 'El lote DIOT debe contener al menos un registro',
          severity: DIOTValidationSeverity.error,
        ),
      );
    }

    // Validar duplicados por RFC
    globalErrors.addAll(_validateDuplicateRFCs(batch.records));

    // Validar totales del lote
    globalErrors.addAll(_validateBatchTotals(batch));

    return globalErrors;
  }

  /// Valida tipo de tercero y RFC
  static List<DIOTValidationError> _validateTipoTerceroAndRFC(
    DIOTRecord record,
  ) {
    final List<DIOTValidationError> errors = [];

    switch (record.tipoTercero) {
      case TipoTercero.nacional:
      case TipoTercero.global:
        // RFC es requerido
        if (record.rfc.isEmpty) {
          errors.add(
            const DIOTValidationError(
              field: 'rfc',
              message:
                  'RFC es requerido para proveedores nacionales y globales',
              severity: DIOTValidationSeverity.error,
            ),
          );
        } else {
          // Validar formato del RFC
          if (record.tipoTercero == TipoTercero.global) {
            if (record.rfc != DIOTConstants.rfcProveedorGlobal) {
              errors.add(
                const DIOTValidationError(
                  field: 'rfc',
                  message:
                      'Para proveedor global debe usar ${DIOTConstants.rfcProveedorGlobal}',
                  severity: DIOTValidationSeverity.error,
                ),
              );
            }
          } else {
            if (!RegExp(DIOTConstants.rfcPattern).hasMatch(record.rfc)) {
              errors.add(
                const DIOTValidationError(
                  field: 'rfc',
                  message:
                      'RFC debe tener formato válido (12-13 caracteres alfanuméricos)',
                  severity: DIOTValidationSeverity.error,
                ),
              );
            }
          }
        }
        break;

      case TipoTercero.extranjero:
        // RFC no debe estar presente para extranjeros
        if (record.rfc.isNotEmpty) {
          errors.add(
            const DIOTValidationError(
              field: 'rfc',
              message: 'RFC no debe especificarse para proveedores extranjeros',
              severity: DIOTValidationSeverity.warning,
            ),
          );
        }
        break;
    }

    return errors;
  }

  /// Valida campos específicos de proveedor extranjero
  static List<DIOTValidationError> _validateProveedorExtranjero(
    DIOTRecord record,
  ) {
    final List<DIOTValidationError> errors = [];

    // Número de identificación fiscal requerido
    if (record.numeroIdentificacionFiscal == null ||
        record.numeroIdentificacionFiscal!.isEmpty) {
      errors.add(
        const DIOTValidationError(
          field: 'numeroIdentificacionFiscal',
          message:
              'Número de identificación fiscal es requerido para proveedores extranjeros',
          severity: DIOTValidationSeverity.error,
        ),
      );
    } else if (record.numeroIdentificacionFiscal!.length >
        DIOTConstants.maxIdentificacionFiscalLength) {
      errors.add(
        const DIOTValidationError(
          field: 'numeroIdentificacionFiscal',
          message:
              'Número de identificación fiscal no puede exceder ${DIOTConstants.maxIdentificacionFiscalLength} caracteres',
          severity: DIOTValidationSeverity.error,
        ),
      );
    }

    // Nombre del extranjero requerido
    if (record.nombreExtranjero == null || record.nombreExtranjero!.isEmpty) {
      errors.add(
        const DIOTValidationError(
          field: 'nombreExtranjero',
          message:
              'Nombre del extranjero es requerido para proveedores extranjeros',
          severity: DIOTValidationSeverity.error,
        ),
      );
    } else if (record.nombreExtranjero!.length >
        DIOTConstants.maxNombreExtranjeroLength) {
      errors.add(
        const DIOTValidationError(
          field: 'nombreExtranjero',
          message:
              'Nombre del extranjero no puede exceder ${DIOTConstants.maxNombreExtranjeroLength} caracteres',
          severity: DIOTValidationSeverity.error,
        ),
      );
    }

    // País de residencia fiscal requerido
    if (record.paisResidenciaFiscal == null ||
        record.paisResidenciaFiscal!.isEmpty) {
      errors.add(
        const DIOTValidationError(
          field: 'paisResidenciaFiscal',
          message:
              'País de residencia fiscal es requerido para proveedores extranjeros',
          severity: DIOTValidationSeverity.error,
        ),
      );
    } else {
      // Validar que el país existe en el catálogo
      if (!DIOTConstants.paisesResidenciaFiscal
          .containsKey(record.paisResidenciaFiscal!)) {
        errors.add(
          const DIOTValidationError(
            field: 'paisResidenciaFiscal',
            message: 'Código de país no válido según catálogo SAT',
            severity: DIOTValidationSeverity.error,
          ),
        );
      }

      // Validar formato (2 caracteres alfabéticos)
      if (!RegExp(DIOTConstants.paisPattern)
          .hasMatch(record.paisResidenciaFiscal!)) {
        errors.add(
          const DIOTValidationError(
            field: 'paisResidenciaFiscal',
            message: 'País debe ser código de 2 caracteres alfabéticos',
            severity: DIOTValidationSeverity.error,
          ),
        );
      }

      // Validar jurisdicción especial
      if (record.paisResidenciaFiscal == 'ZZZ') {
        if (record.especificarJurisdiccion == null ||
            record.especificarJurisdiccion!.isEmpty) {
          errors.add(
            const DIOTValidationError(
              field: 'especificarJurisdiccion',
              message:
                  'Especificar jurisdicción es requerido cuando país es "ZZZ"',
              severity: DIOTValidationSeverity.error,
            ),
          );
        } else if (record.especificarJurisdiccion!.length >
            DIOTConstants.maxJurisdiccionLength) {
          errors.add(
            const DIOTValidationError(
              field: 'especificarJurisdiccion',
              message:
                  'Jurisdicción no puede exceder ${DIOTConstants.maxJurisdiccionLength} caracteres',
              severity: DIOTValidationSeverity.error,
            ),
          );
        }
      } else {
        // Si no es ZZZ, no debe especificar jurisdicción
        if (record.especificarJurisdiccion != null &&
            record.especificarJurisdiccion!.isNotEmpty) {
          errors.add(
            const DIOTValidationError(
              field: 'especificarJurisdiccion',
              message: 'Solo especificar jurisdicción cuando país sea "ZZZ"',
              severity: DIOTValidationSeverity.warning,
            ),
          );
        }
      }
    }

    return errors;
  }

  /// Valida tipo de operación según tipo de tercero
  static List<DIOTValidationError> _validateTipoOperacion(DIOTRecord record) {
    final List<DIOTValidationError> errors = [];

    final validOperations =
        TipoOperacion.getValidForTipoTercero(record.tipoTercero);

    if (!validOperations.contains(record.tipoOperacion)) {
      errors.add(
        DIOTValidationError(
          field: 'tipoOperacion',
          message:
              'Tipo de operación ${record.tipoOperacion.description} no es válido para ${record.tipoTercero.description}',
          severity: DIOTValidationSeverity.error,
        ),
      );
    }

    return errors;
  }

  /// Valida valores numéricos
  static List<DIOTValidationError> _validateNumericValues(DIOTRecord record) {
    final List<DIOTValidationError> errors = [];

    final numericFields = [
      ('valorActosFronteraNorte', record.valorActosFronteraNorte),
      ('devolucionesFronteraNorte', record.devolucionesFronteraNorte),
      ('valorActosFronteraSur', record.valorActosFronteraSur),
      ('devolucionesFronteraSur', record.devolucionesFronteraSur),
      ('valorActos16Porciento', record.valorActos16Porciento),
      ('devoluciones16Porciento', record.devoluciones16Porciento),
      ('ivaRetenido', record.ivaRetenido),
    ];

    for (final field in numericFields) {
      final fieldName = field.$1;
      final value = field.$2;

      // Validar que es positivo
      if ((value ?? 0) < 0) {
        errors.add(
          DIOTValidationError(
            field: fieldName,
            message: 'El valor debe ser positivo',
            severity: DIOTValidationSeverity.error,
          ),
        );
      }

      // Validar que no excede el máximo
      if ((value ?? 0) > DIOTConstants.maxNumericValue) {
        errors.add(
          DIOTValidationError(
            field: fieldName,
            message:
                'El valor no puede exceder ${DIOTConstants.maxNumericValue} (14 dígitos)',
            severity: DIOTValidationSeverity.error,
          ),
        );
      }
    }

    return errors;
  }

  /// Valida consistencia de valores de IVA
  static List<DIOTValidationError> _validateIVAConsistency(DIOTRecord record) {
    final List<DIOTValidationError> errors = [];

    // Si hay valor de actos, debe haber IVA correspondiente (y viceversa)
    if ((record.valorActosFronteraNorte ?? 0) > 0) {
      final totalIVANorte = (record.ivaAcreditableExclusivoFronteraNorte ?? 0) +
          (record.ivaAcreditableProporcionFronteraNorte ?? 0) +
          (record.ivaNoAcreditableProporcionFronteraNorte ?? 0) +
          (record.ivaNoAcreditableSinRequisitosFronteraNorte ?? 0) +
          (record.ivaNoAcreditableExentasFronteraNorte ?? 0) +
          (record.ivaNoAcreditableNoObjetoFronteraNorte ?? 0);

      if (totalIVANorte == 0) {
        errors.add(
          const DIOTValidationError(
            field: 'ivaFronteraNorte',
            message:
                'Si hay valor de actos en frontera norte, debe especificar IVA correspondiente',
            severity: DIOTValidationSeverity.warning,
          ),
        );
      }
    }

    // Validación similar para otras regiones...

    return errors;
  }

  /// Valida efectos fiscales
  static List<DIOTValidationError> _validateEfectosFiscales(DIOTRecord record) {
    final List<DIOTValidationError> errors = [];

    // Los efectos fiscales son siempre requeridos
    // (ya se maneja en el enum, pero validación adicional si es necesario)

    return errors;
  }

  /// Valida configuración del lote
  static List<DIOTValidationError> _validateConfiguration(
    DIOTConfiguration config,
  ) {
    final List<DIOTValidationError> errors = [];

    // Validar año
    final currentYear = DateTime.now().year;
    if (config.year < 2020 || config.year > currentYear + 1) {
      errors.add(
        DIOTValidationError(
          field: 'year',
          message: 'Año debe estar entre 2020 y ${currentYear + 1}',
          severity: DIOTValidationSeverity.error,
        ),
      );
    }

    // Validar mes
    if (config.month < 1 || config.month > 12) {
      errors.add(
        const DIOTValidationError(
          field: 'month',
          message: 'Mes debe estar entre 1 y 12',
          severity: DIOTValidationSeverity.error,
        ),
      );
    }

    // Validar RFC del declarante si está presente
    if (config.rfcDeclarante != null && config.rfcDeclarante!.isNotEmpty) {
      if (!RegExp(DIOTConstants.rfcPattern).hasMatch(config.rfcDeclarante!)) {
        errors.add(
          const DIOTValidationError(
            field: 'rfcDeclarante',
            message: 'RFC del declarante debe tener formato válido',
            severity: DIOTValidationSeverity.error,
          ),
        );
      }
    }

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

  /// Valida un registro antes de permitir su exportación
  static bool isRecordReadyForExport(DIOTRecord record) {
    final errors = validateRecord(record);
    final hasErrors =
        errors.any((error) => error.severity == DIOTValidationSeverity.error);
    return !hasErrors && !record.requiresUserInput;
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

    // Contar errores de registros
    for (final record in batch.records) {
      bool hasErrors = false;
      for (final error in record.validationErrors) {
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
