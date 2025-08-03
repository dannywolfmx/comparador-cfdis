import 'package:equatable/equatable.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/services/diot_validation_service.dart';

abstract class DIOTState extends Equatable {
  const DIOTState();

  @override
  List<Object?> get props => [];
}

class DIOTInitial extends DIOTState {}

class DIOTLoading extends DIOTState {
  final String message;

  const DIOTLoading({this.message = 'Procesando...'});

  @override
  List<Object> get props => [message];
}

class DIOTBatchLoaded extends DIOTState {
  final DIOTBatch batch;
  final DIOTValidationSummary validationSummary;

  const DIOTBatchLoaded(this.batch, this.validationSummary);

  @override
  List<Object> get props => [batch, validationSummary];
}

class DIOTBatchCreated extends DIOTState {
  final DIOTBatch batch;
  final DIOTValidationSummary validationSummary;
  final int recordsRequiringInput;

  const DIOTBatchCreated(
    this.batch,
    this.validationSummary,
    this.recordsRequiringInput,
  );

  @override
  List<Object> get props => [batch, validationSummary, recordsRequiringInput];
}

class DIOTBatchGenerated extends DIOTState {
  final DIOTBatch batch;
  final DIOTValidationSummary validationSummary;
  final int recordsRequiringInput;

  const DIOTBatchGenerated(
    this.batch,
    this.validationSummary,
    this.recordsRequiringInput,
  );

  @override
  List<Object> get props => [batch, validationSummary, recordsRequiringInput];
}

class DIOTRecordUpdated extends DIOTState {
  final DIOTBatch batch;
  final DIOTValidationSummary validationSummary;
  final String updatedRfc;

  const DIOTRecordUpdated(
    this.batch,
    this.validationSummary,
    this.updatedRfc,
  );

  @override
  List<Object> get props => [batch, validationSummary, updatedRfc];
}

class DIOTValidated extends DIOTState {
  final DIOTBatch batch;
  final DIOTValidationSummary validationSummary;
  final bool isReadyForExport;

  const DIOTValidated(
    this.batch,
    this.validationSummary,
    this.isReadyForExport,
  );

  @override
  List<Object> get props => [batch, validationSummary, isReadyForExport];
}

class DIOTExported extends DIOTState {
  final String filePath;
  final int totalRecords;

  const DIOTExported(this.filePath, this.totalRecords);

  @override
  List<Object> get props => [filePath, totalRecords];
}

class DIOTError extends DIOTState {
  final String message;
  final String? details;

  const DIOTError(this.message, {this.details});

  @override
  List<Object?> get props => [message, details];
}

class DIOTUserInputRequired extends DIOTState {
  final DIOTBatch batch;
  final List<String> rfcsRequiringInput;
  final String message;

  const DIOTUserInputRequired(
    this.batch,
    this.rfcsRequiringInput,
    this.message,
  );

  @override
  List<Object> get props => [batch, rfcsRequiringInput, message];
}
