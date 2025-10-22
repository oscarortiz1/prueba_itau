# Prueba Itaú – Frontend

Aplicación Flutter que implementa una experiencia offline-first para la gestión de transacciones.

## Decisiones técnicas clave

- **Arquitectura limpia + BLoC**: la capa de presentación usa `TransactionsBloc` y demás BLoCs para aislar el UI de la lógica de negocio y facilitar pruebas. Las capas `domain` y `data` exponen casos de uso y repositorios con contratos claros.
- **Inyección de dependencias con GetIt**: `lib/src/app/di/injection_container.dart` registra data sources, repositorios, casos de uso y BLoCs. Esto permite intercambiar implementaciones (por ejemplo, reemplazar el datasource local en tests) sin tocar el resto del código.
- **Soporte offline y sincronización automática**: `TransactionsRepositoryImpl` decide cuándo trabajar contra la API o contra el cache local (`SharedPreferences`). Al perder conexión se generan IDs locales y se encola la operación en `PendingTransactionOperationModel`; cuando el dispositivo recupera red, `SyncPendingTransactions` reprocesa la cola.
- **Detección de conectividad reactiva**: `NetworkInfoImpl` envuelve `connectivity_plus` y expone un stream usado por el `TransactionsBloc` para reaccionar a cambios de red y gatillar sincronizaciones sin intervención del usuario.
- **Normalización de fechas**: todos los timestamps se envían al backend en UTC y se convierten a hora local al mostrarlos, eliminando desfasajes por zona horaria.
- **Cobertura de pruebas**: se añadieron unit tests para el repositorio, el BLoC y widget tests para `TransactionsSection`, asegurando que los estados principal, vacío y de datos se rendericen correctamente.

## Ejecutar el proyecto

```bash
flutter pub get
flutter run
```

## Ejecutar pruebas

```bash
flutter test
```

---

Para las decisiones técnicas del backend, revisa `../prueba_itau_backend/README.md`.
