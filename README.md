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

To develop a simplified yet powerful note-taking app that demonstrates a professional and scalable architecture. This project serves as a comprehensive portfolio piece, highlighting a modern full-stack development approach.

---

## ✨ Key Features

### 🔹 Authentication and Sessions
> User registration, login, and persistent sessions handled by **Supabase Auth**.

### 🔹 Cloud Synchronization
> Create, edit, and view notes with real-time synchronization using **Supabase Database**.

### 🔹 Rich Text Editor
> Advanced text editing with **Flutter Quill** supporting formatting, lists, quotes, and more.

### 🔹 State Management
> Efficient and predictable application state managed with **Riverpod**.

### 🔹 Cross-Platform Experience
> A single codebase that runs on Web, Android, and iOS.

### 🔹 Modern UI/UX
> Beautiful and intuitive interface built with **Material Design 3**.

---

## 💻 Technologies & Tools

- **Flutter & Dart** → The UI framework and programming language
- **Supabase** → Backend-as-a-Service (Auth, Database, Realtime)
- **Riverpod** → State management solution
- **Flutter Quill** → Rich text editor for note content
- **Material Design 3** → Modern and polished UI design language
- **GitHub** → Version control
- **Visual Studio Code** → Development environment

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

### ✅ Completed Features
- [x] **Basic Authentication:** Implement login and registration with Supabase Auth
- [x] **Persistent Sessions:** Maintain user login status between app restarts
- [x] **Note Creation:** Allow authenticated users to create and save notes
- [x] **Note Editing:** Implement a rich text editor for modifying notes
- [x] **Note Management:** View, edit, and delete notes with proper error handling
- [x] **Cloud Sync:** Real-time synchronization with Supabase Database
- [x] **Modern UI:** Beautiful interface with Material Design 3
- [x] **State Management:** Efficient state handling with Riverpod

### 🚧 In Progress
- [ ] **Enhanced Editor:** More formatting options and better UX
- [ ] **Search Functionality:** Robust search across all user notes
- [ ] **Performance Optimization:** Better loading states and caching

### 🔮 Future Features
- [ ] **Real-time Collaboration:** Enable multiple users to edit the same note
- [ ] **Workspaces:** Add shared spaces for collaborative note-taking
- [ ] **Advanced Formatting:** Tables, code blocks, and media embedding
- [ ] **Offline Support:** Local caching and offline editing
- [ ] **Export Options:** PDF, Markdown, and other export formats
- [ ] **Themes:** Dark mode and customizable color schemes
- [ ] **Mobile Features:** Push notifications and mobile-specific optimizations

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