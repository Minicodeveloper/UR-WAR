# ⚔️ UR WAR

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](https://github.com/)

**UR WAR** es un juego multiplataforma y de código abierto desarrollado con [Flutter](https://flutter.dev). Diseñado para ser veloz, expandible y ejecutarse en cualquier dispositivo.

---

## 📱 Plataformas Soportadas

- 🤖 **Android**
- 🍏 **iOS**
- 🌐 **Web** (Chrome, Firefox, Safari, Edge)
- 🪟 **Windows**
- 🐧 **Linux**
- 🍎 **macOS**

---

## 🚀 Comenzar / Instalación

### Prerrequisitos
- Tener instalado [Flutter SDK](https://docs.flutter.dev/get-started/install) (versión 3.0+ recomendada).
- Git.

### Pasos

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/TU-USUARIO/UR-WAR.git
   cd "UR WAR"
   ```

2. Obtener dependencias:
   ```bash
   flutter pub get
   ```

3. Ejecutar el juego:
   ```bash
   # En el navegador web
   flutter run -d chrome

   # En Android / iOS / Desktop (según dispositivos conectados)
   flutter run
   ```

---

## 📂 Estructura del Código

```text
lib/
├── core/                  # Tema, colores, audio y configuraciones globales
│   ├── constants.dart
│   └── theme.dart
├── models/                # Modelos de datos y entidades del juego
├── screens/               # Pantallas (Menú Principal, Juego, Ajustes, Créditos)
│   ├── main_menu_screen.dart
│   ├── game_screen.dart
│   ├── settings_screen.dart
│   └── credits_screen.dart
├── widgets/               # Componentes UI reutilizables
└── main.dart              # Punto de entrada de la aplicación
```

---

## 🤝 Cómo Contribuir

¡Las contribuciones son bienvenidas! Ya sea reportando bugs, proponiendo nuevas mecánicas, diseñando arte o enviando código:

1. Revisa [CONTRIBUTING.md](CONTRIBUTING.md) para conocer las pautas de contribución.
2. Abre un **Issue** para discutir nuevas funciones antes de implementarlas.
3. Envía un **Pull Request** siguiendo la plantilla establecida.

---

## 📜 Licencia

Este proyecto está bajo la Licencia **MIT**. Consulta el archivo [LICENSE](LICENSE) para más información.
