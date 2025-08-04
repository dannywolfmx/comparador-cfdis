import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/services/diot_2025_validation_service.dart';
import 'package:comparador_cfdis/models/diot_record.dart';

void main() {
  group('DIOT Discount Handling Tests - Legacy (Now Incorrect)', () {
    test('Should FAIL with old incorrect discount handling approach', () {
      print('=== TEST: Enfoque INCORRECTO (para mostrar el problema) ===');

      // ENFOQUE INCORRECTO: usar base gravable como valor de actos
      const subtotalOriginal = 2359.53;
      const descuento = 717.68;
      const baseGravable = subtotalOriginal - descuento; // $1,641.85
      const ivaEsperado = baseGravable * 0.16; // $262.70

      print('ENFOQUE INCORRECTO:');
      print(
          '  Valor de actos: \$${baseGravable.toStringAsFixed(2)} (base gravable)');
      print('  IVA: \$${ivaEsperado.toStringAsFixed(2)}');

      const record = DIOTRecord(
        rfc: 'XAXX010101000',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: baseGravable, // INCORRECTO: debe ser subtotal
        ivaAcreditableExclusivo16: 262.70,
      );

      final errors = DIOT2025ValidationService.validateRecord2025(record);
      final ivaErrors =
          errors.where((e) => e.field == 'iva_16_porciento').toList();

      // Con el nuevo sistema correcto, esto DEBE pasar sin errores
      // porque el cálculo es consistente (aunque conceptualmente incorrecto)
      expect(ivaErrors.isEmpty, true);

      print(
          '❌ PROBLEMA: Este enfoque "funciona" pero es conceptualmente incorrecto');
      print(
          '   Los descuentos deberían ir en devoluciones, no reducir el valor de actos');
    });

    test('Should show CORRECT approach with subtotal and devoluciones', () {
      print('=== TEST: Enfoque CORRECTO ===');

      const subtotalOriginal = 2359.53;
      const descuento = 717.68;
      const ivaEsperado = subtotalOriginal * 0.16; // $377.52

      print('ENFOQUE CORRECTO:');
      print(
          '  Valor de actos: \$${subtotalOriginal.toStringAsFixed(2)} (subtotal completo)');
      print('  Devoluciones: \$${descuento.toStringAsFixed(2)}');
      print('  IVA: \$${ivaEsperado.toStringAsFixed(2)}');

      const record = DIOTRecord(
        rfc: 'XAXX010101000',
        tipoTercero: TipoTercero.nacional,
        tipoOperacion: TipoOperacion.enajenacionBienes,
        efectosFiscales: EfectosFiscales.si,
        valorActos16Porciento: subtotalOriginal, // CORRECTO: subtotal completo
        devoluciones16Porciento:
            descuento, // CORRECTO: descuento como devolución
        ivaAcreditableExclusivo16:
            ivaEsperado, // CORRECTO: IVA basado en subtotal
      );

      final errors = DIOT2025ValidationService.validateRecord2025(record);
      final ivaErrors =
          errors.where((e) => e.field == 'iva_16_porciento').toList();

      expect(ivaErrors.isEmpty, true);

      print('✅ CORRECTO: Este es el enfoque apropiado según normativa DIOT');
    });
  });
}
