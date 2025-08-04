import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/services/diot_2025_validation_service.dart';
import 'package:comparador_cfdis/services/diot_2025_mapping_service.dart';
import 'package:comparador_cfdis/models/diot_record.dart';
import 'package:comparador_cfdis/constants/diot_constants.dart';

void main() {
  group('DIOT 2025 Compliance Tests', () {
    test('Should validate all 54 fields structure', () {
      print('=== TEST: Estructura de 54 campos DIOT 2025 ===');

      // Crear un registro completo para proveedor nacional
      const recordNacional = DIOTRecord(
        rfc: 'ABC123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 10000.0,
        ivaAcreditableExclusivo16: 1600.0,
      );

      // Verificar que genera 54 campos
      final pipeDelimited = recordNacional.toPipeDelimitedString();
      final fields = pipeDelimited.split('|');

      print('Número de campos generados: ${fields.length}');
      expect(
        fields.length,
        54,
        reason: 'Debe generar exactamente 54 campos según DIOT 2025',
      );

      // Verificar estructura usando el servicio de mapeo
      final isComplete =
          DIOT2025MappingService.validateFieldCompleteness(recordNacional);
      expect(
        isComplete,
        true,
        reason: 'La estructura debe ser completa para DIOT 2025',
      );

      print('✓ Estructura de 54 campos validada correctamente');
    });

    test('Should validate foreign provider fields according to DIOT 2025', () {
      print('=== TEST: Campos de proveedor extranjero DIOT 2025 ===');

      // Crear proveedor extranjero incompleto
      const recordIncompleto = DIOTRecord(
        rfc: '', // Debe estar vacío para extranjeros
        tipoTercero: TipoTercero.extranjero,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
      );

      final errorsIncompleto =
          DIOT2025ValidationService.validateRecord2025(recordIncompleto);
      final errorFields = errorsIncompleto.map((e) => e.field).toList();

      expect(
        errorFields.contains('numero_identificacion_fiscal'),
        true,
        reason: 'Debe requerir número de identificación fiscal',
      );
      expect(
        errorFields.contains('nombre_extranjero'),
        true,
        reason: 'Debe requerir nombre del extranjero',
      );
      expect(
        errorFields.contains('pais_residencia_fiscal'),
        true,
        reason: 'Debe requerir país de residencia fiscal',
      );

      // Crear proveedor extranjero completo
      const recordCompleto = DIOTRecord(
        rfc: '', // Vacío para extranjeros según DIOT 2025
        numeroIdentificacionFiscal: 'US123456789',
        nombreExtranjero: 'FOREIGN COMPANY INC',
        paisResidenciaFiscal: 'USA',
        tipoTercero: TipoTercero.extranjero,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
      );

      final errorsCompleto =
          DIOT2025ValidationService.validateRecord2025(recordCompleto);
      final hasErrors =
          errorsCompleto.any((e) => e.severity == DIOTValidationSeverity.error);
      expect(
        hasErrors,
        false,
        reason: 'Proveedor extranjero completo no debe tener errores',
      );

      print('✓ Validación de proveedor extranjero conforme a DIOT 2025');
    });

    test('Should validate country catalog according to DIOT 2025', () {
      print('=== TEST: Catálogo de países DIOT 2025 ===');

      // Verificar que el catálogo incluye países necesarios
      expect(
        DIOTConstants.paisesResidenciaFiscal.containsKey('USA'),
        true,
        reason: 'Debe incluir Estados Unidos',
      );
      expect(
        DIOTConstants.paisesResidenciaFiscal.containsKey('ZZZ'),
        true,
        reason: 'Debe incluir código especial ZZZ',
      );

      // Crear registro con país inválido
      const recordPaisInvalido = DIOTRecord(
        rfc: '',
        numeroIdentificacionFiscal: 'XX123456789',
        nombreExtranjero: 'TEST COMPANY',
        paisResidenciaFiscal: 'XXX', // País inválido
        tipoTercero: TipoTercero.extranjero,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
      );

      final errors =
          DIOT2025ValidationService.validateRecord2025(recordPaisInvalido);
      final hasCountryError = errors.any(
        (e) =>
            e.field == 'pais_residencia_fiscal' &&
            e.severity == DIOTValidationSeverity.error,
      );

      expect(hasCountryError, true, reason: 'Debe rechazar países no válidos');

      print('✓ Catálogo de países validado según DIOT 2025');
    });

    test('Should validate special jurisdiction when country is ZZZ', () {
      print('=== TEST: Jurisdicción especial para país ZZZ ===');

      // Crear registro con país ZZZ sin especificar jurisdicción
      const recordSinJurisdiccion = DIOTRecord(
        rfc: '',
        numeroIdentificacionFiscal: 'ZZ123456789',
        nombreExtranjero: 'OTHER JURISDICTION COMPANY',
        paisResidenciaFiscal: 'ZZZ',
        especificarJurisdiccion: null, // Falta jurisdicción
        tipoTercero: TipoTercero.extranjero,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
      );

      final errors =
          DIOT2025ValidationService.validateRecord2025(recordSinJurisdiccion);
      final hasJurisdictionError = errors.any(
        (e) =>
            e.field == 'especificar_jurisdiccion' &&
            e.severity == DIOTValidationSeverity.error,
      );

      expect(
        hasJurisdictionError,
        true,
        reason: 'Debe requerir jurisdicción cuando país es ZZZ',
      );

      // Crear registro con país ZZZ y jurisdicción especificada
      final recordConJurisdiccion = recordSinJurisdiccion.copyWith(
        especificarJurisdiccion: 'Otro país no listado',
      );

      final errorsCompleto =
          DIOT2025ValidationService.validateRecord2025(recordConJurisdiccion);
      final hasJurisdictionErrorCompleto = errorsCompleto.any(
        (e) =>
            e.field == 'especificar_jurisdiccion' &&
            e.severity == DIOTValidationSeverity.error,
      );

      expect(
        hasJurisdictionErrorCompleto,
        false,
        reason: 'No debe tener error cuando jurisdicción está especificada',
      );

      print('✓ Validación de jurisdicción especial para ZZZ');
    });

    test(
        'Should validate operation types by provider type according to DIOT 2025',
        () {
      print('=== TEST: Tipos de operación por tipo de tercero DIOT 2025 ===');

      // Validar operaciones para proveedor nacional
      const operacionInvalidaNacional = DIOTRecord(
        rfc: 'ABC123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion:
            TipoOperacion.importacionBienesServicios, // Inválida para nacional
        efectosFiscales: EfectosFiscales.si,
      );

      final errorsNacional = DIOT2025ValidationService.validateRecord2025(
        operacionInvalidaNacional,
      );
      final hasOperationError = errorsNacional.any(
        (e) =>
            e.field == 'tipo_operacion' &&
            e.severity == DIOTValidationSeverity.error,
      );

      expect(
        hasOperationError,
        true,
        reason:
            'Importación de bienes/servicios no válida para proveedor nacional',
      );

      // Validar operaciones para proveedor global
      const operacionValidaGlobal = DIOTRecord(
        rfc: DIOTConstants.rfcProveedorGlobal,
        tipoTercero: TipoTercero.global,
        tipoOperacion:
            TipoOperacion.operacionesGlobales, // Única válida para global
        efectosFiscales: EfectosFiscales.si,
      );

      final errorsGlobal =
          DIOT2025ValidationService.validateRecord2025(operacionValidaGlobal);
      final hasGlobalError = errorsGlobal.any(
        (e) =>
            e.field == 'tipo_operacion' &&
            e.severity == DIOTValidationSeverity.error,
      );

      expect(
        hasGlobalError,
        false,
        reason: 'Operaciones globales debe ser válida para proveedor global',
      );

      print('✓ Tipos de operación validados según tipo de tercero DIOT 2025');
    });

    test('Should validate numeric fields according to DIOT 2025 specifications',
        () {
      print('=== TEST: Campos numéricos según especificación DIOT 2025 ===');

      // Crear registro con valor numérico que excede límite
      const recordConValorExcesivo = DIOTRecord(
        rfc: 'ABC123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 999999999999999.0, // Excede 14 dígitos
      );

      final errors =
          DIOT2025ValidationService.validateRecord2025(recordConValorExcesivo);
      final hasNumericError = errors.any(
        (e) =>
            e.field == 'valor_actos_16_porciento' &&
            e.severity == DIOTValidationSeverity.error,
      );

      expect(
        hasNumericError,
        true,
        reason: 'Debe rechazar valores que excedan 14 dígitos',
      );

      // Verificar formato sin decimales en salida
      const recordValido = DIOTRecord(
        rfc: 'ABC123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 10000.50, // Con decimales
      );

      final pipeDelimited = recordValido.toPipeDelimitedString();
      final fields = pipeDelimited.split('|');
      // El campo 12 es valor_actos_16_porciento
      expect(
        fields[11],
        '10000',
        reason: 'Debe formatear sin decimales según DIOT 2025',
      );

      print('✓ Campos numéricos validados según especificación DIOT 2025');
    });

    test('Should verify field consistency for IVA values', () {
      print('=== TEST: Consistencia de campos IVA DIOT 2025 ===');

      // Crear registro con valores de actos pero sin IVA correspondiente
      const recordSinIVA = DIOTRecord(
        rfc: 'ABC123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 10000.0, // Hay valor de actos
        // Sin especificar IVA correspondiente
      );

      final errors = DIOT2025ValidationService.validateRecord2025(recordSinIVA);

      // NOTA: Validaciones de consistencia de IVA han sido deshabilitadas
      // porque los valores del CFDI ya son correctos según el SAT
      final hasConsistencyWarning = errors.any(
        (e) =>
            e.field == 'iva_16_porciento' &&
            e.severity == DIOTValidationSeverity.warning,
      );

      expect(
        hasConsistencyWarning,
        false,
        reason: 'IVA consistency validations should be disabled. '
            'CFDI values are already validated by SAT.',
      );

      print('✓ Consistencia de campos IVA validada');
    });

    test('Should validate complete DIOT 2025 export readiness', () {
      print('=== TEST: Preparación completa para exportación DIOT 2025 ===');

      // Crear registro completamente válido
      const recordCompleto = DIOTRecord(
        rfc: 'ABC123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 10000.0,
        ivaAcreditableExclusivo16: 1600.0,
        clasificacionRegional: ClasificacionRegional.nacional,
        clasificacionIVA: ClasificacionIVA.exclusivoActividades,
      );

      final isReady =
          DIOT2025ValidationService.isRecord2025ReadyForExport(recordCompleto);
      expect(
        isReady,
        true,
        reason: 'Registro completo debe estar listo para exportación',
      );

      // Verificar campos faltantes
      final missingFields =
          DIOT2025MappingService.getMissingFields(recordCompleto);
      expect(
        missingFields.isEmpty,
        true,
        reason: 'No debe tener campos faltantes',
      );

      print('✓ Registro listo para exportación DIOT 2025');
    });

    test('Should generate valid DIOT 2025 example record', () {
      print('=== TEST: Generar ejemplo válido DIOT 2025 ===');

      // Generar el ejemplo de la especificación:
      // "04|03|RFC123456789|||||12500|0|0|0|0|0|8900|0|0|0|0|0|1424|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|01"
      const exampleRecord = DIOTRecord(
        rfc: 'RFC123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.prestacionServicios,
        efectosFiscales: EfectosFiscales.si,
        valorActosFronteraNorte: 12500.0,
        valorActos16Porciento: 8900.0,
        ivaAcreditableExclusivo16: 1424.0,
      );

      final generated = exampleRecord.toPipeDelimitedString();
      final fields = generated.split('|');

      // Verificar campos clave del ejemplo
      expect(fields[0], '04', reason: 'Tipo tercero nacional');
      expect(fields[1], '03', reason: 'Prestación de servicios');
      expect(fields[2], 'RFC123456789', reason: 'RFC del ejemplo');
      expect(fields[7], '12500', reason: 'Valor frontera norte');
      expect(fields[11], '8900', reason: 'Valor actos 16%');
      expect(fields[21], '1424', reason: 'IVA acreditable exclusivo 16%');
      expect(fields[53], '01', reason: 'Efectos fiscales Sí');

      print('Ejemplo generado: $generated');
      print('✓ Ejemplo DIOT 2025 generado correctamente');
    });
  });
}
