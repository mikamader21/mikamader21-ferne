# Ver y probar FERNÉ desde Windows

No existe un simulador de iPhone nativo para Windows. Ninguno. Lo que sí existe es una cadena
que permite compilar en macOS remoto y ver el resultado en el navegador.

```
Windows + Claude Code
      ↓ git push
GitHub (repositorio privado)
      ↓
GitHub Actions · runner macOS
  XcodeGen → build iOS Simulator → tests → capturas → FERNE-simulator.zip
      ↓ descarga manual
Windows
  ├── galería local  → revisar el diseño (estático)
  └── Appetize.io    → iPhone virtual interactivo en el navegador
```

**Estado actual: configurado y validado estáticamente; ejecución remota pendiente.** El
repositorio de GitHub todavía no existe y el workflow no se ha ejecutado nunca.

---

## 1 · Descargar el artifact desde GitHub Actions

1. Abre tu repositorio en GitHub → pestaña **Actions**.
2. Entra en la ejecución más reciente de **iOS CI** (la de arriba).
3. Baja hasta la sección **Artifacts** del resumen.
4. Descarga los que necesites:

| Artifact | Qué contiene | Para qué |
|---|---|---|
| `FERNE-simulator-app` | `FERNE-simulator.zip` + `BUILD_INFO.txt` | **Subir a Appetize** |
| `FERNE-screenshots` | PNG + `index.html` | Revisar el diseño sin Appetize |
| `FERNE-test-results` | Bundles `.xcresult` | Investigar un test que falló |
| `FERNE-code-coverage` | `coverage.json` y `.txt` | Ver qué código no está probado |
| `FERNE-build-logs` | Logs de cada paso | Diagnosticar un fallo de compilación |

GitHub los entrega como `.zip`. Descomprímelos en una carpeta de trabajo, por ejemplo
`C:\Users\MIKA\Downloads\ferne-build-42\`.

> Los artifacts caducan: 30 días los de app y capturas, 14 días el resto. Descárgalos antes.

---

## 2 · Revisar el diseño sin Appetize (galería local)

La vía rápida. No necesita cuenta en ningún servicio.

```bat
Scripts\abrir-galeria.bat "C:\Users\MIKA\Downloads\ferne-build-42\FERNE-screenshots"
```

Abre en el navegador una página con tus referencias aprobadas, las capturas reales del
simulador y el estado de cada pantalla.

**Limitación:** son imágenes fijas. No se puede tocar nada.

---

## 3 · Appetize.io · iPhone virtual en el navegador

### 3.1 Qué archivo se sube

Del artifact `FERNE-simulator-app`, el archivo:

```
FERNE-simulator.zip
```

Es un build **de simulador**, sin firma. **No** es un `.ipa` y no sirve para instalarlo en un
iPhone real. Appetize necesita exactamente este formato.

`BUILD_INFO.txt` viene al lado e indica commit, rama, número de ejecución y qué simulador se
usó. Sirve para saber qué build estás mirando semanas después.

### 3.2 Subir por primera vez

1. Entra en [appetize.io](https://appetize.io) y crea una cuenta.
2. **Upload App**.
3. Arrastra `FERNE-simulator.zip`.
4. Plataforma: **iOS**.
5. Dispositivo por defecto: **iPhone 15 Pro** o superior (FERNÉ requiere iOS 18).
6. Al terminar, Appetize da una **URL pública** y un **`publicKey`**. Guárdalos.

> El plan gratuito de Appetize impone un límite de minutos al mes y las sesiones caducan.
> Es suficiente para revisar, no para usar la app a diario.

### 3.3 Reemplazar por una versión nueva

**No subas un app nuevo cada vez.** Si lo haces, cambia la URL y pierdes el historial.

1. En Appetize, ve a **Manage** → localiza la app por su `publicKey`.
2. **Update** → sube el `FERNE-simulator.zip` nuevo.
3. La URL se mantiene; el contenido se reemplaza.

Así puedes tener el enlace guardado en favoritos y encontrar siempre el último build.

### 3.4 Abrirlo desde Windows

Abre la URL de Appetize en Chrome o Edge. Verás un iPhone dibujado en la página. Pulsa
**Tap to play** y la app arranca en un simulador real corriendo en los servidores de Appetize.

Recomendaciones:

- Usa pantalla completa para juzgar proporciones.
- La primera carga tarda 20–40 segundos: está arrancando un simulador de verdad.
- Si se congela, recarga. El simulador remoto se reinicia.

---

## 4 · Qué se puede probar en Appetize

| Se puede probar | Cómo |
|---|---|
| **Navegación** | Toca las cuatro pestañas: Inicio, Progreso, Destellos, Perfil. Comprueba que cada una carga y que la pestaña activa se marca. |
| **Splash** | Recarga la sesión. La escena debe durar 2–3 s y desvanecerse sola. |
| **Animaciones** | Observa la deriva del sol/luna, las nubes y el parpadeo de partículas. El check elástico al marcar una actividad. |
| **Escena día/noche** | El tema sigue la hora del simulador remoto. Para forzar la noche, cambia la hora del dispositivo en Ajustes dentro del simulador. |
| **Dynamic Type** | Ajustes → Pantalla y brillo → Tamaño del texto. |
| **Reduce Motion** | Ajustes → Accesibilidad → Movimiento → Reducir movimiento. **Esta es la única forma de verificar de verdad que FERNÉ lo respeta.** |
| **VoiceOver** | Ajustes → Accesibilidad → VoiceOver. Funciona, aunque la experiencia con ratón es incómoda. |
| **Layout en distintos tamaños** | Appetize permite elegir el modelo de iPhone al lanzar la sesión. |
| **Persistencia entre pantallas** | Dentro de la misma sesión. Al cerrarla, todo se borra. |

### Cómo juzgar las animaciones a 60 fps

Appetize transmite vídeo: **lo que ves no refleja el rendimiento real**. Un tirón en Appetize
puede ser de la red. Sirve para comprobar que la animación *ocurre* y que su ritmo es el
correcto, no para medir fluidez. Eso se mide con Instruments en un dispositivo.

---

## 5 · Limitaciones honestas de Appetize

| No funciona | Por qué |
|---|---|
| **Notificaciones locales** | El simulador las muestra, pero sin modos de concentración, sin resumen programado y sin pantalla bloqueada real. Lo que veas no predice el comportamiento en un iPhone. |
| **AlarmKit** | Las alarmas prominentes dependen de servicios del sistema que el simulador no reproduce fielmente. |
| **Sonidos** | El audio del simulador remoto es poco fiable y el volumen no se comporta como en un dispositivo. No sirve para juzgar si "Amanecer" suena bien. |
| **Haptics** | El hardware no existe. Ni en el simulador ni en el navegador. |
| **Face ID** | Solo se puede simular; no prueba la integración real. |
| **iCloud / CloudKit** | Necesita una cuenta iCloud con sesión iniciada. |
| **Rendimiento** | La transmisión de vídeo enmascara los tirones reales. |
| **Duración de batería y térmica** | Imposible de evaluar. |
| **Persistencia entre sesiones** | Cada sesión de Appetize arranca limpia. No sirve para probar que los datos sobreviven a un reinicio. |

---

## 6 · Qué exige el iPhone real de Fer

Estas pruebas **no pueden aprobarse** en ningún entorno remoto. Detalle completo en
[`NOTIFICATIONS_TEST_MATRIX.md`](NOTIFICATIONS_TEST_MATRIX.md).

1. Entrega real de notificaciones con la app en segundo plano.
2. Comportamiento con la pantalla bloqueada.
3. Modo silencio y modos de concentración.
4. AlarmKit: alarmas prominentes de despertar y dormir.
5. Reproducción y volumen de los seis sonidos.
6. Haptics.
7. Persistencia tras reiniciar el dispositivo.
8. Funcionamiento sin conexión, en modo avión.
9. Rendimiento a 60 fps medido con Instruments.
10. Face ID.

Hasta ejecutarlas en un iPhone, se registran como **NO VERIFICADO**. Nunca como aprobadas.

---

## 7 · Credenciales

**No hay ninguna credencial de Appetize en este repositorio, y no debe haberla.**

La subida es manual y deliberadamente manual. La API de Appetize permitiría automatizarla
desde el workflow, pero eso exige guardar un token, y eso no se hace sin tu autorización
explícita. Cuando quieras automatizarlo:

1. Genera el token en Appetize.
2. Guárdalo como **GitHub Secret** (`APPETIZE_API_TOKEN`), nunca en un archivo.
3. Avísame y añado el paso al workflow.

Primero conviene verificar que el primer build funciona a mano.
