# Prueba Itaú – Frontend

Documento breve (README) explicando las decisiones técnicas tomadas para el cliente móvil/web.

Aplicación Flutter enfocada en experiencia offline-first, sincronización transparente y autenticación segura sobre la API NestJS.

## Novedades recientes

- API base unificada: el `AppConfig` resuelve `http://localhost:3000/api/v1` (o `http://10.0.2.2:3000/api/v1` en emulador Android) y se inyecta vía GetIt en todos los data sources.
- Cliente HTTP migrado a `dio`, con timeouts configurados y traducción consistente de errores a `AppException` para mostrar mensajes amigables.
- Manejo de sesión centralizado en `SessionManager`, que guarda tokens JWT en `SharedPreferences` y los comparte con los repositorios.
- Sincronización offline resiliente: las operaciones pendientes se almacenan como `PendingTransactionOperationModel` y `SyncPendingTransactions` las reintenta cuando vuelve la conectividad.
- Estado global con `flutter_bloc` para auth y transacciones, aprovechando `connectivity_plus` para disparar sincronizaciones automáticas.
- Transacciones en tiempo real: `TransactionsRepositoryImpl` se suscribe al socket usando `TransactionsRealtimeDataSource`; difunde eventos creados/actualizados/eliminados a `TransactionsBloc`, que actualiza la lista sin refrescos manuales.
- Lints actualizados (`flutter_lints` v6) y código alineado con las reglas; `flutter analyze` queda limpio.

## Arquitectura en breve

- **Presentación**: Widgets consumen BLoCs (`LoginBloc`, `TransactionsBloc`, etc.) registrados en `lib/src/app/di/injection_container.dart`.
- **Dominio**: Casos de uso (`GetTransactions`, `LoginUser`, …) orquestan los flujos sin depender de Flutter.
- **Datos**: Repositorios como `TransactionsRepositoryImpl` combinan `TransactionsRemoteDataSource` (HTTP) y `TransactionsLocalDataSource` (cache + cola offline).
- **Configuración**: `_resolveApiHost()` adapta el host según plataforma, evitando ajustes manuales al alternar entre web, emulador y escritorio.

## Puesta en marcha

1. Ten el backend corriendo en `http://localhost:3000` (`npm run start:dev` en `prueba_itau_backend`).
2. Instala dependencias y lanza la app:

	```bash
	flutter pub get
	flutter run
	```

	En VS Code puedes usar el target que prefieras (web, emulador Android/iOS o desktop).

## Transacciones en tiempo real

- Mantén el backend NestJS activo (`npm run start:dev`) para habilitar el gateway de websockets.
- Inicia sesión en la app; el `SessionManager` inyecta el token al socket y `TransactionsRealtimeDataSource` establece la conexión.
- Crea, actualiza o elimina transacciones desde la app o vía API externa (Postman/cURL). `TransactionsBloc` reflejará los cambios al instante sin recargar la pantalla.
- Puedes simular modo offline: desconecta tu red, realiza operaciones (quedarán en cola), vuelve a conectarte y verifica que la sincronización y los eventos en vivo se apliquen tras reconectar.

## Autenticación y pruebas

- El login (`POST /api/v1/auth/login`) devuelve el JWT que `SessionManager` persiste; la sesión se restaura automáticamente al abrir la app.
- Ejecuta las pruebas con `flutter test`; la suite cubre repositorios, BLoCs y widgets clave.
- Para validar la conexión con el backend puedes usar el comando `flutter test --plain-name "transactions"` y revisar que no fallen por red.

---

Para más detalles del backend, revisa `../prueba_itau_backend/README.md`.
