---
name: prepare-testflight
description: Prepara una distribución de FERNÉ para TestFlight. Úsalo en la Fase 8, o cuando se quiera instalar en el iPhone real de Fer. NUNCA sube nada sin autorización explícita.
---

# /prepare-testflight

## Cuándo usarlo
Solo en la Fase 8 o ante una petición explícita de instalación en dispositivo.

## Entradas
- Team ID de Apple Developer (**no se versiona**; se introduce localmente).
- Número de versión y de build.

## Requisito previo insalvable
La firma para dispositivo exige certificados. No hay Mac, así que tendrán que vivir como
**GitHub Secrets** (`BUILD_CERTIFICATE_BASE64`, `P12_PASSWORD`, `PROVISIONING_PROFILE_BASE64`,
`APPLE_TEAM_ID`). **Nada de eso se configura sin autorización explícita de Mika.**

Además, las 12 pruebas de nivel 3 de `docs/NOTIFICATIONS_TEST_MATRIX.md` deben haberse
ejecutado en el iPhone de Fer. Sin eso, no hay TestFlight.

## Procedimiento
1. Verifica que el quality gate pasa **completo** y que el workflow `iOS CI` está en verde.
   Si algo está en NO VERIFICADO, detente.
2. Comprueba que no hay secretos: `bash Scripts/design-guard.sh`.
3. Confirma las capacidades en `project.yml`: iCloud/CloudKit, Push (acciones de notificación), AlarmKit.
4. Ajusta `MARKETING_VERSION` y `CURRENT_PROJECT_VERSION`.
5. Regenera el proyecto: `xcodegen generate`.
6. Archiva:
   ```bash
   xcodebuild archive -project FERNE.xcodeproj -scheme FERNE \
     -destination 'generic/platform=iOS' \
     -archivePath build/FERNE.xcarchive \
     DEVELOPMENT_TEAM=<TU_TEAM_ID>
   ```
7. Exporta con un `ExportOptions.plist` local (**no versionado**).
8. **DETENTE AQUÍ.** La subida a App Store Connect requiere autorización explícita de Mika en el mensaje.

## Validaciones
- [ ] Quality gate completo en verde.
- [ ] Sin secretos ni Team ID en el repositorio.
- [ ] Capacidades declaradas coinciden con las del portal de Apple.
- [ ] Notificaciones probadas en dispositivo real.
- [ ] Versión y build incrementados.

## Fallos comunes
- Archivar con `CODE_SIGNING_ALLOWED=NO` (sirve para compilar, no para distribuir).
- Olvidar la capacidad de iCloud y descubrirlo al validar.
- Subir un build con el entitlement de AlarmKit sin el permiso concedido por Apple.

## Definición de terminado
Archivo `.xcarchive` generado y validado localmente, instrucciones de subida documentadas, y **ninguna publicación realizada sin autorización**.
