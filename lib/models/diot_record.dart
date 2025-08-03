import 'package:equatable/equatable.dart';

/// Representa un registro individual en la DIOT
class DIOTRecord extends Equatable {
  final String rfc;
  final String? numeroIdentificacionFiscal;
  final String? nombreExtranjero;
  final String? paisResidenciaFiscal;
  final String? especificarJurisdiccion;

  // Clasificaciones del usuario
  final TipoTercero tipoTercero;
  final TipoOperacion tipoOperacion;
  final ClasificacionRegional? clasificacionRegional;
  final ClasificacionIVA? clasificacionIVA;
  final EfectosFiscales efectosFiscales;

  // Valores calculados desde CFDIs
  final double valorActosFronteraNorte;
  final double devolucionesFronteraNorte;
  final double valorActosFronteraSur;
  final double devolucionesFronteraSur;
  final double valorActos16Porciento;
  final double devoluciones16Porciento;
  final double valorImportacionTangibles16;
  final double devolucionesImportacionTangibles16;
  final double valorImportacionIntangibles16;
  final double devolucionesImportacionIntangibles16;

  // IVA acreditable (requiere clasificación del usuario)
  final double ivaAcreditableExclusivoFronteraNorte;
  final double ivaAcreditableProporcionFronteraNorte;
  final double ivaAcreditableExclusivoFronteraSur;
  final double ivaAcreditableProporcionFronteraSur;
  final double ivaAcreditableExclusivo16;
  final double ivaAcreditableProporcion16;
  final double ivaAcreditableExclusivoImportacionTangibles16;
  final double ivaAcreditableProporcionImportacionTangibles16;
  final double ivaAcreditableExclusivoImportacionIntangibles16;
  final double ivaAcreditableProporcionImportacionIntangibles16;

  // IVA no acreditable
  final double ivaNoAcreditableProporcionFronteraNorte;
  final double ivaNoAcreditableSinRequisitosFronteraNorte;
  final double ivaNoAcreditableExentasFronteraNorte;
  final double ivaNoAcreditableNoObjetoFronteraNorte;
  final double ivaNoAcreditableProporcionFronteraSur;
  final double ivaNoAcreditableSinRequisitosFronteraSur;
  final double ivaNoAcreditableExentasFronteraSur;
  final double ivaNoAcreditableNoObjetoFronteraSur;
  final double ivaNoAcreditableProporcion16;
  final double ivaNoAcreditableSinRequisitos16;
  final double ivaNoAcreditableExentas16;
  final double ivaNoAcreditableNoObjeto16;
  final double ivaNoAcreditableProporcionImportacionTangibles16;
  final double ivaNoAcreditableSinRequisitosImportacionTangibles16;
  final double ivaNoAcreditableExentasImportacionTangibles16;
  final double ivaNoAcreditableNoObjetoImportacionTangibles16;
  final double ivaNoAcreditableProporcionImportacionIntangibles16;
  final double ivaNoAcreditableSinRequisitosImportacionIntangibles16;
  final double ivaNoAcreditableExentasImportacionIntangibles16;
  final double ivaNoAcreditableNoObjetoImportacionIntangibles16;

  // Otros campos
  final double ivaRetenido;
  final double importacionExentos;
  final double actosExentos;
  final double actosTasaCero;
  final double actosNoObjetoNacional;
  final double actosNoObjetoSinEstablecimiento;

  // Estado de validación
  final List<DIOTValidationError> validationErrors;
  final bool requiresUserInput;

  const DIOTRecord({
    required this.rfc,
    this.numeroIdentificacionFiscal,
    this.nombreExtranjero,
    this.paisResidenciaFiscal,
    this.especificarJurisdiccion,
    required this.tipoTercero,
    required this.tipoOperacion,
    this.clasificacionRegional,
    this.clasificacionIVA,
    required this.efectosFiscales,
    this.valorActosFronteraNorte = 0,
    this.devolucionesFronteraNorte = 0,
    this.valorActosFronteraSur = 0,
    this.devolucionesFronteraSur = 0,
    this.valorActos16Porciento = 0,
    this.devoluciones16Porciento = 0,
    this.valorImportacionTangibles16 = 0,
    this.devolucionesImportacionTangibles16 = 0,
    this.valorImportacionIntangibles16 = 0,
    this.devolucionesImportacionIntangibles16 = 0,
    this.ivaAcreditableExclusivoFronteraNorte = 0,
    this.ivaAcreditableProporcionFronteraNorte = 0,
    this.ivaAcreditableExclusivoFronteraSur = 0,
    this.ivaAcreditableProporcionFronteraSur = 0,
    this.ivaAcreditableExclusivo16 = 0,
    this.ivaAcreditableProporcion16 = 0,
    this.ivaAcreditableExclusivoImportacionTangibles16 = 0,
    this.ivaAcreditableProporcionImportacionTangibles16 = 0,
    this.ivaAcreditableExclusivoImportacionIntangibles16 = 0,
    this.ivaAcreditableProporcionImportacionIntangibles16 = 0,
    this.ivaNoAcreditableProporcionFronteraNorte = 0,
    this.ivaNoAcreditableSinRequisitosFronteraNorte = 0,
    this.ivaNoAcreditableExentasFronteraNorte = 0,
    this.ivaNoAcreditableNoObjetoFronteraNorte = 0,
    this.ivaNoAcreditableProporcionFronteraSur = 0,
    this.ivaNoAcreditableSinRequisitosFronteraSur = 0,
    this.ivaNoAcreditableExentasFronteraSur = 0,
    this.ivaNoAcreditableNoObjetoFronteraSur = 0,
    this.ivaNoAcreditableProporcion16 = 0,
    this.ivaNoAcreditableSinRequisitos16 = 0,
    this.ivaNoAcreditableExentas16 = 0,
    this.ivaNoAcreditableNoObjeto16 = 0,
    this.ivaNoAcreditableProporcionImportacionTangibles16 = 0,
    this.ivaNoAcreditableSinRequisitosImportacionTangibles16 = 0,
    this.ivaNoAcreditableExentasImportacionTangibles16 = 0,
    this.ivaNoAcreditableNoObjetoImportacionTangibles16 = 0,
    this.ivaNoAcreditableProporcionImportacionIntangibles16 = 0,
    this.ivaNoAcreditableSinRequisitosImportacionIntangibles16 = 0,
    this.ivaNoAcreditableExentasImportacionIntangibles16 = 0,
    this.ivaNoAcreditableNoObjetoImportacionIntangibles16 = 0,
    this.ivaRetenido = 0,
    this.importacionExentos = 0,
    this.actosExentos = 0,
    this.actosTasaCero = 0,
    this.actosNoObjetoNacional = 0,
    this.actosNoObjetoSinEstablecimiento = 0,
    this.validationErrors = const [],
    this.requiresUserInput = false,
  });

  DIOTRecord copyWith({
    String? rfc,
    String? numeroIdentificacionFiscal,
    String? nombreExtranjero,
    String? paisResidenciaFiscal,
    String? especificarJurisdiccion,
    TipoTercero? tipoTercero,
    TipoOperacion? tipoOperacion,
    ClasificacionRegional? clasificacionRegional,
    ClasificacionIVA? clasificacionIVA,
    EfectosFiscales? efectosFiscales,
    double? valorActosFronteraNorte,
    double? devolucionesFronteraNorte,
    double? valorActosFronteraSur,
    double? devolucionesFronteraSur,
    double? valorActos16Porciento,
    double? devoluciones16Porciento,
    double? valorImportacionTangibles16,
    double? devolucionesImportacionTangibles16,
    double? valorImportacionIntangibles16,
    double? devolucionesImportacionIntangibles16,
    double? ivaAcreditableExclusivoFronteraNorte,
    double? ivaAcreditableProporcionFronteraNorte,
    double? ivaAcreditableExclusivoFronteraSur,
    double? ivaAcreditableProporcionFronteraSur,
    double? ivaAcreditableExclusivo16,
    double? ivaAcreditableProporcion16,
    double? ivaAcreditableExclusivoImportacionTangibles16,
    double? ivaAcreditableProporcionImportacionTangibles16,
    double? ivaAcreditableExclusivoImportacionIntangibles16,
    double? ivaAcreditableProporcionImportacionIntangibles16,
    double? ivaNoAcreditableProporcionFronteraNorte,
    double? ivaNoAcreditableSinRequisitosFronteraNorte,
    double? ivaNoAcreditableExentasFronteraNorte,
    double? ivaNoAcreditableNoObjetoFronteraNorte,
    double? ivaNoAcreditableProporcionFronteraSur,
    double? ivaNoAcreditableSinRequisitosFronteraSur,
    double? ivaNoAcreditableExentasFronteraSur,
    double? ivaNoAcreditableNoObjetoFronteraSur,
    double? ivaNoAcreditableProporcion16,
    double? ivaNoAcreditableSinRequisitos16,
    double? ivaNoAcreditableExentas16,
    double? ivaNoAcreditableNoObjeto16,
    double? ivaNoAcreditableProporcionImportacionTangibles16,
    double? ivaNoAcreditableSinRequisitosImportacionTangibles16,
    double? ivaNoAcreditableExentasImportacionTangibles16,
    double? ivaNoAcreditableNoObjetoImportacionTangibles16,
    double? ivaNoAcreditableProporcionImportacionIntangibles16,
    double? ivaNoAcreditableSinRequisitosImportacionIntangibles16,
    double? ivaNoAcreditableExentasImportacionIntangibles16,
    double? ivaNoAcreditableNoObjetoImportacionIntangibles16,
    double? ivaRetenido,
    double? importacionExentos,
    double? actosExentos,
    double? actosTasaCero,
    double? actosNoObjetoNacional,
    double? actosNoObjetoSinEstablecimiento,
    List<DIOTValidationError>? validationErrors,
    bool? requiresUserInput,
  }) {
    return DIOTRecord(
      rfc: rfc ?? this.rfc,
      numeroIdentificacionFiscal:
          numeroIdentificacionFiscal ?? this.numeroIdentificacionFiscal,
      nombreExtranjero: nombreExtranjero ?? this.nombreExtranjero,
      paisResidenciaFiscal: paisResidenciaFiscal ?? this.paisResidenciaFiscal,
      especificarJurisdiccion:
          especificarJurisdiccion ?? this.especificarJurisdiccion,
      tipoTercero: tipoTercero ?? this.tipoTercero,
      tipoOperacion: tipoOperacion ?? this.tipoOperacion,
      clasificacionRegional:
          clasificacionRegional ?? this.clasificacionRegional,
      clasificacionIVA: clasificacionIVA ?? this.clasificacionIVA,
      efectosFiscales: efectosFiscales ?? this.efectosFiscales,
      valorActosFronteraNorte:
          valorActosFronteraNorte ?? this.valorActosFronteraNorte,
      devolucionesFronteraNorte:
          devolucionesFronteraNorte ?? this.devolucionesFronteraNorte,
      valorActosFronteraSur:
          valorActosFronteraSur ?? this.valorActosFronteraSur,
      devolucionesFronteraSur:
          devolucionesFronteraSur ?? this.devolucionesFronteraSur,
      valorActos16Porciento:
          valorActos16Porciento ?? this.valorActos16Porciento,
      devoluciones16Porciento:
          devoluciones16Porciento ?? this.devoluciones16Porciento,
      valorImportacionTangibles16:
          valorImportacionTangibles16 ?? this.valorImportacionTangibles16,
      devolucionesImportacionTangibles16: devolucionesImportacionTangibles16 ??
          this.devolucionesImportacionTangibles16,
      valorImportacionIntangibles16:
          valorImportacionIntangibles16 ?? this.valorImportacionIntangibles16,
      devolucionesImportacionIntangibles16:
          devolucionesImportacionIntangibles16 ??
              this.devolucionesImportacionIntangibles16,
      ivaAcreditableExclusivoFronteraNorte:
          ivaAcreditableExclusivoFronteraNorte ??
              this.ivaAcreditableExclusivoFronteraNorte,
      ivaAcreditableProporcionFronteraNorte:
          ivaAcreditableProporcionFronteraNorte ??
              this.ivaAcreditableProporcionFronteraNorte,
      ivaAcreditableExclusivoFronteraSur: ivaAcreditableExclusivoFronteraSur ??
          this.ivaAcreditableExclusivoFronteraSur,
      ivaAcreditableProporcionFronteraSur:
          ivaAcreditableProporcionFronteraSur ??
              this.ivaAcreditableProporcionFronteraSur,
      ivaAcreditableExclusivo16:
          ivaAcreditableExclusivo16 ?? this.ivaAcreditableExclusivo16,
      ivaAcreditableProporcion16:
          ivaAcreditableProporcion16 ?? this.ivaAcreditableProporcion16,
      ivaAcreditableExclusivoImportacionTangibles16:
          ivaAcreditableExclusivoImportacionTangibles16 ??
              this.ivaAcreditableExclusivoImportacionTangibles16,
      ivaAcreditableProporcionImportacionTangibles16:
          ivaAcreditableProporcionImportacionTangibles16 ??
              this.ivaAcreditableProporcionImportacionTangibles16,
      ivaAcreditableExclusivoImportacionIntangibles16:
          ivaAcreditableExclusivoImportacionIntangibles16 ??
              this.ivaAcreditableExclusivoImportacionIntangibles16,
      ivaAcreditableProporcionImportacionIntangibles16:
          ivaAcreditableProporcionImportacionIntangibles16 ??
              this.ivaAcreditableProporcionImportacionIntangibles16,
      ivaNoAcreditableProporcionFronteraNorte:
          ivaNoAcreditableProporcionFronteraNorte ??
              this.ivaNoAcreditableProporcionFronteraNorte,
      ivaNoAcreditableSinRequisitosFronteraNorte:
          ivaNoAcreditableSinRequisitosFronteraNorte ??
              this.ivaNoAcreditableSinRequisitosFronteraNorte,
      ivaNoAcreditableExentasFronteraNorte:
          ivaNoAcreditableExentasFronteraNorte ??
              this.ivaNoAcreditableExentasFronteraNorte,
      ivaNoAcreditableNoObjetoFronteraNorte:
          ivaNoAcreditableNoObjetoFronteraNorte ??
              this.ivaNoAcreditableNoObjetoFronteraNorte,
      ivaNoAcreditableProporcionFronteraSur:
          ivaNoAcreditableProporcionFronteraSur ??
              this.ivaNoAcreditableProporcionFronteraSur,
      ivaNoAcreditableSinRequisitosFronteraSur:
          ivaNoAcreditableSinRequisitosFronteraSur ??
              this.ivaNoAcreditableSinRequisitosFronteraSur,
      ivaNoAcreditableExentasFronteraSur: ivaNoAcreditableExentasFronteraSur ??
          this.ivaNoAcreditableExentasFronteraSur,
      ivaNoAcreditableNoObjetoFronteraSur:
          ivaNoAcreditableNoObjetoFronteraSur ??
              this.ivaNoAcreditableNoObjetoFronteraSur,
      ivaNoAcreditableProporcion16:
          ivaNoAcreditableProporcion16 ?? this.ivaNoAcreditableProporcion16,
      ivaNoAcreditableSinRequisitos16: ivaNoAcreditableSinRequisitos16 ??
          this.ivaNoAcreditableSinRequisitos16,
      ivaNoAcreditableExentas16:
          ivaNoAcreditableExentas16 ?? this.ivaNoAcreditableExentas16,
      ivaNoAcreditableNoObjeto16:
          ivaNoAcreditableNoObjeto16 ?? this.ivaNoAcreditableNoObjeto16,
      ivaNoAcreditableProporcionImportacionTangibles16:
          ivaNoAcreditableProporcionImportacionTangibles16 ??
              this.ivaNoAcreditableProporcionImportacionTangibles16,
      ivaNoAcreditableSinRequisitosImportacionTangibles16:
          ivaNoAcreditableSinRequisitosImportacionTangibles16 ??
              this.ivaNoAcreditableSinRequisitosImportacionTangibles16,
      ivaNoAcreditableExentasImportacionTangibles16:
          ivaNoAcreditableExentasImportacionTangibles16 ??
              this.ivaNoAcreditableExentasImportacionTangibles16,
      ivaNoAcreditableNoObjetoImportacionTangibles16:
          ivaNoAcreditableNoObjetoImportacionTangibles16 ??
              this.ivaNoAcreditableNoObjetoImportacionTangibles16,
      ivaNoAcreditableProporcionImportacionIntangibles16:
          ivaNoAcreditableProporcionImportacionIntangibles16 ??
              this.ivaNoAcreditableProporcionImportacionIntangibles16,
      ivaNoAcreditableSinRequisitosImportacionIntangibles16:
          ivaNoAcreditableSinRequisitosImportacionIntangibles16 ??
              this.ivaNoAcreditableSinRequisitosImportacionIntangibles16,
      ivaNoAcreditableExentasImportacionIntangibles16:
          ivaNoAcreditableExentasImportacionIntangibles16 ??
              this.ivaNoAcreditableExentasImportacionIntangibles16,
      ivaNoAcreditableNoObjetoImportacionIntangibles16:
          ivaNoAcreditableNoObjetoImportacionIntangibles16 ??
              this.ivaNoAcreditableNoObjetoImportacionIntangibles16,
      ivaRetenido: ivaRetenido ?? this.ivaRetenido,
      importacionExentos: importacionExentos ?? this.importacionExentos,
      actosExentos: actosExentos ?? this.actosExentos,
      actosTasaCero: actosTasaCero ?? this.actosTasaCero,
      actosNoObjetoNacional:
          actosNoObjetoNacional ?? this.actosNoObjetoNacional,
      actosNoObjetoSinEstablecimiento: actosNoObjetoSinEstablecimiento ??
          this.actosNoObjetoSinEstablecimiento,
      validationErrors: validationErrors ?? this.validationErrors,
      requiresUserInput: requiresUserInput ?? this.requiresUserInput,
    );
  }

  /// Convierte el registro a formato pipe-delimited para DIOT
  String toPipeDelimitedString() {
    return [
      tipoTercero.code,
      tipoOperacion.code,
      tipoTercero == TipoTercero.global
          ? 'XAXX010101000'
          : (rfc.isEmpty ? '' : rfc),
      tipoTercero == TipoTercero.extranjero
          ? (numeroIdentificacionFiscal ?? '')
          : '',
      tipoTercero == TipoTercero.extranjero ? (nombreExtranjero ?? '') : '',
      tipoTercero == TipoTercero.extranjero ? (paisResidenciaFiscal ?? '') : '',
      paisResidenciaFiscal == 'ZZZ' ? (especificarJurisdiccion ?? '') : '',
      valorActosFronteraNorte.toInt().toString(),
      devolucionesFronteraNorte.toInt().toString(),
      valorActosFronteraSur.toInt().toString(),
      devolucionesFronteraSur.toInt().toString(),
      valorActos16Porciento.toInt().toString(),
      devoluciones16Porciento.toInt().toString(),
      valorImportacionTangibles16.toInt().toString(),
      devolucionesImportacionTangibles16.toInt().toString(),
      valorImportacionIntangibles16.toInt().toString(),
      devolucionesImportacionIntangibles16.toInt().toString(),
      ivaAcreditableExclusivoFronteraNorte.toInt().toString(),
      ivaAcreditableProporcionFronteraNorte.toInt().toString(),
      ivaAcreditableExclusivoFronteraSur.toInt().toString(),
      ivaAcreditableProporcionFronteraSur.toInt().toString(),
      ivaAcreditableExclusivo16.toInt().toString(),
      ivaAcreditableProporcion16.toInt().toString(),
      ivaAcreditableExclusivoImportacionTangibles16.toInt().toString(),
      ivaAcreditableProporcionImportacionTangibles16.toInt().toString(),
      ivaAcreditableExclusivoImportacionIntangibles16.toInt().toString(),
      ivaAcreditableProporcionImportacionIntangibles16.toInt().toString(),
      ivaNoAcreditableProporcionFronteraNorte.toInt().toString(),
      ivaNoAcreditableSinRequisitosFronteraNorte.toInt().toString(),
      ivaNoAcreditableExentasFronteraNorte.toInt().toString(),
      ivaNoAcreditableNoObjetoFronteraNorte.toInt().toString(),
      ivaNoAcreditableProporcionFronteraSur.toInt().toString(),
      ivaNoAcreditableSinRequisitosFronteraSur.toInt().toString(),
      ivaNoAcreditableExentasFronteraSur.toInt().toString(),
      ivaNoAcreditableNoObjetoFronteraSur.toInt().toString(),
      ivaNoAcreditableProporcion16.toInt().toString(),
      ivaNoAcreditableSinRequisitos16.toInt().toString(),
      ivaNoAcreditableExentas16.toInt().toString(),
      ivaNoAcreditableNoObjeto16.toInt().toString(),
      ivaNoAcreditableProporcionImportacionTangibles16.toInt().toString(),
      ivaNoAcreditableSinRequisitosImportacionTangibles16.toInt().toString(),
      ivaNoAcreditableExentasImportacionTangibles16.toInt().toString(),
      ivaNoAcreditableNoObjetoImportacionTangibles16.toInt().toString(),
      ivaNoAcreditableProporcionImportacionIntangibles16.toInt().toString(),
      ivaNoAcreditableSinRequisitosImportacionIntangibles16.toInt().toString(),
      ivaNoAcreditableExentasImportacionIntangibles16.toInt().toString(),
      ivaNoAcreditableNoObjetoImportacionIntangibles16.toInt().toString(),
      ivaRetenido.toInt().toString(),
      importacionExentos.toInt().toString(),
      actosExentos.toInt().toString(),
      actosTasaCero.toInt().toString(),
      actosNoObjetoNacional.toInt().toString(),
      actosNoObjetoSinEstablecimiento.toInt().toString(),
      efectosFiscales.code,
    ].join('|');
  }

  @override
  List<Object?> get props => [
        rfc,
        numeroIdentificacionFiscal,
        nombreExtranjero,
        paisResidenciaFiscal,
        especificarJurisdiccion,
        tipoTercero,
        tipoOperacion,
        clasificacionRegional,
        clasificacionIVA,
        efectosFiscales,
        valorActosFronteraNorte,
        devolucionesFronteraNorte,
        valorActosFronteraSur,
        devolucionesFronteraSur,
        valorActos16Porciento,
        devoluciones16Porciento,
        valorImportacionTangibles16,
        devolucionesImportacionTangibles16,
        valorImportacionIntangibles16,
        devolucionesImportacionIntangibles16,
        validationErrors,
        requiresUserInput,
      ];
}

/// Enumeración para tipos de tercero
enum TipoTercero {
  nacional('04', 'Proveedor Nacional'),
  extranjero('05', 'Proveedor Extranjero'),
  global('15', 'Proveedor Global');

  const TipoTercero(this.code, this.description);
  final String code;
  final String description;
}

/// Enumeración para tipos de operación
enum TipoOperacion {
  enajenacionBienes('02', 'Enajenación de bienes'),
  prestacionServicios('03', 'Prestación de Servicios Profesionales'),
  usoGoceTemporal('06', 'Uso o goce temporal de bienes'),
  importacionTransferencia('08', 'Importación por transferencia virtual'),
  otros('85', 'Otros'),
  importacionBienesServicios('07', 'Importación de bienes o servicios'),
  operacionesGlobales('87', 'Operaciones globales');

  const TipoOperacion(this.code, this.description);
  final String code;
  final String description;

  static List<TipoOperacion> getValidForTipoTercero(TipoTercero tipoTercero) {
    switch (tipoTercero) {
      case TipoTercero.nacional:
        return [
          enajenacionBienes,
          prestacionServicios,
          usoGoceTemporal,
          importacionTransferencia,
          otros,
        ];
      case TipoTercero.extranjero:
        return [
          enajenacionBienes,
          prestacionServicios,
          importacionBienesServicios,
        ];
      case TipoTercero.global:
        return [operacionesGlobales];
    }
  }
}

/// Clasificación regional para IVA
enum ClasificacionRegional {
  fronteraNorte('Región Fronteriza Norte'),
  fronteraSur('Región Fronteriza Sur'),
  nacional('Nacional - 16%');

  const ClasificacionRegional(this.description);
  final String description;
}

/// Clasificación de IVA acreditable
enum ClasificacionIVA {
  exclusivoActividades('Exclusivamente de actividades gravadas'),
  proporcion('Asociado a actividades por las cuales se aplicó una proporción'),
  sinRequisitos('Asociado a actividades que no cumple con requisitos'),
  exentas('Asociado a actividades exentas'),
  noObjeto('Asociado a actividades no objeto');

  const ClasificacionIVA(this.description);
  final String description;
}

/// Efectos fiscales de los comprobantes
enum EfectosFiscales {
  si('01', 'Sí'),
  no('02', 'No');

  const EfectosFiscales(this.code, this.description);
  final String code;
  final String description;
}

/// Error de validación DIOT
class DIOTValidationError extends Equatable {
  final String field;
  final String message;
  final DIOTValidationSeverity severity;

  const DIOTValidationError({
    required this.field,
    required this.message,
    required this.severity,
  });

  @override
  List<Object> get props => [field, message, severity];
}

enum DIOTValidationSeverity {
  error,
  warning,
  info,
}
