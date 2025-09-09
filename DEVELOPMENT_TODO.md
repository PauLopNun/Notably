# 📋 NOTABLY - Development TODO & Bug Fixes

## 🚨 ERRORES CRÍTICOS IDENTIFICADOS

### 1. **Errores de Base de Datos / Backend**
- ❌ **Delete Note Error**: `Exception: Error al eliminar la nota`
  - **Ubicación**: `note_service.dart:67`
  - **Causa**: Problemas con la consulta DELETE en Supabase
  - **Estado**: 🔴 BLOQUEANTE

- ❌ **Update Note Error**: `Exception: Error al actualizar la nota` 
  - **Ubicación**: `note_service.dart:67`
  - **Causa**: Problemas con UPDATE queries en Supabase
  - **Estado**: 🔴 BLOQUEANTE

### 2. **Errores de UI/Material Design**
- ❌ **FilterChip Material Error**: `No Material widget found`
  - **Ubicación**: `template_gallery.dart:241`
  - **Causa**: FilterChip sin Material ancestor
  - **Estado**: 🟡 MEDIO

- ❌ **RenderFlex Overflow**: `overflowed by 99348 pixels on the bottom`
  - **Ubicación**: Page Properties panel
  - **Estado**: 🟡 MEDIO

- ❌ **RenderFlex Overflow**: `overflowed by 118 pixels on the right`
  - **Estado**: 🟡 MEDIO

## 🔧 FUNCIONALIDADES NO IMPLEMENTADAS

### 3. **Sistema de Colaboración**
- ❌ **Invitar Colaboradores**: Botón existe pero no funciona
  - **Ubicación**: Share menu en content area
  - **Requiere**: 
    - Backend service para invitaciones
    - Email service integration
    - Permissions management
  - **Estado**: 🔴 NO IMPLEMENTADO

- ❌ **Edición en Tiempo Real**: No funciona colaboración simultánea
  - **Requiere**:
    - WebSocket/Realtime subscriptions
    - Operational Transform o similar
    - Live cursors
  - **Estado**: 🔴 NO IMPLEMENTADO

### 4. **Sistema de Workspace**
- ❌ **Invitar Usuarios al Workspace**: No funciona
  - **Ubicación**: WorkspaceSelector settings
  - **Requiere**: 
    - Workspace member management
    - Role-based access control
  - **Estado**: 🔴 NO IMPLEMENTADO

### 5. **Exportación de Documentos**
- ❌ **Export to PDF**: No descarga archivo
  - **Ubicación**: Export menu
  - **Requiere**: 
    - PDF generation library
    - File download handling
  - **Estado**: 🔴 NO IMPLEMENTADO

- ❌ **Export to Markdown**: No funciona
  - **Requiere**: Quill to Markdown converter
  - **Estado**: 🔴 NO IMPLEMENTADO

### 6. **Autenticación**
- ❌ **Google Login**: No funciona
  - **Requiere**: Google OAuth setup
  - **Estado**: 🔴 NO IMPLEMENTADO

- ❌ **Auth UI Inconsistente**: Colores no coinciden con app
  - **Requiere**: Redesign auth pages para ser consistente con NotionTheme
  - **Estado**: 🟡 ESTÉTICO

## 🔨 PLAN DE DESARROLLO PASO A PASO

### **FASE 1: Errores Críticos de Backend** 🔴
1. **Fix Database Operations**
   - Investigar schema de Supabase 
   - Corregir DELETE queries en note_service.dart
   - Corregir UPDATE queries en note_service.dart
   - Test CRUD operations

### **FASE 2: UI/Layout Fixes** 🟡  
2. **Fix Material Widget Issues**
   - Wrap FilterChip en Material en template_gallery.dart
   - Fix overflow en Page Properties panel
   - Fix layout overflows generales

### **FASE 3: Funcionalidades Core** 🔵
3. **Sistema de Colaboración Básico**
   - Implementar invite system (backend + frontend)
   - Setup email notifications
   - Basic permissions management

4. **Exportación de Documentos**
   - Implementar PDF export con pdf library
   - Implementar Markdown export
   - File download handling

### **FASE 4: Autenticación Mejorada** 🔵
5. **Google OAuth Integration**
   - Setup Google OAuth en Supabase
   - Frontend Google Sign In
   - Test authentication flow

6. **Auth UI Redesign**
   - Aplicar NotionTheme a auth pages
   - Consistent branding y colores
   - Mejorar UX de auth flow

### **FASE 5: Funcionalidades Avanzadas** 🟢
7. **Real-time Collaboration**
   - Setup Supabase Realtime
   - Implement live document editing
   - Live cursors y presence

8. **Workspace Management**
   - User invitation system
   - Role management
   - Workspace settings

## 🎯 PRIORIDADES DE DESARROLLO

### **🔴 ALTA PRIORIDAD** (Necesario para funcionalidad básica)
- Database CRUD operations (delete/update notes)
- Basic collaboration (invitations)
- PDF/Markdown export
- Google authentication

### **🟡 MEDIA PRIORIDAD** (Mejoras UX/UI)
- Material widget fixes
- Layout overflow fixes  
- Auth UI consistency

### **🟢 BAJA PRIORIDAD** (Features avanzadas)
- Real-time collaboration
- Advanced workspace features
- Live cursors

## 📝 NOTAS TÉCNICAS

### **Database Issues Investigation Needed:**
```sql
-- Verificar estructura de tabla notes en Supabase
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'notes';

-- Verificar RLS policies
SHOW POLICIES ON notes;
```

### **Dependencies Needed:**
```yaml
# Para PDF export
pdf: ^3.10.4
printing: ^5.11.0

# Para Google Auth  
google_sign_in: ^6.1.5

# Para real-time collaboration
supabase_flutter: ^latest # ya instalado
```

### **File Structure for Implementation:**
```
lib/
├── services/
│   ├── collaboration_service.dart ❌ FALTA IMPLEMENTAR
│   ├── export_service.dart ❌ FALTA IMPLEMENTAR  
│   ├── workspace_service.dart ❌ FALTA IMPLEMENTAR
│   └── note_service.dart 🔧 NEEDS FIXING
├── auth/
│   └── auth_pages/ 🎨 NEEDS REDESIGN
└── widgets/
    ├── collaboration/ ❌ FALTA IMPLEMENTAR
    └── export/ ❌ FALTA IMPLEMENTAR
```

---

## ⚡ NEXT STEPS
1. Start with **FASE 1** - Fix database operations
2. Test cada fix antes de continuar
3. Document progress en este file
4. Update status: ❌ → 🔧 → ✅

**Estimated Timeline**: 2-3 días para FASE 1-2, 1 semana para FASE 3-4, 2 semanas para FASE 5