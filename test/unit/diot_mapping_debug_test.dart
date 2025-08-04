import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/services/diot_mapping_service.dart';

void main() {
  group('DIOT Mapping Service Debug', () {
    test('Trigger mapping service with debug output', () {
      print('=== TRIGGER MAPPING SERVICE DEBUG ===');

      // CFDI con TotalImpuestosTrasladados
      final cfdiData = {
        'SubTotal': '2359.53',
        'Emisor': {
          'Rfc': 'ABC123456789',
          'Nombre': 'Proveedor Test',
        },
        'Impuestos': {
          'TotalImpuestosTrasladados': '219.31',
        },
      };

      final cfdi = CFDI.fromJson(cfdiData);

      // Configuración mínima
      final configuration = DIOTConfiguration(
        year: 2025,
        month: 1,
        ejercicio: 2025,
        periodo: 1,
        rfcContribuyente: 'XAXX010101000',
        tipoComplemento: TipoComplemento.proveedor,
        filterCriteria: FilterCriteria(),
        userPreferences: UserPreferences(
          rfcToTipoTercero: {},
          rfcToTipoOperacion: {},
          rfcToClasificacionRegional: {},
          rfcToClasificacionIVA: {},
          rfcToEfectosFiscales: {},
          rfcToExtranjeroInfo: {},
        ),
      );

      // Esto debería activar el debug
      final records =
          DIOTMappingService.mapCFDIsToRecords([cfdi], configuration);

      expect(records.length, 1);
      final record = records.first;

      print('Resultado final:');
      print('  ivaAcreditableExclusivo16: ${record.ivaAcreditableExclusivo16}');

      expect(record.ivaAcreditableExclusivo16, 219.31);
    });
  });
}
