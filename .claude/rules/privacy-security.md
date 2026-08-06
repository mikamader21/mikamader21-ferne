# Regla · Privacidad y seguridad

Aplica a: todo el repositorio

1. **Cero secretos versionados.** Ni claves de API, ni certificados, ni perfiles de aprovisionamiento, ni Team ID ajenos.
2. Las claves de IA van en **Keychain**, introducidas por la usuaria. Nunca en `Info.plist`, `.xcconfig` versionado ni código.
3. **Nunca registrar datos personales**: títulos, notas, mensajes, reflexiones, prompts o respuestas de IA. `FerneLog` registra identificadores y estados, no contenido.
4. Las acciones destructivas (eliminar historial, eliminar todo) piden confirmación explícita y explican exactamente qué se borra.
5. Exportación y eliminación de datos deben existir y funcionar.
6. Face ID es opcional y jamás bloquea el arranque si el usuario no lo activó.
7. Si la app llegara a distribuirse públicamente con IA, las llamadas deben moverse a un backend seguro; no enviar claves desde el dispositivo.

`Scripts/design-guard.sh` incluye un escaneo de secretos. No es infalible: la revisión humana sigue siendo obligatoria antes de cualquier commit.
