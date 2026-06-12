# Things Collector

A secure, private vault for storing and managing your "Things". Built as a Progressive Web App (PWA) using Flutter and Firebase.

🌍 **Live Demo:** [https://things-collector.web.app](https://things-collector.web.app)

## Features
- **Secure Authentication:** User accounts protected via Firebase Authentication (Google Sign-In & Email/Password).
- **Private Data Vault:** Cloud Firestore database with strict security rules ensuring that only the authenticated owner can view or modify their data.
- **Rich Metadata Extraction:** Automatically fetches titles, descriptions, and cover images from URLs using the `metadata_fetch` package.
- **Cross-Platform:** Built with Flutter, fully optimized for Web and mobile browsers as an installable PWA.

## Tech Stack
- **Frontend:** [Flutter](https://flutter.dev) (Web)
- **Backend:** [Firebase](https://firebase.google.com) (Auth, Firestore, Hosting)
- **Languages:** Dart

## Setup & Running Locally
1. Clone this repository.
2. Run `flutter pub get` to install dependencies.
3. Connect your own Firebase Project by running `flutterfire configure`.
4. Run the app using `flutter run -d chrome`.
