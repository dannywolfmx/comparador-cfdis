import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/services/diot_2025_validation_service.dart';
import 'package:comparador_cfdis/models/diot_record.dart';

void main() {
  group('DIOT Real World Scenarios', () {
    test('Should not validate CFDIs with 0.01 subtotal (validation disabled)',
        () {
      print(
          '=== TEST: No validar CFDI con subtotal 0.01 (validación deshabilitada) ===');

      // Escenario reportado por el usuario:
      // Factura con subtotal 0.01, total 0.01 (sin IVA)
      // AHORA: Confiamos en los valores del CFDI ya validados por el SAT

      const record = DIOTRecord(
        rfc: 'XAXX010101000',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: 0.01, // 1 centavo
        // Sin IVA especificado - valores del CFDI ya validados por SAT
      );

      print('Monto: \$0.01 (valores del CFDI ya validados por SAT)');

      final errors = DIOT2025ValidationService.validateRecord2025(record);
      final ivaErrors = errors
          .where(
            (e) =>
                e.field == 'iva_16_porciento' &&
                e.severity == DIOTValidationSeverity.warning,
          )
          .toList();

      // NOTA: Validaciones de consistencia de IVA han sido deshabilitadas
      // porque los valores del CFDI ya son correctos según el SAT
      expect(
        ivaErrors.isEmpty,
        true,
        reason: 'IVA consistency validations are disabled. '
            'CFDI values are already validated by SAT.',
      );

      print(
          '✓ CORRECTO: No se valida consistencia para CFDI con subtotal \$0.01');
    });

    test('Should not validate tolerance thresholds (validation disabled)', () {
      print(
          '=== TEST: No validar umbrales de tolerancia (validación deshabilitada) ===');

      // Casos de prueba que anteriormente se basaban en umbrales
      // AHORA: Confiamos en los valores del CFDI ya validados por el SAT
      final testCases = [
        {
          'amount': 0.01,
          'description': '1 centavo',
        },
        {
          'amount': 0.05,
          'description': '5 centavos',
        },
        {
          'amount': 0.60,
          'description': '60 centavos',
        },
        {
          'amount': 0.625,
          'description': '62.5 centavos',
        },
        {
          'amount': 0.70,
          'description': '70 centavos',
        }
      ];

      for (final testCase in testCases) {
        final amount = testCase['amount'] as double;
        final description = testCase['description'] as String;

        final record = DIOTRecord(
          rfc: 'XAXX010101000',
          tipoTercero: TipoTercero.nacional,
          tipoOperacion: TipoOperacion.enajenacionBienes,
          efectosFiscales: EfectosFiscales.si,
          valorActos16Porciento: amount,
          // Sin IVA especificado - valores del CFDI ya validados por SAT
        );

        final errors = DIOT2025ValidationService.validateRecord2025(record);
        final hasIVAError = errors.any(
          (e) =>
              e.field == 'iva_16_porciento' &&
              e.severity == DIOTValidationSeverity.warning,
        );

        // NOTA: Validaciones de consistencia de IVA han sido deshabilitadas
        // porque los valores del CFDI ya son correctos según el SAT
        expect(
          hasIVAError,
          false,
          reason: 'IVA consistency validations are disabled. '
              'CFDI values are already validated by SAT.',
        );

        print('  ✓ $description - No se valida consistencia');
      }
    });

    test('Should not validate IVA for small amounts (validation disabled)', () {
      print(
        '=== TEST: No validar IVA para montos pequeños (validación deshabilitada) ===',
      );

      // Verificar que no se valida consistencia de IVA independientemente del monto
      // AHORA: Confiamos en los valores del CFDI ya validados por el SAT
      final testCases = [
        {'amount': 0.01, 'iva': 0.00}, // IVA del CFDI
        {'amount': 0.75, 'iva': 0.12}, // IVA del CFDI
        {'amount': 0.99, 'iva': 0.16}, // IVA del CFDI
      ];

      for (final testCase in testCases) {
        final amount = testCase['amount'] as double;
        final iva = testCase['iva'] as double;

        final record = DIOTRecord(
          rfc: 'XAXX010101000',
          tipoTercero: TipoTercero.nacional,
          tipoOperacion: TipoOperacion.enajenacionBienes,
          efectosFiscales: EfectosFiscales.si,
          valorActos16Porciento: amount,
          ivaAcreditableExclusivo16: iva,
        );

        final errors = DIOT2025ValidationService.validateRecord2025(record);
        final ivaErrors = errors
            .where(
              (e) =>
                  e.field == 'iva_16_porciento' &&
                  e.severity == DIOTValidationSeverity.warning,
            )
            .toList();

        // NOTA: Validaciones de consistencia de IVA han sido deshabilitadas
        // porque los valores del CFDI ya son correctos según el SAT
        expect(
          ivaErrors.isEmpty,
          true,
          reason: 'IVA consistency validations are disabled. '
              'CFDI values are already validated by SAT.',
        );

        print(
          '  ✓ Monto \$${amount.toStringAsFixed(2)} con IVA \$${iva.toStringAsFixed(2)} - No se valida consistencia',
        );
      }
    });
  });
}
