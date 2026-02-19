# Nordlys

Projet Flutter "Nordlys" — application multi-plateforme (Android / iOS / Web /
Desktop).

## Résumé

Ce dépôt contient l'application Flutter `norvege_app` avec une intégration
Supabase et des fonctions côté serveur dans `supabase/functions/`.

## Prérequis

- Flutter SDK (stable) installé et configuré
- Dart (fourni par Flutter)
- Outils de plateforme au besoin (Android SDK, Xcode pour iOS)

## Installation locale

1. Ouvrir le projet racine.
2. Récupérer les dépendances:

```bash
flutter pub get
```

3. Variables d'environnement: adaptez `lib/envSample.dart` en créant
   `lib/env.dart` et en renseignant vos clés (Supabase, API, etc.).

## Lancer l'application

- Sur un appareil ou simulateur connecté:

```bash
flutter run
```

- Construire un APK Android (release):

```bash
flutter build apk --release
```

- Construire pour le web:

```bash
flutter build web
```

## Tests

Lancer la suite de tests unitaires/Widget:

```bash
flutter test
```

Les tests d'intégration se trouvent dans `test/`.

## Structure importante

- `app/norvege_app/lib/` : code source principal
- `app/norvege_app/assets/` : assets
- `supabase/` : configuration Supabase et fonctions (p.ex.
  `supabase/functions/generate-lesson/`)
- `app/norvege_app/test/` : tests

## Déploiement des fonctions Supabase

Voir le dossier `supabase/functions/` pour les fonctions Cloud. Suivre la doc
Supabase pour déployer.

## Contribuer

1. Créez une branche feature.
2. Ajoutez des tests lorsque possible.
3. Ouvrez une pull request.

## Licence

Ajouter ici la licence du projet (ex: MIT) ou indiquer "All rights reserved".

---

Fichier créé automatiquement — ajustez les sections `Prérequis` et
`Variables d'environnement` selon vos besoins.
