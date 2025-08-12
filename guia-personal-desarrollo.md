# Guía de desarrollo

---

## Fases y pasos para el desarrollo

### Fase 1: Preparación y configuración básica

- [ ] Instalar y configurar Flutter, Android Studio y emuladores.  
- [ ] Crear proyecto Flutter `notably`.  
- [ ] Configurar Supabase y crear proyecto backend (base de datos y autenticación).  
- [ ] Añadir dependencias en Flutter para Supabase, Riverpod/Bloc, Y.js (WebAssembly).

---

### Fase 2: Autenticación y estructura básica de la app

- [ ] Implementar login/signup con Supabase Auth.  
- [ ] Crear pantalla principal con lista de espacios de trabajo.  
- [ ] Permitir crear y unirse a espacios.

---

### Fase 3: Editor colaborativo básico

- [ ] Integrar editor Flutter (`flutter_quill` u otro) para edición de texto enriquecido.  
- [ ] Integrar Y.js compilado a WebAssembly para manejar estado colaborativo.  
- [ ] Conectar canal WebSocket con Supabase Realtime o Liveblocks para sincronización.  
- [ ] Manejar actualización en tiempo real entre múltiples usuarios.

---

### Fase 4: Backend avanzado y permisos

- [ ] Definir esquema PostgreSQL para documentos, usuarios, espacios y roles.  
- [ ] Configurar políticas RLS (Row-Level Security) para control de acceso.  
- [ ] Guardar versiones del documento para historial.

---

### Fase 5: IA y mejoras de productividad

- [ ] Integrar API OpenAI / Llama 3 para funciones como resumen automático, generación de esquemas.  
- [ ] Añadir búsqueda semántica usando embeddings.  
- [ ] Mejorar UI/UX con Material 3 y diseño personalizado.

---

### Fase 6: Testing, optimización y despliegue

- [ ] Pruebas en dispositivos reales y emuladores.  
- [ ] Optimización de sincronización y manejo de conflictos CRDT.  
- [ ] Despliegue en tiendas (Google Play, Apple Store) y hosting web.

---

## Herramientas recomendadas

- VSCode o Android Studio para Flutter  
- Supabase dashboard para backend  
- Git + GitHub para control de versiones  
- Postman para probar APIs
