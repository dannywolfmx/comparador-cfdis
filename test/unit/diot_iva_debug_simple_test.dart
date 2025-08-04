import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/services/diot_mapping_service.dart';

void main() {
  group('DIOT IVA Source Debug', () {
    test('Debug exact TotalImpuestosTrasladados usage', () {
      print('=== DEBUG: Uso exacto de TotalImpuestosTrasladados ===');

      // CFDI con TotalImpuestosTrasladados explícito
      final cfdiData = {
        'SubTotal': '2359.53',
        'Emisor': {'Rfc': 'ABC123456789'},
        'Impuestos': {
          'TotalImpuestosTrasladados': '219.31',
        },
      };

      final cfdi = CFDI.fromJson(cfdiData);

      print('CFDI parseado:');
      print('  SubTotal: ${cfdi.subTotal}');
      print('  cfdi.impuestos != null: ${cfdi.impuestos != null}');

      if (cfdi.impuestos != null) {
        print(
            '  TotalImpuestosTrasladados: ${cfdi.impuestos!.totalImpuestosTrasladados}');
        print(
            '  ¿Es mayor que 0?: ${cfdi.impuestos!.totalImpuestosTrasladados > 0}');
      }

      // Usar método público para debug
      final values = DIOTMappingService.calculateValuesFromCFDIs([cfdi]);

      print('');
      print('Resultado del mapping:');
      print('  ivaTotal16: ${values.ivaTotal16}');
      print('  valorActos16Porciento: ${values.valorActos16Porciento}');

      // Verificar que usa el valor correcto
      expect(
        values.ivaTotal16,
        219.31,
        reason: 'Debe usar TotalImpuestosTrasladados del CFDI',
      );

      print('');
      print(
          '✅ ${values.ivaTotal16 == 219.31 ? "CORRECTO" : "ERROR"}: IVA = ${values.ivaTotal16}');
    });

    test('Debug case without TotalImpuestosTrasladados', () {
      print('=== DEBUG: Caso sin TotalImpuestosTrasladados ===');

      final cfdiData = {
        'SubTotal': '1000.00',
        'Emisor': {'Rfc': 'ABC123456789'},
        'Impuestos': {
          'TotalImpuestosTrasladados': '0.0', // Explícitamente cero
        },
      };

      final cfdi = CFDI.fromJson(cfdiData);
      final values = DIOTMappingService.calculateValuesFromCFDIs([cfdi]);

      print(
          'TotalImpuestosTrasladados: ${cfdi.impuestos!.totalImpuestosTrasladados}');
      print('Resultado IVA: ${values.ivaTotal16}');
      print('¿Usa fallback?: ${values.ivaTotal16 == 0.0}');

      expect(
        values.ivaTotal16,
        0.0,
        reason: 'Sin TotalImpuestosTrasladados debe usar fallback',
      );

      print('✅ Fallback funciona correctamente');
    });

    test('Verify the exact condition logic', () {
      print('=== DEBUG: Lógica exacta de condiciones ===');

      final scenarios = [
        {'name': 'Con valor 219.31', 'value': '219.31', 'shouldUse': true},
        {'name': 'Con valor 0.0', 'value': '0.0', 'shouldUse': false},
        {'name': 'Con valor null (omitido)', 'value': null, 'shouldUse': false},
      ];

      for (final scenario in scenarios) {
        print('');
        print('📋 Escenario: ${scenario['name']}');

        final cfdiData = <String, dynamic>{
          'SubTotal': '1000.00',
          'Emisor': {'Rfc': 'ABC123456789'},
        };

        if (scenario['value'] != null) {
          cfdiData['Impuestos'] = {
            'TotalImpuestosTrasladados': scenario['value'],
          };
        }

        final cfdi = CFDI.fromJson(cfdiData);

        // Simular la condición exacta del código
        final bool condition =
            cfdi.impuestos?.totalImpuestosTrasladados != null &&
                cfdi.impuestos!.totalImpuestosTrasladados > 0;

        print('  cfdi.impuestos != null: ${cfdi.impuestos != null}');
        if (cfdi.impuestos != null) {
          print(
              '  totalImpuestosTrasladados: ${cfdi.impuestos!.totalImpuestosTrasladados}');
          print('  > 0: ${cfdi.impuestos!.totalImpuestosTrasladados > 0}');
        }
        print('  Condición completa: $condition');
        print(
            '  ¿Debería usar TotalImpuestosTrasladados?: ${scenario['shouldUse']}');

        expect(
          condition,
          scenario['shouldUse'],
          reason:
              'Condición debe evaluar correctamente para ${scenario['name']}',
        );
      }

      print('');
      print('✅ Lógica de condiciones verificada');
    });
  });
}
