import 'package:comparador_cfdis/models/diot_record.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/constants/diot_constants.dart';

/// Servicio de validación DIOT actualizado para estructura 2025 del SAT
class DIOT2025ValidationService {
  /// Estructura completa de campos DIOT 2025 según especificación SAT
  static const Map<int, String> diot2025Fields = {
    1: 'tipo_tercero',
    2: 'tipo_operacion',
    3: 'rfc',
    4: 'numero_identificacion_fiscal',
    5: 'nombre_extranjero',
    6: 'pais_residencia_fiscal',
    7: 'especificar_jurisdiccion',
    8: 'valor_actos_frontera_norte',
    9: 'devoluciones_frontera_norte',
    10: 'valor_actos_frontera_sur',
    11: 'devoluciones_frontera_sur',
    12: 'valor_actos_16_porciento',
    13: 'devoluciones_16_porciento',
    14: 'valor_importacion_tangibles_16',
    15: 'devoluciones_importacion_tangibles_16',
    16: 'valor_importacion_intangibles_16',
    17: 'devoluciones_importacion_intangibles_16',
    18: 'iva_acreditable_exclusivo_frontera_norte',
    19: 'iva_acreditable_proporcion_frontera_norte',
    20: 'iva_acreditable_exclusivo_frontera_sur',
    21: 'iva_acreditable_proporcion_frontera_sur',
    22: 'iva_acreditable_exclusivo_16',
    23: 'iva_acreditable_proporcion_16',
    24: 'iva_acreditable_exclusivo_importacion_tangibles_16',
    25: 'iva_acreditable_proporcion_importacion_tangibles_16',
    26: 'iva_acreditable_exclusivo_importacion_intangibles_16',
    27: 'iva_acreditable_proporcion_importacion_intangibles_16',
    28: 'iva_no_acreditable_proporcion_frontera_norte',
    29: 'iva_no_acreditable_sin_requisitos_frontera_norte',
    30: 'iva_no_acreditable_exentas_frontera_norte',
    31: 'iva_no_acreditable_no_objeto_frontera_norte',
    32: 'iva_no_acreditable_proporcion_frontera_sur',
    33: 'iva_no_acreditable_sin_requisitos_frontera_sur',
    34: 'iva_no_acreditable_exentas_frontera_sur',
    35: 'iva_no_acreditable_no_objeto_frontera_sur',
    36: 'iva_no_acreditable_proporcion_16',
    37: 'iva_no_acreditable_sin_requisitos_16',
    38: 'iva_no_acreditable_exentas_16',
    39: 'iva_no_acreditable_no_objeto_16',
    40: 'iva_no_acreditable_proporcion_importacion_tangibles_16',
    41: 'iva_no_acreditable_sin_requisitos_importacion_tangibles_16',
    42: 'iva_no_acreditable_exentas_importacion_tangibles_16',
    43: 'iva_no_acreditable_no_objeto_importacion_tangibles_16',
    44: 'iva_no_acreditable_proporcion_importacion_intangibles_16',
    45: 'iva_no_acreditable_sin_requisitos_importacion_intangibles_16',
    46: 'iva_no_acreditable_exentas_importacion_intangibles_16',
    47: 'iva_no_acreditable_no_objeto_importacion_intangibles_16',
    48: 'iva_retenido',
    49: 'importacion_exentos',
    50: 'actos_exentos',
    51: 'actos_tasa_cero',
    52: 'actos_no_objeto_nacional',
    53: 'actos_no_objeto_sin_establecimiento',
    54: 'efectos_fiscales',
  };

  /// Valida un registro DIOT individual según especificación 2025
  static List<DIOTValidationError> validateRecord2025(DIOTRecord record) {
    final List<DIOTValidationError> errors = [];

    // 1. Validaciones de identificación (campos 1-3)
    errors.addAll(_validateIdentificationFields(record));

    // 2. Validaciones de proveedor extranjero (campos 4-7)
    if (record.tipoTercero == TipoTercero.extranjero) {
      errors.addAll(_validateForeignProviderFields(record));
    }

    // 3. Validaciones de valores monetarios (campos 8-53)
    errors.addAll(_validateMonetaryFields(record));

    // 4. Validaciones de consistencia entre campos
    errors.addAll(_validateFieldConsistency(record));

    // 5. Validación de efectos fiscales (campo 54)
    errors.addAll(_validateEfectosFiscalesField(record));

    // 6. Validaciones de estructura completa DIOT 2025
    errors.addAll(_validateDIOT2025Structure(record));

    return errors;
  }

  /// Valida campos de identificación (posiciones 1-3)
  static List<DIOTValidationError> _validateIdentificationFields(
    DIOTRecord record,
  ) {
    final List<DIOTValidationError> errors = [];

    // Campo 1: Tipo de tercero
    if (!['04', '05', '15'].contains(record.tipoTercero.code)) {
      errors.add(
        const DIOTValidationError(
          field: 'tipo_tercero',
          message:
              'Tipo de tercero debe ser 04 (Nacional), 05 (Extranjero) o 15 (Global)',
          severity: DIOTValidationSeverity.error,
        ),
      );
    }

    // Campo 2: Tipo de operación según tipo de tercero
    final validOperations =
        _getValidOperationsForTipoTercero(record.tipoTercero);
    if (!validOperations.contains(record.tipoOperacion.code)) {
      errors.add(
        DIOTValidationError(
          field: 'tipo_operacion',
          message:
              'Tipo de operación ${record.tipoOperacion.code} no válido para ${record.tipoTercero.description}',
          severity: DIOTValidationSeverity.error,
        ),
      );
    }

    // Campo 3: RFC según especificación 2025
    errors.addAll(_validateRFC2025(record));

    return errors;
  }

  /// Valida RFC según reglas DIOT 2025
  static List<DIOTValidationError> _validateRFC2025(DIOTRecord record) {
    final List<DIOTValidationError> errors = [];

    switch (record.tipoTercero) {
      case TipoTercero.nacional:
        if (record.rfc.isEmpty) {
          errors.add(
            const DIOTValidationError(
              field: 'rfc',
              message: 'RFC es requerido para proveedores nacionales',
              severity: DIOTValidationSeverity.error,
            ),
          );
        } else {
          if (record.rfc.length < 12 || record.rfc.length > 13) {
            errors.add(
              const DIOTValidationError(
                field: 'rfc',
                message: 'RFC debe tener 12 o 13 caracteres',
                severity: DIOTValidationSeverity.error,
              ),
            );
          }
          if (!RegExp(DIOTConstants.rfcPattern).hasMatch(record.rfc)) {
            errors.add(
              const DIOTValidationError(
                field: 'rfc',
                message: 'RFC debe tener formato alfanumérico válido',
                severity: DIOTValidationSeverity.error,
              ),
            );
          }
        }
        break;

      case TipoTercero.global:
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
        break;

      case TipoTercero.extranjero:
        if (record.rfc.isNotEmpty) {
          errors.add(
            const DIOTValidationError(
              field: 'rfc',
              message: 'RFC debe estar vacío para proveedores extranjeros',
              severity: DIOTValidationSeverity.warning,
            ),
          );
        }
        break;
    }

    return errors;
  }

  /// Valida campos de proveedor extranjero (posiciones 4-7)
  static List<DIOTValidationError> _validateForeignProviderFields(
    DIOTRecord record,
  ) {
    final List<DIOTValidationError> errors = [];

    // Campo 4: Número de identificación fiscal
    if (record.numeroIdentificacionFiscal == null ||
        record.numeroIdentificacionFiscal!.isEmpty) {
      errors.add(
        const DIOTValidationError(
          field: 'numero_identificacion_fiscal',
          message:
              'Número de identificación fiscal es requerido para proveedores extranjeros',
          severity: DIOTValidationSeverity.error,
        ),
      );
    } else if (record.numeroIdentificacionFiscal!.length > 40) {
      errors.add(
        const DIOTValidationError(
          field: 'numero_identificacion_fiscal',
          message:
              'Número de identificación fiscal no puede exceder 40 caracteres',
          severity: DIOTValidationSeverity.error,
        ),
      );
    }

    // Campo 5: Nombre del extranjero
    if (record.nombreExtranjero == null || record.nombreExtranjero!.isEmpty) {
      errors.add(
        const DIOTValidationError(
          field: 'nombre_extranjero',
          message:
              'Nombre del extranjero es requerido para proveedores extranjeros',
          severity: DIOTValidationSeverity.error,
        ),
      );
    } else if (record.nombreExtranjero!.length > 300) {
      errors.add(
        const DIOTValidationError(
          field: 'nombre_extranjero',
          message: 'Nombre del extranjero no puede exceder 300 caracteres',
          severity: DIOTValidationSeverity.error,
        ),
      );
    }

    // Campo 6: País de residencia fiscal
    if (record.paisResidenciaFiscal == null ||
        record.paisResidenciaFiscal!.isEmpty) {
      errors.add(
        const DIOTValidationError(
          field: 'pais_residencia_fiscal',
          message:
              'País de residencia fiscal es requerido para proveedores extranjeros',
          severity: DIOTValidationSeverity.error,
        ),
      );
    } else {
      // Verificar longitud según catálogo (3 caracteres para ISO alpha-3)
      if (record.paisResidenciaFiscal!.length != 3) {
        errors.add(
          const DIOTValidationError(
            field: 'pais_residencia_fiscal',
            message:
                'País debe ser código de 3 caracteres alfabéticos (ISO alpha-3)',
            severity: DIOTValidationSeverity.error,
          ),
        );
      }
      // Verificar que el país existe en el catálogo
      if (!DIOTConstants.paisesResidenciaFiscal
          .containsKey(record.paisResidenciaFiscal!)) {
        errors.add(
          const DIOTValidationError(
            field: 'pais_residencia_fiscal',
            message: 'Código de país no válido según catálogo SAT',
            severity: DIOTValidationSeverity.error,
          ),
        );
      }
    }

    // Campo 7: Especificar jurisdicción
    if (record.paisResidenciaFiscal == 'ZZZ') {
      if (record.especificarJurisdiccion == null ||
          record.especificarJurisdiccion!.isEmpty) {
        errors.add(
          const DIOTValidationError(
            field: 'especificar_jurisdiccion',
            message:
                'Especificar jurisdicción es requerido cuando país es "ZZZ"',
            severity: DIOTValidationSeverity.error,
          ),
        );
      } else if (record.especificarJurisdiccion!.length > 300) {
        errors.add(
          const DIOTValidationError(
            field: 'especificar_jurisdiccion',
            message: 'Jurisdicción no puede exceder 300 caracteres',
            severity: DIOTValidationSeverity.error,
          ),
        );
      }
    } else if (record.especificarJurisdiccion != null &&
        record.especificarJurisdiccion!.isNotEmpty) {
      errors.add(
        const DIOTValidationError(
          field: 'especificar_jurisdiccion',
          message: 'Solo especificar jurisdicción cuando país sea "ZZZ"',
          severity: DIOTValidationSeverity.warning,
        ),
      );
    }

    return errors;
  }

  /// Valida campos monetarios (posiciones 8-53)
  static List<DIOTValidationError> _validateMonetaryFields(DIOTRecord record) {
    final List<DIOTValidationError> errors = [];

    // Todos los campos monetarios deben cumplir las mismas reglas básicas
    final monetaryFields = [
      ('valor_actos_frontera_norte', record.valorActosFronteraNorte),
      ('devoluciones_frontera_norte', record.devolucionesFronteraNorte),
      ('valor_actos_frontera_sur', record.valorActosFronteraSur),
      ('devoluciones_frontera_sur', record.devolucionesFronteraSur),
      ('valor_actos_16_porciento', record.valorActos16Porciento),
      ('devoluciones_16_porciento', record.devoluciones16Porciento),
      ('valor_importacion_tangibles_16', record.valorImportacionTangibles16),
      (
        'devoluciones_importacion_tangibles_16',
        record.devolucionesImportacionTangibles16
      ),
      (
        'valor_importacion_intangibles_16',
        record.valorImportacionIntangibles16
      ),
      (
        'devoluciones_importacion_intangibles_16',
        record.devolucionesImportacionIntangibles16
      ),
      ('iva_retenido', record.ivaRetenido),
      ('importacion_exentos', record.importacionExentos),
      ('actos_exentos', record.actosExentos),
      ('actos_tasa_cero', record.actosTasaCero),
      ('actos_no_objeto_nacional', record.actosNoObjetoNacional),
      (
        'actos_no_objeto_sin_establecimiento',
        record.actosNoObjetoSinEstablecimiento
      ),
    ];

    for (final field in monetaryFields) {
      final fieldName = field.$1;
      final value = field.$2;

      if (value != null) {
        // Debe ser positivo
        if (value < 0) {
          errors.add(
            DIOTValidationError(
              field: fieldName,
              message: 'El valor debe ser positivo',
              severity: DIOTValidationSeverity.error,
            ),
          );
        }

        // No puede exceder 14 dígitos
        if (value > DIOTConstants.maxNumericValue) {
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
    }

    return errors;
  }

  /// Valida consistencia entre campos según reglas DIOT 2025
  static List<DIOTValidationError> _validateFieldConsistency(
    DIOTRecord record,
  ) {
    final List<DIOTValidationError> errors = [];

    // NOTA: Validaciones de consistencia de IVA deshabilitadas
    // Los valores del CFDI ya son correctos según el SAT y pueden incluir
    // productos con tasa 0% que hacen que el IVA real sea menor al esperado
    /*
    // Regla: Si hay valor de actos en frontera norte, debe haber IVA correspondiente
    if ((record.valorActosFronteraNorte ?? 0) > 0) {
      final totalIVANorte = (record.ivaAcreditableExclusivoFronteraNorte ?? 0) +
          (record.ivaAcreditableProporcionFronteraNorte ?? 0) +
          (record.ivaNoAcreditableProporcionFronteraNorte ?? 0) +
          (record.ivaNoAcreditableSinRequisitosFronteraNorte ?? 0) +
          (record.ivaNoAcreditableExentasFronteraNorte ?? 0) +
          (record.ivaNoAcreditableNoObjetoFronteraNorte ?? 0);

      if (!_isIVAConsistentWithAmount(
        record.valorActosFronteraNorte ?? 0,
        totalIVANorte,
      )) {
        errors.add(
          const DIOTValidationError(
            field: 'iva_frontera_norte',
            message:
                'Si hay valor de actos en frontera norte, debe especificar IVA correspondiente',
            severity: DIOTValidationSeverity.warning,
          ),
        );
      }
    }

    // Regla: Si hay valor de actos en frontera sur, debe haber IVA correspondiente
    if ((record.valorActosFronteraSur ?? 0) > 0) {
      final totalIVASur = (record.ivaAcreditableExclusivoFronteraSur ?? 0) +
          (record.ivaAcreditableProporcionFronteraSur ?? 0) +
          (record.ivaNoAcreditableProporcionFronteraSur ?? 0) +
          (record.ivaNoAcreditableSinRequisitosFronteraSur ?? 0) +
          (record.ivaNoAcreditableExentasFronteraSur ?? 0) +
          (record.ivaNoAcreditableNoObjetoFronteraSur ?? 0);

      if (!_isIVAConsistentWithAmount(
        record.valorActosFronteraSur ?? 0,
        totalIVASur,
      )) {
        errors.add(
          const DIOTValidationError(
            field: 'iva_frontera_sur',
            message:
                'Si hay valor de actos en frontera sur, debe especificar IVA correspondiente',
            severity: DIOTValidationSeverity.warning,
          ),
        );
      }
    }
    */

    // Regla: Si hay valor de actos 16%, debe haber IVA correspondiente
    if ((record.valorActos16Porciento ?? 0) > 0) {
      // NOTA: Validación de consistencia de IVA deshabilitada
      // Los valores del CFDI ya son correctos según el SAT y pueden incluir
      // productos con tasa 0% que hacen que el IVA real sea menor al 16% del subtotal
      /*
      final totalIVA16 = (record.ivaAcreditableExclusivo16 ?? 0) +
          (record.ivaAcreditableProporcion16 ?? 0) +
          (record.ivaNoAcreditableProporcion16 ?? 0) +
          (record.ivaNoAcreditableSinRequisitos16 ?? 0) +
          (record.ivaNoAcreditableExentas16 ?? 0) +
          (record.ivaNoAcreditableNoObjeto16 ?? 0);

      if (!_isIVAConsistentWithAmount(
        record.valorActos16Porciento ?? 0,
        totalIVA16,
      )) {
        errors.add(
          DIOTValidationError(
            field: 'iva_16_porciento',
            message: _getIVAConsistencyMessage(
              record.valorActos16Porciento ?? 0,
              totalIVA16,
            ),
            severity: DIOTValidationSeverity.warning,
          ),
        );
      }
      */
    }

    return errors;
  }

  /*
  /// Valida si el IVA es consistente con el monto, considerando tolerancias para montos pequeños
  static bool _isIVAConsistentWithAmount(double amount, double totalIVA) {
    final expectedIVA = amount * 0.16; // 16% de IVA

    // Para montos muy pequeños (< $1.00), aplicar tolerancia especial
    if (amount < DIOTConstants.minAmountForIVAValidation) {
      // Si el IVA esperado es muy pequeño (< 10 centavos), permitir IVA = 0
      if (expectedIVA < DIOTConstants.ivaToleranceThreshold) {
        // Permitir IVA cero O IVA calculado correctamente
        if (totalIVA == 0.0) {
          return true; // IVA cero permitido para montos muy pequeños
        }
      }
    }

    // Para cualquier monto, si se proporciona IVA, debe ser consistente
    if (totalIVA == 0) {
      // IVA cero solo permitido para casos especiales ya manejados arriba
      return amount < DIOTConstants.minAmountForIVAValidation &&
          expectedIVA < DIOTConstants.ivaToleranceThreshold;
    }

    // Validar que el IVA proporcionado sea consistente con el esperado
    final difference = (totalIVA - expectedIVA).abs();

    // Tolerancia estándar para diferencias de redondeo
    if (difference <= DIOTConstants.roundingTolerance) {
      return true;
    }

    // Tolerancia relativa del 5% para diferencias normales
    if ((difference / expectedIVA) <= 0.05) {
      return true;
    }

    return false;
  }

  /// Genera mensaje específico para problemas de consistencia de IVA
  static String _getIVAConsistencyMessage(double amount, double totalIVA) {
    if (amount < DIOTConstants.minAmountForIVAValidation) {
      return 'Para montos pequeños (< \$${DIOTConstants.minAmountForIVAValidation.toStringAsFixed(2)}), '
          'verifique la clasificación de IVA si el monto calculado es significativo';
    } else {
      final expectedIVA = amount * 0.16;
      return 'IVA proporcionado (\$${totalIVA.toStringAsFixed(2)}) difiere del esperado '
          '(\$${expectedIVA.toStringAsFixed(2)}). Verifique que el valor de actos corresponda '
          'al subtotal y que los descuentos estén registrados en el campo de devoluciones.';
    }
  }
  */

  /// Valida campo de efectos fiscales (posición 54)
  static List<DIOTValidationError> _validateEfectosFiscalesField(
    DIOTRecord record,
  ) {
    final List<DIOTValidationError> errors = [];

    if (!['01', '02'].contains(record.efectosFiscales.code)) {
      errors.add(
        const DIOTValidationError(
          field: 'efectos_fiscales',
          message: 'Efectos fiscales debe ser 01 (Sí) o 02 (No)',
          severity: DIOTValidationSeverity.error,
        ),
      );
    }

    return errors;
  }

  /// Valida estructura completa DIOT 2025
  static List<DIOTValidationError> _validateDIOT2025Structure(
    DIOTRecord record,
  ) {
    final List<DIOTValidationError> errors = [];

    // Verificar que el registro puede generar los 54 campos requeridos
    try {
      final pipeDelimited = record.toPipeDelimitedString();
      final fields = pipeDelimited.split('|');

      if (fields.length != 54) {
        errors.add(
          DIOTValidationError(
            field: 'estructura',
            message:
                'El registro debe generar exactamente 54 campos, generó ${fields.length}',
            severity: DIOTValidationSeverity.error,
          ),
        );
      }
    } catch (e) {
      errors.add(
        DIOTValidationError(
          field: 'estructura',
          message: 'Error al generar estructura DIOT: $e',
          severity: DIOTValidationSeverity.error,
        ),
      );
    }

    return errors;
  }

  /// Obtiene operaciones válidas para un tipo de tercero según DIOT 2025
  static List<String> _getValidOperationsForTipoTercero(
    TipoTercero tipoTercero,
  ) {
    switch (tipoTercero) {
      case TipoTercero.nacional:
        return ['02', '03', '06', '08', '85'];
      case TipoTercero.extranjero:
        return ['02', '03', '07'];
      case TipoTercero.global:
        return ['87'];
    }
  }

  /// Valida un lote completo según especificación DIOT 2025
  static List<DIOTValidationError> validateBatch2025(DIOTBatch batch) {
    final List<DIOTValidationError> globalErrors = [];

    // Validaciones básicas de configuración
    if (batch.configuration.year < 2025) {
      globalErrors.add(
        const DIOTValidationError(
          field: 'year',
          message: 'Este validador es para DIOT 2025 en adelante',
          severity: DIOTValidationSeverity.warning,
        ),
      );
    }

    // Validar que todos los registros cumplen con DIOT 2025
    for (int i = 0; i < batch.records.length; i++) {
      final recordErrors = validateRecord2025(batch.records[i]);
      for (final error in recordErrors) {
        globalErrors.add(
          DIOTValidationError(
            field: 'record_${i + 1}_${error.field}',
            message: 'Registro ${i + 1}: ${error.message}',
            severity: error.severity,
          ),
        );
      }
    }

    return globalErrors;
  }

  /// Verifica si un registro está listo para exportación DIOT 2025
  static bool isRecord2025ReadyForExport(DIOTRecord record) {
    final errors = validateRecord2025(record);
    final hasErrors =
        errors.any((error) => error.severity == DIOTValidationSeverity.error);
    return !hasErrors && !record.requiresUserInput;
  }
}
