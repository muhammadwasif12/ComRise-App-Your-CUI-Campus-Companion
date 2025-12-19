# ComRise CUI - Clean Architecture Structure

## 📁 Project Structure

│   │   └── theme_text_styles.dart     # Typography styles
│   ├── utils/                         # Utility functions and helpers
│   │   ├── constants.dart             # App-wide constants
│   │   ├── grade_utils.dart           # Grade calculation utilities
│   │   └── semester_helper.dart       # Semester management helpers
│   └── widgets/                       # Shared reusable widgets
│
├── features/                          # Feature modules (bounded contexts)
│   ├── about/                         # About screen feature
│   ├── assignment/                    # Assignment management feature
│   ├── auth/                          # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── views/
│   │       │   ├── login_screen.dart
│   │       │   └── register_screen.dart
│   │       └── widgets/
│   ├── cgpa/                          # CGPA Calculator feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── cgpa_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── course_model.dart
│   │   │   │   └── semester_model.dart
│   │   │   └── repositories/
│   │   │       └── cgpa_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── course.dart
│   │   │   │   └── semester.dart
│   │   │   └── repositories/
│   │   │       └── cgpa_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── cgpa_provider.dart
│   │       ├── views/
│   │       │   ├── cgpa_calculator_screen.dart
│   │       │   ├── cgpa_hub_screen.dart
│   │       │   ├── cgpa_tracker_screen.dart
│   │       │   ├── gpa_calculator_screen.dart
│   │       │   ├── gpa_planning_calculator_screen.dart
│   │       │   ├── internal_marks_calculator_screen.dart
│   │       │   └── merit_calculator_screen.dart
│   │       └── widgets/
│   │           ├── calculator_card.dart
│   │           └── cgpa_overview_card.dart
│   ├── class_diary/                   # Lectures diary feature
│   ├── datesheet_timetable/           # Datesheet and timetable feature
│   ├── home/                          # Home screen feature
│   │   └── presentation/
│   │       ├── views/
│   │       │   └── home_screen.dart
│   │       └── widgets/
│   │           ├── calculator_card.dart
│   │           ├── cgpa_home_card.dart
│   │           ├── daily_motivation_widget.dart
│   │           ├── feature_card.dart
│   │           ├── header_widget.dart
│   │           └── quick_access_section.dart
│   ├── motivation_uni_tips/           # Motivation and university tips
│   ├── notifications/                 # Notifications feature
│   ├── profile_settings/              # Profile and settings
│   ├── roadmap/                       # Academic roadmap feature
│   ├── self_chat/                     # Self-chat feature
│   └── splash/                        # Splash screen
│
└── main.dart                          # App entry point
```

## 🏗️ Architecture Layers

### 1. **Data Layer** (`data/`)
- **Responsibility**: Handles data operations and external data sources
- **Components**:
  - `datasources/`: Local (SQLite) and remote (API) data sources
  - `models/`: Data models with JSON serialization
  - `repositories/`: Implementation of repository interfaces

### 2. **Domain Layer** (`domain/`)
- **Responsibility**: Contains business logic and rules
- **Components**:
  - `entities/`: Plain Dart objects representing business entities
  - `repositories/`: Repository interfaces (contracts)
  - `usecases/`: Business use cases (optional, for complex operations)

### 3. **Presentation Layer** (`presentation/`)
- **Responsibility**: UI and user interaction
- **Components**:
  - `providers/`: State management using Riverpod
  - `views/`: Screen/page widgets
  - `widgets/`: Reusable UI components specific to the feature

## 🎯 Key Principles

1. **Dependency Rule**: Dependencies point inward (Presentation → Domain ← Data)
2. **Single Responsibility**: Each layer has one reason to change
3. **Dependency Inversion**: High-level modules don't depend on low-level modules
4. **Feature-First Organization**: Code organized by feature/module, not by type
5. **Consistent Naming**: lowercase_with_underscores for folders and files

## 📝 Naming Conventions

- **Folders**: `lowercase_with_underscores`
- **Files**: `lowercase_with_underscores.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE` or `camelCase` for private

## 🔄 Data Flow

```
User Interaction (View)
    ↓
Provider (ViewModel)
    ↓
Repository Interface (Domain)
    ↓
Repository Implementation (Data)
    ↓
DataSource (Local/Remote)
    ↓
External Data (SQLite/API)
```

## 🚀 Benefits of This Structure

1. **Testability**: Easy to write unit tests for each layer independently
2. **Maintainability**: Clear separation makes code easier to understand and modify
3. **Scalability**: Adding new features doesn't affect existing code
4. **Reusability**: Shared code in `core/` can be used across features
5. **Team Collaboration**: Multiple developers can work on different features simultaneously

## 📦 Feature Template

When adding a new feature, follow this structure:

```
features/
└── new_feature/
    ├── data/
    │   ├── datasources/
    │   │   └── new_feature_local_datasource.dart
    │   ├── models/
    │   │   └── new_feature_model.dart
    │   └── repositories/
    │       └── new_feature_repository_impl.dart
    ├── domain/
    │   ├── entities/
    │   │   └── new_feature_entity.dart
    │   └── repositories/
    │       └── new_feature_repository.dart
    └── presentation/
        ├── providers/
        │   └── new_feature_provider.dart
        ├── views/
        │   └── new_feature_screen.dart
        └── widgets/
            └── new_feature_widget.dart
```

## 🔍 Notes

- All code has been reorganized without modification
- Import statements may need to be updated to reflect new file locations
- This structure follows industry best practices for Flutter applications
- Uses Riverpod for state management
- Database operations handled through repository pattern

---

**Last Updated**: December 1, 2025
**Architecture**: MVVM Clean Architecture
**State Management**: Riverpod 2.0+
