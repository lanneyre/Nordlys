// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Norvégien';

  @override
  String get loginLevelUnknown => 'Je ne sais pas';

  @override
  String get loginLevelBeginner => 'Débutant (A0)';

  @override
  String get loginLevelFalseBeginner => 'Faux-Débutant (A1)';

  @override
  String get loginLevelIntermediate => 'Intermédiaire (B1)';

  @override
  String get loginLevelAdvanced => 'Avancé (B2)';

  @override
  String get loginModeFun => 'Ludique 🎮';

  @override
  String get loginModeSerious => 'Sérieux 🎓';

  @override
  String get loginModeImmersive => 'Immersif 🇳🇴';

  @override
  String get loginModeDirect => 'Direct ⚡';

  @override
  String get loginModeCaring => 'Bienveillant ❤️';

  @override
  String get loginObjectiveIsMandatory => 'L\'objectif est obligatoire';

  @override
  String get loginPasswordsDoNotMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get loginPasswordTooShort =>
      'Le mot de passe doit faire au moins 6 caractères';

  @override
  String get loginNameIsMandatory => 'Le nom est obligatoire';

  @override
  String get loginChooseAtLeastOneStyle => 'Choisis au moins un style';

  @override
  String get loginAccountConfiguredSuccessfully =>
      'Compte configuré avec succès ! Bienvenue.';

  @override
  String loginError(Object error) {
    return 'Erreur : $error';
  }

  @override
  String profileError(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get profileObjectiveCannotBeEmpty =>
      'L\'objectif ne peut pas être vide';

  @override
  String get profileSelectAtLeastOneStyle => 'Sélectionnez au moins un style';

  @override
  String get profileProfileUpdated => 'Profil mis à jour !';

  @override
  String get profileUnsavedChanges => 'Modifications non enregistrées';

  @override
  String get profileUnsavedChangesWarning =>
      'Vous n\'avez pas cliqué sur \'Enregistrer\'. Voulez-vous vraiment quitter et perdre vos modifications ?';

  @override
  String get profileCancel => 'Annuler';

  @override
  String get profileQuitWithoutSaving => 'Quitter sans sauvegarder';

  @override
  String get profileMyProfile => 'Mon Profil';

  @override
  String get profileWhoAreYou => 'Qui êtes-vous ?';

  @override
  String get profileFirstNameOrNickname => 'Prénom ou pseudo';

  @override
  String get profileYourObjective => 'Votre Objectif (Libre)';

  @override
  String get profileDescribeYourGoal =>
      'Décrivez votre but avec vos mots (ex: \'Lire le journal\', \'Parler à ma belle-famille\'...).';

  @override
  String get profileFreeObjective => 'Objectif libre';

  @override
  String get profileCoachingStyle => 'Style de Coaching';

  @override
  String get profileSelectOneOrMoreStyles =>
      'Sélectionnez un ou plusieurs styles. Le coach alternera !';

  @override
  String get profileSAVE => 'ENREGISTRER';

  @override
  String get loginAboutYou => 'À propos de vous';

  @override
  String get loginPseudo => 'Pseudo ou Prénom';

  @override
  String get loginEstimatedLevel => 'Niveau estimé';

  @override
  String get loginObjectiveExample => 'Objectif (ex: Voyage)';

  @override
  String get loginPreferredStyles => 'Styles préférés';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Mot de passe';

  @override
  String get loginConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get loginConnect => 'SE CONNECTER';

  @override
  String get loginValidateProfile => 'VALIDER MON PROFIL';

  @override
  String get loginWelcomeBack => 'Bon retour ! 👋';

  @override
  String get loginCreateProfileTitle => 'Créer mon Profil 🚀';

  @override
  String get loginNoAccount => 'Pas de compte ? ';

  @override
  String get loginAlreadyMember => 'Déjà membre ? ';

  @override
  String get loginCreateProfile => 'Créer un profil';

  @override
  String get loginSignIn => 'Me connecter';

  @override
  String get chatScreenTitle => 'NORDLYS';

  @override
  String chatAiConnectionError(Object error) {
    return 'Erreur connexion IA: $error';
  }

  @override
  String chatGenericError(Object error) {
    return 'Erreur: $error';
  }

  @override
  String get chatHello => 'Bonjour, je suis prêt.';

  @override
  String get chatCoachIsPreparing => 'Le coach prépare votre séance...';

  @override
  String get chatTypeHere => 'Écrivez ici...';

  @override
  String get profileLanguage => 'Langue de l\'application';

  @override
  String get langueFr => '🇫🇷  Français';

  @override
  String get langueEn => '🇬🇧  Anglais';
}
