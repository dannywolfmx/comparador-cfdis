import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/diot_record.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/constants/diot_constants.dart';

/// Servicio para mapear CFDIs a registros DIOT
class DIOTMappingService {
  /// Convierte lista de CFDIs a registros DIOT preliminares
  static List<DIOTRecord> mapCFDIsToRecords(
    List<CFDI> cfdis,
    DIOTConfiguration configuration,
  ) {
    // Agrupar CFDIs por RFC del emisor
    final Map<String, List<CFDI>> cfdisGroupedByRfc = {};

    for (final cfdi in cfdis) {
      final rfc = cfdi.emisor?.rfc ?? '';
      if (rfc.isNotEmpty) {
        cfdisGroupedByRfc.putIfAbsent(rfc, () => []).add(cfdi);
      }
    }

    final List<DIOTRecord> records = [];

    // Crear un registro DIOT por cada RFC
    for (final entry in cfdisGroupedByRfc.entries) {
      final rfc = entry.key;
      final rfcCfdis = entry.value;

      final record = _createRecordFromCFDIs(rfc, rfcCfdis, configuration);
      records.add(record);
    }

    return records;
  }

  /// Crea un registro DIOT desde un grupo de CFDIs del mismo RFC
  static DIOTRecord _createRecordFromCFDIs(
    String rfc,
    List<CFDI> cfdis,
    DIOTConfiguration configuration,
  ) {
    // Obtener configuraciones predeterminadas del usuario
    final prefs = configuration.userPreferences;

    // Calcular valores monetarios desde CFDIs
    final values = _calculateValuesFromCFDIs(cfdis);

    // Determinar tipo de tercero (con configuración del usuario o inferido)
    final tipoTercero =
        prefs.rfcToTipoTercero[rfc] ?? _inferTipoTercero(rfc, cfdis);

    // Determinar tipo de operación
    final tipoOperacion = prefs.rfcToTipoOperacion[rfc] ??
        _inferTipoOperacion(tipoTercero, cfdis);

    // Clasificaciones regionales e IVA
    final clasificacionRegional = prefs.rfcToClasificacionRegional[rfc];
    final clasificacionIVA = prefs.rfcToClasificacionIVA[rfc];

    // Efectos fiscales
    final efectosFiscales =
        prefs.rfcToEfectosFiscales[rfc] ?? EfectosFiscales.si;

    // Información de extranjero si aplica
    final extranjeroInfo = prefs.rfcToExtranjeroInfo[rfc];

    // Determinar si requiere intervención del usuario
    final requiresUserInput = _determineRequiresUserInput(
      tipoTercero,
      clasificacionRegional,
      clasificacionIVA,
      extranjeroInfo,
      values,
    );

    // Crear el registro
    return DIOTRecord(
      rfc: rfc,
      numeroIdentificacionFiscal: extranjeroInfo?.numeroIdentificacionFiscal,
      nombreExtranjero: extranjeroInfo?.nombreExtranjero,
      paisResidenciaFiscal: extranjeroInfo?.paisResidenciaFiscal,
      especificarJurisdiccion: extranjeroInfo?.especificarJurisdiccion,
      tipoTercero: tipoTercero,
      tipoOperacion: tipoOperacion,
      clasificacionRegional: clasificacionRegional,
      clasificacionIVA: clasificacionIVA,
      efectosFiscales: efectosFiscales,
      valorActos16Porciento: values.valorActos16Porciento,
      valorActosFronteraNorte: values.valorActosFronteraNorte,
      valorActosFronteraSur: values.valorActosFronteraSur,
      devoluciones16Porciento: values.devoluciones16Porciento,
      ivaAcreditableExclusivo16: values.ivaTotal16,
      requiresUserInput: requiresUserInput,
    );
  }

  /// Calcula valores monetarios desde CFDIs
  static _CFDIValues _calculateValuesFromCFDIs(List<CFDI> cfdis) {
    double valorActos16Porciento = 0;
    const double valorActosFronteraNorte = 0;
    const double valorActosFronteraSur = 0;
    double ivaTotal16 = 0;
    double devoluciones16Porciento = 0;

    for (final cfdi in cfdis) {
      // 💱 CONVERSIÓN DE TIPO DE CAMBIO A PESOS MEXICANOS
      final tipoCambio = double.tryParse(cfdi.tipoCambio ?? '1') ?? 1.0;
      final isMonedaExtranjera = tipoCambio != 1.0;

      if (isMonedaExtranjera) {
        print('💱 CFDI en moneda extranjera detectado:');
        print('   RFC: ${cfdi.emisor?.rfc}');
        print('   Moneda: ${cfdi.moneda ?? 'USD'}');
        print('   Tipo de cambio: $tipoCambio');
      }

      // Tomar valores directamente del CFDI y convertir a pesos si es necesario
      final subtotalOriginal = double.tryParse(cfdi.subTotal ?? '0') ?? 0;
      final descuentoOriginal = double.tryParse(cfdi.descuento ?? '0') ?? 0;

      // Aplicar conversión a pesos mexicanos
      final subtotal =
          isMonedaExtranjera ? subtotalOriginal * tipoCambio : subtotalOriginal;
      final descuento = isMonedaExtranjera
          ? descuentoOriginal * tipoCambio
          : descuentoOriginal;

      if (isMonedaExtranjera) {
        print(
          '   Subtotal original: \$${subtotalOriginal.toStringAsFixed(2)} ${cfdi.moneda ?? 'USD'}',
        );
        print('   Subtotal en MXN: \$${subtotal.toStringAsFixed(2)}');
        print(
          '   Descuento original: \$${descuentoOriginal.toStringAsFixed(2)} ${cfdi.moneda ?? 'USD'}',
        );
        print('   Descuento en MXN: \$${descuento.toStringAsFixed(2)}');
      }

      // Usar TotalImpuestosTrasladados directamente del CFDI si está disponible
      double iva = 0;

      // DEBUG: Para el RFC problemático específico
      final rfcEmisor = cfdi.emisor?.rfc ?? '';
      if (rfcEmisor.isNotEmpty) {
        print('🔍 DEBUG RFC $rfcEmisor:');
        print('   cfdi.impuestos != null: ${cfdi.impuestos != null}');
        if (cfdi.impuestos != null) {
          print(
            '   TotalImpuestosTrasladados: ${cfdi.impuestos!.totalImpuestosTrasladados}',
          );
          print('   > 0: ${cfdi.impuestos!.totalImpuestosTrasladados > 0}');
        }
      }

      if (cfdi.impuestos?.totalImpuestosTrasladados != null &&
          cfdi.impuestos!.totalImpuestosTrasladados > 0) {
        final ivaOriginal = cfdi.impuestos!.totalImpuestosTrasladados;
        iva = isMonedaExtranjera ? ivaOriginal * tipoCambio : ivaOriginal;

        if (rfcEmisor.isNotEmpty) print('   ✅ USANDO: $iva');
        if (isMonedaExtranjera) {
          print(
            '   IVA original: \$${ivaOriginal.toStringAsFixed(2)} ${cfdi.moneda ?? 'USD'}',
          );
          print('   IVA en MXN: \$${iva.toStringAsFixed(2)}');
        }
      } else {
        // Fallback: calcular desde conceptos solo si no está disponible el total
        iva = _calculateIVAFromCFDI(cfdi, tipoCambio);
        if (isMonedaExtranjera) {
          print('   ⚠️  FALLBACK convertido a MXN: $iva');
        } else {
          if (rfcEmisor.isNotEmpty) print('   ⚠️  FALLBACK: $iva');
        }
      }

      // Para DIOT: valor de actos es el subtotal, descuentos van en devoluciones
      // TODOS LOS VALORES YA ESTÁN EN PESOS MEXICANOS
      valorActos16Porciento += subtotal;
      devoluciones16Porciento += descuento;
      ivaTotal16 += iva;
    }

    return _CFDIValues(
      valorActos16Porciento: valorActos16Porciento,
      valorActosFronteraNorte: valorActosFronteraNorte,
      valorActosFronteraSur: valorActosFronteraSur,
      ivaTotal16: ivaTotal16,
      devoluciones16Porciento: devoluciones16Porciento,
    );
  }

  /// Calcula el IVA total de un CFDI (fallback cuando no está disponible TotalImpuestosTrasladados)
  /// NOTA: Este método puede tener discrepancias con el total real del CFDI debido a:
  /// - Productos con tasa 0% que no aparecen en traslados
  /// - Redondeos en el cálculo individual vs total
  /// - Otros casos especiales del SAT
  ///
  /// [tipoCambio] - Tipo de cambio para convertir a pesos mexicanos
  static double _calculateIVAFromCFDI(CFDI cfdi, double tipoCambio) {
    double totalIVA = 0;

    // Sumar IVA de conceptos (en moneda original)
    if (cfdi.conceptos?.concepto != null) {
      for (final concepto in cfdi.conceptos!.concepto!) {
        for (final traslado in concepto.traslados) {
          if (traslado.impuesto == '002') {
            // IVA
            totalIVA += traslado.importe;
          }
        }
      }
    }

    // Convertir a pesos mexicanos si es necesario
    final isMonedaExtranjera = tipoCambio != 1.0;
    return isMonedaExtranjera ? totalIVA * tipoCambio : totalIVA;
  }

  /// Infiere el tipo de tercero basado en el RFC
  static TipoTercero _inferTipoTercero(String rfc, List<CFDI> cfdis) {
    // Si es el RFC global especial
    if (rfc == DIOTConstants.rfcProveedorGlobal) {
      return TipoTercero.global;
    }

    // Si el RFC tiene formato de persona física o moral mexicana
    if (RegExp(DIOTConstants.rfcPattern).hasMatch(rfc)) {
      return TipoTercero.nacional;
    }

    // Por defecto, asumir extranjero si no coincide con patrón mexicano
    return TipoTercero.extranjero;
  }

  /// Infiere el tipo de operación basado en los CFDIs
  static TipoOperacion _inferTipoOperacion(
    TipoTercero tipoTercero,
    List<CFDI> cfdis,
  ) {
    // Para proveedor global, solo hay una opción
    if (tipoTercero == TipoTercero.global) {
      return TipoOperacion.operacionesGlobales;
    }

    // Analizar los CFDIs para inferir el tipo de operación más común
    final Map<String, int> conceptoFrequency = {};

    for (final cfdi in cfdis) {
      if (cfdi.conceptos?.concepto != null) {
        for (final concepto in cfdi.conceptos!.concepto!) {
          final descripcion = concepto.descripcion.toLowerCase();

          // Inferir basado en palabras clave en las descripciones
          if (descripcion.contains('servicio') ||
              descripcion.contains('consultoría') ||
              descripcion.contains('honorarios') ||
              descripcion.contains('profesional')) {
            conceptoFrequency['servicios'] =
                (conceptoFrequency['servicios'] ?? 0) + 1;
          } else if (descripcion.contains('arrenda') ||
              descripcion.contains('renta') ||
              descripcion.contains('uso') ||
              descripcion.contains('goce')) {
            conceptoFrequency['uso_goce'] =
                (conceptoFrequency['uso_goce'] ?? 0) + 1;
          } else {
            conceptoFrequency['bienes'] =
                (conceptoFrequency['bienes'] ?? 0) + 1;
          }
        }
      }
    }

    // Determinar el tipo más frecuente
    String mostFrequent = 'bienes';
    int maxCount = 0;

    for (final entry in conceptoFrequency.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostFrequent = entry.key;
      }
    }

    // Mapear a tipo de operación
    switch (mostFrequent) {
      case 'servicios':
        return TipoOperacion.prestacionServicios;
      case 'uso_goce':
        return TipoOperacion.usoGoceTemporal;
      default:
        return TipoOperacion.enajenacionBienes;
    }
  }

  /// Determina si el registro requiere intervención del usuario
  static bool _determineRequiresUserInput(
    TipoTercero tipoTercero,
    ClasificacionRegional? clasificacionRegional,
    ClasificacionIVA? clasificacionIVA,
    ProveedorExtranjeroInfo? extranjeroInfo,
    _CFDIValues values,
  ) {
    // Si es extranjero y no tiene información completa
    if (tipoTercero == TipoTercero.extranjero && extranjeroInfo == null) {
      return true;
    }

    // Si tiene valores de IVA pero no tiene clasificación
    if (values.ivaTotal16 > 0 && clasificacionIVA == null) {
      return true;
    }

    // Si no tiene clasificación regional definida
    if (clasificacionRegional == null) {
      return true;
    }

    return false;
  }

  /// Actualiza un registro con información del usuario
  static DIOTRecord updateRecordWithUserInput(
    DIOTRecord record,
    Map<String, dynamic> userInput,
  ) {
    return record.copyWith(
      tipoTercero: userInput['tipoTercero'] ?? record.tipoTercero,
      tipoOperacion: userInput['tipoOperacion'] ?? record.tipoOperacion,
      clasificacionRegional:
          userInput['clasificacionRegional'] ?? record.clasificacionRegional,
      clasificacionIVA:
          userInput['clasificacionIVA'] ?? record.clasificacionIVA,
      efectosFiscales: userInput['efectosFiscales'] ?? record.efectosFiscales,
      numeroIdentificacionFiscal: userInput['numeroIdentificacionFiscal'] ??
          record.numeroIdentificacionFiscal,
      nombreExtranjero:
          userInput['nombreExtranjero'] ?? record.nombreExtranjero,
      paisResidenciaFiscal:
          userInput['paisResidenciaFiscal'] ?? record.paisResidenciaFiscal,
      especificarJurisdiccion: userInput['especificarJurisdiccion'] ??
          record.especificarJurisdiccion,
      // 🚫 ELIMINADO: Ya no permitir sobrescribir devoluciones
      // El descuento SIEMPRE debe venir del CFDI automáticamente
      // devoluciones16Porciento: userInput['devoluciones'] != null
      //     ? (userInput['devoluciones'] as num).toDouble()
      //     : record.devoluciones16Porciento,
      requiresUserInput: false,
    );
  }

  /// Redistribuye valores entre regiones basado en clasificación del usuario
  static DIOTRecord redistributeValuesByRegion(
    DIOTRecord record,
    ClasificacionRegional region,
  ) {
    switch (region) {
      case ClasificacionRegional.fronteraNorte:
        return record.copyWith(
          valorActosFronteraNorte: record.valorActos16Porciento,
          valorActos16Porciento: 0,
          ivaAcreditableExclusivoFronteraNorte:
              record.ivaAcreditableExclusivo16,
          ivaAcreditableExclusivo16: 0,
        );
      case ClasificacionRegional.fronteraSur:
        return record.copyWith(
          valorActosFronteraSur: record.valorActos16Porciento,
          valorActos16Porciento: 0,
          ivaAcreditableExclusivoFronteraSur: record.ivaAcreditableExclusivo16,
          ivaAcreditableExclusivo16: 0,
        );
      case ClasificacionRegional.nacional:
        // Ya está en la clasificación correcta
        return record;
    }
  }
}

/// Clase auxiliar para valores calculados desde CFDIs
class _CFDIValues {
  final double valorActos16Porciento;
  final double valorActosFronteraNorte;
  final double valorActosFronteraSur;
  final double ivaTotal16;
  final double devoluciones16Porciento;

  const _CFDIValues({
    required this.valorActos16Porciento,
    required this.valorActosFronteraNorte,
    required this.valorActosFronteraSur,
    required this.ivaTotal16,
    required this.devoluciones16Porciento,
  });
}
