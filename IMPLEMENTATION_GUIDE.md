# 🚀 GUIDE D'IMPLÉMENTATION - Refactorisation Flutter

## Vue complète des fichiers créés

### ✅ Fichiers créés (7 nouveaux)

```
lib/
├── core/                          # 🆕 NOUVEAU DOSSIER
│   ├── constants.dart             # ✨ Constantes centralisées
│   ├── validation_helper.dart     # ✨ Validation centralisée
│   ├── service_locator.dart       # ✨ Injection de dépendances
│   ├── error_handler.dart         # ✨ Gestion d'erreurs
│   └── core.dart                  # ✨ Barrel export
├── screens/
│   ├── view_models/               # 🆕 NOUVEAU DOSSIER
│   │   └── profile_view_model.dart       # ✨ ViewModel pour profil
│   └── profile_screen_refactored.dart    # 📝 Exemple refactorisé
└── widgets/
    └── profile/                   # 🆕 NOUVEAU DOSSIER
        └── profile_section.dart         # ✨ Composants réutilisables
```

### 📋 Changements requis dans les fichiers existants

---

## ÉTAPE 1️⃣: Mettre à jour `main.dart`

**Lieu:** `lib/main.dart` **Changements:** Ajouter l'initialisation du
ServiceLocator

```dart
import 'core/service_locator.dart';  // 🆕 NOUVEAU

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final savedLanguage = prefs.getString('app_language') ?? 'fr';
  appLocale.value = Locale(savedLanguage);

  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  
  setupServiceLocator();  // 🆕 AJOUTER CETTE LIGNE
  
  runApp(const NorvegeIAApp());
}
```

---

## ÉTAPE 2️⃣: Ajouter les dépendances pubspec.yaml

**Lieu:** `pubspec.yaml`

```yaml
dependencies:
    flutter:
        sdk: flutter
    get_it: ^7.6.0 # 🆕 Pour le Service Locator
    provider: ^6.0.0 # 🆕 Pour le state management (optionnel)
    # ... autres dépendances
```

Exécuter:

```bash
flutter pub get
```

---

## ÉTAPE 3️⃣: Refactoriser ProfileScreen (Progressivement)

### Approche 1: Migrer graduellement

**Jour 1:** Garder le ProfileScreen original, créer une version
`ProfileScreenRefactored` comme référence.

**Jour 2:** Utiliser les widgets réutilisables dans ProfileScreen:

```dart
import '../widgets/profile/profile_section.dart';

// Dans le build():
ProfileSection(
  title: 'Qui êtes-vous ?',
  child: NordlysTextField(...),
)
```

**Jour 3:** Intégrer le ViewModel progressivement:

```dart
class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel();
  }
}
```

---

## ÉTAPE 4️⃣: Mettre à jour les services

### Mise à jour de `AuthService`

**Lieu:** `lib/services/auth_service.dart`

Changements mineurs (optionnels):

```dart
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ✅ Reste du code inchangé
}
```

---

## ÉTAPE 5️⃣: Utiliser le ServiceLocator dans les screens

### Avant:

```dart
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();  // ❌ Création locale
}
```

### Après:

```dart
import '../core/service_locator.dart';

class _LoginScreenState extends State<LoginScreen> {
  get _authService => ServiceLocator.authService;  // ✅ Depuis ServiceLocator
}
```

---

## ÉTAPE 6️⃣: Utiliser ValidationHelper

### Avant:

```dart
if (_nameController.text.trim().isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Nom requis')),
  );
  return;
}
```

### Après:

```dart
import '../core/validation_helper.dart';

final error = ValidationHelper.validateUsername(_nameController.text);
if (error != null) {
  _showError(error);
  return;
}
```

---

## ÉTAPE 7️⃣: Centralisez les constantes

### Avant:

```dart
final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
await supabase.storage.from('avatars').upload(fileName, ...);
const int debounce = 500;
```

### Après:

```dart
import '../core/constants.dart';

final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
await supabase.storage.from(AppConstants.supabaseBucketAvatars).upload(fileName, ...);
Future.delayed(Duration(milliseconds: AppConstants.debounceDelayMs));
```

---

## ÉTAPE 8️⃣: Gestion d'erreurs centralisée

### Avant:

```dart
catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString())),
  );
}
```

### Après:

```dart
import '../core/error_handler.dart';

catch (e) {
  final appError = ErrorHandler.handleError(e, l10n);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(appError.message)),
  );
}
```

---

## 📊 Checklist de Refactorisation

- [ ] Créer les fichiers `core/` (constants, validation_helper, service_locator,
      error_handler)
- [ ] Ajouter `get_it` à `pubspec.yaml` et exécuter `flutter pub get`
- [ ] Mettre à jour `main.dart` avec `setupServiceLocator()`
- [ ] Créer les widgets réutilisables dans `widgets/profile/`
- [ ] Créer `ProfileViewModel` dans `screens/view_models/`
- [ ] Remplacer les instances hardcodées par `ServiceLocator.xxxService`
- [ ] Remplacer les validations dispersées par `ValidationHelper`
- [ ] Remplacer la gestion d'erreurs par `ErrorHandler`
- [ ] Tester chaque screen après modification
- [ ] Mettre à jour les imports dans tous les files (imports relatifs →
      `core.dart`)

---

## 🧪 Tests

### Test 1: Vérifier le ServiceLocator

```dart
void main() {
  test('ServiceLocator doit avoir AuthService', () {
    setupServiceLocator();
    expect(ServiceLocator.authService, isNotNull);
  });
}
```

### Test 2: Vérifier la validation

```dart
test('validateEmail avec email invalide', () {
  final error = ValidationHelper.validateEmail('invalid-email');
  expect(error, isNotNull);
});
```

---

## 🚨 Ressources de Dépannage

### Error: `get_it` not found

**Solution:** Exécuter `flutter pub get`

### Error: Import not found `core.dart`

**Solution:** Vérifier que le fichier `lib/core/core.dart` existe avec tous les
exports

### Error: `ServiceLocator.authService` est null

**Solution:** S'assurer que `setupServiceLocator()` est appelé dans `main()`
AVANT `runApp()`

### Warning: Unused import

**Solution:** Utiliser des barrel files (`core.dart`) pour certains imports

---

## 📈 Prochaines Optimisations (Après v1)

1. **State Management Avancé**
   - Remplacer `ChangeNotifier` par **Riverpod** ou **Bloc**
   - Avantages: Performance, réactivité, testing

2. **Repository Pattern**
   - Ajouter une couche Repository entre Services et UI
   - Avantage: Abstraction de la source de données

3. **Feature Modules**
   - Organiser par feature (auth/, profile/, chat/)
   - Avantage: Scalabilité et modularité

4. **Tests Automatisés**
   - Tests unitaires pour ViewModels
   - Tests d'intégration pour Screens
   - Tests e2e pour workflows complets

---

## 📚 Ressources

- [Flutter Architecture Best Practices](https://flutter.dev/development/architecture)
- [GetIt Documentation](https://pub.dev/packages/get_it)
- [Provider Pattern](https://pub.dev/packages/provider)
- [Clean Architecture in Flutter](https://codewithandrea.com/articles/flutter-state-management-riverpod/)

---

**✅ C'est tout ! Vous avez maintenant une architecture Flutter professionnelle
et scalable! 🎉**
