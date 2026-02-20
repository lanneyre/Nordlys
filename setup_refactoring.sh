#!/bin/bash
# 🚀 Installation rapide des dépendances pour la refactorisation
# Exécutez ce script dans le dossier app/norvege_app/

echo "🎯 Installation de la refactorisation Flutter..."
echo "=================================================="
echo ""

# Vérifier que nous sommes dans le bon dossier
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Erreur: pubspec.yaml non trouvé"
    echo "Assurez-vous d'exécuter ce script depuis la racine du projet Flutter"
    exit 1
fi

echo "1️⃣  Fetching dependencies..."
flutter pub get

echo ""
echo "2️⃣  Ajout de get_it pour Service Locator..."
flutter pub add get_it

echo ""
echo "3️⃣  Ajout de provider pour State Management (optionnel)..."
flutter pub add provider

echo ""
echo "4️⃣  Nettoyage du cache..."
flutter clean

echo ""
echo "5️⃣  Rebuild du projet..."
flutter pub get

echo ""
echo "✅ Installation complète!"
echo ""
echo "=================================================="
echo "Prochaines étapes:"
echo "1. Vérifier que les fichiers core/ existent"
echo "2. Mettre à jour main.dart avec setupServiceLocator()"
echo "3. Consulter IMPLEMENTATION_GUIDE.md pour la migration"
echo "=================================================="
