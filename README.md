# in-side

**Load Web (HTML/JS/CSS) Apps within a Native Mobile App**

`in-side` is a beautifully designed Flutter application that serves as a seamless environment for running standalone HTML, JS, and CSS applications directly on your mobile device. Built with a stunning Glassmorphism UI, it provides a highly polished, aesthetic shell to load your custom web-based tools and features.

## 🎯 Use Cases

A prime example use case for `in-side` is quickly generating and deploying **custom apps** with HTTP GET and POST capabilities. This allows you to give powerful, specialized data-driven features to complementary existing apps without needing to build and compile entirely new native mobile applications.

- **Fast Iteration:** Write an HTML/JS utility in minutes, zip it, and run it fluidly inside of a high-quality native wrapper.
- **Companion Tools:** Build isolated GET/POST data fetchers, form submitters, or search clients utilizing simple web tech.
- **Responsive Layout:** The embedded WebViews run your JavaScript seamlessly alongside local storage.

## ✨ Features

- **Glassmorphism UI:** Stunning, frosted-glass design language with dynamic animations and modern typography (Sora).
- **Easy Import:** Import any web-based application packaged as a `.zip` file right from your device.
- **Robust Integration:** Extracts and securely runs your web technologies locally using `flutter_inappwebview`.
- **App Management:** View imported apps, launch them seamlessly, and remove them using the 3-dot uninstall menu. 
- **Persistent Storage:** Keeps track of imported apps and their metadata (installation dates, names, etc.) persistently.

## 🚀 Getting Started

To get started with the Flutter project:

### Prerequisites

- Flutter SDK (>=3.4.4 <4.0.0)
- Android Studio / Xcode for device emulation

### Installation

1. Clean the project and fetch dependencies:
   ```bash
   flutter clean
   flutter pub get
   ```

2. Run the application:
   ```bash
   flutter run
   ```

3. To build a release APK for Android:
   ```bash
   flutter build apk --release
   ```

## 📦 Creating a Custom Web App

To create an app that works with `in-side`:
1. Build a standard web application (HTML, CSS, JavaScript).
2. Ensure there is an `index.html` at the root of your project directory.
3. Zip the entire folder.
4. Open the `in-side` app, tap the **+** FAB button, and select your `.zip` file!

## 🛠️ Tech Stack

- **Framework:** Flutter (`uses-material-design: true`)
- **Web Engine:** `flutter_inappwebview`
- **File Management:** `archive`, `path_provider`, `file_picker`
- **Styling:** `google_fonts`, custom `GlassTheme` CSS/Dart integration
