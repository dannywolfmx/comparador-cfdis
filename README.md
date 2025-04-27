# My Flutter App

This is a simple Flutter application that demonstrates the basic structure and setup of a Flutter project.

## Project Structure

```
my-flutter-app
├── lib
│   ├── main.dart          # Entry point of the application
│   └── screens
│       └── home_screen.dart # Home screen UI
├── pubspec.yaml           # Project configuration and dependencies
├── android                # Android-specific code and configuration
└── ios                    # iOS-specific code and configuration
```

## Getting Started

To run this application, ensure you have Flutter installed on your machine. You can follow the official Flutter installation guide at [flutter.dev](https://flutter.dev/docs/get-started/install).

### Running the App

1. Navigate to the project directory:
   ```
   cd my-flutter-app
   ```

2. Get the dependencies:
   ```
   flutter pub get
   ```

3. Run the application:
   ```
   flutter run
   ```


## Intructions to compile the project to windows
1. Open the terminal and navigate to the project directory:
   ```
   cd my-flutter-app
   ```
2. Get the dependencies:
   ```
   flutter pub get
   ```
3. Run the application:
   ```
   flutter run -d windows
   ```
4. If you want to build the application for release, use the following command:
   ```
   flutter build windows
   ```
5. The compiled application will be located in the `build/windows/runner/Release` directory.