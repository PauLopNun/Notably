# 🐛 ERROR TRACKING - Notably App
*Real-time error monitoring - 10 Sep 2025*

## 📍 **APP STATUS**
- **URL**: http://localhost:8081
- **Auto-detection**: Implemented in main.dart
- **Expected behavior**: Should show DB setup guide if table missing

---

## 🔍 **TESTING CHECKLIST - BOTONES ACCIONABLES**

### **🔐 AUTHENTICATION PAGE**
- [ ] **Email Login Button** - Test with valid/invalid credentials
- [ ] **Google Login Button** - Should show configuration error  
- [ ] **Sign Up Button** - Test account creation
- [ ] **Password Reset** - Test reset flow

### **🏠 HOME PAGE - SIDEBAR**
- [ ] **+ New Note Button** - Should create new note
- [ ] **Search Bar** - Should filter notes
- [ ] **Templates Button** - Should show template gallery
- [ ] **All Notes Filter** - Should show all notes
- [ ] **Recent Filter** - Should show last 7 days
- [ ] **Favorites Filter** - Should show favorites (may be empty)
- [ ] **Settings Button** - Should navigate to settings

### **📝 NOTE ACTIONS**
- [ ] **Note Click** - Should open note editor
- [ ] **Note Menu (⋯)** - Should show options:
  - [ ] **Duplicate** - Should clone note
  - [ ] **Export** - Should show PDF/Markdown options
  - [ ] **Delete** - Should show confirmation dialog

### **📄 CONTENT AREA**
- [ ] **Editor Toolbar** - Check all formatting buttons:
  - [ ] **Bold (B)** - Should format text
  - [ ] **Italic (I)** - Should format text  
  - [ ] **Underline (U)** - Should format text
  - [ ] **Bullet List** - Should create list
  - [ ] **Number List** - Should create numbered list
  - [ ] **Quote** - Should create blockquote
  - [ ] **Code** - Should format code
  - [ ] **Link** - Should create link

### **📊 TOP TOOLBAR**
- [ ] **Share Button** - Should open collaboration panel
- [ ] **Export Menu** - Should show:
  - [ ] **Export PDF** - Should download PDF file
  - [ ] **Export Markdown** - Should download MD file
- [ ] **Properties Button** - Should open properties panel

### **🤝 COLLABORATION PANEL** (if activated)
- [ ] **Invite Email Field** - Should accept email input
- [ ] **Send Invite Button** - Should send invitation
- [ ] **Permission Dropdown** - Should change permissions
- [ ] **Remove Collaborator** - Should remove access

---

## 🚨 **ERRORS DETECTADOS**

### **❌ ERRORES CRÍTICOS**
1. **Database Connection Error**
   - **Expected**: Auto-detection message in console
   - **Location**: Browser Developer Tools → Console
   - **Fix**: Execute SQL setup in Supabase

### **❌ ERRORES UI/MATERIAL**
2. **FilterChip Material Error**
   - **Location**: `template_gallery.dart:241`
   - **Error**: "No Material widget found"
   - **Fix**: Wrap FilterChip in Material widget

3. **RenderFlex Overflow**
   - **Location**: Properties panel & toolbar
   - **Error**: Pixel overflow
   - **Fix**: Add scrolling or responsive layout

### **❌ ERRORES FUNCIONALIDAD**
4. **PDF Export Button**
   - **Expected**: Download PDF file
   - **Actual**: May show path but no download
   - **Fix**: Verify web download implementation

5. **Google Login**
   - **Expected**: OAuth popup
   - **Actual**: Configuration error
   - **Fix**: Add real Client ID

6. **Collaboration Features**
   - **Expected**: Send invitations
   - **Actual**: UI exists but may not be connected
   - **Fix**: Verify backend integration

---

## 🔧 **FIXES IMPLEMENTADOS**

### ✅ **COMPLETED**
- [x] **Toolbar Overflow** - Fixed with SingleChildScrollView
- [x] **Auto-detection** - Added database schema check
- [x] **Documentation** - Created setup guides

### 🔄 **IN PROGRESS**
- [ ] **Material Widget Error** - Need to wrap FilterChip
- [ ] **PDF Download** - Need to verify web implementation
- [ ] **Database Setup** - Waiting for SQL execution

### ⏳ **PENDING**
- [ ] **Google OAuth** - Need real Client ID
- [ ] **Collaboration Backend** - Need to verify connections
- [ ] **UI Polish** - Fix remaining overflows

---

## 📋 **TESTING PROTOCOL**

### **Step 1: Basic App Launch**
```bash
1. Open: http://localhost:8081
2. Check console for auto-detection message
3. Verify auth page loads without crashes
```

### **Step 2: Authentication Flow**
```bash
1. Try email login (should fail if no DB setup)
2. Check Google login (should show config error)
3. Monitor console for errors
```

### **Step 3: Main UI Testing**
```bash
1. After auth, test each sidebar button
2. Test toolbar buttons
3. Test note creation/editing
4. Test export functionality
```

### **Step 4: Error Collection**
```bash
1. Document each error in console
2. Note which buttons don't work
3. Identify missing functionality
4. Prioritize fixes by severity
```

---

## 🎯 **NEXT ACTIONS**

### **Immediate (High Priority)**
1. **Monitor console logs** for auto-detection
2. **Test PDF export** in browser
3. **Fix Material widget errors**
4. **Verify database connectivity**

### **Short-term (Medium Priority)**
1. **Fix remaining UI overflows**
2. **Test collaboration features**
3. **Verify all button functionality**
4. **Polish error handling**

### **Long-term (Low Priority)**
1. **Add Google OAuth Client ID**
2. **Enhanced error reporting**
3. **Performance optimization**
4. **Cross-browser testing**

---

*Error tracking started: 2025-09-10 20:57*
*Status: Monitoring active*