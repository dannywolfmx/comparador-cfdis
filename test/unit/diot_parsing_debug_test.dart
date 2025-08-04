import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/models/cfdi.dart';

void main() {
  group('CFDI TotalImpuestosTrasladados Parsing Tests', () {
    test('Should parse TotalImpuestosTrasladados correctly from string', () {
      print('=== TEST: Parsing de TotalImpuestosTrasladados ===');

      final testCases = [
        {
          'input': '219.31',
          'expected': 219.31,
          'description': 'Decimal normal',
        },
        {'input': '0.00', 'expected': 0.0, 'description': 'Cero explícito'},
        {'input': '377.52', 'expected': 377.52, 'description': 'Otro decimal'},
        {'input': '1600', 'expected': 1600.0, 'description': 'Entero'},
        {'input': '', 'expected': 0.0, 'description': 'String vacío'},
      ];

      for (final testCase in testCases) {
        print('');
        print('🧪 Caso: ${testCase['description']}');
        print('   Input: "${testCase['input']}"');

        final cfdiData = {
          'SubTotal': '1000.00',
          'Emisor': {'Rfc': 'TEST123456789'},
          'Impuestos': {
            'TotalImpuestosTrasladados': testCase['input'],
          },
        };

        final cfdi = CFDI.fromJson(cfdiData);
        final result = cfdi.impuestos?.totalImpuestosTrasladados;

        print('   Resultado parseado: $result');
        print('   Esperado: ${testCase['expected']}');

        expect(
          result,
          testCase['expected'],
          reason:
              'Debe parsear "${testCase['input']}" como ${testCase['expected']}',
        );

        print('   ✅ CORRECTO');
      }
    });

    test(
        'Should handle malformed or problematic TotalImpuestosTrasladados values',
        () {
      print('=== TEST: Valores problemáticos de TotalImpuestosTrasladados ===');

      final problematicCases = [
        {'input': 'abc', 'expected': 0.0, 'description': 'Texto no numérico'},
        {
          'input': '219,31',
          'expected': 0.0,
          'description': 'Coma en lugar de punto',
        },
        {
          'input': '  219.31  ',
          'expected': 219.31,
          'description': 'Con espacios',
        },
        {
          'input': '+219.31',
          'expected': 219.31,
          'description': 'Con signo positivo',
        },
        {
          'input': '-219.31',
          'expected': -219.31,
          'description': 'Con signo negativo',
        },
      ];

      for (final testCase in problematicCases) {
        print('');
        print('🚨 Caso problemático: ${testCase['description']}');
        print('   Input: "${testCase['input']}"');

        final cfdiData = {
          'SubTotal': '1000.00',
          'Emisor': {'Rfc': 'TEST123456789'},
          'Impuestos': {
            'TotalImpuestosTrasladados': testCase['input'],
          },
        };

        final cfdi = CFDI.fromJson(cfdiData);
        final result = cfdi.impuestos?.totalImpuestosTrasladados;

        print('   Resultado parseado: $result');
        print('   Esperado: ${testCase['expected']}');

        expect(
          result,
          testCase['expected'],
          reason: 'Debe manejar "${testCase['input']}" apropiadamente',
        );

        print('   ✅ MANEJADO CORRECTAMENTE');
      }
    });

    test('Should verify the exact problematic scenario', () {
      print('=== TEST: Escenario exacto del problema ===');

      // Simular exactamente lo que menciona el usuario
      final cfdiData = {
        'SubTotal': '2359.53',
        'Emisor': {'Rfc': 'PROBLEMA123'},
        'Impuestos': {
          'TotalImpuestosTrasladados': '219.31', // ❗ VALOR EXACTO DEL PROBLEMA
        },
      };

      final cfdi = CFDI.fromJson(cfdiData);

      print(
        'XML simulado: <cfdi:Impuestos TotalImpuestosTrasladados="219.31">',
      );
      print(
        'Resultado del parsing: ${cfdi.impuestos?.totalImpuestosTrasladados}',
      );

      if (cfdi.impuestos?.totalImpuestosTrasladados == 219.31) {
        print('✅ PARSING CORRECTO: Se parseó como 219.31');
      } else if (cfdi.impuestos?.totalImpuestosTrasladados == 0.0) {
        print('❌ PARSING INCORRECTO: Se parseó como 0.0');
        print('   Esto explica por qué usa el fallback de cálculo');
      } else {
        print(
          '⚠️  PARSING INESPERADO: ${cfdi.impuestos?.totalImpuestosTrasladados}',
        );
      }

      expect(
        cfdi.impuestos?.totalImpuestosTrasladados,
        219.31,
        reason: 'El parsing debe funcionar correctamente para "219.31"',
      );
    });
  });
}
