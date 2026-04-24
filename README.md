# 🔥 Asador Patagónico

Calculadora de asado para Río Gallegos y la Patagonia. Disponible en dos versiones.

## Versiones

| | Free | Pro |
|---|---|---|
| Cálculo de carne, chorizos y fuego | ✅ | ✅ |
| Panel termodinámico (temp + viento) | ✅ | ✅ |
| Historial cifrado de cálculos | ✅ | ✅ |
| Publicidad (banner inferior) | ✅ | ❌ |
| Repo | Público | Privado |

## Stack

- **Flutter** 3.x (Android + iOS desde un solo código base)
- **flutter_secure_storage** — almacenamiento cifrado (AES-256 via Android Keystore / iOS Keychain)
- **google_mobile_ads** — banner no invasivo (solo versión Free)
- **in_app_purchase** — compra de versión Pro desde la Free

## Estructura

```
lib/
├── main_free.dart        # Punto de entrada versión Free
├── main_pro.dart         # Punto de entrada versión Pro
├── app.dart              # MaterialApp compartido
├── flavors/
│   └── flavor_config.dart   # Configuración Free/Pro
├── models/
│   └── calculo_asado.dart   # Tipos y modelos
├── services/
│   ├── calculadora_service.dart  # Lógica de cálculo (pura, testeable)
│   └── storage_service.dart      # Almacenamiento cifrado
├── screens/
│   └── calculator_screen.dart   # Pantalla principal
└── widgets/
    └── banner_ad_widget.dart    # Banner publicitario (Free only)
```

## Correr en desarrollo

```bash
# Versión Free
flutter run --flavor free -t lib/main_free.dart

# Versión Pro
flutter run --flavor pro -t lib/main_pro.dart
```

## Build

```bash
# APK Free
flutter build apk --flavor free -t lib/main_free.dart --release

# APK Pro
flutter build apk --flavor pro -t lib/main_pro.dart --release

# iOS Free
flutter build ios --flavor free -t lib/main_free.dart --release
```

## Seguridad

Los parámetros e historial del usuario se guardan cifrados:
- **Android**: `EncryptedSharedPreferences` con AES-256 via Android Keystore
- **iOS**: `Keychain` con `KeychainAccessibility.first_unlock`
