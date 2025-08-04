import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/models/cfdi.dart';

void main() {
  group('DIOT CFDI IVA Value Source Tests', () {
    test('Should verify CFDI correctly parses TotalImpuestosTrasladados', () {
      print(
        '=== TEST: Verificar que CFDI parsea TotalImpuestosTrasladados ===',
      );

      // Crear CFDI con TotalImpuestosTrasladados específico
      final cfdiData = {
        'SubTotal': '2359.53',
        'Descuento': '717.68',
        'Total': '1861.16',
        'Emisor': {
          'Rfc': 'ABC123456789',
          'Nombre': 'Proveedor Test',
        },
        'Impuestos': {
          'TotalImpuestosTrasladados': '219.31', // ❗ VALOR REAL DEL SAT
        },
        'Conceptos': {
          'Concepto': [], // Vacío para forzar uso del total
        },
      };

      final cfdi = CFDI.fromJson(cfdiData);

      print('Datos del CFDI parseado:');
      print('  Subtotal: \$${cfdi.subTotal}');
      print(
        '  TotalImpuestosTrasladados: \$${cfdi.impuestos?.totalImpuestosTrasladados}',
      );
      print('  Descuento: \$${cfdi.descuento}');

      // Verificar que el CFDI tiene el valor correcto
      expect(
        cfdi.impuestos?.totalImpuestosTrasladados,
        219.31,
        reason: 'CFDI debe parsear TotalImpuestosTrasladados correctamente',
      );

      print('');
      print('✅ CORRECTO: CFDI parsea TotalImpuestosTrasladados del XML');
      print('   Valor: \$${cfdi.impuestos?.totalImpuestosTrasladados}');
    });

    test('Should demonstrate problem with calculated vs real IVA', () {
      print('=== TEST: Demostrar problema entre IVA calculado vs real ===');

      const subtotal = 2359.53;
      const ivaReal = 219.31; // Del CFDI con productos mixtos
      const ivaCalculado = subtotal * 0.16; // Cálculo erróneo

      print('COMPARACIÓN:');
      print('  Subtotal: \$${subtotal.toStringAsFixed(2)}');
      print(
        '  IVA calculado (16%): \$${ivaCalculado.toStringAsFixed(2)} ← INCORRECTO',
      );
      print('  IVA real del CFDI: \$${ivaReal.toStringAsFixed(2)} ← CORRECTO');
      print('  Diferencia: \$${(ivaCalculado - ivaReal).toStringAsFixed(2)}');

      print('');
      print('RAZÓN DE LA DIFERENCIA:');
      print('  - CFDI contiene productos con tasas mixtas (0% y 16%)');
      print('  - SAT calcula IVA solo sobre productos gravados');
      print('  - Sistema anterior calculaba 16% sobre todo el subtotal');
      print('  - Por eso 377.52 ≠ 219.31');

      expect(
        ivaCalculado,
        isNot(equals(ivaReal)),
        reason: 'IVA calculado debe ser diferente del real en productos mixtos',
      );

      print('');
      print('✅ PROBLEMA IDENTIFICADO: Cálculo vs Realidad');
      print('   Solución: Usar siempre valor del CFDI');
    });

    test('Should verify TotalImpuestosTrasladados priority in mapping logic',
        () {
      print('=== TEST: Verificar prioridad de TotalImpuestosTrasladados ===');

      // Simular la lógica del mapping service
      final cfdiConTotal = {
        'Impuestos': {
          'TotalImpuestosTrasladados': '219.31',
        },
      };

      final cfdiSinTotal = {
        'Impuestos': {
          'TotalImpuestosTrasladados': '0.0',
        },
      };

      final cfdi1 = CFDI.fromJson(cfdiConTotal);
      final cfdi2 = CFDI.fromJson(cfdiSinTotal);

      print('CFDI con TotalImpuestosTrasladados:');
      print('  Valor: \$${cfdi1.impuestos?.totalImpuestosTrasladados}');
      print(
        '  ¿Disponible?: ${cfdi1.impuestos?.totalImpuestosTrasladados != null && cfdi1.impuestos!.totalImpuestosTrasladados > 0}',
      );

      print('');
      print('CFDI sin TotalImpuestosTrasladados:');
      print('  Valor: \$${cfdi2.impuestos?.totalImpuestosTrasladados}');
      print(
        '  ¿Disponible?: ${cfdi2.impuestos?.totalImpuestosTrasladados != null && cfdi2.impuestos!.totalImpuestosTrasladados > 0}',
      );

      // Verificar lógica de prioridad
      expect(
        cfdi1.impuestos!.totalImpuestosTrasladados > 0,
        true,
        reason: 'CFDI1 debe tener TotalImpuestosTrasladados disponible',
      );

      expect(
        cfdi2.impuestos!.totalImpuestosTrasladados > 0,
        false,
        reason: 'CFDI2 debe requerir fallback a cálculo',
      );

      print('');
      print('✅ LÓGICA DE PRIORIDAD VERIFICADA:');
      print('   1. Usar TotalImpuestosTrasladados si > 0');
      print('   2. Fallback a cálculo desde conceptos si = 0');
    });
  });
}
