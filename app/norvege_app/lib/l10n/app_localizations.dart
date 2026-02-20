import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Norvégien'**
  String get appTitle;

  /// No description provided for @loginLevelUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Je ne sais pas'**
  String get loginLevelUnknown;

  /// No description provided for @loginLevelBeginner.
  ///
  /// In fr, this message translates to:
  /// **'Débutant (A0)'**
  String get loginLevelBeginner;

  /// No description provided for @loginLevelFalseBeginner.
  ///
  /// In fr, this message translates to:
  /// **'Faux-Débutant (A1)'**
  String get loginLevelFalseBeginner;

  /// No description provided for @loginLevelIntermediate.
  ///
  /// In fr, this message translates to:
  /// **'Intermédiaire (B1)'**
  String get loginLevelIntermediate;

  /// No description provided for @loginLevelAdvanced.
  ///
  /// In fr, this message translates to:
  /// **'Avancé (B2)'**
  String get loginLevelAdvanced;

  /// No description provided for @loginModeFun.
  ///
  /// In fr, this message translates to:
  /// **'Ludique 🎮'**
  String get loginModeFun;

  /// No description provided for @loginModeSerious.
  ///
  /// In fr, this message translates to:
  /// **'Sérieux 🎓'**
  String get loginModeSerious;

  /// No description provided for @loginModeImmersive.
  ///
  /// In fr, this message translates to:
  /// **'Immersif 🇳🇴'**
  String get loginModeImmersive;

  /// No description provided for @loginModeDirect.
  ///
  /// In fr, this message translates to:
  /// **'Direct ⚡'**
  String get loginModeDirect;

  /// No description provided for @loginModeCaring.
  ///
  /// In fr, this message translates to:
  /// **'Bienveillant ❤️'**
  String get loginModeCaring;

  /// No description provided for @loginObjectiveIsMandatory.
  ///
  /// In fr, this message translates to:
  /// **'L\'objectif est obligatoire'**
  String get loginObjectiveIsMandatory;

  /// No description provided for @loginPasswordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get loginPasswordsDoNotMatch;

  /// No description provided for @loginPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit faire au moins 6 caractères'**
  String get loginPasswordTooShort;

  /// No description provided for @loginNameIsMandatory.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est obligatoire'**
  String get loginNameIsMandatory;

  /// No description provided for @loginChooseAtLeastOneStyle.
  ///
  /// In fr, this message translates to:
  /// **'Choisis au moins un style'**
  String get loginChooseAtLeastOneStyle;

  /// No description provided for @loginAccountConfiguredSuccessfully.
  ///
  /// In fr, this message translates to:
  /// **'Compte configuré avec succès ! Bienvenue.'**
  String get loginAccountConfiguredSuccessfully;

  /// No description provided for @loginError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {error}'**
  String loginError(Object error);

  /// No description provided for @profileError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {error}'**
  String profileError(Object error);

  /// No description provided for @profileObjectiveCannotBeEmpty.
  ///
  /// In fr, this message translates to:
  /// **'L\'objectif ne peut pas être vide'**
  String get profileObjectiveCannotBeEmpty;

  /// No description provided for @profileSelectAtLeastOneStyle.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez au moins un style'**
  String get profileSelectAtLeastOneStyle;

  /// No description provided for @profileProfileUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour !'**
  String get profileProfileUpdated;

  /// No description provided for @profileUnsavedChanges.
  ///
  /// In fr, this message translates to:
  /// **'Modifications non enregistrées'**
  String get profileUnsavedChanges;

  /// No description provided for @profileUnsavedChangesWarning.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas cliqué sur \'Enregistrer\'. Voulez-vous vraiment quitter et perdre vos modifications ?'**
  String get profileUnsavedChangesWarning;

  /// No description provided for @profileCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get profileCancel;

  /// No description provided for @profileQuitWithoutSaving.
  ///
  /// In fr, this message translates to:
  /// **'Quitter sans sauvegarder'**
  String get profileQuitWithoutSaving;

  /// No description provided for @profileMyProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon Profil'**
  String get profileMyProfile;

  /// No description provided for @profileWhoAreYou.
  ///
  /// In fr, this message translates to:
  /// **'Qui êtes-vous ?'**
  String get profileWhoAreYou;

  /// No description provided for @profileFirstNameOrNickname.
  ///
  /// In fr, this message translates to:
  /// **'Prénom ou pseudo'**
  String get profileFirstNameOrNickname;

  /// No description provided for @profileYourObjective.
  ///
  /// In fr, this message translates to:
  /// **'Votre Objectif (Libre)'**
  String get profileYourObjective;

  /// No description provided for @profileDescribeYourGoal.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez votre but avec vos mots (ex: \'Lire le journal\', \'Parler à ma belle-famille\'...).'**
  String get profileDescribeYourGoal;

  /// No description provided for @profileFreeObjective.
  ///
  /// In fr, this message translates to:
  /// **'Objectif libre'**
  String get profileFreeObjective;

  /// No description provided for @profileCoachingStyle.
  ///
  /// In fr, this message translates to:
  /// **'Style de Coaching'**
  String get profileCoachingStyle;

  /// No description provided for @profileSelectOneOrMoreStyles.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez un ou plusieurs styles. Le coach alternera !'**
  String get profileSelectOneOrMoreStyles;

  /// No description provided for @profileSAVE.
  ///
  /// In fr, this message translates to:
  /// **'ENREGISTRER'**
  String get profileSAVE;

  /// No description provided for @loginAboutYou.
  ///
  /// In fr, this message translates to:
  /// **'À propos de vous'**
  String get loginAboutYou;

  /// No description provided for @loginPseudo.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo ou Prénom'**
  String get loginPseudo;

  /// No description provided for @loginEstimatedLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau estimé'**
  String get loginEstimatedLevel;

  /// No description provided for @loginObjectiveExample.
  ///
  /// In fr, this message translates to:
  /// **'Objectif (ex: Voyage)'**
  String get loginObjectiveExample;

  /// No description provided for @loginPreferredStyles.
  ///
  /// In fr, this message translates to:
  /// **'Styles préférés'**
  String get loginPreferredStyles;

  /// No description provided for @loginEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get loginPassword;

  /// No description provided for @loginConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get loginConfirmPassword;

  /// No description provided for @loginConnect.
  ///
  /// In fr, this message translates to:
  /// **'SE CONNECTER'**
  String get loginConnect;

  /// No description provided for @loginValidateProfile.
  ///
  /// In fr, this message translates to:
  /// **'VALIDER MON PROFIL'**
  String get loginValidateProfile;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour ! 👋'**
  String get loginWelcomeBack;

  /// No description provided for @loginCreateProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon Profil 🚀'**
  String get loginCreateProfileTitle;

  /// No description provided for @loginNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas de compte ? '**
  String get loginNoAccount;

  /// No description provided for @loginAlreadyMember.
  ///
  /// In fr, this message translates to:
  /// **'Déjà membre ? '**
  String get loginAlreadyMember;

  /// No description provided for @loginCreateProfile.
  ///
  /// In fr, this message translates to:
  /// **'Créer un profil'**
  String get loginCreateProfile;

  /// No description provided for @loginSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Me connecter'**
  String get loginSignIn;

  /// No description provided for @chatScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'NORDLYS'**
  String get chatScreenTitle;

  /// No description provided for @chatAiConnectionError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur connexion IA: {error}'**
  String chatAiConnectionError(Object error);

  /// No description provided for @chatGenericError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur: {error}'**
  String chatGenericError(Object error);

  /// No description provided for @chatHello.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour, je suis prêt.'**
  String get chatHello;

  /// No description provided for @chatCoachIsPreparing.
  ///
  /// In fr, this message translates to:
  /// **'Le coach prépare votre séance...'**
  String get chatCoachIsPreparing;

  /// No description provided for @chatTypeHere.
  ///
  /// In fr, this message translates to:
  /// **'Écrivez ici...'**
  String get chatTypeHere;

  /// No description provided for @profileLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l\'application'**
  String get profileLanguage;

  /// No description provided for @langueFr.
  ///
  /// In fr, this message translates to:
  /// **'🇫🇷  Français'**
  String get langueFr;

  /// No description provided for @langueEn.
  ///
  /// In fr, this message translates to:
  /// **'🇬🇧  Anglais'**
  String get langueEn;

  /// No description provided for @profileProgression.
  ///
  /// In fr, this message translates to:
  /// **'Votre progression'**
  String get profileProgression;

  /// No description provided for @levelMotivationA0.
  ///
  /// In fr, this message translates to:
  /// **'Tout voyage commence par un premier pas ! 🚀'**
  String get levelMotivationA0;

  /// No description provided for @levelMotivationA1.
  ///
  /// In fr, this message translates to:
  /// **'Excellent départ ! Les bases s\'installent. 🧱'**
  String get levelMotivationA1;

  /// No description provided for @levelMotivationA2.
  ///
  /// In fr, this message translates to:
  /// **'Vous commencez à bien vous débrouiller ! 🗣️'**
  String get levelMotivationA2;

  /// No description provided for @levelMotivationB1.
  ///
  /// In fr, this message translates to:
  /// **'Impressionnant ! Vous êtes indépendant. 🎒'**
  String get levelMotivationB1;

  /// No description provided for @levelMotivationB2.
  ///
  /// In fr, this message translates to:
  /// **'Très fluide ! La Norvège n\'a plus de secrets. 🇳🇴'**
  String get levelMotivationB2;

  /// No description provided for @levelMotivationC1.
  ///
  /// In fr, this message translates to:
  /// **'Niveau expert atteint ! Presque bilingue. 🎓'**
  String get levelMotivationC1;

  /// No description provided for @levelMotivationC2.
  ///
  /// In fr, this message translates to:
  /// **'Maîtrise totale. Gratulerer ! 👑'**
  String get levelMotivationC2;

  /// No description provided for @levelMotivationDefault.
  ///
  /// In fr, this message translates to:
  /// **'Continuez comme ça ! 💪'**
  String get levelMotivationDefault;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
