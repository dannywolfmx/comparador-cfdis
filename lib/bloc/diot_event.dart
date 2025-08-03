import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/models/diot_record.dart';
import 'package:comparador_cfdis/models/cfdi.dart';

abstract class DIOTEvent {}

class CreateDIOTBatch extends DIOTEvent {
  final DIOTConfiguration configuration;

  CreateDIOTBatch(this.configuration);
}

class GenerateDIOTBatch extends DIOTEvent {
  final List<CFDI> cfdis;
  final DIOTConfiguration configuration;

  GenerateDIOTBatch({required this.cfdis, required this.configuration});
}

class LoadDIOTBatch extends DIOTEvent {
  final String batchId;

  LoadDIOTBatch(this.batchId);
}

class UpdateRecordUserInput extends DIOTEvent {
  final String recordRfc;
  final Map<String, dynamic> userInput;

  UpdateRecordUserInput(this.recordRfc, this.userInput);
}

class ValidateBatch extends DIOTEvent {}

class ExportDIOTFile extends DIOTEvent {
  final String? filePath;

  ExportDIOTFile({this.filePath});
}

class ApplyBulkClassification extends DIOTEvent {
  final List<String> rfcs;
  final TipoTercero? tipoTercero;
  final TipoOperacion? tipoOperacion;
  final ClasificacionRegional? clasificacionRegional;
  final ClasificacionIVA? clasificacionIVA;

  ApplyBulkClassification({
    required this.rfcs,
    this.tipoTercero,
    this.tipoOperacion,
    this.clasificacionRegional,
    this.clasificacionIVA,
  });
}

class SaveUserPreferences extends DIOTEvent {
  final DIOTUserPreferences preferences;

  SaveUserPreferences(this.preferences);
}

class ClearDIOTBatch extends DIOTEvent {}
