# 📒 Notably – A Modern Notes App

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-5B5FEF?style=for-the-badge&logo=riverpod&logoColor=white)
![Material-3](https://img.shields.io/badge/Material%20Design%203-000000?style=for-the-badge&logo=google&logoColor=white)

---

Hello! I'm **Pau**, and this is the repository for **Notably**, a cross-platform notes application inspired by Notion.  
This project was developed using **Flutter**, **Supabase**, and **Riverpod**. It showcases how to build a modern application with authentication, cloud synchronization, and advanced state management.

---

## 📌 Table of Contents

- [🎯 Project Goal](#project-goal)
- [✨ Key Features](#key-features)
- [💻 Technologies & Tools](#technologies--tools)
- [📁 Project Structure](#project-structure)
- [🚀 Getting Started](#getting-started)
- [🛣️ Roadmap](#roadmap)
- [📫 Contact](#contact)

---

## 🎯 Project Goal

To develop a **Notion-like collaborative note-taking application** with real-time editing, workspace organization, and advanced formatting capabilities. This project demonstrates a professional full-stack development approach with modern technologies and scalable architecture suitable for team collaboration and academic use.

---

## ✨ Key Features

### 🔹 Real-time Collaborative Editing
> **Google Docs-style collaboration** with live cursors, instant synchronization, and conflict resolution using **Yjs** and **WebRTC**.

### 🔹 Workspace Organization
> **Subject-based workspaces** for organizing notes by courses, projects, or topics with hierarchical page structure.

### 🔹 Advanced Block-based Editor
> **Notion-style editor** with drag & drop blocks, rich formatting, code blocks, tables, and multimedia support.

### 🔹 Document Export & Sharing
> **Multi-format export** to PDF, Markdown, Word, and HTML with customizable templates and sharing options.

### 🔹 Authentication & Permissions
> **Secure user management** with invitation system, role-based permissions, and collaborative workspace access.

### 🔹 Cross-Platform Experience
> **Responsive design** optimized for Web, Android, and iOS with consistent user experience across devices.

---

## 💻 Technologies & Tools

### Core Stack
- **Flutter & Dart** → Cross-platform UI framework and programming language
- **Supabase** → Backend-as-a-Service (Auth, Database, Realtime, Storage)
- **Riverpod** → Advanced state management with dependency injection

### Collaboration & Real-time
- **Yjs** → Conflict-free replicated data types for collaborative editing
- **WebRTC** → Peer-to-peer communication for real-time collaboration
- **Supabase Realtime** → WebSocket-based real-time synchronization

### UI & Editor
- **Material Design 3** → Modern and adaptive UI design system
- **Custom Block Editor** → Notion-inspired modular content blocks
- **Flutter Quill** → Rich text editing foundation

### Export & Integration
- **PDF Generation** → Document export with custom styling
- **Markdown Support** → Import/export compatibility
- **File System Access** → Cross-platform file operations

---

## 📁 Project Structure

```plaintext
NOTABLY/
├── android/            # Android-specific files
├── ios/                # iOS-specific files
├── lib/
│   ├── main.dart       # Application entry point
│   ├── config/         # Configuration files
│   │   └── supabase_config.dart
│   ├── pages/          # Individual screens (e.g., Auth, Home, Editor)
│   ├── models/         # Data models (e.g., Note, User)
│   ├── providers/      # Riverpod providers for managing app state
│   ├── services/       # Logic for Supabase communication
│   └── widgets/        # Reusable UI components
├── test/               # Unit and widget tests
├── web/                # Web-specific files
├── assets/             # Assets like images, fonts, and icons
├── pubspec.yaml        # Project dependencies and metadata
├── SETUP.md            # Detailed setup instructions
└── README.md
```

## 🚀 Getting Started

Follow these steps to set up and run the project locally.

### Prerequisites
- **Flutter SDK** (3.8.1 or higher)
- A **Supabase** project with **Email Auth** enabled
- A `notes` table configured with proper RLS policies

### Quick Setup
1. **Clone the repository:**
   ```bash
   git clone https://github.com/paulopnun/notably.git
   cd notably
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase:**
   - Follow the detailed instructions in [SETUP.md](./SETUP.md)
   - Update `lib/config/supabase_config.dart` with your credentials

4. **Run the application:**
   ```bash
   flutter run
   ```
   Choose your desired platform (e.g., Chrome, Android, iOS).

### Detailed Setup
For comprehensive setup instructions, including database schema and Supabase configuration, see [SETUP.md](./SETUP.md).

---

## 🛣️ Roadmap

### ✅ Phase 1: Foundation (Completed)
- [x] **Basic Authentication:** Supabase Auth with email/password login
- [x] **Persistent Sessions:** Automatic session restoration
- [x] **Basic Note CRUD:** Create, read, update, delete operations
- [x] **Rich Text Editor:** Flutter Quill integration
- [x] **Cloud Synchronization:** Supabase Database integration
- [x] **Material Design 3:** Modern UI foundation
- [x] **State Management:** Riverpod provider architecture

### 🚧 Phase 2: Real-time Collaboration (In Progress)
- [x] **Collaborative Editor Service:** Real-time sync with Operational Transformation *(Implemented)*
- [x] **Live Cursors:** Real-time cursor positions and user presence *(Implemented)*
- [x] **Conflict Resolution:** Automatic merge of concurrent edits *(Implemented)*
- [x] **Invitation System:** Invite collaborators to documents *(Implemented)*
- [x] **Permission Management:** Role-based access control with RLS *(Implemented)*
- [x] **Database Schema:** Tables for operations, collaborators, and presence *(Implemented)*
- [ ] **WebRTC Communication:** Peer-to-peer real-time sync *(Not Implemented)*

### 🚧 Phase 3: Advanced Editor (In Progress)
- [x] **Block-based Architecture:** Notion-style modular content blocks *(Implemented)*
- [x] **Factory Pattern:** Extensible widget factory for all block types *(Implemented)*
- [x] **Text & Heading Blocks:** Paragraph and heading blocks with styling *(Implemented)*
- [x] **Slash Commands:** Quick block insertion with "/" commands and search *(Implemented)*
- [x] **Block Selection:** Visual selection and action menus *(Implemented)*
- [x] **Image Blocks:** Image upload, display, and caption support *(Implemented)*
- [x] **Page Editor:** Complete Notion-like page editing experience *(Implemented)*
- [ ] **Drag & Drop:** Reorder blocks with intuitive interactions *(Not Implemented)*
- [ ] **Advanced Blocks:** Tables, code blocks, callouts, embeds *(Partially Implemented)*
- [ ] **Templates:** Pre-built page templates for different use cases *(Not Implemented)*

### 🚧 Phase 4: Workspace Organization (In Progress)
- [x] **Subject Workspaces:** Organize by courses/projects with custom icons *(Implemented)*
- [x] **Academic Templates:** Pre-built templates for different subjects *(Implemented)*
- [x] **Workspace Navigation:** Sidebar with hierarchical navigation *(Implemented)*
- [x] **Page Management:** Create, organize, and manage pages within workspaces *(Implemented)*
- [x] **Template System:** Templates for Math, Science, History, Literature, etc. *(Implemented)*
- [x] **Modern Interface:** Clean, organized workspace-based layout *(Implemented)*
- [ ] **Hierarchical Pages:** Nested page structure with breadcrumbs *(Partially Implemented)*
- [ ] **Search & Filter:** Advanced search across all content *(Not Implemented)*
- [ ] **Favorites & Recent:** Quick access to important content *(Not Implemented)*

### ✅ Phase 5: Export & Integration (Completed)
- [x] **PDF Export:** High-quality PDF generation with multiple themes *(Implemented)*
- [x] **Markdown Export:** Standard markdown compatibility with metadata *(Implemented)*
- [x] **HTML Export:** Static website generation with CSS themes *(Implemented)*
- [x] **Plain Text Export:** Simple text format for universal compatibility *(Implemented)*
- [x] **JSON Export:** Structured data export for backup and migration *(Implemented)*
- [x] **Export Dialog:** User-friendly interface with format options *(Implemented)*
- [x] **File Sharing:** Share exported files via platform share sheet *(Implemented)*
- [x] **Print Support:** Direct printing of pages with proper formatting *(Implemented)*
- [ ] **Bulk Export:** Export entire workspaces *(Partially Implemented)*
- [ ] **Import Tools:** Import from other note-taking apps *(Not Implemented)*

### 🎨 Phase 6: Polish & Performance (Planned)
- [ ] **Dark/Light Themes:** Customizable appearance *(Not Implemented)*
- [ ] **Offline Support:** Local caching and sync *(Not Implemented)*
- [ ] **Performance Optimization:** Lazy loading and caching *(Not Implemented)*
- [ ] **Mobile Optimization:** Touch-friendly interactions *(Not Implemented)*
- [ ] **Keyboard Shortcuts:** Power user productivity features *(Not Implemented)*
- [ ] **Accessibility:** Screen reader and keyboard navigation support *(Not Implemented)*

---

## 🎨 Screenshots

*Coming soon - Screenshots of the app in action*

---

## 🧪 Testing

Run the test suite to ensure everything works correctly:

```bash
flutter test
```

---

## 📱 Supported Platforms

- ✅ **Web** - Chrome, Firefox, Safari, Edge
- ✅ **Android** - API 21+ (Android 5.0+)
- ✅ **iOS** - iOS 11.0+
- 🔄 **Windows** - In development
- 🔄 **macOS** - In development
- 🔄 **Linux** - In development

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Guidelines
1. Follow the existing code style
2. Add tests for new functionality
3. Ensure all tests pass
4. Update documentation as needed

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📫 Contact

**Pau López Núñez**  
📧 [paulopnun@gmail.com](mailto:paulopnun@gmail.com)  
🔗 [GitHub](https://github.com/paulopnun) • [LinkedIn](https://www.linkedin.com/in/paulopnun)

---

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Supabase Team** for the excellent backend service
- **Riverpod Team** for the powerful state management solution
- **Flutter Quill Team** for the rich text editor

---

**Thank you for visiting this repository!** 🎉

If you find this project helpful, please consider giving it a ⭐ star!