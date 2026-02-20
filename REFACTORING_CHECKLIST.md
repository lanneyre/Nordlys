# ✅ Checklist de Refactorisation Flutter

## 📋 Phase 1: Installation & Configuration (1-2 jours)

### Dépendances

- [ ] Exécuter `flutter pub add get_it`
- [ ] Exécuter `flutter pub add provider` (optionnel)
- [ ] Vérifier que pubspec.yaml contient les dépendances
- [ ] Exécuter `flutter pub get`
- [ ] Vérifier que le projet compile: `flutter build apk --release`

### Fichiers de base

- [ ] ✅ `lib/core/constants.dart` (créé)
- [ ] ✅ `lib/core/validation_helper.dart` (créé)
- [ ] ✅ `lib/core/service_locator.dart` (créé)
- [ ] ✅ `lib/core/error_handler.dart` (créé)
- [ ] ✅ `lib/core/core.dart` (créé)

### Documentation

- [ ] ✅ `ARCHITECTURE.md` (créé)
- [ ] ✅ `IMPLEMENTATION_GUIDE.md` (créé)
- [ ] ✅ `REFACTORING_SUMMARY.md` (créé)
- [ ] ✅ `ARCHITECTURE_DIAGRAMS.md` (créé)
- [ ] ✅ `EXAMPLE_BEFORE_AFTER.dart` (créé)

---

## 🔧 Phase 2: Core Setup (3-4 jours)

### main.dart

- [ ] Ajouter `import 'core/service_locator.dart';`
- [ ] Ajouter `setupServiceLocator();` après `Supabase.initialize()`
- [ ] Tester que l'app démarre correctement

### Widgets réutilisables

- [ ] ✅ `lib/widgets/profile/profile_section.dart` (créé)
- [ ] ✅ `lib/widgets/profile/profile_section.dart` contient:
  - [ ] ProfileSection widget
  - [ ] LearningModeChip widget
  - [ ] ChipsGrid widget

### ViewModels

- [ ] ✅ `lib/screens/view_models/profile_view_model.dart` (créé)
- [ ] Tester que ProfileViewModel fonctionne avec ChangeNotifier

### Tests basiques

- [ ] `flutter test` - Tous les tests passent
- [ ] `flutter run` - App démarre sans erreurs
- [ ] App compile: `flutter build apk --release`

---

## 🎯 Phase 3: Migration LoginScreen (4-5 jours)

### Constantes

- [ ] Ajouter au LoginScreen : `import '../core/core.dart';`
- [ ] Remplacer hardcoded strings par `AppConstants.*`
- [ ] Remplacer `Duration(seconds: ...)` par `AppConstants.*Timeout`
- [ ] Remplacer `padding` par `AppDimensions.*`

### Validation

- [ ] Remplacer validation email par `ValidationHelper.validateEmail()`
- [ ] Remplacer validation password par `ValidationHelper.validatePassword()`
- [ ] Remplacer validation username par `ValidationHelper.validateUsername()`
- [ ] Remplacer validation modes par `ValidationHelper.validateModeSelection()`

### Services

- [ ] Remplacer `final _authService = AuthService()` par
      `get _authService => ServiceLocator.authService`
- [ ] Tester que la sign-in fonctionne
- [ ] Tester que la sign-up fonctionne

### Error Handling

- [ ] Remplacer try-catch par `ErrorHandler.handleError()`
- [ ] Afficher les messages d'erreur traduits
- [ ] Tester les différents types d'erreurs (auth, validation, etc.)

### Tests

- [ ] Tester que LoginScreen compile
- [ ] Tester les validations
- [ ] Tester la connexion réussie
- [ ] Tester l'inscription réussie
- [ ] Tester les messages d'erreur

---

## 📱 Phase 4: Migration ProfileScreen (5-6 jours)

### Extraction ViewModel

- [ ] Créer ProfileViewModel (✅ déjà créé)
- [ ] Migrer loadProfile() vers ViewModel
- [ ] Migrer saveProfile() vers ViewModel
- [ ] Ajouter getters et setters au ViewModel

### Utilisation dans UI

- [ ] Créer instance ProfileViewModel dans initState()
- [ ] Remplacer les setState() par ViewModel methods
- [ ] Utiliser Widget ProfileSection
- [ ] Utiliser Widget ChipsGrid

### Constantes & Validation

- [ ] Remplacer strings hardcodées par `AppConstants.*`
- [ ] Remplacer `Duration(...)` par `AppDurations.*`
- [ ] Remplacer `padding` par `AppDimensions.*`
- [ ] Ajouter ValidationHelper pour les validations

### Error Handling

- [ ] Utiliser ErrorHandler pour toutes les exceptions
- [ ] Afficher messages cohérents avec LoginScreen
- [ ] Tester les erreurs (upload, database, auth)

### Tests

- [ ] Tester ProfileScreen compile
- [ ] Tester le chargement du profil
- [ ] Tester la sauvegarde du profil
- [ ] Tester l'upload d'avatar
- [ ] Tester les validation errors
- [ ] Tester les unsaved changes warning

---

## 🔄 Phase 5: Migration des autres Screens (3-4 jours)

### AuthGate

- [ ] Ajouter constantes
- [ ] Ajouter validation si nécessaire
- [ ] Ajouter error handling

### ChatScreen

- [ ] Remplacer AuthService par ServiceLocator
- [ ] Ajouter constantes pour pagination, timeouts
- [ ] Ajouter error handling centralisé
- [ ] Utiliser AIService et TTSService via ServiceLocator

### Autres Screens

- [ ] Identifier les autres screens
- [ ] Appliquer les mêmes patterns
- [ ] Tester chacun individuellement

---

## 🧪 Phase 6: Tests Systématique (2-3 jours)

### Tests Unitaires

- [ ] Tests pour ValidationHelper
- [ ] Tests pour ErrorHandler
- [ ] Tests pour ProfileViewModel
- [ ] Tests pour AuthService (mocker Supabase)

### Tests d'Intégration

- [ ] Login flow complet
- [ ] Signup flow complet
- [ ] Profile edit flow complet
- [ ] Avatar upload flow

### Tests Manuels

- [ ] Tester sur Android
- [ ] Tester sur iOS (si disponible)
- [ ] Tester sur Web (si supporté)
- [ ] Tester les différentes erreurs réseau
- [ ] Tester avec langue FR et EN

---

## 📊 Phase 7: Performance & Optimization (1-2 jours)

### Code Quality

- [ ] Exécuter `flutter analyze` - 0 errors
- [ ] Exécuter `flutter format` - Code formaté
- [ ] Vérifier unused imports
- [ ] Vérifier unused variables

### Performance

- [ ] Vérifier que l'app démarre rapidement
- [ ] Vérifier que les transitions sont fluides
- [ ] Vérifier mémoire avec DevTools
- [ ] Vérifier build time

### Cleanup

- [ ] Supprimer les fichiers profile_screen_refactored.dart (exemple)
- [ ] Nettoyer les commentaires de debug
- [ ] Finaliser la documentation

---

## 🎉 Phase 8: Finalization & Documentation (1 jour)

### Code Documentation

- [ ] Tous les ViewModels ont des comentaires
- [ ] Tous les helpers ont des comentaires
- [ ] core.dart a un readme

### README & Guides

- [ ] Mettre à jour README principal
- [ ] Maintenir ARCHITECTURE.md à jour
- [ ] Maintenir IMPLEMENTATION_GUIDE.md à jour
- [ ] Ajouter troubleshooting guide

### Release

- [ ] Bumper version (1.0.1 ou 1.1.0)
- [ ] Tester la build release finale
- [ ] Documenter les changements
- [ ] Prêt pour le déploiement

---

## 📈 Métriques de Succès

### Avant refactorisation:

- [ ] Nombre de LOC dans ProfileScreen: 454
- [ ] Nombre de validations dispersées: 4+
- [ ] Duplication de code: 40%+
- [ ] Testabilité: < 20%

### Après refactorisation (objectifs):

- [ ] Nombre de LOC dans ProfileScreen: < 250
- [ ] Nombre de validations centralisées: 1
- [ ] Duplication de code: < 10%
- [ ] Testabilité: > 80%
- [ ] Temps d'onboarding dev: -50%
- [ ] Bug fixes: -30% de temps

---

## 🆘 Ressources d'aide

Si vous êtes bloqué sur:

- **Architecture**: Consulter `ARCHITECTURE_DIAGRAMS.md`
- **Implémentation**: Consulter `IMPLEMENTATION_GUIDE.md`
- **Exemples**: Consulter `EXAMPLE_BEFORE_AFTER.dart`
- **ServiceLocator**: Consulter `lib/core/service_locator.dart`
- **Validation**: Consulter `lib/core/validation_helper.dart`
- **Erreurs**: Consulter `lib/core/error_handler.dart`

---

## 💾 Commits Git Recommandés

```bash
# Phase 1
git commit -m "chore: add dependencies (get_it, provider)"

# Phase 2
git commit -m "refactor: create core layer (constants, validation, service_locator, error_handler)"
git commit -m "feat: add reusable profile widgets"
git commit -m "feat: add ProfileViewModel"

# Phase 3
git commit -m "refactor: migrate LoginScreen to use new architecture"

# Phase 4
git commit -m "refactor: migrate ProfileScreen to use ViewModel"

# Phase 5
git commit -m "refactor: migrate ChatScreen to use new architecture"
git commit -m "refactor: migrate AuthGate to use new architecture"

# Phase 6-8
git commit -m "test: add unit and integration tests"
git commit -m "docs: update architecture documentation"
git tag -a v1.1.0 -m "Release: Complete architecture refactoring"
```

---

**Bon courage! 💪 Vous allez transformer votre codebase en une architecture
professionnelle!**
