import 'package:comparador_cfdis/models/diot_record.dart';
import 'package:comparador_cfdis/constants/diot_constants.dart';

/// Servicio de mapeo para estructura DIOT 2025 (54 campos)
class DIOT2025MappingService {
  /// Mapea un DIOTRecord a la estructura completa de 54 campos DIOT 2025
  static Map<int, String> mapRecordToFields(DIOTRecord record) {
    final Map<int, String> fields = {};

    // Campos 1-7: Identificación y datos del tercero
    fields[1] = record.tipoTercero.code; // tipo_tercero
    fields[2] = record.tipoOperacion.code; // tipo_operacion
    fields[3] = _mapRFCField(record); // rfc
    fields[4] = _mapForeignIdField(record); // numero_identificacion_fiscal
    fields[5] = _mapForeignNameField(record); // nombre_extranjero
    fields[6] = _mapCountryField(record); // pais_residencia_fiscal
    fields[7] = _mapJurisdictionField(record); // especificar_jurisdiccion

    // Campos 8-17: Valores de actos y devoluciones
    fields[8] = _formatNumericValue(
        record.valorActosFronteraNorte); // valor_actos_frontera_norte
    fields[9] = _formatNumericValue(
        record.devolucionesFronteraNorte); // devoluciones_frontera_norte
    fields[10] = _formatNumericValue(
        record.valorActosFronteraSur); // valor_actos_frontera_sur
    fields[11] = _formatNumericValue(
        record.devolucionesFronteraSur); // devoluciones_frontera_sur
    fields[12] = _formatNumericValue(
        record.valorActos16Porciento); // valor_actos_16_porciento
    fields[13] = _formatNumericValue(
        record.devoluciones16Porciento); // devoluciones_16_porciento
    fields[14] = _formatNumericValue(
        record.valorImportacionTangibles16); // valor_importacion_tangibles_16
    fields[15] = _formatNumericValue(record
        .devolucionesImportacionTangibles16); // devoluciones_importacion_tangibles_16
    fields[16] = _formatNumericValue(record
        .valorImportacionIntangibles16); // valor_importacion_intangibles_16
    fields[17] = _formatNumericValue(record
        .devolucionesImportacionIntangibles16); // devoluciones_importacion_intangibles_16

    // Campos 18-27: IVA acreditable
    fields[18] = _formatNumericValue(record
        .ivaAcreditableExclusivoFronteraNorte); // iva_acreditable_exclusivo_frontera_norte
    fields[19] = _formatNumericValue(record
        .ivaAcreditableProporcionFronteraNorte); // iva_acreditable_proporcion_frontera_norte
    fields[20] = _formatNumericValue(record
        .ivaAcreditableExclusivoFronteraSur); // iva_acreditable_exclusivo_frontera_sur
    fields[21] = _formatNumericValue(record
        .ivaAcreditableProporcionFronteraSur); // iva_acreditable_proporcion_frontera_sur
    fields[22] = _formatNumericValue(
        record.ivaAcreditableExclusivo16); // iva_acreditable_exclusivo_16
    fields[23] = _formatNumericValue(
        record.ivaAcreditableProporcion16); // iva_acreditable_proporcion_16
    fields[24] = _formatNumericValue(record
        .ivaAcreditableExclusivoImportacionTangibles16); // iva_acreditable_exclusivo_importacion_tangibles_16
    fields[25] = _formatNumericValue(record
        .ivaAcreditableProporcionImportacionTangibles16); // iva_acreditable_proporcion_importacion_tangibles_16
    fields[26] = _formatNumericValue(record
        .ivaAcreditableExclusivoImportacionIntangibles16); // iva_acreditable_exclusivo_importacion_intangibles_16
    fields[27] = _formatNumericValue(record
        .ivaAcreditableProporcionImportacionIntangibles16); // iva_acreditable_proporcion_importacion_intangibles_16

    // Campos 28-47: IVA no acreditable
    fields[28] = _formatNumericValue(record
        .ivaNoAcreditableProporcionFronteraNorte); // iva_no_acreditable_proporcion_frontera_norte
    fields[29] = _formatNumericValue(record
        .ivaNoAcreditableSinRequisitosFronteraNorte); // iva_no_acreditable_sin_requisitos_frontera_norte
    fields[30] = _formatNumericValue(record
        .ivaNoAcreditableExentasFronteraNorte); // iva_no_acreditable_exentas_frontera_norte
    fields[31] = _formatNumericValue(record
        .ivaNoAcreditableNoObjetoFronteraNorte); // iva_no_acreditable_no_objeto_frontera_norte
    fields[32] = _formatNumericValue(record
        .ivaNoAcreditableProporcionFronteraSur); // iva_no_acreditable_proporcion_frontera_sur
    fields[33] = _formatNumericValue(record
        .ivaNoAcreditableSinRequisitosFronteraSur); // iva_no_acreditable_sin_requisitos_frontera_sur
    fields[34] = _formatNumericValue(record
        .ivaNoAcreditableExentasFronteraSur); // iva_no_acreditable_exentas_frontera_sur
    fields[35] = _formatNumericValue(record
        .ivaNoAcreditableNoObjetoFronteraSur); // iva_no_acreditable_no_objeto_frontera_sur
    fields[36] = _formatNumericValue(record
        .ivaNoAcreditableProporcion16); // iva_no_acreditable_proporcion_16
    fields[37] = _formatNumericValue(record
        .ivaNoAcreditableSinRequisitos16); // iva_no_acreditable_sin_requisitos_16
    fields[38] = _formatNumericValue(
        record.ivaNoAcreditableExentas16); // iva_no_acreditable_exentas_16
    fields[39] = _formatNumericValue(
        record.ivaNoAcreditableNoObjeto16); // iva_no_acreditable_no_objeto_16
    fields[40] = _formatNumericValue(record
        .ivaNoAcreditableProporcionImportacionTangibles16); // iva_no_acreditable_proporcion_importacion_tangibles_16
    fields[41] = _formatNumericValue(record
        .ivaNoAcreditableSinRequisitosImportacionTangibles16); // iva_no_acreditable_sin_requisitos_importacion_tangibles_16
    fields[42] = _formatNumericValue(record
        .ivaNoAcreditableExentasImportacionTangibles16); // iva_no_acreditable_exentas_importacion_tangibles_16
    fields[43] = _formatNumericValue(record
        .ivaNoAcreditableNoObjetoImportacionTangibles16); // iva_no_acreditable_no_objeto_importacion_tangibles_16
    fields[44] = _formatNumericValue(record
        .ivaNoAcreditableProporcionImportacionIntangibles16); // iva_no_acreditable_proporcion_importacion_intangibles_16
    fields[45] = _formatNumericValue(record
        .ivaNoAcreditableSinRequisitosImportacionIntangibles16); // iva_no_acreditable_sin_requisitos_importacion_intangibles_16
    fields[46] = _formatNumericValue(record
        .ivaNoAcreditableExentasImportacionIntangibles16); // iva_no_acreditable_exentas_importacion_intangibles_16
    fields[47] = _formatNumericValue(record
        .ivaNoAcreditableNoObjetoImportacionIntangibles16); // iva_no_acreditable_no_objeto_importacion_intangibles_16

    // Campos 48-53: Otros valores
    fields[48] = _formatNumericValue(record.ivaRetenido); // iva_retenido
    fields[49] =
        _formatNumericValue(record.importacionExentos); // importacion_exentos
    fields[50] = _formatNumericValue(record.actosExentos); // actos_exentos
    fields[51] = _formatNumericValue(record.actosTasaCero); // actos_tasa_cero
    fields[52] = _formatNumericValue(
        record.actosNoObjetoNacional); // actos_no_objeto_nacional
    fields[53] = _formatNumericValue(record
        .actosNoObjetoSinEstablecimiento); // actos_no_objeto_sin_establecimiento

    // Campo 54: Efectos fiscales
    fields[54] = record.efectosFiscales.code; // efectos_fiscales

    return fields;
  }

  /// Convierte un registro a string pipe-delimited según DIOT 2025
  static String recordToPipeDelimited2025(DIOTRecord record) {
    final fields = mapRecordToFields(record);
    final orderedValues = <String>[];

    // Asegurar que los campos estén en orden 1-54
    for (int i = 1; i <= 54; i++) {
      orderedValues.add(fields[i] ?? '');
    }

    return orderedValues.join(DIOTConstants.fileDelimiter);
  }

  /// Valida que un registro puede generar la estructura completa de 54 campos
  static bool validateFieldCompleteness(DIOTRecord record) {
    try {
      final fields = mapRecordToFields(record);
      return fields.length == 54 &&
          fields.keys.every((key) => key >= 1 && key <= 54);
    } catch (e) {
      return false;
    }
  }

  /// Obtiene un resumen de campos faltantes para completar DIOT 2025
  static List<String> getMissingFields(DIOTRecord record) {
    final missingFields = <String>[];

    // Verificar campos obligatorios según tipo de tercero
    switch (record.tipoTercero) {
      case TipoTercero.extranjero:
        if (record.numeroIdentificacionFiscal == null ||
            record.numeroIdentificacionFiscal!.isEmpty) {
          missingFields.add('numero_identificacion_fiscal');
        }
        if (record.nombreExtranjero == null ||
            record.nombreExtranjero!.isEmpty) {
          missingFields.add('nombre_extranjero');
        }
        if (record.paisResidenciaFiscal == null ||
            record.paisResidenciaFiscal!.isEmpty) {
          missingFields.add('pais_residencia_fiscal');
        }
        if (record.paisResidenciaFiscal == 'ZZZ' &&
            (record.especificarJurisdiccion == null ||
                record.especificarJurisdiccion!.isEmpty)) {
          missingFields.add('especificar_jurisdiccion');
        }
        break;
      case TipoTercero.nacional:
        if (record.rfc.isEmpty) {
          missingFields.add('rfc');
        }
        break;
      case TipoTercero.global:
        if (record.rfc != DIOTConstants.rfcProveedorGlobal) {
          missingFields.add('rfc_global_correcto');
        }
        break;
    }

    // Verificar clasificaciones cuando hay valores de IVA
    if ((record.valorActos16Porciento ?? 0) > 0) {
      if (record.clasificacionRegional == null) {
        missingFields.add('clasificacion_regional');
      }
      if (record.clasificacionIVA == null) {
        missingFields.add('clasificacion_iva');
      }
    }

    return missingFields;
  }

  /// Mapea campo RFC según reglas DIOT 2025
  static String _mapRFCField(DIOTRecord record) {
    switch (record.tipoTercero) {
      case TipoTercero.global:
        return DIOTConstants.rfcProveedorGlobal;
      case TipoTercero.nacional:
        return record.rfc.isEmpty ? '' : record.rfc;
      case TipoTercero.extranjero:
        return ''; // RFC debe estar vacío para extranjeros
    }
  }

  /// Mapea campo de identificación fiscal extranjero
  static String _mapForeignIdField(DIOTRecord record) {
    return record.tipoTercero == TipoTercero.extranjero
        ? (record.numeroIdentificacionFiscal ?? '')
        : '';
  }

  /// Mapea campo de nombre extranjero
  static String _mapForeignNameField(DIOTRecord record) {
    return record.tipoTercero == TipoTercero.extranjero
        ? (record.nombreExtranjero ?? '')
        : '';
  }

  /// Mapea campo de país
  static String _mapCountryField(DIOTRecord record) {
    return record.tipoTercero == TipoTercero.extranjero
        ? (record.paisResidenciaFiscal ?? '')
        : '';
  }

  /// Mapea campo de jurisdicción especial
  static String _mapJurisdictionField(DIOTRecord record) {
    return record.paisResidenciaFiscal == 'ZZZ'
        ? (record.especificarJurisdiccion ?? '')
        : '';
  }

  /// Formatea valores numéricos según especificación DIOT 2025
  static String _formatNumericValue(double? value) {
    if (value == null || value == 0) {
      return ''; // Campo vacío para null o cero según algunos casos
    }

    // DIOT 2025 requiere valores sin decimales
    return value.toInt().toString();
  }

  /// Obtiene nombres de campos en español para mostrar al usuario
  static const Map<int, String> fieldDisplayNames = {
    1: 'Tipo de tercero',
    2: 'Tipo de operación',
    3: 'RFC',
    4: 'Número de identificación fiscal',
    5: 'Nombre del extranjero',
    6: 'País de residencia fiscal',
    7: 'Especificar jurisdicción',
    8: 'Valor actos frontera norte',
    9: 'Devoluciones frontera norte',
    10: 'Valor actos frontera sur',
    11: 'Devoluciones frontera sur',
    12: 'Valor actos 16%',
    13: 'Devoluciones 16%',
    14: 'Valor importación tangibles 16%',
    15: 'Devoluciones importación tangibles 16%',
    16: 'Valor importación intangibles 16%',
    17: 'Devoluciones importación intangibles 16%',
    18: 'IVA acreditable exclusivo frontera norte',
    19: 'IVA acreditable proporción frontera norte',
    20: 'IVA acreditable exclusivo frontera sur',
    21: 'IVA acreditable proporción frontera sur',
    22: 'IVA acreditable exclusivo 16%',
    23: 'IVA acreditable proporción 16%',
    24: 'IVA acreditable exclusivo importación tangibles 16%',
    25: 'IVA acreditable proporción importación tangibles 16%',
    26: 'IVA acreditable exclusivo importación intangibles 16%',
    27: 'IVA acreditable proporción importación intangibles 16%',
    28: 'IVA no acreditable proporción frontera norte',
    29: 'IVA no acreditable sin requisitos frontera norte',
    30: 'IVA no acreditable exentas frontera norte',
    31: 'IVA no acreditable no objeto frontera norte',
    32: 'IVA no acreditable proporción frontera sur',
    33: 'IVA no acreditable sin requisitos frontera sur',
    34: 'IVA no acreditable exentas frontera sur',
    35: 'IVA no acreditable no objeto frontera sur',
    36: 'IVA no acreditable proporción 16%',
    37: 'IVA no acreditable sin requisitos 16%',
    38: 'IVA no acreditable exentas 16%',
    39: 'IVA no acreditable no objeto 16%',
    40: 'IVA no acreditable proporción importación tangibles 16%',
    41: 'IVA no acreditable sin requisitos importación tangibles 16%',
    42: 'IVA no acreditable exentas importación tangibles 16%',
    43: 'IVA no acreditable no objeto importación tangibles 16%',
    44: 'IVA no acreditable proporción importación intangibles 16%',
    45: 'IVA no acreditable sin requisitos importación intangibles 16%',
    46: 'IVA no acreditable exentas importación intangibles 16%',
    47: 'IVA no acreditable no objeto importación intangibles 16%',
    48: 'IVA retenido',
    49: 'Importación exentos',
    50: 'Actos exentos',
    51: 'Actos tasa cero',
    52: 'Actos no objeto nacional',
    53: 'Actos no objeto sin establecimiento',
    54: 'Efectos fiscales',
  };
}
