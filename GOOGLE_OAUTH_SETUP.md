# Google OAuth Setup para Notably

## Pasos para configurar Google Sign-In en Web

### 1. Crear proyecto en Google Cloud Console
1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita la "Google+ API" o "Google Sign-In API"

### 2. Configurar OAuth consent screen
1. En el menú lateral, ve a "APIs & Services" > "OAuth consent screen"
2. Selecciona "External" y haz clic en "Create"
3. Completa la información requerida:
   - App name: "Notably"
   - User support email: tu email
   - Developer contact: tu email

### 3. Crear credenciales OAuth 2.0
1. Ve a "APIs & Services" > "Credentials"
2. Haz clic en "+ CREATE CREDENTIALS" > "OAuth 2.0 Client IDs"
3. Selecciona "Web application"
4. Agrega los dominios autorizados:
   - Para desarrollo: `http://localhost:port` (reemplaza port con tu puerto)
   - Para producción: tu dominio
5. Copia el Client ID generado

### 4. Actualizar la configuración en la app
1. En `web/index.html`, línea 24:
   Reemplaza `YOUR_GOOGLE_CLIENT_ID_HERE` con tu Client ID real
   
2. En `lib/services/google_auth_service.dart`, línea 9:
   Reemplaza `YOUR_GOOGLE_CLIENT_ID_HERE` con tu Client ID real

### 5. Probar la configuración
1. Ejecuta `flutter run -d web-server --web-port=8080`
2. Ve a tu app y prueba el botón de Google Sign-In
3. Debe abrir un popup de Google para autenticación

## Troubleshooting
- Si ves "popup_closed_by_user": Usuario cerró el popup, normal
- Si ves "unauthorized_client": Revisa que el dominio esté en authorized origins
- Si ves errores de CORS: Asegúrate de estar usando el puerto correcto

## Notas importantes
- El Client ID es público, no es un secreto
- Para producción, agrega tu dominio real a authorized origins
- Mantén este archivo actualizado si cambias la configuración