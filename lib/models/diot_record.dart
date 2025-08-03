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
  final double? valorActosFronteraNorte;
  final double? devolucionesFronteraNorte;
  final double? valorActosFronteraSur;
  final double? devolucionesFronteraSur;
  final double? valorActos16Porciento;
  final double? devoluciones16Porciento;
  final double? valorImportacionTangibles16;
  final double? devolucionesImportacionTangibles16;
  final double? valorImportacionIntangibles16;
  final double? devolucionesImportacionIntangibles16;

  // IVA acreditable (requiere clasificación del usuario)
  final double? ivaAcreditableExclusivoFronteraNorte;
  final double? ivaAcreditableProporcionFronteraNorte;
  final double? ivaAcreditableExclusivoFronteraSur;
  final double? ivaAcreditableProporcionFronteraSur;
  final double? ivaAcreditableExclusivo16;
  final double? ivaAcreditableProporcion16;
  final double? ivaAcreditableExclusivoImportacionTangibles16;
  final double? ivaAcreditableProporcionImportacionTangibles16;
  final double? ivaAcreditableExclusivoImportacionIntangibles16;
  final double? ivaAcreditableProporcionImportacionIntangibles16;

  // IVA no acreditable
  final double? ivaNoAcreditableProporcionFronteraNorte;
  final double? ivaNoAcreditableSinRequisitosFronteraNorte;
  final double? ivaNoAcreditableExentasFronteraNorte;
  final double? ivaNoAcreditableNoObjetoFronteraNorte;
  final double? ivaNoAcreditableProporcionFronteraSur;
  final double? ivaNoAcreditableSinRequisitosFronteraSur;
  final double? ivaNoAcreditableExentasFronteraSur;
  final double? ivaNoAcreditableNoObjetoFronteraSur;
  final double? ivaNoAcreditableProporcion16;
  final double? ivaNoAcreditableSinRequisitos16;
  final double? ivaNoAcreditableExentas16;
  final double? ivaNoAcreditableNoObjeto16;
  final double? ivaNoAcreditableProporcionImportacionTangibles16;
  final double? ivaNoAcreditableSinRequisitosImportacionTangibles16;
  final double? ivaNoAcreditableExentasImportacionTangibles16;
  final double? ivaNoAcreditableNoObjetoImportacionTangibles16;
  final double? ivaNoAcreditableProporcionImportacionIntangibles16;
  final double? ivaNoAcreditableSinRequisitosImportacionIntangibles16;
  final double? ivaNoAcreditableExentasImportacionIntangibles16;
  final double? ivaNoAcreditableNoObjetoImportacionIntangibles16;

  // Otros campos
  final double? ivaRetenido;
  final double? importacionExentos;
  final double? actosExentos;
  final double? actosTasaCero;
  final double? actosNoObjetoNacional;
  final double? actosNoObjetoSinEstablecimiento;

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
    this.valorActosFronteraNorte,
    this.devolucionesFronteraNorte,
    this.valorActosFronteraSur,
    this.devolucionesFronteraSur,
    this.valorActos16Porciento,
    this.devoluciones16Porciento,
    this.valorImportacionTangibles16,
    this.devolucionesImportacionTangibles16,
    this.valorImportacionIntangibles16,
    this.devolucionesImportacionIntangibles16,
    this.ivaAcreditableExclusivoFronteraNorte,
    this.ivaAcreditableProporcionFronteraNorte,
    this.ivaAcreditableExclusivoFronteraSur,
    this.ivaAcreditableProporcionFronteraSur,
    this.ivaAcreditableExclusivo16,
    this.ivaAcreditableProporcion16,
    this.ivaAcreditableExclusivoImportacionTangibles16,
    this.ivaAcreditableProporcionImportacionTangibles16,
    this.ivaAcreditableExclusivoImportacionIntangibles16,
    this.ivaAcreditableProporcionImportacionIntangibles16,
    this.ivaNoAcreditableProporcionFronteraNorte,
    this.ivaNoAcreditableSinRequisitosFronteraNorte,
    this.ivaNoAcreditableExentasFronteraNorte,
    this.ivaNoAcreditableNoObjetoFronteraNorte,
    this.ivaNoAcreditableProporcionFronteraSur,
    this.ivaNoAcreditableSinRequisitosFronteraSur,
    this.ivaNoAcreditableExentasFronteraSur,
    this.ivaNoAcreditableNoObjetoFronteraSur,
    this.ivaNoAcreditableProporcion16,
    this.ivaNoAcreditableSinRequisitos16,
    this.ivaNoAcreditableExentas16,
    this.ivaNoAcreditableNoObjeto16,
    this.ivaNoAcreditableProporcionImportacionTangibles16,
    this.ivaNoAcreditableSinRequisitosImportacionTangibles16,
    this.ivaNoAcreditableExentasImportacionTangibles16,
    this.ivaNoAcreditableNoObjetoImportacionTangibles16,
    this.ivaNoAcreditableProporcionImportacionIntangibles16,
    this.ivaNoAcreditableSinRequisitosImportacionIntangibles16,
    this.ivaNoAcreditableExentasImportacionIntangibles16,
    this.ivaNoAcreditableNoObjetoImportacionIntangibles16,
    this.ivaRetenido,
    this.importacionExentos,
    this.actosExentos,
    this.actosTasaCero,
    this.actosNoObjetoNacional,
    this.actosNoObjetoSinEstablecimiento,
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
      _formatNullableNumericValue(valorActosFronteraNorte),
      _formatNullableNumericValue(devolucionesFronteraNorte),
      _formatNullableNumericValue(valorActosFronteraSur),
      _formatNullableNumericValue(devolucionesFronteraSur),
      _formatNullableNumericValue(valorActos16Porciento),
      _formatNullableNumericValue(devoluciones16Porciento),
      _formatNullableNumericValue(valorImportacionTangibles16),
      _formatNullableNumericValue(devolucionesImportacionTangibles16),
      _formatNullableNumericValue(valorImportacionIntangibles16),
      _formatNullableNumericValue(devolucionesImportacionIntangibles16),
      _formatNullableNumericValue(ivaAcreditableExclusivoFronteraNorte),
      _formatNullableNumericValue(ivaAcreditableProporcionFronteraNorte),
      _formatNullableNumericValue(ivaAcreditableExclusivoFronteraSur),
      _formatNullableNumericValue(ivaAcreditableProporcionFronteraSur),
      _formatNullableNumericValue(ivaAcreditableExclusivo16),
      _formatNullableNumericValue(ivaAcreditableProporcion16),
      _formatNullableNumericValue(
          ivaAcreditableExclusivoImportacionTangibles16),
      _formatNullableNumericValue(
          ivaAcreditableProporcionImportacionTangibles16),
      _formatNullableNumericValue(
          ivaAcreditableExclusivoImportacionIntangibles16),
      _formatNullableNumericValue(
          ivaAcreditableProporcionImportacionIntangibles16),
      _formatNullableNumericValue(ivaNoAcreditableProporcionFronteraNorte),
      _formatNullableNumericValue(ivaNoAcreditableSinRequisitosFronteraNorte),
      _formatNullableNumericValue(ivaNoAcreditableExentasFronteraNorte),
      _formatNullableNumericValue(ivaNoAcreditableNoObjetoFronteraNorte),
      _formatNullableNumericValue(ivaNoAcreditableProporcionFronteraSur),
      _formatNullableNumericValue(ivaNoAcreditableSinRequisitosFronteraSur),
      _formatNullableNumericValue(ivaNoAcreditableExentasFronteraSur),
      _formatNullableNumericValue(ivaNoAcreditableNoObjetoFronteraSur),
      _formatNullableNumericValue(ivaNoAcreditableProporcion16),
      _formatNullableNumericValue(ivaNoAcreditableSinRequisitos16),
      _formatNullableNumericValue(ivaNoAcreditableExentas16),
      _formatNullableNumericValue(ivaNoAcreditableNoObjeto16),
      _formatNullableNumericValue(
          ivaNoAcreditableProporcionImportacionTangibles16),
      _formatNullableNumericValue(
          ivaNoAcreditableSinRequisitosImportacionTangibles16),
      _formatNullableNumericValue(
          ivaNoAcreditableExentasImportacionTangibles16),
      _formatNullableNumericValue(
          ivaNoAcreditableNoObjetoImportacionTangibles16),
      _formatNullableNumericValue(
          ivaNoAcreditableProporcionImportacionIntangibles16),
      _formatNullableNumericValue(
        ivaNoAcreditableSinRequisitosImportacionIntangibles16,
      ),
      _formatNullableNumericValue(
          ivaNoAcreditableExentasImportacionIntangibles16),
      _formatNullableNumericValue(
          ivaNoAcreditableNoObjetoImportacionIntangibles16),
      _formatNullableNumericValue(ivaRetenido),
      _formatNullableNumericValue(importacionExentos),
      _formatNullableNumericValue(actosExentos),
      _formatNullableNumericValue(actosTasaCero),
      _formatNullableNumericValue(actosNoObjetoNacional),
      _formatNullableNumericValue(actosNoObjetoSinEstablecimiento),
      efectosFiscales.code,
    ].join('|');
  }

  /// Formatea valores numéricos nullable para DIOT:
  /// - null = campo vacío (no aplica)
  /// - 0.0 = "0" (valor cero legítimo)
  /// - >0 = valor como entero
  String _formatNullableNumericValue(double? value) {
    if (value == null) {
      return ''; // Campo vacío cuando no aplica
    }
    return value.toInt().toString(); // Incluye 0 como valor legítimo
  }

  /// Helper para obtener valor numérico tratando null como 0
  double get safeValorActos16Porciento => valorActos16Porciento ?? 0;
  double get safeValorActosFronteraNorte => valorActosFronteraNorte ?? 0;
  double get safeValorActosFronteraSur => valorActosFronteraSur ?? 0;
  double get safeIvaAcreditableExclusivo16 => ivaAcreditableExclusivo16 ?? 0;
  double get safeIvaNoAcreditableSinRequisitos16 => ivaNoAcreditableSinRequisitos16 ?? 0;

  /// Indica si el registro tiene valores de IVA significativos
  bool get hasIVAValues => 
    safeValorActos16Porciento > 0 ||
    safeValorActosFronteraNorte > 0 ||
    safeValorActosFronteraSur > 0;

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
