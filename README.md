# Comparador de CFDI

Aplicación de escritorio para Windows construida con Flutter que permite a los usuarios cargar, visualizar y comparar facturas electrónicas de México (CFDI) en formato XML.

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
