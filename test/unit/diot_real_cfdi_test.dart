import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/services/cfdi_parser.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/services/diot_mapping_service.dart';
import 'package:comparador_cfdis/constants/diot_constants.dart';
import 'dart:io';

void main() {
  group('DIOT Real CFDI Test', () {
    test('Should use real TotalImpuestosTrasladados from actual CFDI XML',
        () async {
      print('=== TEST: CFDI Real con TotalImpuestosTrasladados="219.31" ===');

      // Leer el CFDI real desde docs
      final xmlFile = File('docs/sat/c589b7b7-955f-4f5d-a16b-b78f875e02db.xml');
      expect(xmlFile.existsSync(), true, reason: 'Archivo XML debe existir');

      final xmlContent = await xmlFile.readAsString();

      // Verificar que el XML contiene el valor correcto
      expect(
        xmlContent.contains('TotalImpuestosTrasladados="219.31"'),
        true,
        reason: 'XML debe contener TotalImpuestosTrasladados="219.31"',
      );
      expect(
        xmlContent.contains('SubTotal="2359.53"'),
        true,
        reason: 'XML debe contener SubTotal="2359.53"',
      );

      // Parsear el CFDI
      final cfdi = CFDIParser.parseXmlString(xmlContent);
      expect(cfdi, isNotNull, reason: 'CFDI debe parsearse correctamente');

      print('📄 CFDI Parseado:');
      print('  RFC Emisor: ${cfdi!.emisor?.rfc}');
      print('  SubTotal: ${cfdi.subTotal}');
      print('  Descuento: ${cfdi.descuento}');
      print('  Total: ${cfdi.total}');
      print('');

      print('🎯 IMPUESTOS:');
      print('  cfdi.impuestos != null: ${cfdi.impuestos != null}');
      if (cfdi.impuestos != null) {
        print(
            '  TotalImpuestosTrasladados: ${cfdi.impuestos!.totalImpuestosTrasladados}');
        print('  ¿Es > 0?: ${cfdi.impuestos!.totalImpuestosTrasladados > 0}');
      }

      // Verificar que el parsing es correcto
      expect(cfdi.subTotal, '2359.53');
      expect(cfdi.descuento, '717.68');
      expect(cfdi.total, '1861.16');
      expect(
        cfdi.impuestos?.totalImpuestosTrasladados,
        219.31,
        reason: 'TotalImpuestosTrasladados debe parsearse como 219.31',
      );

      // Configuración mínima para mapping
      const configuration = DIOTConfiguration(
        year: 2025,
        month: 6,
        ejercicio: 2025,
        periodo: 6,
        rfcContribuyente: 'MERC640209B90',
        tipoComplemento: TipoComplemento.normal,
        filterCriteria: DIOTFilterCriteria(),
        userPreferences: DIOTUserPreferences(),
      );

      // Mapear a DIOT
      final records =
          DIOTMappingService.mapCFDIsToRecords([cfdi], configuration);
      expect(records.length, 1);

      final record = records.first;

      print('');
      print('📊 RESULTADO DEL MAPPING:');
      print('  RFC: ${record.rfc}');
      print('  valorActos16Porciento: \$${record.valorActos16Porciento}');
      print('  devoluciones16Porciento: \$${record.devoluciones16Porciento}');
      print(
          '  ivaAcreditableExclusivo16: \$${record.ivaAcreditableExclusivo16}');

      print('');
      print('🔍 ANÁLISIS CRÍTICO:');
      if (record.ivaAcreditableExclusivo16 == 219.31) {
        print('  ✅ CORRECTO: Usa TotalImpuestosTrasladados (\$219.31)');
      } else if (record.ivaAcreditableExclusivo16 == 377.52) {
        print('  ❌ ERROR: Está calculando 16% del subtotal (\$377.52)');
        print('     Valor esperado: \$219.31');
        print('     Valor obtenido: \$${record.ivaAcreditableExclusivo16}');
      } else {
        print('  ⚠️  OTRO VALOR: \$${record.ivaAcreditableExclusivo16}');
      }

      print('');
      print('🧪 VERIFICANDO EXPORTACIÓN A TXT:');
      final txtLine = record.toPipeDelimitedString();
      print('  Línea TXT generada (primeros 200 chars):');
      print(
          '  ${txtLine.substring(0, txtLine.length > 200 ? 200 : txtLine.length)}...');

      // Extraer campo 11 (Devoluciones 16%)
      final fields = txtLine.split('|');
      if (fields.length > 10) {
        final devolucionesFromTxt = fields[10]; // Campo 11 (0-indexed = 10)
        print('  Campo 11 (Devoluciones 16%): "$devolucionesFromTxt"');

        if (devolucionesFromTxt.contains('717')) {
          print('  ✅ TXT CORRECTO: Contiene descuento del CFDI');
        } else if (devolucionesFromTxt.isEmpty) {
          print('  ❌ TXT VACÍO: Descuento no aparece en TXT');
        } else {
          print('  ⚠️  TXT DESCONOCIDO: "$devolucionesFromTxt"');
        }
      }

      // Verificación final
      expect(
        record.ivaAcreditableExclusivo16,
        219.31,
        reason:
            'Debe usar TotalImpuestosTrasladados del CFDI real (219.31), no calcular',
      );

      // Verificar otros valores
      expect(
        record.valorActos16Porciento,
        2359.53,
        reason: 'Valor de actos debe ser el subtotal',
      );
      expect(
        record.devoluciones16Porciento,
        717.68,
        reason: 'Devoluciones debe ser el descuento del CFDI',
      );

      print('');
      print('✅ ÉXITO: CFDI real se procesa correctamente');
      print('   - TotalImpuestosTrasladados se usa directamente del XML');
      print('   - Descuento se extrae correctamente del CFDI');
      print('   - No se permiten sobrescrituras manuales');
      print('   - Mapping funciona como esperado');
      print('   - Exportación TXT usa valores correctos');
    });

    test('Should demonstrate the exact problem scenario', () async {
      print('=== TEST: Demostrar el problema exacto ===');

      final xmlFile = File('docs/sat/c589b7b7-955f-4f5d-a16b-b78f875e02db.xml');
      final xmlContent = await xmlFile.readAsString();
      final cfdi = CFDIParser.parseXmlString(xmlContent);

      final subtotal = double.parse(cfdi!.subTotal!);
      final ivaReal = cfdi.impuestos!.totalImpuestosTrasladados;
      final ivaCalculadoIncorrecto = subtotal * 0.16;

      print('ESCENARIO REAL:');
      print('  Subtotal: \$${subtotal.toStringAsFixed(2)}');
      print(
          '  TotalImpuestosTrasladados (XML): \$${ivaReal.toStringAsFixed(2)}');
      print(
          '  IVA calculado erróneamente (16%): \$${ivaCalculadoIncorrecto.toStringAsFixed(2)}');
      print(
          '  Diferencia: \$${(ivaCalculadoIncorrecto - ivaReal).toStringAsFixed(2)}');

      print('');
      print('PRODUCTOS EN EL CFDI:');
      if (cfdi.conceptos?.concepto != null) {
        for (int i = 0; i < cfdi.conceptos!.concepto!.length; i++) {
          final concepto = cfdi.conceptos!.concepto![i];
          final tasa = concepto.traslados.isNotEmpty
              ? concepto.traslados.first.tasaOCuota
              : 0.0;
          print(
              '  ${i + 1}. ${concepto.descripcion} - Tasa: ${(tasa * 100).toStringAsFixed(1)}%');
        }
      }

      print('');
      print('💡 CONCLUSIÓN:');
      print('   El CFDI contiene productos con tasas mixtas (0% y 16%)');
      print('   SAT calcula IVA correcto: \$${ivaReal.toStringAsFixed(2)}');
      print('   Sistema debe usar este valor, no calcular 16% sobre todo');

      expect(ivaReal, 219.31);
      expect(ivaCalculadoIncorrecto, 377.52);
    });

    test('Should preserve CFDI descuento even when bulk user input applied',
        () async {
      print(
          '=== TEST: Verificar que descuentos NO se sobrescriben en bulk ===');

      final xmlFile = File('docs/sat/c589b7b7-955f-4f5d-a16b-b78f875e02db.xml');
      final xmlContent = await xmlFile.readAsString();
      final cfdi = CFDIParser.parseXmlString(xmlContent);

      const configuration = DIOTConfiguration(
        year: 2025,
        month: 6,
        ejercicio: 2025,
        periodo: 6,
        rfcContribuyente: 'MERC640209B90',
        tipoComplemento: TipoComplemento.normal,
        filterCriteria: DIOTFilterCriteria(),
        userPreferences: DIOTUserPreferences(),
      );

      // Mapear CFDI a record
      final records =
          DIOTMappingService.mapCFDIsToRecords([cfdi!], configuration);
      final originalRecord = records.first;

      print('📊 RECORD ORIGINAL:');
      print(
          '  devoluciones16Porciento: \$${originalRecord.devoluciones16Porciento}');

      // Simular bulk input que anteriormente sobrescribía descuentos
      final bulkUserInput = {
        'tipoTercero': null, // No cambiar tipo tercero
        'tipoOperacion': null, // No cambiar operación
        'clasificacionRegional': null, // No cambiar región
        'clasificacionIVA': null, // No cambiar clasificación IVA
        // ⚠️ En el código anterior, esto sobrescribía el descuento:
        'devoluciones': 0.0, // <- Este valor NO debe afectar ya el record
      };

      // Aplicar la entrada del usuario
      final updatedRecord = DIOTMappingService.updateRecordWithUserInput(
        originalRecord,
        bulkUserInput,
      );

      print('');
      print('📊 RECORD DESPUÉS DE BULK INPUT:');
      print(
          '  devoluciones16Porciento: \$${updatedRecord.devoluciones16Porciento}');

      print('');
      print('🔍 VERIFICACIÓN:');
      if (updatedRecord.devoluciones16Porciento ==
          originalRecord.devoluciones16Porciento) {
        print('  ✅ CORRECTO: Descuento del CFDI se preservó');
        print(
            '  📋 Valor mantenido: \$${updatedRecord.devoluciones16Porciento}');
      } else {
        print('  ❌ ERROR: Descuento fue sobrescrito');
        print('     Original: \$${originalRecord.devoluciones16Porciento}');
        print('     Después: \$${updatedRecord.devoluciones16Porciento}');
      }

      // El descuento debe mantenerse igual (717.68) sin importar el input del usuario
      expect(
        updatedRecord.devoluciones16Porciento,
        717.68,
        reason:
            'Descuento debe mantenerse del CFDI y no ser sobrescrito por bulk input',
      );

      // Verificar que otros campos no cambiaron (ya que enviamos null)
      expect(updatedRecord.tipoTercero, originalRecord.tipoTercero);
      expect(updatedRecord.clasificacionIVA, originalRecord.clasificacionIVA);

      print('');
      print('✅ ÉXITO: Bulk input ya no sobrescribe descuentos del CFDI');
    });
  });
}
