# Configuración de firma — Asador Patagónico

## Keystore generado

| Campo | Valor |
|---|---|
| Archivo | `android/app/asador-patagonico.jks` |
| Alias | `asador` |
| Válido hasta | 09/09/2053 (~27 años) |
| SHA256 | `02:AF:92:30:4A:15:71:87:61:07:15:7C:6D:A2:01:15:39:0F:CA:3D:2E:25:16:47:CD:75:83:41:E7:48:13:0E` |

> ⚠️ **El archivo `.jks` y `key.properties` están en `.gitignore` y NUNCA deben subirse a Git.**
> Guardar el `.jks` en un lugar seguro (ej: gestor de contraseñas, Google Drive privado).
> Si se pierde el keystore, no se puede actualizar la app en Play Store.

---

## Configurar GitHub Secrets (requerido para CI/CD)

Ir a: **GitHub repo → Settings → Secrets and variables → Actions → New repository secret**

Cargar estos 4 secrets:

| Secret | Valor |
|---|---|
| `KEYSTORE_BASE64` | Contenido del archivo `android/app/asador-patagonico.jks.b64` |
| `KEYSTORE_PASSWORD` | `AsadorP4t4g0nico!` |
| `KEY_ALIAS` | `asador` |
| `KEY_PASSWORD` | `AsadorP4t4g0nico!` |

### Cómo obtener el base64 del keystore

```bash
# En tu máquina local (después de clonar el repo y copiar el .jks):
base64 -w 0 android/app/asador-patagonico.jks
# Copiar el output completo y pegarlo en el secret KEYSTORE_BASE64
```

---

## Desarrollo local

Crear `android/key.properties` (no se sube a git):

```properties
storePassword=AsadorP4t4g0nico!
keyPassword=AsadorP4t4g0nico!
keyAlias=asador
storeFile=app/asador-patagonico.jks
```

Luego compilar:

```bash
# APK Free firmado
flutter build apk --flavor free -t lib/main_free.dart --release

# APK Pro firmado
flutter build apk --flavor pro -t lib/main_pro.dart --release

# AAB para Play Store (recomendado sobre APK)
flutter build appbundle --flavor free -t lib/main_free.dart --release
flutter build appbundle --flavor pro  -t lib/main_pro.dart  --release
```

---

## Play Store — Bundle IDs

| Versión | Application ID |
|---|---|
| Free | `com.olmosle.asado.free` |
| Pro | `com.olmosle.asado.pro` |

Registrar **dos apps separadas** en Google Play Console con estos IDs.

---

## App Store (iOS) — próximo paso

Para iOS necesitás:
1. Cuenta Apple Developer ($99/año)
2. App ID registrado en developer.apple.com: `com.olmosle.asado`
3. Distribution Certificate + Provisioning Profile
4. Cargar el `.p12` y el perfil como secrets en GitHub para el CI
