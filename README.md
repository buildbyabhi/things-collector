# Things Collector

A secure, private vault for storing and managing your "Things" (links, articles, ideas, and screenshots). Built as a Progressive Web App (PWA) using Flutter and Firebase.

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

### 3. Cost-Effective Storage Architecture
To keep the app strictly within the 100% free limits of Firebase (and avoid Paid Firebase Storage buckets), I designed a custom architecture for image uploads:
- **Base64 Encoding:** Uploaded images are converted directly into massive strings of text and stored inside the free Firestore text database.
- **On-Device Compression:** Since Firestore has a hard limit of 1 Megabyte per document, I injected the Dart `image` compression engine. Before the image is turned into text, it is resized to a maximum width of 600 pixels and heavily compressed into a highly efficient JPEG. This shrinks a massive 3MB screenshot down to ~60KB instantly!

### 4. Smart Metadata Extraction
When a URL is pasted, the app automatically scrapes the Open Graph (OG) HTML tags from the website using the `metadata_fetch` package, instantly grabbing the title, description, and thumbnail image so users don't have to type it manually.

### 5. Web Platform Integrity
Web browsers (like Chrome/Safari) aggressively block file-picker popups when triggered from inside custom dialogs. To solve this, I implemented `image_picker_web`, which injects a native invisible `<input type="file">` HTML tag directly under the user's cursor pointer, tricking the browser into bypassing 100% of popup blockers.

### 6. Premium UI Features
The app includes several premium mobile-like interactions:
- **Hero Animations:** Tapping an item's image detaches it from the card and smoothly flies it across the screen to expand into the Details page.
- **Live Search & Filtering:** A real-time search engine that instantly filters the collection by title, subtitle, and category.
- **Pull-To-Refresh:** Mobile-native tactile feedback for refreshing the feed.
- **Data Export:** A custom engine using `dart:html` that compiles the entire database (including base64 images) into a downloadable `my_things_backup.json` file.

### 7. Security & Authentication
- **Firebase Auth:** Complete authentication flow supporting Google Sign-In.
- **Firestore Security Rules:** Strict rules ensuring that data is scoped entirely to the logged-in user. A user's data is stored in `/users/{userId}/things/`, making it strictly impossible for unauthorized visitors to access another user's private vault items.

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
