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

### 🔹 State Management
> Efficient and predictable application state managed with **Riverpod**.

### 🔹 Cross-Platform Experience
> A single codebase that runs on Web, Android, and iOS.

---

## 💻 Technologies & Tools

- **Flutter & Dart** → The UI framework and programming language
- **Supabase** → Backend-as-a-Service (Auth, Database, Realtime)
- **Riverpod** → State management solution
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
│   ├── pages/          # Individual screens (e.g., Auth, Home, Editor)
│   ├── models/         # Data models (e.g., Note, User)
│   ├── providers/      # Riverpod providers for managing app state
│   ├── services/       # Logic for Supabase communication
│   └── widgets/        # Reusable UI components
├── test/               # Unit and widget tests
├── web/                # Web-specific files
├── assets/             # Assets like images, fonts, and icons
├── pubspec.yaml        # Project dependencies and metadata
└── README.md
```

## 🚀 Getting Started
Follow these steps to set up and run the project locally.

### Prerequisites
- **Flutter SDK**
- A **Supabase** project with **Email Auth** enabled and a `notes` table configured.

### Installation
1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/paulopnun/notably.git](https://github.com/paulopnun/notably.git)
    cd notably
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Configure Supabase Credentials:**
    - Replace the `supabaseUrl` and `supabaseAnonKey` placeholders in `lib/main.dart` with your actual keys.
4.  **Run the application:**
    ```bash
    flutter run
    ```
    Choose your desired platform (e.g., Chrome, Android, iOS).

---

## 🛣️ Roadmap
- [x] **Basic Authentication:** Implement login and registration.
- [x] **Persistent Sessions:** Maintain user login status between app restarts.
- [ ] **Note Creation:** Allow authenticated users to create and save notes.
- [ ] **Note Editing:** Implement a rich text editor for modifying notes.
- [ ] **Real-time Collaboration:** Enable multiple users to edit the same note simultaneously.
- [ ] **Workspaces:** Add a feature to create shared spaces for notes.
- [ ] **Search:** Implement a robust search function across all user notes.

---

## 📫 Contact
**Pau López Núñez** [📧 paulopnun@gmail.com](mailto:paulopnun@gmail.com)  
[🔗 GitHub](https://github.com/paulopnun) • [🔗 LinkedIn](https://www.linkedin.com/in/paulopnun)

---

**Thank you for visiting this repository!**