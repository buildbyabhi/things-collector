# Things Collector

A secure, private vault for storing and managing your "Things" (links, articles, and videos). Built as a Progressive Web App (PWA) using Flutter and Firebase.

🌍 **Live Demo:** [https://things-collector.web.app](https://things-collector.web.app)

---

## 🚀 How I Built This

This project was built from scratch using a modern tech stack to ensure it was fast, secure, and cross-platform. Here is an overview of the development process:

### 1. The Foundation: Flutter & Dart
I chose **Flutter** and **Dart** for the frontend because they allow for a beautiful, responsive UI that compiles directly to Web, iOS, and Android from a single codebase. I implemented a modern "glassmorphism" aesthetic with a dark theme, utilizing rich gradients and blurred background containers to make the app feel premium.

### 2. Backend & Database: Firebase
Instead of managing a traditional server, I integrated **Firebase** to handle the backend architecture:
- **Firebase Hosting:** Used to deploy the Web version as an installable PWA.
- **Cloud Firestore:** A real-time NoSQL database used to store the items instantly.

### 3. Smart Metadata Extraction
To make adding "Things" effortless, I didn't want users to have to type out titles or upload cover images manually. I integrated the `metadata_fetch` package. When a URL is pasted, the app automatically scrapes the Open Graph (OG) HTML tags from the website, instantly grabbing the title, description, and thumbnail image.

### 4. Security & Authentication
Since this is a private vault, security was paramount:
- **Firebase Auth:** I implemented a complete authentication flow, supporting both **Email/Password** and **Google Sign-In**.
- **Firestore Security Rules:** I wrote strict database rules (`firestore.rules`) so that data is scoped entirely to the logged-in user. A user's data is stored in `/users/{userId}/things/`, making it strictly impossible for unauthorized visitors to read or write another user's private vault items.

---

## 🛠 Tech Stack
- **Frontend:** [Flutter](https://flutter.dev) (Web)
- **Backend:** [Firebase](https://firebase.google.com) (Auth, Firestore, Hosting)
- **Languages:** Dart

## 💻 Setup & Running Locally
1. Clone this repository.
2. Run `flutter pub get` to install dependencies.
3. Connect your own Firebase Project by running `flutterfire configure`.
4. Run the app using `flutter run -d chrome`.
