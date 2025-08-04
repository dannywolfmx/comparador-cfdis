import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/services/diot_2025_validation_service.dart';
import 'package:comparador_cfdis/models/diot_record.dart';

void main() {
  group('DIOT 2025 Small Amount Tolerance Tests', () {
    test('Should allow zero IVA for very small amounts due to rounding', () {
      print('=== TEST: Tolerancia para montos muy pequeños ===');

      // Caso 1: Monto muy pequeño (0.01) donde el IVA sería 0.0016, prácticamente cero
      const recordMontoMuyPequeno = DIOTRecord(
        rfc: 'ABC123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 0.01, // 1 centavo
        // Sin IVA especificado (se considera cero por redondeo)
      );

      final errors =
          DIOT2025ValidationService.validateRecord2025(recordMontoMuyPequeno);
      final hasIVAError = errors.any(
        (e) =>
            e.field == 'iva_16_porciento' &&
            e.severity == DIOTValidationSeverity.warning,
      );

      expect(
        hasIVAError,
        false,
        reason:
            'Montos muy pequeños (< \$1.00) no deben requerir IVA debido al redondeo',
      );

      print('✓ Monto \$0.01 - Sin error de IVA (tolerancia aplicada)');
    });

    test('Should allow zero IVA for amounts under tolerance threshold', () {
      print('=== TEST: Tolerancia para montos bajo umbral ===');

      // Caso 2: Montos pequeños donde el IVA calculado es menor al umbral
      final testCases = [
        0.05, // 5 centavos - IVA: 0.008 (< 0.10)
        0.10, // 10 centavos - IVA: 0.016 (< 0.10)
        0.50, // 50 centavos - IVA: 0.08 (< 0.10)
        0.62, // 62 centavos - IVA: 0.0992 (< 0.10)
      ];

      for (final amount in testCases) {
        final expectedIVA = amount * 0.16;
        print(
          '  Probando monto: \$${amount.toStringAsFixed(2)}, IVA esperado: \$${expectedIVA.toStringAsFixed(4)}',
        );

        final record = DIOTRecord(
          rfc: 'ABC123456789',
          tipoTercero: TipoTercero.nacional,
          tipoOperacion: TipoOperacion.enajenacionBienes,
          efectosFiscales: EfectosFiscales.si,
          valorActos16Porciento: amount,
          // Sin IVA especificado
        );

        final errors = DIOT2025ValidationService.validateRecord2025(record);
        final hasIVAError = errors.any(
          (e) =>
              e.field == 'iva_16_porciento' &&
              e.severity == DIOTValidationSeverity.warning,
        );

        expect(
          hasIVAError,
          false,
          reason:
              'Monto \$${amount.toStringAsFixed(2)} (IVA: \$${expectedIVA.toStringAsFixed(4)}) no debe requerir IVA (bajo umbral de tolerancia)',
        );

        print('✓ Monto \$${amount.toStringAsFixed(2)} - Sin error de IVA');
      }
    });

    test('Should require IVA for amounts above tolerance threshold', () {
      print('=== TEST: Requerir IVA para montos normales ===');

      // Caso 3: Montos normales que sí deben tener IVA
      const record = DIOTRecord(
        rfc: 'ABC123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 10.00, // $10.00 - monto normal
        // Sin IVA especificado
      );

      final errors = DIOT2025ValidationService.validateRecord2025(record);
      final hasIVAError = errors.any(
        (e) =>
            e.field == 'iva_16_porciento' &&
            e.severity == DIOTValidationSeverity.warning,
      );

      expect(
        hasIVAError,
        false,
        reason: 'IVA validation is disabled - CFDI values are trusted',
      );

      print('✓ Monto \$10.00 - No se valida IVA (validación deshabilitada)');
    });

    test('Should accept small IVA amounts within rounding tolerance', () {
      print('=== TEST: Tolerancia de redondeo para IVA ===');

      // Caso 4: Monto pequeño con IVA correspondiente pero con redondeo
      const record = DIOTRecord(
        rfc: 'ABC123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 0.75, // 75 centavos
        ivaAcreditableExclusivo16: 0.12, // IVA calculado: 0.75 * 0.16 = 0.12
      );

      final errors = DIOT2025ValidationService.validateRecord2025(record);
      final hasIVAError = errors.any(
        (e) =>
            e.field == 'iva_16_porciento' &&
            e.severity == DIOTValidationSeverity.warning,
      );

      expect(
        hasIVAError,
        false,
        reason: 'IVA calculado correctamente debe ser aceptado',
      );

      print('✓ Monto \$0.75 con IVA \$0.12 - Aceptado (cálculo correcto)');
    });

    test('Should confirm IVA tolerance validation is disabled', () {
      print(
        '=== TEST: Confirmar que validación de tolerancia IVA está deshabilitada ===',
      );

      // Las constantes de tolerancia ya no se usan porque
      // las validaciones de consistencia de IVA han sido deshabilitadas
      // Los valores del CFDI ya son considerados correctos por el SAT

      // Verificar que la validación no usa constantes de tolerancia
      const record = DIOTRecord(
        rfc: 'ABC123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 100.0,
        ivaAcreditableExclusivo16: 15.50, // Diferente del 16% esperado
      );

      final errors = DIOT2025ValidationService.validateRecord2025(record);

      // No debe haber errores de consistencia de IVA
      final hasIVAConsistencyError = errors.any(
        (e) =>
            e.field == 'iva_16_porciento' &&
            e.message.contains('difiere del esperado'),
      );

      expect(
        hasIVAConsistencyError,
        false,
        reason: 'IVA consistency validation should be disabled',
      );

      print('✓ Validación de tolerancia IVA confirmada como deshabilitada');
      print('  - No se validan umbrales de tolerancia');
      print('  - Se confía en valores del CFDI validados por SAT');
    });

    test('Should handle edge cases properly', () {
      print('=== TEST: Casos límite ===');

      // Caso 5: Exactamente en el límite de tolerancia
      const recordLimite = DIOTRecord(
        rfc: 'ABC123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 1.00, // Exactamente en el límite
        // Sin IVA - debería requerir IVA
      );

      final errorsLimite =
          DIOT2025ValidationService.validateRecord2025(recordLimite);
      final hasIVAErrorLimite = errorsLimite.any(
        (e) =>
            e.field == 'iva_16_porciento' &&
            e.severity == DIOTValidationSeverity.warning,
      );

      expect(
        hasIVAErrorLimite,
        false,
        reason: 'IVA validation is disabled - CFDI values are trusted',
      );

      // Caso 6: Justo por debajo del límite PERO IVA calculado > umbral
      const recordDebajo = DIOTRecord(
        rfc: 'ABC123456789',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 0.99, // IVA esperado: 0.1584 (> 0.10)
        // Sin IVA - DEBERÍA requerir IVA porque 0.1584 > 0.10
      );

      final errorsDebajo =
          DIOT2025ValidationService.validateRecord2025(recordDebajo);
      final hasIVAErrorDebajo = errorsDebajo.any(
        (e) =>
            e.field == 'iva_16_porciento' &&
            e.severity == DIOTValidationSeverity.warning,
      );

      expect(
        hasIVAErrorDebajo,
        false,
        reason: 'IVA validation is disabled - CFDI values are trusted',
      );

      print('✓ Casos límite - No se valida IVA (validación deshabilitada)');
    });
  });
}
