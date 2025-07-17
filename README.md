# Comparador de CFDI

# Comparador CFDIs

## Descripción
Aplicación Flutter para comparar y analizar Comprobantes Fiscales Digitales por Internet (CFDIs) del SAT mexicano.

## Funcionalidades Principales
- ✅ Carga de CFDIs desde archivos XML individuales
- ✅ Carga masiva desde directorios
- ✅ Visualización en tabla con filtros
- ✅ Cálculo de totales y subtotales
- ✅ Detalle de CFDIs individuales
- ✅ Filtros por tipo de comprobante, método de pago, etc.

## Arquitectura
- **Patrón**: BLoC (Business Logic Component)
- **Estado**: flutter_bloc para manejo de estado
- **Parsing**: xml package para procesar CFDIs
- **UI**: Material Design con widgets personalizados

## Estructura del Proyecto

```
lib/
├── bloc/               # Lógica de negocio (BLoC)
├── constants/          # Constantes de la aplicación
├── exceptions/         # Excepciones personalizadas
├── models/            # Modelos de datos
├── providers/         # Providers para estado global
├── repositories/      # Acceso a datos
├── screens/           # Pantallas de la aplicación
├── services/          # Servicios de la aplicación
├── utils/             # Utilidades generales
├── validators/        # Validadores de datos
└── widgets/           # Widgets reutilizables
```

## Instalación

### Prerrequisitos
- Flutter SDK (>=3.0.0)
- Dart SDK
- IDE con soporte para Flutter (VS Code, Android Studio)

### Pasos
1. Clonar el repositorio
2. Ejecutar `flutter pub get`
3. Ejecutar `flutter run`

## Testing

### Ejecutar tests
```bash
flutter test
```

### Ejecutar tests con coverage
```bash
flutter test --coverage
```

## Configuración

### Variables de entorno
No se requieren variables de entorno especiales.

### Configuración de build
- Android: `android/app/build.gradle`
- iOS: `ios/Runner/Info.plist`
- Windows: `windows/runner/main.cpp`

## Contribución

### Estándares de código
- Seguir las convenciones de Dart/Flutter
- Usar `flutter analyze` antes de commit
- Mantener coverage de tests >80%

### Flujo de contribución
1. Fork del proyecto
2. Crear rama para feature
3. Hacer cambios con tests
4. Crear Pull Request

## Licencia
Ver archivo LICENSE para detalles.

## Contacto
- Desarrollador: [Tu nombre]
- Email: [Tu email]
- GitHub: [Tu perfil]

## Changelog
Ver CHANGELOG.md para historial de cambios.

## Características Principales

- **Carga de Múltiples Archivos:** Carga CFDI desde un directorio completo o de forma individual.
- **Visualización de Datos:** Muestra la información clave de los CFDI en una tabla interactiva.
- **Diseño Responsivo:** Se adapta a diferentes tamaños de pantalla, mostrando una lista en pantallas pequeñas y una tabla en pantallas más grandes.
- **Filtrado de Datos:** Permite filtrar los CFDI por diferentes criterios.
- **Cálculo de Totales:** Calcula automáticamente los subtotales, descuentos y totales de los CFDI cargados.

## Capturas de Pantalla

*(Aquí se podrían añadir capturas de pantalla de la aplicación en el futuro)*

## Cómo Empezar

Para ejecutar esta aplicación, asegúrate de tener Flutter instalado en tu máquina. Puedes seguir la guía oficial de instalación de Flutter en [flutter.dev](https://flutter.dev/docs/get-started/install).

### Ejecutar la Aplicación en Windows

1.  Clona o descarga este repositorio.
2.  Abre una terminal y navega al directorio del proyecto:
    ```bash
    cd comparador-cfdis
    ```
3.  Obtén las dependencias del proyecto:
    ```bash
    flutter pub get
    ```
4.  Ejecuta la aplicación en modo de depuración:
    ```bash
    flutter run -d windows
    ```

### Compilar para Producción

Si deseas compilar la aplicación para distribución, utiliza el siguiente comando:

```bash
flutter build windows
```

El ejecutable se encontrará en el directorio `build/windows/runner/Release`.

## Estructura del Proyecto

El proyecto sigue una arquitectura limpia, separando la lógica de negocio, la interfaz de usuario y los datos:

```
comparador-cfdis/
├── lib/
│   ├── bloc/         # Lógica de negocio con BLoC
│   ├── models/       # Modelos de datos para los CFDI
│   ├── repositories/ # Abstracción para la obtención de datos
│   ├── screens/      # Widgets de pantalla principal
│   ├── services/     # Servicios para el parseo de archivos
│   └── widgets/      # Widgets reutilizables
├── pubspec.yaml      # Dependencias y configuración del proyecto
└── ...
```
