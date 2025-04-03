# Smart Foot Diet App

A Flutter application designed to provide personalized diet recommendations based on foot health metrics. This app uses Firebase for backend services.

## Project Overview

The Smart Foot Diet app helps users track their diet and provides recommendations based on foot health indicators. The app follows a feature-first architecture with clean separation of concerns.

## Tech Stack

- **Frontend**: Flutter
- **State Management**: Riverpod
- **Navigation**: Go Router
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Additional Packages**:
  - `flutter_secure_storage` - For secure data storage
  - `flutter_svg` - For SVG rendering
  - `cached_network_image` - For efficient image loading
  - `flutter_local_notifications` - For local notifications
  - `intl` - For internationalization and formatting

## Project Structure

The project follows a feature-first architecture with Clean Architecture principles:

```
lib/
├── core/                  # Core functionality shared across features
│   ├── constants/         # App-wide constants
│   ├── navigation/        # Routing configuration
│   ├── services/          # Shared services (Firebase, API clients)
│   ├── theme/             # App theming
│   ├── utils/             # Utility functions
│   └── widgets/           # Reusable widgets
│
├── features/              # App features
│   ├── auth/              # Authentication feature
│   │   ├── data/          # Data sources, repositories, models
│   │   ├── domain/        # Business logic, entities
│   │   └── presentation/  # UI components
│   │
│   ├── profile/           # User profile feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── meal_tracking/     # Meal tracking feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── diet_recommendations/  # Diet recommendations feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── foot_health/       # Foot health tracking feature
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── firebase_options.dart  # Firebase configuration
└── main.dart             # App entry point
```

## File Responsibilities

### Core

#### constants/

- `app_constants.dart` - App-wide constants like API endpoints, timeouts
- `asset_paths.dart` - Paths to image, font, and other assets
- `error_messages.dart` - Standardized error messages

#### navigation/

- `app_router.dart` - Go Router configuration and route definitions

#### services/

- `firebase_service.dart` - Firebase interactions (Auth, Firestore, Storage)
- `secure_storage_service.dart` - Secure storage for sensitive data
- `analytics_service.dart` - Usage analytics tracking

#### theme/

- `app_theme.dart` - Theme data and styling
- `app_colors.dart` - Color palette
- `app_text_styles.dart` - Text styling

#### utils/

- `validators.dart` - Form validation functions
- `date_formatters.dart` - Date and time formatting utilities
- `logger.dart` - Logging utility

#### widgets/

- `custom_button.dart` - Reusable button component
- `loading_indicator.dart` - Loading state indicator
- `error_view.dart` - Standard error display component

### Features

#### auth/

- `data/auth_repository.dart` - Authentication repository
- `domain/auth_state.dart` - Auth state entity
- `presentation/login_screen.dart` - Login UI
- `presentation/signup_screen.dart` - Signup UI
- `presentation/auth_view_model.dart` - Auth business logic

#### profile/

- `data/profile_repository.dart` - User profile data repository
- `domain/user_profile.dart` - User profile entity
- `presentation/profile_screen.dart` - Profile UI
- `presentation/edit_profile_screen.dart` - Profile editing UI

#### meal_tracking/

- `data/meal_repository.dart` - Meal data repository
- `domain/meal.dart` - Meal entity
- `presentation/meal_list_screen.dart` - Meal list UI
- `presentation/add_meal_screen.dart` - Add meal UI

#### diet_recommendations/

- `data/recommendation_repository.dart` - Recommendation data source
- `domain/recommendation.dart` - Recommendation entity
- `presentation/recommendations_screen.dart` - Recommendation display UI

#### foot_health/

- `data/foot_health_repository.dart` - Foot health data repository
- `domain/foot_metrics.dart` - Foot health metrics entity
- `presentation/foot_metrics_screen.dart` - Foot metrics input/display UI

### Firebase Configuration

- `firebase_options.dart` - Generated Firebase configuration
- `main.dart` - App initialization with Firebase setup

## Setup Instructions

1. Ensure Flutter is installed and set up
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Enable Firebase Authentication in the Firebase Console
5. Run the app with `flutter run`

## Development Guidelines

1. **Feature Development**:

   - Create new features in the `features` directory following the existing pattern
   - Maintain separation between data, domain, and presentation layers

2. **State Management**:

   - Use Riverpod for state management
   - Create providers in appropriate feature modules

3. **Code Style**:

   - Follow Flutter's style guide
   - Use meaningful variable and method names
   - Document complex logic with comments
