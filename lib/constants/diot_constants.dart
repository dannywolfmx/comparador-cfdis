/// Constantes y catálogos para DIOT 2025
class DIOTConstants {
  // Especificaciones del archivo según DIOT 2025
  static const String fileDelimiter = '|';
  static const String fileEncoding = 'UTF-8';
  static const String fileExtension = '.txt';
  static const int maxNumericLength = 14;
  static const bool numericAcceptsDecimals = false;

  // RFC especial para proveedor global
  static const String rfcProveedorGlobal = 'XAXX010101000';

  // Tolerancias para validación de montos muy pequeños
  static const double minAmountForIVAValidation =
      1.0; // Monto mínimo para validar IVA
  static const double ivaToleranceThreshold =
      0.10; // Umbral de tolerancia para IVA (10 centavos)
  static const double roundingTolerance =
      0.01; // Tolerancia de redondeo (1 centavo)

  // Estructura DIOT 2025 - 54 campos obligatorios
  static const Map<int, Map<String, dynamic>> diot2025Structure = {
    1: {
      'name': 'tipo_tercero',
      'description': 'Tipo de tercero',
      'data_type': 'numeric',
      'length': 2,
      'required': true,
      'values': {
        '04': 'Proveedor Nacional',
        '05': 'Proveedor Extranjero',
        '15': 'Proveedor Global',
      },
    },
    2: {
      'name': 'tipo_operacion',
      'description': 'Tipo de operación',
      'data_type': 'numeric',
      'length': 2,
      'required': true,
      'values_by_tercero': {
        '04': {
          '02': 'Enajenación de bienes',
          '03': 'Prestación de Servicios Profesionales',
          '06': 'Uso o goce temporal de bienes',
          '08': 'Importación por transferencia virtual',
          '85': 'Otros',
        },
        '05': {
          '02': 'Enajenación de bienes',
          '03': 'Prestación de Servicios Profesionales',
          '07': 'Importación de bienes o servicios',
        },
        '15': {'87': 'Operaciones globales'},
      },
    },
    54: {
      'name': 'efectos_fiscales',
      'description':
          'Manifiesto que se dio efectos fiscales a los comprobantes',
      'data_type': 'numeric',
      'length': 2,
      'required': true,
      'values': {'01': 'Sí', '02': 'No'},
    },
  };

  // Catálogo de países (ISO 3166-1 alpha-3)
  static const Map<String, String> paisesResidenciaFiscal = {
    'AFG': 'Afganistán',
    'ALA': 'Islas Aland',
    'ALB': 'Albania',
    'DEU': 'Alemania',
    'AND': 'Andorra',
    'AGO': 'Angola',
    'AIA': 'Anguila',
    'ATA': 'Antártida',
    'ATG': 'Antigua y Barbuda',
    'SAU': 'Arabia Saudita',
    'DZA': 'Argelia',
    'ARG': 'Argentina',
    'ARM': 'Armenia',
    'ABW': 'Aruba',
    'AUS': 'Australia',
    'AUT': 'Austria',
    'AZE': 'Azerbaiyán',
    'BHS': 'Bahamas (las)',
    'BGD': 'Bangladés',
    'BRB': 'Barbados',
    'BHR': 'Baréin',
    'BEL': 'Bélgica',
    'BLZ': 'Belice',
    'BEN': 'Benín',
    'BMU': 'Bermudas',
    'BLR': 'Bielorrusia',
    'MMR': 'Myanmar',
    'BOL': 'Bolivia, Estado Plurinacional de',
    'BIH': 'Bosnia y Herzegovina',
    'BWA': 'Botsuana',
    'BRA': 'Brasil',
    'BRN': 'Brunéi Darussalam',
    'BGR': 'Bulgaria',
    'BFA': 'Burkina Faso',
    'BDI': 'Burundi',
    'BTN': 'Bután',
    'CPV': 'Cabo Verde',
    'KHM': 'Camboya',
    'CMR': 'Camerún',
    'CAN': 'Canadá',
    'QAT': 'Catar',
    'BES': 'Bonaire, San Eustaquio y Saba',
    'TCD': 'Chad',
    'CHL': 'Chile',
    'CHN': 'China',
    'CYP': 'Chipre',
    'COL': 'Colombia',
    'COM': 'Comoras',
    'PRK': 'Corea (la República Democrática Popular de)',
    'KOR': 'Corea (la República de)',
    'CIV': 'Côte d\'Ivoire',
    'CRI': 'Costa Rica',
    'HRV': 'Croacia',
    'CUB': 'Cuba',
    'CUW': 'Curaçao',
    'DNK': 'Dinamarca',
    'DMA': 'Dominica',
    'ECU': 'Ecuador',
    'EGY': 'Egipto',
    'SLV': 'El Salvador',
    'ARE': 'Emiratos Árabes Unidos (Los)',
    'ERI': 'Eritrea',
    'SVK': 'Eslovaquia',
    'SVN': 'Eslovenia',
    'ESP': 'España',
    'USA': 'Estados Unidos (los)',
    'EST': 'Estonia',
    'ETH': 'Etiopía',
    'PHL': 'Filipinas (las)',
    'FIN': 'Finlandia',
    'FJI': 'Fiyi',
    'FRA': 'Francia',
    'GAB': 'Gabón',
    'GMB': 'Gambia (La)',
    'GEO': 'Georgia',
    'GHA': 'Ghana',
    'GIB': 'Gibraltar',
    'GRD': 'Granada',
    'GRC': 'Grecia',
    'GRL': 'Groenlandia',
    'GLP': 'Guadalupe',
    'GUM': 'Guam',
    'GTM': 'Guatemala',
    'GUF': 'Guayana Francesa',
    'GGY': 'Guernsey',
    'GIN': 'Guinea',
    'GNB': 'Guinea-Bisáu',
    'GNQ': 'Guinea Ecuatorial',
    'GUY': 'Guyana',
    'HTI': 'Haití',
    'HND': 'Honduras',
    'HKG': 'Hong Kong',
    'HUN': 'Hungría',
    'IND': 'India',
    'IDN': 'Indonesia',
    'IRQ': 'Irak',
    'IRN': 'Irán (la República Islámica de)',
    'IRL': 'Irlanda',
    'BVT': 'Isla Bouvet',
    'IMN': 'Isla de Man',
    'CXR': 'Isla de Navidad',
    'NFK': 'Isla Norfolk',
    'ISL': 'Islandia',
    'CYM': 'Islas Caimán (las)',
    'CCK': 'Islas Cocos (Keeling)',
    'COK': 'Islas Cook (las)',
    'FRO': 'Islas Feroe (las)',
    'SGS': 'Georgia del sur y las islas sandwich del sur',
    'HMD': 'Isla Heard e Islas McDonald',
    'FLK': 'Islas Malvinas [Falkland] (las)',
    'MNP': 'Islas Marianas del Norte (las)',
    'MHL': 'Islas Marshall (las)',
    'PCN': 'Pitcairn',
    'SLB': 'Islas Salomón (las)',
    'TCA': 'Islas Turcas y Caicos (las)',
    'UMI': 'Islas de Ultramar Menores de Estados Unidos (las)',
    'VGB': 'Islas Vírgenes (Británicas)',
    'VIR': 'Islas Vírgenes (EE.UU.)',
    'ISR': 'Israel',
    'ITA': 'Italia',
    'JAM': 'Jamaica',
    'JPN': 'Japón',
    'JEY': 'Jersey',
    'JOR': 'Jordania',
    'KAZ': 'Kazajistán',
    'KEN': 'Kenia',
    'KGZ': 'Kirguistán',
    'KIR': 'Kiribati',
    'KWT': 'Kuwait',
    'LAO': 'Lao, (la) República Democrática Popular',
    'LSO': 'Lesoto',
    'LVA': 'Letonia',
    'LBN': 'Líbano',
    'LBR': 'Liberia',
    'LBY': 'Libia',
    'LIE': 'Liechtenstein',
    'LTU': 'Lituania',
    'LUX': 'Luxemburgo',
    'MAC': 'Macao',
    'MDG': 'Madagascar',
    'MYS': 'Malasia',
    'MWI': 'Malaui',
    'MDV': 'Maldivas',
    'MLI': 'Malí',
    'MLT': 'Malta',
    'MAR': 'Marruecos',
    'MTQ': 'Martinica',
    'MUS': 'Mauricio',
    'MRT': 'Mauritania',
    'MYT': 'Mayotte',
    'FSM': 'Micronesia (los Estados Federados de)',
    'MDA': 'Moldavia (la República de)',
    'MCO': 'Mónaco',
    'MNG': 'Mongolia',
    'MNE': 'Montenegro',
    'MSR': 'Montserrat',
    'MOZ': 'Mozambique',
    'NAM': 'Namibia',
    'NRU': 'Nauru',
    'NPL': 'Nepal',
    'NIC': 'Nicaragua',
    'NER': 'Níger (el)',
    'NGA': 'Nigeria',
    'NIU': 'Niue',
    'NOR': 'Noruega',
    'NCL': 'Nueva Caledonia',
    'NZL': 'Nueva Zelanda',
    'OMN': 'Omán',
    'NLD': 'Países Bajos (los)',
    'PAK': 'Pakistán',
    'PLW': 'Palaos',
    'PSE': 'Palestina, Estado de',
    'PAN': 'Panamá',
    'PNG': 'Papúa Nueva Guinea',
    'PRY': 'Paraguay',
    'PER': 'Perú',
    'PYF': 'Polinesia Francesa',
    'POL': 'Polonia',
    'PRT': 'Portugal',
    'PRI': 'Puerto Rico',
    'GBR': 'Reino Unido (el)',
    'CAF': 'República Centroafricana (la)',
    'CZE': 'República Checa (la)',
    'MKD': 'Macedonia (la antigua República Yugoslava de)',
    'COG': 'Congo',
    'COD': 'Congo (la República Democrática del)',
    'DOM': 'República Dominicana (la)',
    'REU': 'Reunión',
    'RWA': 'Ruanda',
    'ROU': 'Rumania',
    'RUS': 'Rusia, (la) Federación de',
    'ESH': 'Sahara Occidental',
    'WSM': 'Samoa',
    'ASM': 'Samoa Americana',
    'BLM': 'San Bartolomé',
    'KNA': 'San Cristóbal y Nieves',
    'SMR': 'San Marino',
    'MAF': 'San Martín (parte francesa)',
    'SPM': 'San Pedro y Miquelón',
    'VCT': 'San Vicente y las Granadinas',
    'SHN': 'Santa Helena, Ascensión y Tristán de Acuña',
    'LCA': 'Santa Lucía',
    'STP': 'Santo Tomé y Príncipe',
    'SEN': 'Senegal',
    'SRB': 'Serbia',
    'SYC': 'Seychelles',
    'SLE': 'Sierra leona',
    'SGP': 'Singapur',
    'SXM': 'Sint Maarten (parte holandesa)',
    'SYR': 'Siria, (la) República Árabe',
    'SOM': 'Somalia',
    'LKA': 'Sri Lanka',
    'SWZ': 'Suazilandia',
    'ZAF': 'Sudáfrica',
    'SDN': 'Sudán (el)',
    'SSD': 'Sudán del Sur',
    'SWE': 'Suecia',
    'CHE': 'Suiza',
    'SUR': 'Surinam',
    'SJM': 'Svalbard y Jan Mayen',
    'THA': 'Tailandia',
    'TWN': 'Taiwán (Provincia de China)',
    'TZA': 'Tanzania, República Unida de',
    'TJK': 'Tayikistán',
    'IOT': 'Territorio Británico del Océano Índico (el)',
    'ATF': 'Territorios Australes Franceses (los)',
    'TLS': 'Timor-Leste',
    'TGO': 'Togo',
    'TKL': 'Tokelau',
    'TON': 'Tonga',
    'TTO': 'Trinidad y Tobago',
    'TUN': 'Túnez',
    'TKM': 'Turkmenistán',
    'TUR': 'Turquía',
    'TUV': 'Tuvalu',
    'UKR': 'Ucrania',
    'UGA': 'Uganda',
    'URY': 'Uruguay',
    'UZB': 'Uzbekistán',
    'VUT': 'Vanuatu',
    'VAT': 'Santa Sede[Estado de la Ciudad del Vaticano] (la)',
    'VEN': 'Venezuela, República Bolivariana de',
    'VNM': 'Viet Nam',
    'WLF': 'Wallis y Futuna',
    'YEM': 'Yemen',
    'DJI': 'Yibuti',
    'ZMB': 'Zambia',
    'ZWE': 'Zimbabue',
    'ZZZ': 'Otro',
  };

  // Regiones fronterizas
  static const List<String> municipiosFronterizaNorte = [
    // Baja California
    'Mexicali', 'Tecate', 'Tijuana',
    // Sonora
    'Agua Prieta', 'Altar', 'Caborca', 'Cananea',
    'General Plutarco Elías Calles',
    'Naco', 'Nogales', 'Puerto Peñasco', 'San Luis Río Colorado', 'Santa Cruz',
    'Sáric', 'Sonoyta',
    // Chihuahua
    'Ascensión', 'Guadalupe', 'Janos', 'Manuel Benavides', 'Ojinaga',
    'Praxedis G. Guerrero',
    // Coahuila
    'Acuña', 'Guerrero', 'Hidalgo', 'Jiménez', 'Nava', 'Ocampo',
    'Piedras Negras', 'Zaragoza',
    // Nuevo León
    'Anáhuac',
    // Tamaulipas
    'Camargo', 'Guerrero', 'Gustavo Díaz Ordaz', 'Matamoros', 'Mier',
    'Miguel Alemán',
    'Nuevo Laredo', 'Reynosa', 'Río Bravo', 'Valle Hermoso',
  ];

  static const List<String> municipiosFronterizaSur = [
    // Chiapas
    'Acacoyagua', 'Acapetahua', 'Amatenango de la Frontera', 'Arriaga',
    'Bejucal de Ocampo',
    'Bella Vista', 'Cacahoatán', 'Chicomuselo', 'Frontera Comalapa',
    'Frontera Hidalgo',
    'Huehuetán', 'Huixtla', 'La Grandeza', 'La Trinitaria', 'Las Margaritas',
    'Mapastepec',
    'Mazatán', 'Metapa', 'Motozintla', 'Niquivil', 'Pijijiapan', 'Siltepec',
    'Suchiate',
    'Tapachula', 'Tonalá', 'Tuxtla Chico', 'Tuzantán', 'Unión Juárez',
    'Villa Comaltitlán',
    // Campeche
    'Calakmul', 'Calkiní', 'Campeche', 'Candelaria', 'Carmen', 'Champotón',
    'Escárcega',
    'Hopelchén', 'Palizada', 'Tenabo',
  ];

  // Tasas de IVA por región
  static const double tasaIVAGeneral = 0.16;
  static const double tasaIVAFronteriza = 0.08;

  // Validación DIOT 2025 - Reglas específicas
  static const Map<String, dynamic> diot2025ValidationRules = {
    'general': {
      'delimiter_required': '|',
      'encoding_required': 'UTF-8',
      'file_extension': '.txt',
      'numeric_no_decimals': true,
      'numeric_accepts_zero': true,
    },
    'conditional_requirements': {
      'extranjero_fields': {
        'required_when': 'tipo_tercero == "05"',
        'fields': [
          'numero_identificacion_fiscal',
          'nombre_extranjero',
          'pais_residencia_fiscal',
        ],
      },
      'jurisdiccion_especial': {
        'required_when': 'pais_residencia_fiscal == "ZZZ"',
        'fields': ['especificar_jurisdiccion'],
      },
      'iva_acreditable_conditions': {
        'frontera_norte': 'valor_actos_frontera_norte > 0',
        'frontera_sur': 'valor_actos_frontera_sur > 0',
        'tasa_16': 'valor_actos_16_porciento > 0',
        'importacion_tangibles': 'valor_importacion_tangibles_16 > 0',
        'importacion_intangibles': 'valor_importacion_intangibles_16 > 0',
      },
    },
    'data_consistency': {
      'rfc_validation': {
        'length': [12, 13],
        'format': 'alphanumeric_uppercase',
        'special_case_global': 'XAXX010101000',
      },
      'country_code_validation': {
        'length': 3, // ISO 3166-1 alpha-3
        'format': 'alphabetic_uppercase',
        'must_exist_in_catalog': true,
      },
      'numeric_validation': {
        'max_length': 14,
        'no_decimals': true,
        'accepts_zero': true,
        'positive_only': true,
      },
    },
  };

  // Mensajes de validación actualizados para DIOT 2025
  static const Map<String, String> validationMessages = {
    'rfc_required':
        'El RFC es requerido para proveedores nacionales y globales',
    'rfc_invalid_format': 'El RFC debe tener 12 o 13 caracteres alfanuméricos',
    'rfc_invalid_global': 'Para proveedor global debe usar XAXX010101000',
    'extranjero_fields_required':
        'Los campos de proveedor extranjero son requeridos',
    'pais_required': 'El país de residencia fiscal es requerido',
    'pais_invalid': 'El código de país no es válido según catálogo DIOT 2025',
    'jurisdiccion_required':
        'Especificar jurisdicción es requerido cuando país es "ZZZ"',
    'tipo_operacion_invalid':
        'Tipo de operación no válido para el tipo de tercero según DIOT 2025',
    'numeric_invalid':
        'El valor numérico debe ser positivo y menor a 14 dígitos sin decimales',
    'efectos_fiscales_required':
        'Los efectos fiscales son requeridos (01 o 02)',
    'structure_invalid':
        'El registro no cumple con la estructura de 54 campos DIOT 2025',
    'iva_consistency':
        'Si hay valores de actos, debe especificar IVA correspondiente',
  };

  // Configuraciones por defecto
  static const Map<String, dynamic> defaultSettings = {
    'auto_classify_nacional': true,
    'default_efectos_fiscales': '01', // Sí
    'default_clasificacion_iva': 'exclusivo',
    'include_zero_values': false,
    'validate_on_input': true,
  };

  // Límites y restricciones
  static const int maxRfcLength = 13;
  static const int minRfcLength = 12;
  static const int maxNombreExtranjeroLength = 300;
  static const int maxIdentificacionFiscalLength = 40;
  static const int maxJurisdiccionLength = 300;
  static const int maxNumericValue = 99999999999999; // 14 dígitos

  // Expresiones regulares para validación
  static const String rfcPattern = r'^[A-Z&Ñ]{3,4}[0-9]{6}[A-Z0-9]{3}$';
  static const String paisPattern =
      r'^[A-Z]{3}$'; // ISO 3166-1 alpha-3 (3 caracteres)
  static const String numericPattern = r'^[0-9]{1,14}$';
}

/// Tipo de complemento DIOT
enum TipoComplemento {
  normal('Normal'),
  complementaria('Complementaria');

  const TipoComplemento(this.descripcion);
  final String descripcion;
}
