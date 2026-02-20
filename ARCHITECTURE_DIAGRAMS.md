# Architecture Refactorisée - Diagrammes

## 📊 1. Structure des couches

```
┌─────────────────────────────────────────────────────────┐
│                     UI LAYER (Screens)                   │
│  LoginScreen  ProfileScreen  ChatScreen  AuthGate       │
└──────────────────────────┬──────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────┐
│           VIEW MODEL LAYER (Business Logic)              │
│                                                          │
│  ProfileViewModel (avec ChangeNotifier)                 │
│  - loadProfile()                                         │
│  - saveProfile()                                         │
│  - updateUsername()                                      │
│  - etc.                                                  │
└──────────────────────────┬──────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────┐
│              SERVICE LAYER (Core Services)               │
│                                                          │
│  AuthService  │  AIService  │  TTSService               │
│  (Singleton via ServiceLocator)                         │
└──────────────────────────┬──────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────┐
│            DATA LAYER (Supabase, APIs)                   │
│                                                          │
│  Supabase Client  │  Storage  │  Auth  │  Database      │
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 2. Data Flow - Exemple: Sauvegarder le profil

```
1. UI (ProfileScreen)
   └─> User clicks "Enregistrer"
       └─> _save() called

2. Validation Layer
   └─> ValidationHelper.validateUsername()
   └─> ValidationHelper.validateObjective()
   └─> ValidationHelper.validateModeSelection()
       └─> If errors, show SnackBar

3. ViewModel (ProfileViewModel)
   └─> updateUsername(value)
   └─> updateTargetLevel(value)
   └─> saveProfile()

4. Service Layer (AuthService)
   └─> uploadAvatar() [if new avatar]
   └─> updateProfile() [persister to Supabase]

5. Error Handling (ErrorHandler)
   └─> If error, translate to user message
   └─> Show SnackBar with readable message

6. Success
   └─> notifyListeners() [ChangeNotifier]
   └─> UI rebuilds with new state
```

---

## 📦 3. Architecture en résumé

```
┌─── CORE MODULE ───────────────────────────┐
│                                            │
│  ┌─ constants.dart ────────────────────┐ │
│  │ • AppConstants                      │ │
│  │ • AppDimensions                     │ │
│  │ • RegexPatterns                     │ │
│  └─────────────────────────────────────┘ │
│                                            │
│  ┌─ validation_helper.dart ────────────┐ │
│  │ • validateEmail()                   │ │
│  │ • validatePassword()                │ │
│  │ • validateUsername()                │ │
│  │ • validateObjective()               │ │
│  └─────────────────────────────────────┘ │
│                                            │
│  ┌─ error_handler.dart ────────────────┐ │
│  │ • handleError()                     │ │
│  │ • _handleAuthError()                │ │
│  │ • _handleStorageError()             │ │
│  │ • _handleDatabaseError()            │ │
│  └─────────────────────────────────────┘ │
│                                            │
│  ┌─ service_locator.dart ──────────────┐ │
│  │ • setupServiceLocator()             │ │
│  │ • ServiceLocator (class helper)     │ │
│  └─────────────────────────────────────┘ │
│                                            │
└────────────────────────────────────────────┘

┌─── SCREENS / VIEW MODELS ─────────────────┐
│                                            │
│  ProfileScreen                             │
│    └─ ProfileViewModel                    │
│       └─ ChangeNotifier                   │
│                                            │
└────────────────────────────────────────────┘

┌─── WIDGETS (Reusable Components) ────────┐
│                                            │
│  ProfileSection                            │
│  LearningModeChip                          │
│  ChipsGrid                                 │
│                                            │
└────────────────────────────────────────────┘

┌─── SERVICES ─────────────────────────────┐
│                                            │
│  AuthService (Singleton)                  │
│  AIService (Singleton)                    │
│  TTSService (Singleton)                   │
│                                            │
└────────────────────────────────────────────┘
```

---

## 🔌 4. Service Locator Pattern

```
main.dart
   │
   └─> setupServiceLocator()
        │
        ├─> getIt.registerSingleton<AuthService>()
        ├─> getIt.registerSingleton<AIService>()
        └─> getIt.registerSingleton<TTSService>()
              │
              └─> getIt.allReady()

Utilisation dans n'importe quel widget:
   ServiceLocator.authService
   ServiceLocator.aiService
   ServiceLocator.ttsService
```

---

## 🎯 5. Dépendances des Fichiers

```
main.dart
   ├─ constants.dart
   ├─ service_locator.dart
   │    ├─ AuthService
   │    ├─ AIService
   │    └─ TTSService
   ├─ env.dart
   ├─ theme.dart
   └─ screens/auth_gate.dart

ProfileScreen
   ├─ core/core.dart
   │   ├─ constants.dart
   │   ├─ validation_helper.dart
   │   ├─ error_handler.dart
   │   └─ service_locator.dart
   ├─ l10n/app_localizations.dart
   ├─ screens/view_models/profile_view_model.dart
   └─ widgets/profile/profile_section.dart

ProfileViewModel
   ├─ core/constants.dart
   ├─ core/service_locator.dart
   ├─ services/auth_service.dart
   └─ utils/app_logger.dart
```

---

## 📈 6. Avantages de cette Architecture

```
╔════════════════════════════════════════════════════════════╗
║  BEFORE (Monolithic)     │  AFTER (Layered & Modular)    ║
╠════════════════════════════════════════════════════════════╣
║  ProfileScreen (454 LOC) │  ProfileScreen (200 LOC)      ║
║  + ProfileViewModel      │  + ProfileViewModel (150 LOC) ║
║  + profile_section.dart  │  ├─ Réutilisable             ║
║                          │  ├─ Testable                 ║
║                          │  └─ Maintenable              ║
║  ────────────────────── │  ──────────────────────────── ║
║  Validation x4 places   │  Validation x1 place          ║
║  Error handling x4 ways │  Error handling x1 way        ║
║  Constants everywhere   │  Constants in constants.dart  ║
║  Services duplicated    │  Services: GetIt Singleton    ║
║  50% code duplication   │  DRY principle                ║
╚════════════════════════════════════════════════════════════╝
```

---

## ⚙️ 7. Flux d'Initialisation (Application Startup)

```
main()
   ↓
WidgetsFlutterBinding.ensureInitialized()
   ↓
SharedPreferences.getInstance()
   ↓
Load saved language
   ↓
Supabase.initialize()
   ↓
setupServiceLocator()
   ├─ getIt.registerSingleton<AuthService>()
   ├─ getIt.registerSingleton<AIService>()
   ├─ getIt.registerSingleton<TTSService>()
   └─ getIt.allReady()
   ↓
runApp(NorvegeIAApp)
   ↓
MaterialApp
   ├─ locale: appLocale.value
   ├─ home: AuthGate()
   │   └─ StreamBuilder<AuthState>
   │       ├─ if (session != null) → ChatScreen
   │       └─ else → LoginScreen
   └─ BuildContext ready for use
```

---

## 🏗️ 8. Comparaison: Ajout d'une nouvelle Feature

### AVANT (Architecture initiale):

```
1. Créer nouveau screen (300+ LOC)
2. Ajouter validation partout (50+ LOC)
3. Ajouter error handling (100+ LOC)
4. Créer services ad-hoc
5. Tester manuellement
6. Déboguer lentement

Total: ~500+ LOC, 3-4 jours
```

### APRÈS (Architecture refactorisée):

```
1. Créer ViewModel (100 LOC, réutilisable)
2. Ajouter constants (5 LOC)
3. Utiliser ValidationHelper (2 LOC)
4. Utiliser ErrorHandler (3 LOC)
5. Utiliser ServiceLocator (1 LOC)
6. Réutiliser widgets existants (0 LOC)

Total: ~150 LOC, 1 jour
```

---

## 🎓 9. Best Practices Implémentées

```
✅ Single Responsibility Principle
   - Chaque classe a UNE responsabilité

✅ Dependency Injection
   - Services injectés via GetIt
   - Facile à tester et mocker

✅ DRY (Don't Repeat Yourself)
   - Pas de duplication de code
   - Constantes centralisées

✅ Separation of Concerns
   - UI ≠ Logique métier
   - Services ≠ ViewModels

✅ Consistent Error Handling
   - Tous les erreurs gérées uniformément
   - Messages utilisateur cohérents

✅ Reusable Components
   - Widgets réutilisables
   - Helpers partagés
```

---

## 📋 Quick Reference Sheet

```
Import shortcut:
    import '../core/core.dart';

Service access:
    final authService = ServiceLocator.authService;

Validation:
    ValidationHelper.validateEmail(email)
    ValidationHelper.validatePassword(password)

Constants:
    AppConstants.apiTimeout
    AppDimensions.paddingLarge
    AppDurations.animationNormal

Error handling:
    ErrorHandler.handleError(error, l10n)

ChangeNotifier:
    ChangeNotifier + notifyListeners()
```
