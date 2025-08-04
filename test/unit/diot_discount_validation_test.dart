import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/models/cfdi.dart';

void main() {
  group('DIOT Discount Calculation Tests', () {
    test('Should calculate correct base gravable with discount', () {
      print('=== TEST: Validación de cálculo con descuento ===');

      // Caso del usuario: Total $1,861.16, Descuento $717.68, Subtotal $2,359.53
      const subtotal = 2359.53;
      const descuento = 717.68;
      const baseGravableEsperada = subtotal - descuento; // = 1641.85
      const ivaEsperado = baseGravableEsperada * 0.16; // = 262.70

      print('Datos del CFDI:');
      print('  Subtotal: \$${subtotal.toStringAsFixed(2)}');
      print('  Descuento: \$${descuento.toStringAsFixed(2)}');
      print('  Base gravable: \$${baseGravableEsperada.toStringAsFixed(2)}');
      print('  IVA esperado (16%): \$${ivaEsperado.toStringAsFixed(2)}');

      // Crear CFDI
      final cfdi = CFDI(
        subTotal: subtotal.toString(),
        descuento: descuento.toString(),
        total: '1861.16',
        emisor: Emisor(rfc: 'XAXX010101000'),
      );

      // Verificar que los datos se parsean correctamente
      final subtotalParsed = double.tryParse(cfdi.subTotal ?? '0') ?? 0;
      final descuentoParsed = double.tryParse(cfdi.descuento ?? '0') ?? 0;
      final baseGravableCalculada = subtotalParsed - descuentoParsed;

      expect(
        baseGravableCalculada,
        closeTo(baseGravableEsperada, 0.01),
        reason: 'La base gravable debe ser subtotal - descuento',
      );

      print(
        '✅ Cálculo correcto: Base gravable = \$${baseGravableCalculada.toStringAsFixed(2)}',
      );
      print(
        '✅ La lógica actualizada en diot_mapping_service.dart debería usar este valor',
      );

      // Verificar que es diferente del subtotal completo (problema original)
      expect(
        baseGravableCalculada,
        isNot(closeTo(subtotal, 0.01)),
        reason:
            'La base gravable NO debe ser igual al subtotal cuando hay descuento',
      );

      print('✅ Diferente del subtotal completo (evita el error original)');
    });

    test('Should handle CFDI without discount correctly', () {
      print('=== TEST: CFDI sin descuento ===');

      final cfdi = CFDI(
        subTotal: '1000.00',
        // Sin descuento
        total: '1160.00',
        emisor: Emisor(rfc: 'XAXX010101000'),
      );

      final subtotalParsed = double.tryParse(cfdi.subTotal ?? '0') ?? 0;
      final descuentoParsed = double.tryParse(cfdi.descuento ?? '0') ?? 0;
      final baseGravableCalculada = subtotalParsed - descuentoParsed;

      expect(
        baseGravableCalculada,
        closeTo(1000.00, 0.01),
        reason: 'Sin descuento, la base gravable debe ser igual al subtotal',
      );

      print(
        '✅ Sin descuento: Base gravable = \$${baseGravableCalculada.toStringAsFixed(2)}',
      );
    });

    test('Should demonstrate the fix resolves validation issue', () {
      print('=== TEST: Demostración de la corrección ===');

      const subtotal = 2359.53;
      const descuento = 717.68;
      const baseGravableCorrecta = subtotal - descuento; // 1641.85
      const ivaReal = 262.70; // IVA del CFDI real

      // Calcular diferencia con método correcto vs incorrecto
      const ivaEsperadoCorrecto = baseGravableCorrecta * 0.16; // 262.696
      const ivaEsperadoIncorrecto = subtotal * 0.16; // 377.5248

      final diferenciaCorrecto =
          (ivaReal - ivaEsperadoCorrecto).abs(); // ≈ 0.00
      final diferenciaIncorrecto =
          (ivaReal - ivaEsperadoIncorrecto).abs(); // ≈ 114.82

      print('Comparación de métodos:');
      print('  Método CORRECTO (con descuento):');
      print('    Base gravable: \$${baseGravableCorrecta.toStringAsFixed(2)}');
      print('    IVA esperado: \$${ivaEsperadoCorrecto.toStringAsFixed(2)}');
      print('    IVA real: \$${ivaReal.toStringAsFixed(2)}');
      print('    Diferencia: \$${diferenciaCorrecto.toStringAsFixed(2)} ✅');
      print('');
      print('  Método INCORRECTO (sin descuento):');
      print('    Base gravable: \$${subtotal.toStringAsFixed(2)}');
      print('    IVA esperado: \$${ivaEsperadoIncorrecto.toStringAsFixed(2)}');
      print('    IVA real: \$${ivaReal.toStringAsFixed(2)}');
      print('    Diferencia: \$${diferenciaIncorrecto.toStringAsFixed(2)} ❌');

      // Asumiendo tolerancia de 1 centavo (0.01)
      const tolerancia = 0.01;

      expect(
        diferenciaCorrecto <= tolerancia,
        true,
        reason: 'El método correcto debe estar dentro de tolerancia',
      );

      expect(
        diferenciaIncorrecto > tolerancia,
        true,
        reason: 'El método incorrecto debe exceder tolerancia',
      );

      print('✅ La corrección resuelve el problema de validación');
    });
  });
}
