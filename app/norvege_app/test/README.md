# 📋 Suite de Tests Norvege App

Guide complet pour exécuter et maintenir la suite de tests de Norvege App.

## 📁 Structure des Tests

```
test/
├── models/
│   └── chat_message_test.dart          # Tests du modèle ChatMessage
├── services/
│   ├── auth_service_test.dart          # Tests du service d'authentification
│   ├── ai_service_test.dart            # Tests du service IA
│   └── tts_service_test.dart           # Tests du service de synthèse vocale
├── screens/
│   └── auth_gate_test.dart             # Tests de l'écran AuthGate
├── widgets/
│   └── message_bubble_test.dart        # Tests du widget MessageBubble
├── integration_test.dart               # Tests d'intégration globaux
├── theme_test.dart                     # Tests du thème et des couleurs
├── widgets_utils_test.dart             # Tests des composants utilitaires
└── widget_test.dart                    # Test initial (peut être supprimé)
```

## 🚀 Avant de Commencer

### Installation des Dépendances

Assurez-vous que les dépendances de test sont installées:

```bash
flutter pub get
```

Vérifiez que `mocktail` est dans votre `pubspec.yaml`:

```yaml
dev_dependencies:
    flutter_test:
        sdk: flutter
    intl: any
    mocktail: ^1.0.0
```

## ▶️ Exécuter les Tests

### 1. **Exécuter tous les tests**

```bash
flutter test
```

### 2. **Exécuter un fichier de test spécifique**

```bash
# Tests du modèle ChatMessage
flutter test test/models/chat_message_test.dart

# Tests du service d'authentification
flutter test test/services/auth_service_test.dart

# Tests du service IA
flutter test test/services/ai_service_test.dart

# Tests du service TTS
flutter test test/services/tts_service_test.dart

# Tests des widgets
flutter test test/widgets/message_bubble_test.dart

# Tests des écrans
flutter test test/screens/auth_gate_test.dart

# Tests d'intégration
flutter test test/integration_test.dart

# Tests du thème
flutter test test/theme_test.dart

# Tests des composants utilitaires
flutter test test/widgets_utils_test.dart
```

### 3. **Exécuter les tests avec verbose output**

```bash
flutter test --verbose
```

### 4. **Exécuter les tests avec couverture de code**

```bash
flutter test --coverage
```

### 5. **Générer un rapport de couverture (HTML)**

```bash
# Sur macOS/Linux
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Sur Windows
flutter test --coverage
# Utilisez un outil compatible Windows pour générer le rapport
```

## 📊 Couverture des Tests

### Par Composant

| Composant       | Tests     | Couverture                          |
| --------------- | --------- | ----------------------------------- |
| **Models**      |           |                                     |
| ChatMessage     | 9 tests   | Création, accesseurs, métadonnées   |
| **Services**    |           |                                     |
| AuthService     | 9 tests   | Singleton, authentification, profil |
| AiService       | 10 tests  | Génération de leçons, évaluation    |
| TtsService      | 15 tests  | Synthèse vocale, gestion erreurs    |
| **Screens**     |           |                                     |
| AuthGate        | 10 tests  | StreamBuilder, navigation           |
| **Widgets**     |           |                                     |
| MessageBubble   | 15 tests  | Rendu, alignement, métadonnées      |
| Utils Widgets   | 6 tests   | TextField, Avatar, Builders         |
| **Integration** | 20+ tests | Flux conversation, progression      |
| **Theme**       | 15+ tests | Couleurs, styles                    |

**Total : ~100+ Tests**

## 🧪 Détails des Tests Principaux

### 1. **ChatMessage Tests** ✅

- ✓ Création de messages utilisateur/IA
- ✓ Gestion des métadonnées complexes
- ✓ Caractères spéciaux norvégiens
- ✓ Messages vides et longs

### 2. **AuthService Tests** ✅

- ✓ Singleton pattern
- ✓ Authentification (signup/signin)
- ✓ Gestion du profil
- ✓ Changements d'état d'authentification

### 3. **AiService Tests** ✅

- ✓ Génération de leçons
- ✓ Métadonnées structurées
- ✓ Évaluation du niveau linguistique
- ✓ Gestion d'erreurs

### 4. **TtsService Tests** ✅

- ✓ Synthèse vocale
- ✓ Arrêt de la lecture
- ✓ Textes courts et longs
- ✓ Textes avec caractères spéciaux

### 5. **MessageBubble Tests** ✅

- ✓ Rendu correct des messages
- ✓ Alignement utilisateur/IA
- ✓ Callbacks (onSend, onReply)
- ✓ Métadonnées et actions UI

### 6. **Integration Tests** ✅

- ✓ Flux de conversation complet
- ✓ Quizzes et évaluations
- ✓ Suivi de progression
- ✓ Gestion d'erreurs

## 🔍 Interpréter les Résultats

### ✅ Test Réussi (PASSED)

```
test library test/models/chat_message_test.dart ... OK
0 seconds
All tests passed!
```

### ❌ Test Échoué (FAILED)

```
test library test/models/chat_message_test.dart ... FAILED
Expected: ...
Actual: ...
```

### ⏭️ Test Ignoré (SKIPPED)

```
test library test/models/chat_message_test.dart ... SKIPPED
```

## 🛠️ Maintenance des Tests

### Ajouter un Nouveau Test

1. Créez un fichier dans la structure appropriée
2. Importez les dépendances nécessaires
3. Écrivez votre test dans un groupe `group()`

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Nom du Test', () {
    test('description du test', () {
      // Arrange
      // Act
      // Assert
    });
  });
}
```

### Mettre à Jour les Mocks

Si vous changez les signatures des services, mettez à jour les mocks
correspondants:

```dart
class MockSupabaseClient extends Mock implements SupabaseClient {}
```

## 📱 Tests Spécifiques aux Plateformes

### Tests Linux (TtsService)

Le service TTS sur Linux utilise `espeak-ng`. Assurez-vous qu'il est installé:

```bash
# Ubuntu/Debian
sudo apt-get install espeak-ng

# Fedora
sudo dnf install espeak-ng

# macOS
brew install espeak-ng
```

## 🐛 Dépannage

### Problème : "Package not found"

```bash
flutter pub get
flutter pub upgrade
```

### Problème : Tests timeout

```bash
# Augmentez le timeout
flutter test --timeout=300s
```

### Problème : Erreurs de mock

- Vérifiez que `mocktail` est bien dépendance de développement
- Vérifiez les signatures des mocks
- Utilisez `registerFallbackValue()` si nécessaire

### Problème : Rendu des widgets

- Utilisez `tester.pumpWidget()` pour initialiser
- Utilisez `tester.pumpAndSettle()` pour attendre les animations
- Enveloppez dans `MaterialApp` pour le thème

## 📈 Améliorations Futures

- [ ] Ajouter des tests de performance
- [ ] Ajouter des tests E2E avec Patrol
- [ ] Augmenter la couverture à 90%+
- [ ] Ajouter des tests d'accessibilité
- [ ] CI/CD intégration (GitHub Actions)

## 🤝 Contribution

Quand vous ajoutez une nouvelle fonctionnalité:

1. Écrivez les tests en premier (TDD)
2. Assurez-vous que les tests passent
3. Vérifiez la couverture de code
4. Documentez les cas complexes

## 📞 Support

Pour des questions sur les tests:

1. Consultez la documentation Flutter:
   [flutter.dev/docs](https://flutter.dev/docs)
2. Mocktail docs: [pub.dev/packages/mocktail](https://pub.dev/packages/mocktail)
3. Vérifiez les exemples existants dans ce répertoire

---

**Dernière mise à jour:** 19 février 2026 **Nombre de tests:** 100+ **Taux de
couverture:** En progression
