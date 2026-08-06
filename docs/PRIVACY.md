# Privacidad y seguridad

## Modelo de datos personales

Todo vive **en el dispositivo**, en SwiftData. No hay servidor, no hay cuenta, no hay analytics, no hay telemetría. Nadie más que Fer puede ver sus datos, incluidos quienes construimos la app.

iCloud/CloudKit privado es **opcional** y solo actúa como respaldo. Con iCloud desactivado o sin conexión, la app funciona completa.

## Qué nunca se registra

`FerneLog` puede registrar identificadores, categorías y estados. **Nunca**:

- Títulos ni notas de actividades.
- Mensajes guardados, reflexiones o contenido de "Para mí".
- Prompts o respuestas de IA.
- Nada escrito por la usuaria.

Regla práctica: si un dato lo escribió Fer, no entra en un log. `Scripts/design-guard.sh` rechaza `print(` en el código de la app precisamente por esto.

## Secretos

1. **Cero secretos versionados.** Ni claves de API, ni certificados, ni perfiles, ni `.p8`, ni Team ID.
2. Las claves de IA las introduce la usuaria y viven en **Keychain**. Nunca en `Info.plist`, `.xcconfig` versionado ni en código.
3. `.gitignore` excluye `.env*`, `*.p12`, `*.p8`, `*.mobileprovision`, `Secrets.xcconfig`.
4. El hook `guard-secrets.sh` **bloquea la escritura** de esos archivos y de contenidos que parezcan una clave real. Se probó y funciona.
5. `design-guard.sh` escanea el repositorio en cada quality gate.

Ninguna de estas capas sustituye a la revisión humana antes de un commit.

## IA opcional (§10)

- Ninguna función central depende de IA. Si la usuaria nunca la activa, no pierde nada.
- Permisos granulares y revocables: agenda, rutinas, creación de recordatorios.
- La importación de historial es **por archivo exportado**, con selección de conversaciones. No se promete sincronización automática con cuentas personales de ChatGPT o Gemini, porque no existe una vía soportada para ello.
- Procesamiento local siempre que sea posible.
- Eliminación de la importación y de la memoria desde Privacidad.
- Si FERNÉ se distribuyera públicamente con IA, las llamadas deben moverse a un backend seguro. Enviar la clave desde el dispositivo solo es aceptable en un uso personal y controlado.

## Derechos de la usuaria (pantalla 32)

- Ver qué datos existen.
- Exportarlos.
- Eliminar el historial importado.
- Eliminar la memoria de IA.
- Eliminar todo.

Cada acción destructiva pide confirmación explícita y **dice exactamente qué se borra**, sin eufemismos.

## Face ID

Opcional, activable desde Ajustes. Nunca bloquea el arranque si la usuaria no lo activó. No sustituye al cifrado del sistema: es una capa de conveniencia, no de seguridad criptográfica adicional.
