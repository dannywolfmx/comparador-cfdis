import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/services/diot_mapping_service.dart';

void main() {
  group('DIOT CFDI IVA Debug Tests', () {
    test('Debug exact scenario from user problem', () {
      print('=== DEBUG: Escenario exacto del problema del usuario ===');

      // Simular XML parsing que resulta en el CFDI problemático
      final cfdiData = {
        'SubTotal': '2359.53',
        'Descuento': '717.68',
        'Total': '1861.16',
        'Emisor': {
          'Rfc': 'ABC123456789',
          'Nombre': 'Proveedor Problemático',
        },
        'Receptor': {
          'Rfc': 'XAXX010101000',
          'Nombre': 'Mi Empresa',
        },
        'Impuestos': {
          'TotalImpuestosTrasladados': '219.31', // ❗ VALOR REAL DEL PROBLEMA
          'Traslados': {
            'Traslado': [
              {
                'Impuesto': '002',
                'TipoFactor': 'Tasa',
                'TasaOCuota': '0.160000',
                'Importe': '160.00',
              },
              {
                'Impuesto': '002',
                'TipoFactor': 'Tasa',
                'TasaOCuota': '0.000000',
                'Importe': '0.00',
              }
            ],
          },
        },
        'Conceptos': {
          'Concepto': [
            {
              'Cantidad': '1',
              'ClaveUnidad': 'H87',
              'ClaveProdServ': '50202306',
              'Descripcion': 'Producto con IVA 16%',
              'ValorUnitario': '1000.00',
              'Importe': '1000.00',
              'Impuestos': {
                'Traslados': {
                  'Traslado': {
                    'Base': '1000.00',
                    'Impuesto': '002',
                    'TipoFactor': 'Tasa',
                    'TasaOCuota': '0.160000',
                    'Importe': '160.00',
                  },
                },
              },
            },
            {
              'Cantidad': '1',
              'ClaveUnidad': 'H87',
              'ClaveProdServ': '50202306',
              'Descripcion': 'Producto exento 0%',
              'ValorUnitario': '1359.53',
              'Importe': '1359.53',
              'Impuestos': {
                'Traslados': {
                  'Traslado': {
                    'Base': '1359.53',
                    'Impuesto': '002',
                    'TipoFactor': 'Tasa',
                    'TasaOCuota': '0.000000',
                    'Importe': '0.00',
                  },
                },
              },
            }
          ],
        },
      };

      final cfdi = CFDI.fromJson(cfdiData);

      print('🔍 ANÁLISIS DEL CFDI PARSEADO:');
      print('  SubTotal: \$${cfdi.subTotal}');
      print('  Descuento: \$${cfdi.descuento}');
      print('  Total: \$${cfdi.total}');
      print('');
      print('🎯 IMPUESTOS:');
      print('  cfdi.impuestos != null: ${cfdi.impuestos != null}');
      if (cfdi.impuestos != null) {
        print(
            '  TotalImpuestosTrasladados: \$${cfdi.impuestos!.totalImpuestosTrasladados}');
        print(
            '  TotalImpuestosTrasladados > 0: ${cfdi.impuestos!.totalImpuestosTrasladados > 0}');
      }

      // Simular configuración mínima
      final configuration = DIOTConfiguration(
        year: 2025,
        month: 1,
        ejercicio: '2025',
        periodo: '01',
        rfcContribuyente: 'XAXX010101000',
        tipoComplemento: '0',
        userPreferences: UserPreferences(
          rfcToTipoTercero: {},
          rfcToTipoOperacion: {},
          rfcToClasificacionRegional: {},
          rfcToClasificacionIVA: {},
          rfcToEfectosFiscales: {},
          rfcToExtranjeroInfo: {},
        ),
      );

      // Mapear a DIOT
      final records =
          DIOTMappingService.mapCFDIsToRecords([cfdi], configuration);
      expect(records.length, 1);

      final record = records.first;

      print('');
      print('📋 RESULTADO DEL MAPEO DIOT:');
      print('  valorActos16Porciento: \$${record.valorActos16Porciento}');
      print(
          '  ivaAcreditableExclusivo16: \$${record.ivaAcreditableExclusivo16}');
      print('  devoluciones16Porciento: \$${record.devoluciones16Porciento}');

      print('');
      print('🎯 ANÁLISIS CRÍTICO:');
      if (record.ivaAcreditableExclusivo16 == 219.31) {
        print('  ✅ CORRECTO: Usa TotalImpuestosTrasladados (\$219.31)');
      } else if (record.ivaAcreditableExclusivo16 == 377.52) {
        print('  ❌ ERROR: Está calculando 16% del subtotal (\$377.52)');
      } else {
        print('  ⚠️  OTRO VALOR: \$${record.ivaAcreditableExclusivo16}');
      }

      // Verificación final
      expect(
        record.ivaAcreditableExclusivo16,
        219.31,
        reason: 'Debe usar TotalImpuestosTrasladados del CFDI, no calcular',
      );

      print('');
      print('✅ DIAGNÓSTICO COMPLETO: Sistema funciona correctamente');
    });

    test('Debug potential null or zero TotalImpuestosTrasladados', () {
      print('=== DEBUG: Potencial TotalImpuestosTrasladados nulo o cero ===');

      final testCases = [
        {
          'name': 'Con TotalImpuestosTrasladados válido',
          'data': {
            'SubTotal': '1000.00',
            'Emisor': {'Rfc': 'TEST123456789'},
            'Impuestos': {'TotalImpuestosTrasladados': '160.00'},
          },
          'expected': 160.0,
        },
        {
          'name': 'Con TotalImpuestosTrasladados en cero',
          'data': {
            'SubTotal': '1000.00',
            'Emisor': {'Rfc': 'TEST123456789'},
            'Impuestos': {'TotalImpuestosTrasladados': '0.00'},
          },
          'expected': 0.0, // Debería usar fallback pero sin conceptos = 0
        },
        {
          'name': 'Sin sección Impuestos',
          'data': {
            'SubTotal': '1000.00',
            'Emisor': {'Rfc': 'TEST123456789'},
          },
          'expected': 0.0, // Sin impuestos, fallback = 0
        }
      ];

      for (final testCase in testCases) {
        print('');
        print('🧪 Caso: ${testCase['name']}');

        final cfdi = CFDI.fromJson(testCase['data']);

        print('  cfdi.impuestos != null: ${cfdi.impuestos != null}');
        if (cfdi.impuestos != null) {
          print(
              '  TotalImpuestosTrasladados: \$${cfdi.impuestos!.totalImpuestosTrasladados}');
        }

        // Simular la lógica del mapping
        double ivaResultado = 0;
        if (cfdi.impuestos?.totalImpuestosTrasladados != null &&
            cfdi.impuestos!.totalImpuestosTrasladados > 0) {
          ivaResultado = cfdi.impuestos!.totalImpuestosTrasladados;
          print('  ✅ Usa TotalImpuestosTrasladados: \$$ivaResultado');
        } else {
          // Fallback (sin conceptos en estos tests = 0)
          ivaResultado = 0.0;
          print('  ⚠️  Usa fallback a cálculo: \$$ivaResultado');
        }

        expect(
          ivaResultado,
          testCase['expected'],
          reason: 'Caso "${testCase['name']}" debe dar resultado esperado',
        );
      }

      print('');
      print('✅ TODOS LOS CASOS MANEJADOS CORRECTAMENTE');
    });
  });
}
