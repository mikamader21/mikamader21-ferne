# FERNÉ — Documento Maestro de Producto e Implementación

**Versión:** 1.0  
**Fecha:** 6 de agosto de 2026  
**Plataforma:** iPhone / iOS  
**Tecnología principal:** SwiftUI  
**Estado:** Especificación aprobada para implementación con Claude Code

---

## 0. Instrucción principal para Claude Code

Construye FERNÉ como una aplicación nativa, privada y offline-first para iPhone. Este documento es la fuente de verdad del proyecto. No improvises funciones, colores, navegación, lenguaje ni arquitectura fuera de lo especificado.

Antes de escribir código:

1. Lee este documento completo.
2. Inspecciona todas las referencias visuales disponibles.
3. Crea el repositorio y su sistema de instrucciones para Claude Code.
4. Produce un plan por fases con dependencias, riesgos y criterios de aceptación.
5. Implementa una fase a la vez.
6. Compila y prueba después de cada fase.
7. No declares una pantalla terminada hasta que cumpla diseño, interacción, accesibilidad, persistencia y pruebas.
8. No añadas servicios externos ni dependencias innecesarias.
9. No guardes secretos en código, archivos de configuración versionados ni logs.
10. Si una decisión técnica contradice esta especificación, detente, documenta el conflicto y solicita aprobación.

La aplicación debe sentirse viva, elegante y cinematográfica, pero nunca sacrificar legibilidad, rendimiento, estabilidad o accesibilidad.

---

## 1. Visión del producto

FERNÉ es una asistente personal diaria creada para Fer. La acompaña desde que despierta hasta que se prepara para dormir. Organiza recordatorios, comidas, gym, trabajo, TikTok Live, lectura, pagos, rutinas, eventos y compromisos personales.

No es una aplicación empresarial, una red social ni un gestor genérico de tareas. Su valor está en combinar organización, calidez, contexto diario, visuales vivos y recomendaciones amables.

### 1.1 Promesa

> “Tu día, a tu ritmo.”

FERNÉ debe permitir que Fer entienda en segundos:

- Qué debe hacer ahora.
- Qué sigue después.
- Qué completó.
- Qué dejó pendiente.
- Qué reprogramó.
- Qué puede organizar mejor mañana.

### 1.2 Principios

1. **Cero fricción:** abrir y utilizar; sin cuenta adicional en el MVP.
2. **Offline-first:** las funciones principales no dependen de internet.
3. **Amabilidad:** orientar sin castigar, avergonzar ni presionar.
4. **Claridad:** una acción principal por pantalla.
5. **Vida visual:** sol, luna, nubes, partículas, haptics y transiciones con propósito.
6. **Privacidad:** datos personales en el dispositivo y respaldo privado opcional.
7. **Calidad nativa:** comportamientos y componentes coherentes con iOS.

### 1.3 Fuera de alcance inicial

- Android.
- Aplicación web.
- Suscripciones.
- Comunidad o funciones sociales.
- Administración remota.
- Supabase u otra base de datos externa.
- Calorías, peso, medidas corporales o evaluación física.
- IA obligatoria.
- Sincronización automática del historial personal de ChatGPT o Gemini.

---

## 2. Usuarios y acceso

### 2.1 Usuario inicial

Una sola usuaria: Fer.

### 2.2 Acceso recomendado

- Sin registro, correo ni contraseña.
- Inicio directo después del onboarding.
- Face ID opcional desde Ajustes.
- Datos locales en SwiftData.
- Respaldo/sincronización privada mediante iCloud/CloudKit cuando esté disponible.
- La app debe seguir funcionando si iCloud está desactivado o sin conexión.

### 2.3 Futuro

Considerar backend externo únicamente si se agregan varias usuarias, panel web, colaboración, Android, administración remota o notificaciones enviadas por servidor.

---

## 3. Plataforma y arquitectura

### 3.1 Stack

- Swift 6 o versión estable compatible con el Xcode utilizado.
- SwiftUI para interfaz.
- SwiftData para persistencia local.
- CloudKit privado para respaldo opcional.
- UserNotifications para recordatorios locales.
- AlarmKit para alarmas prominentes en versiones compatibles.
- AppStorage para preferencias simples.
- Keychain para secretos e integraciones opcionales.
- Swift Charts para gráficas.
- XCTest/Swift Testing para pruebas.
- Lottie iOS solamente para escenas especiales si aporta valor verificable.

### 3.2 Compatibilidad

- Objetivo base recomendado: iOS 18 o superior.
- Usar AlarmKit mediante comprobación de disponibilidad en iOS compatible.
- Crear fallback completo con UserNotifications.
- Diseñar para iPhone en orientación vertical.
- Optimizar inicialmente para iPhone 15 Pro; validar desde pantallas compactas hasta Pro Max.

### 3.3 Patrón

Arquitectura por features, con separación clara:

- Presentation: vistas, componentes y view models.
- Domain: entidades, reglas, casos de uso y score.
- Data: SwiftData, CloudKit, repositorios y migraciones.
- Services: notificaciones, alarmas, audio, haptics, fecha/hora e IA opcional.

No crear una capa de abstracción sin uso real. Las reglas de negocio no deben vivir dentro de las vistas.

### 3.4 Estructura base

```text
FERNE/
├── CLAUDE.md
├── README.md
├── docs/
│   ├── MASTER_SPEC.md
│   ├── PRODUCT.md
│   ├── SCREEN_CATALOG.md
│   ├── DESIGN_SYSTEM.md
│   ├── ARCHITECTURE.md
│   ├── DATA_MODELS.md
│   ├── NOTIFICATIONS.md
│   ├── MOTION_SYSTEM.md
│   ├── SCORE_ENGINE.md
│   ├── PRIVACY.md
│   ├── QA_PLAN.md
│   └── ACCEPTANCE_TESTS.md
├── .claude/
│   ├── settings.json
│   ├── rules/
│   ├── agents/
│   ├── skills/
│   └── commands/
├── FERNE/
│   ├── App/
│   ├── Core/
│   ├── DesignSystem/
│   ├── Domain/
│   ├── Data/
│   ├── Services/
│   ├── Features/
│   ├── Resources/
│   └── PreviewContent/
├── FERNETests/
└── FERNEUITests/
```

---

## 4. Identidad visual

### 4.1 Nombre y tono

- Nombre provisional: **FERNÉ**.
- Frase: **“Tu día, a tu ritmo.”**
- Personalidad: luminosa, elegante, femenina, viva, cálida y confiable.
- Evitar estética infantil, clínica, corporativa o genérica.

### 4.2 Paleta

| Token | Hex | Uso |
|---|---:|---|
| `ivoryRose` | `#FFF8F7` | Fondo base |
| `warmWhite` | `#FFFCFB` | Tarjetas |
| `cloudPink` | `#FADCE6` | Superficies suaves |
| `softPink` | `#F7A3BE` | Acentos secundarios |
| `fernePink` | `#F45F92` | Acción principal |
| `peachCoral` | `#F7A39A` | Amanecer y gradientes |
| `sunGold` | `#F6C978` | Sol y destacados |
| `deepPlum` | `#3C102F` | Títulos |
| `secondaryPlum` | `#672846` | Texto e iconos |
| `roseGray` | `#876D79` | Texto secundario |
| `successSoft` | `#9FD4B4` | Completado/pagado |
| `attentionAmber` | `#F4B86A` | Atención no crítica |

Rojo se reserva para errores técnicos o pagos vencidos. Nunca usar rojo para juzgar hábitos.

### 4.3 Tipografía

- Encabezados editoriales: serif elegante con licencia apta para distribución o tipografía del sistema equivalente.
- Texto funcional: SF Pro / tipografía del sistema.
- Compatibilidad con Dynamic Type.
- Texto esencial nunca menor al equivalente de 14 pt.
- Contraste mínimo conforme a accesibilidad de iOS.

### 4.4 Componentes

- Tarjetas: radio 20-24 pt, blanco cálido/translúcido, borde sutil, sombra rosada ligera.
- Botón principal: degradado rosa-coral, texto blanco.
- Botón secundario: blanco cálido con borde rosa.
- FAB: círculo rosa, símbolo `+`, haptic suave.
- Iconos: SF Symbols cuando exista el símbolo correcto; iconografía custom solo cuando aporte identidad.
- Barras y círculos de progreso animados.
- Evitar grandes espacios planos sin narrativa visual.

### 4.5 Temas según hora

**Mañana, 05:00-11:59**

- Amanecer rosa/melocotón.
- Sol emergente, nubes y reflejo.
- “Buenos días, Fer ✨”.

**Tarde, 12:00-18:59**

- Cielo más brillante y coral.
- Sol alto y destellos.
- “Buenas tardes, Fer”.

**Noche, 19:00-04:59**

- Cielo ciruela, rosa oscuro y lavanda.
- Luna con halo, nubes suaves y estrellas.
- “Buenas noches, Fer 🌙”.
- Nunca fondo negro puro.

### 4.6 Movimiento

- Sol y luna con movimiento lento.
- Nubes casi imperceptibles.
- Partículas/destellos en baja densidad.
- Check elástico al completar.
- Progreso se actualiza con animación.
- Transiciones de 200-450 ms para UI; escenas de splash 2-3 s.
- Haptics con intención, no en cada toque.
- Respetar `Reduce Motion` y `Reduce Transparency`.
- Mantener 60 fps en dispositivos objetivo.

---

## 5. Navegación

Barra inferior principal:

1. **Inicio**
2. **Progreso**
3. **Destellos** (mensaje, recomendaciones y espacio personal)
4. **Perfil**

Acceso persistente o contextual a Agenda y Rutinas desde Inicio y menú lateral/acciones, según el diseño aprobado. El FAB `+` abre el menú de creación.

Flujos esenciales:

```text
Splash → Bienvenida → Permisos → Inicio
Inicio → Actividad → Completar / Reprogramar / Editar
FAB → Categoría → Formulario → Guardar → Inicio + Agenda
Inicio → Progreso → Detalle del score
Inicio → Agenda → Día / Semana / Mes
Perfil → Ajustes → Notificaciones / IA / Privacidad
Resumen diario → Preparar mañana
Progreso semanal → Celebración semanal
```

---

## 6. Catálogo obligatorio de 40 pantallas

Cada pantalla debe implementarse con estados normal, vacío, cargando, error y accesibilidad cuando corresponda.

### 01. Splash cinematográfico

- Variante día: nubes, amanecer, sol, reflejo, partículas, logo y frase.
- Variante noche: luna, halo, estrellas y cielo ciruela.
- Duración objetivo: 2-3 segundos; permitir omitir tras primera ejecución si interfiere con rapidez.
- Nunca mostrar solo logo sobre fondo plano.

### 02. Bienvenida

- “Hola, Fer ✨”.
- Presentación breve de recordatorios, comidas, gym, lives, lectura y pagos.
- Acciones: `Comenzar` y `Configurar después`.

### 03. Permisos

- Explicar notificaciones, sonidos, alarmas y calendario.
- Solicitar cada permiso en contexto, no todos sin explicación.
- Acciones: activar y omitir.

### 04. Inicio / Hoy

- Saludo dinámico, fecha, escena día/noche.
- Mensaje del día.
- `Mi día` con porcentaje y completadas.
- `Lo que sigue` con cuenta regresiva.
- Agenda del día.
- FAB `+`.
- Acciones por actividad: completar, posponer, reprogramar y abrir.

### 05. Mensaje diario

- Mensaje motivacional.
- Guardar, compartir, leer otro y recordarlo durante el día.
- Contenido amable, directo y no invasivo.

### 06. Menú Agregar

- Hoja inferior con categorías: recordatorio, comida, gym, trabajo, TikTok Live, lectura, pago, rutina, evento, nota y dormir.

### 07. Nuevo recordatorio

- Título, descripción, fecha, hora, repetición, categoría, anticipación, sonido, importancia y repetir hasta confirmar.

### 08. Agenda diaria

- Timeline por hora, espacios libres y filtros.
- Arrastrar/reprogramar con confirmación.

### 09. Agenda semanal

- Lunes-domingo, bloques por categoría, disponibilidad y copiar semana.

### 10. Calendario mensual

- Eventos, pagos, gym y lives; filtros y resumen por día.

### 11. Horarios de comida

- Desayuno, almuerzo, merienda y cena.
- Alarmas individuales y confirmación.
- Sin calorías, peso ni medidas.

### 12. Agregar comida

- Nombre, hora, días, anticipación, sonido, repetición hasta confirmar y nota.

### 13. Gym

- Semana de sesiones, próxima sesión, asistencia y preparar bolso.
- Sin calorías, peso ni objetivos corporales.

### 14. Agregar gym

- Nombre, fecha, hora, duración, repetición, anticipación y nota.

### 15. TikTok Live

- Horarios propuestos que no crucen comidas, gym, lectura o descanso.
- Meta semanal y próximos lives.

### 16. Agregar TikTok Live

- Título, fecha, hora, duración, preparación, recordatorio y tema.

### 17. Lectura

- Objetivo configurable, sesiones, temporizador y progreso amable.

### 18. Agregar lectura

- Libro/título, fecha, hora, duración, repetición y nota.

### 19. Pagos y recibos

- Próximos, pendientes, pagados y vencidos.
- Marcar pagado, aplazar aviso y ver detalle.

### 20. Agregar pago

- Servicio, valor opcional, vencimiento, repetición, anticipación, confirmación y nota.

### 21. Mis rutinas

- Mañana, gym, trabajo, lectura y noche.
- Constancia sin calificaciones punitivas.

### 22. Detalle de rutina

- Pasos reordenables, horarios, agregar paso, activar/desactivar y guardar.

### 23. Hora de dormir

- Objetivo 00:00 configurable.
- Secuencia previa, sonido suave y días activos.

### 24. Alarma activa

- Presentación prominente para despertar o dormir.
- Contexto visual día/noche.
- Confirmar, posponer y abrir actividad.

### 25. Centro de notificaciones

- Hoy, próximos e importantes.
- Completar, posponer y abrir.
- Estado vacío: “Todo está al día ✨”.

### 26. Para mí

- Notas, ideas, sueños, mensajes guardados y compromisos personales.

### 27. Registro del día

- Estado del día, qué salió bien y qué mejorar mañana.
- Lenguaje neutral y cálido.

### 28. Perfil y ajustes

- Saludo, notificaciones, sonidos, alarmas, apariencia, categorías, IA, privacidad, Face ID e iCloud.

### 29. Personalizar saludo

- Nombre preferido, vista previa mañana/tarde/noche y tono del mensaje.

### 30. Integraciones de IA

- ChatGPT y Gemini opcionales.
- Estado conectado/no conectado.
- Permisos granulares para agenda, rutinas y creación de recordatorios.
- La app funciona totalmente sin IA.

### 31. Importar historial

- Seleccionar archivo exportado, elegir conversaciones, progreso y privacidad.
- No prometer sincronización automática con cuentas personales.

### 32. Privacidad y datos

- Datos locales, iCloud, memoria IA, exportar, eliminar historial y eliminar todo.
- Confirmaciones destructivas claras.

### 33. Detalle de actividad

- Fecha, hora, duración, categoría, alertas, repetición, notas y estado.
- Completar, editar, reprogramar o eliminar.

### 34. Reprogramar

- Opciones rápidas, fecha/hora personalizada, conflictos y sugerencias.

### 35. Día completado

- Escena cinematográfica y resumen.
- “Lo hiciste, Fer ✨”.
- Cerrar día o preparar mañana.

### 36. Mi progreso

- Score semanal, completadas, pendientes, reprogramadas y próximas.
- Gráfico de siete días.
- Fortalezas, oportunidad de mejora y prioridad actual.

### 37. Resumen del día

- Score diario, actividad por categoría y recomendación para mañana.

### 38. Detalle del score

- Explicación exacta de cada componente.
- Nota: “Tu score no es una calificación personal. Solo sirve para ayudarte a organizar mejor tu semana.”

### 39. Recomendaciones FERNÉ

- Sugerencias explicables, opcionales y aplicables.
- Mostrar por qué se recomienda y qué cambiará.

### 40. Celebración semanal

- Sol o luna, tres logros, una mejora posible y preparar semana siguiente.

---

## 7. Motor de actividades y datos

### 7.1 Entidad base `Activity`

Campos mínimos:

- `id: UUID`
- `title: String`
- `notes: String?`
- `category: ActivityCategory`
- `startDate: Date`
- `endDate: Date?`
- `allDay: Bool`
- `recurrenceRule: RecurrenceRule?`
- `reminderOffsets: [TimeInterval]`
- `soundID: String?`
- `priority: Priority`
- `requiresConfirmation: Bool`
- `status: ActivityStatus`
- `completedAt: Date?`
- `rescheduledFrom: Date?`
- `createdAt: Date`
- `updatedAt: Date`

Categorías: despertar, comida, gym, trabajo, live, lectura, pago, rutina, evento, nota, dormir y personal.

Estados: programada, completada, pendiente, reprogramada, omitida y cancelada.

### 7.2 Entidades adicionales

- `Routine` y `RoutineStep`.
- `Payment`.
- `MealSchedule`.
- `GymSession`.
- `LiveSession`.
- `ReadingSession`.
- `DailyReflection`.
- `DailyScoreSnapshot`.
- `WeeklyScoreSnapshot`.
- `NotificationPreference`.
- `SoundPreference`.
- `UserPreferences`.
- `AIIntegrationConfig` sin claves en SwiftData.

### 7.3 Migraciones

- Versionar el esquema desde el primer commit.
- Incluir estrategia de migración antes de cambiar modelos.
- Nunca borrar datos como solución a una migración fallida.

---

## 8. Notificaciones, alarmas y sonidos

### 8.1 Objetivo

Las alertas deben ser confiables, configurables y estéticas. La UI no puede prometer entrega si iOS no ha concedido permisos.

### 8.2 Implementación

- `UNUserNotificationCenter` para notificaciones locales.
- AlarmKit para despertar/dormir cuando esté disponible.
- Fallback a notificación local.
- Categorías con acciones: completar, posponer, reprogramar y abrir.
- Reprogramar notificaciones al editar o borrar actividades.
- Recuperar agenda pendiente al iniciar la app.
- Considerar cambios de zona horaria y horario de verano.
- No duplicar alertas.

### 8.3 Biblioteca inicial de sonidos

Nombres de producto:

1. Amanecer
2. Campanita
3. Destello
4. Flor
5. Luna
6. Sueño

Requisitos:

- Sonidos originales o con licencia de distribución.
- Formato y duración compatibles con iOS.
- Preview en Ajustes.
- Selección global y por actividad.
- Opción sonido del sistema y sin sonido.
- Haptic configurable.

### 8.4 Centro de salud de notificaciones

Mostrar:

- Permiso de alertas.
- Permiso de sonido.
- Estado de AlarmKit.
- Próxima notificación programada.
- Botón `Probar notificación`.
- Enlace a Ajustes de iOS si está bloqueado.

No usar Critical Alerts en el MVP.

---

## 9. Score y recomendaciones

### 9.1 Score diario

```text
score diario = completadas / actividades evaluables × 100
```

- Excluir actividades canceladas.
- Una actividad reprogramada se informa aparte y no se trata como fracaso.
- Redondear para presentación; conservar precisión interna.

### 9.2 Constancia semanal

- Cumplimiento diario: 40%.
- Rutinas: 20%.
- Horarios importantes: 20%.
- Compromisos semanales: 20%.

Estados:

- 90-100: Semana excelente.
- 75-89: Vas muy bien.
- 60-74: Sigues avanzando.
- Menos de 60: Vamos a reorganizarlo.

### 9.3 Reglas de lenguaje

Prohibido: “fracaso”, “mala”, “insuficiente”, “perezosa” o equivalentes.

Formato de recomendación:

1. Observación verificable.
2. Explicación breve.
3. Cambio pequeño sugerido.
4. Acción opcional para aplicarlo.

Ejemplo: “Esta semana comenzaste mejor la lectura entre las 19:00 y las 20:00. ¿Quieres reservar ese horario?”

### 9.4 Pruebas obligatorias

- Día sin actividades.
- Todas completadas.
- Algunas reprogramadas.
- Actividad cancelada.
- Cruce de medianoche.
- Cambio de zona horaria.
- Semana parcial.
- Datos históricos modificados.

---

## 10. IA opcional

### 10.1 Regla

Ninguna función central depende de IA.

### 10.2 Proveedores

- ChatGPT/OpenAI.
- Gemini.

### 10.3 Seguridad

- Nunca guardar claves en el repositorio.
- Keychain para uso personal controlado.
- Si la app se distribuye públicamente, mover llamadas a backend seguro.
- No registrar prompts, respuestas o claves en logs de producción.
- Permisos granulares y revocables.

### 10.4 Historial

- Importación mediante archivo exportado.
- Selección de conversaciones.
- Procesamiento local cuando sea posible.
- Eliminar importación y memoria desde Privacidad.

---

## 11. Sistema Claude Code (“Brain”)

### 11.1 `CLAUDE.md`

Debe ser conciso y permanente. Incluir:

- Fuente de verdad: `docs/MASTER_SPEC.md`.
- Stack y versión mínima.
- Arquitectura.
- Comandos de build/test/lint.
- Regla de no añadir dependencias sin justificar.
- Regla de no declarar completado sin compilar y probar.
- Regla de preservar diseño aprobado.
- Regla de no guardar secretos.
- Regla de actualizar documentación y checklist.

### 11.2 Rules

Crear:

- `architecture.md`
- `design-system.md`
- `swift-style.md`
- `notifications.md`
- `persistence.md`
- `privacy-security.md`
- `testing.md`
- `accessibility.md`
- `git-workflow.md`

Usar reglas por ruta cuando solo correspondan a ciertos archivos.

### 11.3 Agentes

1. `product-architect`
2. `ios-architect`
3. `visual-guardian`
4. `motion-designer`
5. `notification-engineer`
6. `data-score-engineer`
7. `accessibility-reviewer`
8. `qa-engineer`
9. `release-engineer`

Cada agente debe tener descripción enfocada, herramientas mínimas, entregable definido y prohibición de modificar áreas ajenas sin aprobación.

### 11.4 Skills

Crear skills de proyecto:

- `build-screen`
- `verify-design`
- `create-animation`
- `add-notification`
- `test-notifications`
- `add-data-model`
- `verify-score`
- `run-quality-gate`
- `audit-accessibility`
- `prepare-testflight`

Cada skill debe incluir: cuándo usar, entradas, procedimiento, validaciones, fallos comunes y definición de terminado.

### 11.5 Hooks

Configurar de forma segura:

- Después de editar Swift: ejecutar formato/lint del archivo afectado.
- Antes de commit: compilar y ejecutar pruebas relevantes.
- Detectar secretos y archivos sensibles.
- Bloquear la inclusión accidental de claves.
- Notificar cuando Claude requiera intervención.

Los hooks nunca deben borrar datos, reescribir ramas o ejecutar comandos destructivos.

---

## 12. Dependencias

### 12.1 Política

- Preferir frameworks de Apple.
- Agregar una librería solo si reduce riesgo o trabajo de forma material.
- Verificar mantenimiento, licencia, compatibilidad y tamaño.
- Fijar versiones.
- Documentar por qué existe cada dependencia.

### 12.2 Permitidas inicialmente

- Lottie iOS, solo para splash/celebraciones si los assets existen.
- SwiftLint y SwiftFormat como herramientas de desarrollo.

No añadir Rive, Firebase, Supabase, analytics, networking o paquetes de UI sin aprobación.

---

## 13. Accesibilidad y privacidad

- Dynamic Type.
- VoiceOver labels y hints.
- Contraste suficiente.
- Áreas táctiles mínimas de 44×44 pt.
- No depender únicamente del color.
- Reducir movimiento/transparencia.
- Orden de foco lógico.
- Sonido acompañado de texto/visual.
- Exportación y eliminación de datos.
- Metadatos privados fuera de logs.
- Face ID opcional.

---

## 14. Pruebas y quality gates

### 14.1 Antes de aceptar una feature

- Compila sin warnings nuevos.
- Tests unitarios pasan.
- UI tests críticos pasan.
- No hay crashes.
- Persistencia validada tras reinicio.
- Notificaciones verificadas en dispositivo.
- VoiceOver y Dynamic Type revisados.
- Reduce Motion revisado.
- Comparación visual contra diseño aprobada.
- Sin secretos ni datos sensibles.

### 14.2 Casos críticos E2E

1. Crear actividad → aparece en Inicio y Agenda → notifica → completar → score cambia.
2. Reprogramar → notificación anterior se cancela → nueva se programa.
3. Crear pago recurrente → aviso anticipado → marcar pagado.
4. Crear rutina → completar pasos → progreso actualiza.
5. Configurar despertar/dormir → alarma compatible/fallback.
6. Cerrar y abrir app → datos permanecen.
7. Sin internet → funciones centrales operan.
8. Permisos denegados → app explica y permite corregir.
9. Cambio de hora/zona → agenda y alertas correctas.
10. Activar Reduce Motion → escenas se simplifican.

### 14.3 Visual QA

- Captura de cada pantalla en tamaño compacto, estándar y grande.
- Comparar jerarquía, paleta, espaciado y estados.
- Revisar día y noche.
- Prohibido aprobar pantallas con fondo plano genérico.

---

## 15. Plan de ejecución

### Fase 0 — Preparación

- Repositorio, proyecto Xcode, documentación, Brain, reglas, agentes, skills y hooks.
- Design tokens, componentes base y datos de preview.
- Resultado: proyecto compila y pruebas base pasan.

### Fase 1 — Núcleo funcional

- Modelos, SwiftData, servicios de fecha, repositorios y navegación.
- Crear/editar/completar/reprogramar actividades.

### Fase 2 — Inicio y agenda

- Splash, onboarding, permisos, Inicio, Agenda día/semana/mes y menú Agregar.

### Fase 3 — Categorías

- Comidas, gym, live, lectura, pagos, rutinas y dormir.

### Fase 4 — Notificaciones

- UserNotifications, AlarmKit/fallback, sonidos, acciones y centro de salud.

### Fase 5 — Progreso

- Score, gráficas, resumen diario, recomendaciones y celebración.

### Fase 6 — Personal y ajustes

- Para mí, registro, perfil, privacidad, Face ID, iCloud e IA opcional preparada pero no obligatoria.

### Fase 7 — Cinemática y polish

- Amanecer, tarde, noche, Lottie si procede, haptics y microinteracciones.

### Fase 8 — QA y distribución

- Pruebas completas, rendimiento, accesibilidad, dispositivo real, firma y TestFlight.

No construir las 40 pantallas como vistas vacías antes del núcleo. Cada fase debe quedar integrada y probada.

---

## 16. Definición de MVP entregable

Para que Fer pueda usar la primera versión deben funcionar:

- Abrir sin cuenta.
- Onboarding y permisos.
- Inicio con saludo día/noche.
- Crear, editar, completar y reprogramar actividades.
- Agenda.
- Comidas, gym, live, lectura, pagos y dormir.
- Notificaciones locales con sonidos seleccionables.
- AlarmKit/fallback para despertar y dormir.
- Datos persistentes.
- Score diario/semanal.
- Ajustes y prueba de notificación.
- Funcionamiento offline.
- Instalación firmada en iPhone.

IA, importación de historial y CloudKit avanzado pueden terminarse después sin bloquear el uso diario.

---

## 17. Criterio final de aceptación

FERNÉ está lista cuando:

1. Las 40 pantallas existen y están conectadas.
2. El MVP funciona en un iPhone real.
3. Las alertas se programan, actualizan y cancelan correctamente.
4. Fer puede escuchar y escoger sonidos.
5. Los datos sobreviven reinicios y uso offline.
6. El score explica sus cálculos.
7. El diseño conserva sol, luna, rosados, ciruela, profundidad y movimiento.
8. La app respeta accesibilidad.
9. No existen secretos en el repositorio.
10. Tests y quality gates pasan.
11. Hay instrucciones de build, firma y TestFlight.
12. La implementación coincide con las referencias visuales aprobadas.

---

## 18. Prompt de arranque para Claude Code

Copiar este mensaje en la primera sesión del repositorio:

```text
Lee completamente docs/MASTER_SPEC.md y todas las referencias del proyecto antes de modificar archivos. Este documento es la fuente de verdad de FERNÉ.

Tu primera tarea no es construir las 40 pantallas. Primero:
1. Audita el entorno y las referencias disponibles.
2. Crea o valida CLAUDE.md, rules, agentes, skills y hooks descritos en la especificación.
3. Propón la arquitectura y el plan de implementación por fases.
4. Identifica decisiones bloqueantes, especialmente versión de iOS, firma y dispositivo objetivo.
5. Crea el proyecto SwiftUI y el sistema de diseño mínimo.
6. Compila y ejecuta pruebas base.
7. Entrega un informe con archivos creados, comandos ejecutados, resultados y siguiente fase.

Reglas obligatorias:
- No añadas Supabase, Firebase ni backend en el MVP.
- No añadas dependencias sin justificar y solicitar aprobación.
- No guardes secretos.
- No declares una pantalla terminada sin compilar, probar y verificar visualmente.
- Preserva exactamente la identidad visual aprobada.
- Trabaja por fases pequeñas y verificables.
- Si falta una referencia o decisión, detente y pregunta; no inventes.
```

---

## 19. Fuentes técnicas de referencia

- Apple User Notifications: https://developer.apple.com/documentation/usernotifications
- Apple AlarmKit: https://developer.apple.com/documentation/AlarmKit
- Apple Notifications HIG: https://developer.apple.com/design/human-interface-guidelines/notifications
- Lottie iOS: https://github.com/airbnb/lottie-ios
- Claude Code extension overview: https://code.claude.com/docs/en/features-overview
- Claude Code project memory: https://code.claude.com/docs/en/memory
- Claude Code subagents: https://code.claude.com/docs/en/sub-agents
- Claude Code skills: https://code.claude.com/docs/en/skills
- Claude Code hooks: https://code.claude.com/docs/en/hooks-guide

---

**Fin de la especificación maestra v1.0.**
