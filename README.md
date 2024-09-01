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
- Firebase Setup:

  - Set up Firebase for your project and add the google-services.json (for Android) and GoogleService-Info.plist (for iOS) to the appropriate directories.
  - Ensure that Firestore, Authentication, and other Firebase services are properly configured in your Firebase console.

## Credits
- @stanleman, @ThatFit3, @jia-jjin
