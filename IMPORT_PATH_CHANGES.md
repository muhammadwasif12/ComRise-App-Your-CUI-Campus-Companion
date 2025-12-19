# Quick Reference: Import Path Changes

This file lists the OLD vs NEW import paths for all moved files.
Use Find & Replace in your IDE to update imports quickly.

## Core Files

### Navigation (formerly routes)
```dart
# OLD
import 'package:comrise_cui/core/routes/app_routes.dart';
import 'package:comrise_cui/core/routes/assignment_routes.dart';
// ... other routes

# NEW (App Routes)
import 'package:comrise_cui/core/routing/app_routes.dart';

# NEW (Feature Routes)
import 'package:comrise_cui/features/assignment/presentation/routes/assignment_routes.dart';
import 'package:comrise_cui/features/cgpa/presentation/routes/cgpa_routes.dart';
// ... check specific feature folders for other routes
```

### Providers
```dart
# OLD
import 'package:comrise_cui/core/providers/database_helper_provider.dart';

# NEW (For Database Helper)
import 'package:comrise_cui/core/providers/database_helper_provider.dart';

# NEW (For Auth Providers)
import 'package:comrise_cui/features/auth/presentation/providers/auth_di_providers.dart';
```

## Feature Files

### About Feature
```dart
# OLD
import 'package:comrise_cui/features/About/presentation/views/about_screen.dart';

# NEW
import 'package:comrise_cui/features/about/presentation/views/about_screen.dart';
```

### Assignment Feature
```dart
# OLD
import 'package:comrise_cui/features/Assignment/presentation/views/assignment_builder_screen.dart.dart';

# NEW
import 'package:comrise_cui/features/assignment/presentation/views/assignment_builder_screen.dart';
```

### CGPA Feature
```dart
# OLD
import 'package:comrise_cui/features/Cgpa/data/datasources/cgpa_local_datasource.dart';
import 'package:comrise_cui/features/Cgpa/data/models/course_model.dart';
import 'package:comrise_cui/features/Cgpa/data/models/semester_model.dart';
import 'package:comrise_cui/features/Cgpa/data/repositories/cgpa_repository_impl.dart';
import 'package:comrise_cui/features/Cgpa/domain/entities/course.dart';
import 'package:comrise_cui/features/Cgpa/domain/entities/semester.dart';
import 'package:comrise_cui/features/Cgpa/domain/repositories/cgpa_repository.dart';
import 'package:comrise_cui/features/Cgpa/presentation/providers/cgpa_provider.dart';
import 'package:comrise_cui/features/Cgpa/presentation/views/cgpa_calculator_screen.dart';
import 'package:comrise_cui/features/Cgpa/presentation/views/cgpa_hub_screen.dart';
import 'package:comrise_cui/features/Cgpa/presentation/views/cgpa_tracker_screen.dart';
import 'package:comrise_cui/features/Cgpa/presentation/views/gpa_calculator_screen.dart';
import 'package:comrise_cui/features/Cgpa/presentation/views/gpa_planning_calculator_screen.dart';
import 'package:comrise_cui/features/Cgpa/presentation/views/internal_marks_calculator_screen.dart';
import 'package:comrise_cui/features/Cgpa/presentation/views/merit_calculator_screen.dart';
import 'package:comrise_cui/features/Cgpa/presentation/widgets/calculator_card.dart';
import 'package:comrise_cui/features/Cgpa/presentation/widgets/cgpa_overview_card.dart';

# NEW
import 'package:comrise_cui/features/cgpa/data/datasources/cgpa_local_datasource.dart';
import 'package:comrise_cui/features/cgpa/data/models/course_model.dart';
import 'package:comrise_cui/features/cgpa/data/models/semester_model.dart';
import 'package:comrise_cui/features/cgpa/data/repositories/cgpa_repository_impl.dart';
import 'package:comrise_cui/features/cgpa/domain/entities/course.dart';
import 'package:comrise_cui/features/cgpa/domain/entities/semester.dart';
import 'package:comrise_cui/features/cgpa/domain/repositories/cgpa_repository.dart';
import 'package:comrise_cui/features/cgpa/presentation/providers/cgpa_provider.dart';
import 'package:comrise_cui/features/cgpa/presentation/views/cgpa_calculator_screen.dart';
import 'package:comrise_cui/features/cgpa/presentation/views/cgpa_hub_screen.dart';
import 'package:comrise_cui/features/cgpa/presentation/views/cgpa_tracker_screen.dart';
import 'package:comrise_cui/features/cgpa/presentation/views/gpa_calculator_screen.dart';
import 'package:comrise_cui/features/cgpa/presentation/views/gpa_planning_calculator_screen.dart';
import 'package:comrise_cui/features/cgpa/presentation/views/internal_marks_calculator_screen.dart';
import 'package:comrise_cui/features/cgpa/presentation/views/merit_calculator_screen.dart';
import 'package:comrise_cui/features/cgpa/presentation/widgets/calculator_card.dart';
import 'package:comrise_cui/features/cgpa/presentation/widgets/cgpa_overview_card.dart';
```

### Class Diary Feature
```dart
# OLD
import 'package:comrise_cui/features/ClassDiary/presentation/views/lectures_diary.dart';
import 'package:comrise_cui/features/ClassDiary/widgets/calculator_card.dart';

# NEW
import 'package:comrise_cui/features/class_diary/presentation/views/lectures_diary.dart';
import 'package:comrise_cui/features/class_diary/presentation/widgets/calculator_card.dart';
```

### Datesheet/Timetable Feature
```dart
# OLD
import 'package:comrise_cui/features/Datesheet_Timetable/presentation/views/datesheet_screen.dart';
import 'package:comrise_cui/features/Datesheet_Timetable/widgets/calculator_card.dart';

# NEW
import 'package:comrise_cui/features/datesheet_timetable/presentation/views/datesheet_screen.dart';
import 'package:comrise_cui/features/datesheet_timetable/presentation/widgets/calculator_card.dart';
```

### Home Feature
```dart
# OLD
import 'package:comrise_cui/features/Home/presentation/views/home_screen.dart';
import 'package:comrise_cui/features/Home/presentation/widgets/calculator_card.dart';
import 'package:comrise_cui/features/Home/presentation/widgets/cgpa_home_card.dart';
import 'package:comrise_cui/features/Home/presentation/widgets/daily_motivation_widget.dart';
import 'package:comrise_cui/features/Home/presentation/widgets/feature_card.dart';
import 'package:comrise_cui/features/Home/presentation/widgets/header_widget.dart';
import 'package:comrise_cui/features/Home/presentation/widgets/quick_access_section.dart';

# NEW
import 'package:comrise_cui/features/home/presentation/views/home_screen.dart';
import 'package:comrise_cui/features/home/presentation/widgets/calculator_card.dart';
import 'package:comrise_cui/features/home/presentation/widgets/cgpa_home_card.dart';
import 'package:comrise_cui/features/home/presentation/widgets/daily_motivation_widget.dart';
import 'package:comrise_cui/features/home/presentation/widgets/feature_card.dart';
import 'package:comrise_cui/features/home/presentation/widgets/header_widget.dart';
import 'package:comrise_cui/features/home/presentation/widgets/quick_access_section.dart';
```

### Motivation/Uni Tips Feature
```dart
# OLD
import 'package:comrise_cui/features/MotivationUniTips/presentation/views/uni_tips_screen.dart';

# NEW
import 'package:comrise_cui/features/motivation_uni_tips/presentation/views/uni_tips_screen.dart';
```

### Notifications Feature
```dart
# OLD
import 'package:comrise_cui/features/Notifications/presentation/views/notifications_screen.dart';

# NEW
import 'package:comrise_cui/features/notifications/presentation/views/notifications_screen.dart';
```

### Profile/Settings Feature
```dart
# OLD
import 'package:comrise_cui/features/Profile_Settings/presentation/views/profile_screen.dart';

# NEW
import 'package:comrise_cui/features/profile_settings/presentation/views/profile_screen.dart';
```

### Roadmap Feature
```dart
# OLD
import 'package:comrise_cui/features/Roadmap/presentation/views/roadmap_screen.dart';

# NEW
import 'package:comrise_cui/features/roadmap/presentation/views/roadmap_screen.dart';
```

### Self Chat Feature
```dart
# OLD
import 'package:comrise_cui/features/SelfChat/presentation/views/selfchat_screen.dart';

# NEW
import 'package:comrise_cui/features/self_chat/presentation/views/selfchat_screen.dart';
```

### Splash Feature
```dart
# OLD
import 'package:comrise_cui/features/Splash/presentation/views/splash_screen.dart';

# NEW
import 'package:comrise_cui/features/splash/presentation/views/splash_screen.dart';
```

---

## Find & Replace Instructions (VS Code)

1. Press `Ctrl+Shift+H` (or `Cmd+Shift+H` on Mac) to open Find & Replace
2. Click the `.*` icon to enable regex mode
3. Use this pattern to replace all at once:

**Find:**
```regex
package:comrise_cui/core/routes/
```
**Replace:**
```
package:comrise_cui/core/routing/
```
*(Note: For feature specific routes, you'll need to update to `package:comrise_cui/features/[feature]/presentation/routes/`)*

**Find:**
```regex
package:comrise_cui/features/(About|Assignment|Cgpa|ClassDiary|Datesheet_Timetable|Home|MotivationUniTips|Notifications|Profile_Settings|Roadmap|SelfChat|Splash)/
```
**Replace (requires manual adjustment for each):**
```
package:comrise_cui/features/[lowercase_version]/
```

Or do individual replacements:
- `features/About/` → `features/about/`
- `features/Assignment/` → `features/assignment/`
- `features/Cgpa/` → `features/cgpa/`
- `features/ClassDiary/` → `features/class_diary/`
- `features/Datesheet_Timetable/` → `features/datesheet_timetable/`
- `features/Home/` → `features/home/`
- `features/MotivationUniTips/` → `features/motivation_uni_tips/`
- `features/Notifications/` → `features/notifications/`
- `features/Profile_Settings/` → `features/profile_settings/`
- `features/Roadmap/` → `features/roadmap/`
- `features/SelfChat/` → `features/self_chat/`
- `features/Splash/` → `features/splash/`

Also fix the double extension:
- `assignment_builder_screen.dart.dart` → `assignment_builder_screen.dart`

---

## After Updating Imports

Run these commands:
```bash
flutter clean
flutter pub get
flutter analyze
flutter run
```

This will help identify any remaining import issues.
