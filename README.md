# PSW Journal App
PSW Journal App is a personal journal application built using Flutter and Firebase. It allows users to create, edit, and manage journal entries, including features like searching and filtering entries by content, tags, and date.

## Features
- Authentication: User login and registration using Firebase Authentication.
- Journal Entries: Create, edit, and delete journal entries with titles, content, tags, and locations.
- Search and Filter: Search entries by content, title, tags, or location, and filter by date range.
- Date Grouping: Entries are grouped by month and year for easy navigation.

## Getting Started

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/stanleman/PSW-journal-app.git
   ```

2. Navigate to the project directory:
   ```bash
   cd PSW-journal-app
   ```
   
3. Install dependencies:
   ```bash
   flutter pub get
   ```
   
## Running the App
Run the app:
  ```bash
  flutter run
  ```

## Configuration
1. Firebase Setup:
   - Set up Firebase for your project and add the google-services.json (for Android) and GoogleService-Info.plist (for iOS) to the appropriate directories.
   - Ensure that Firestore, Authentication, and other Firebase services are properly configured in your Firebase console.

2. Use a .env file
  
   ```bash
   # Universal
   STORAGE_BUCKET = your-value
   PROJECT_ID = your-value
   MESSENGER_ID = your-value
   
   # Web / Windows
   WEB_WIN_API_KEY = your-value
   WEB_APP_ID = your-value
   WIN_APP_ID = your-value
   AUTH_DOMAIN = your-value
     
   # Android
   ANDROID_API_KEY = your-value
   ANDROID_APP_ID = your-value
     
   # IOS/MAC
   IOS_MAC_API_KEY = your-value
   IOS_MAC_APP_ID = your-value
   IOS_MAC_BUNDLE_ID = your-value
   ```

## Credits
- [@stanleman](https://github.com/stanleman), [@ThatFit3](https://github.com/ThatFit3), [@jia-jjin](https://github.com/jia-jjin)
