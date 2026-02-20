// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Norwegian';

  @override
  String get loginLevelUnknown => 'I don\'t know';

  @override
  String get loginLevelBeginner => 'Beginner (A0)';

  @override
  String get loginLevelFalseBeginner => 'False-Beginner (A1)';

  @override
  String get loginLevelIntermediate => 'Intermediate (B1)';

  @override
  String get loginLevelAdvanced => 'Advanced (B2)';

  @override
  String get loginModeFun => 'Fun 🎮';

  @override
  String get loginModeSerious => 'Serious 🎓';

  @override
  String get loginModeImmersive => 'Immersive 🇳🇴';

  @override
  String get loginModeDirect => 'Direct ⚡';

  @override
  String get loginModeCaring => 'Caring ❤️';

  @override
  String get loginObjectiveIsMandatory => 'The objective is mandatory';

  @override
  String get loginPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get loginPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get loginNameIsMandatory => 'Name is mandatory';

  @override
  String get loginChooseAtLeastOneStyle => 'Choose at least one style';

  @override
  String get loginAccountConfiguredSuccessfully =>
      'Account configured successfully! Welcome.';

  @override
  String loginError(Object error) {
    return 'Error: $error';
  }

  @override
  String profileError(Object error) {
    return 'Error: $error';
  }

  @override
  String get profileObjectiveCannotBeEmpty => 'The objective cannot be empty';

  @override
  String get profileSelectAtLeastOneStyle => 'Select at least one style';

  @override
  String get profileProfileUpdated => 'Profile updated!';

  @override
  String get profileUnsavedChanges => 'Unsaved changes';

  @override
  String get profileUnsavedChangesWarning =>
      'You have unsaved changes. Do you really want to quit and lose your changes?';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileQuitWithoutSaving => 'Quit without saving';

  @override
  String get profileMyProfile => 'My Profile';

  @override
  String get profileWhoAreYou => 'Who are you?';

  @override
  String get profileFirstNameOrNickname => 'First name or nickname';

  @override
  String get profileYourObjective => 'Your Objective (Free)';

  @override
  String get profileDescribeYourGoal =>
      'Describe your goal in your own words (e.g., \'Read the newspaper\', \'Talk to my in-laws\'...).';

  @override
  String get profileFreeObjective => 'Free objective';

  @override
  String get profileCoachingStyle => 'Coaching Style';

  @override
  String get profileSelectOneOrMoreStyles =>
      'Select one or more styles. The coach will alternate!';

  @override
  String get profileSAVE => 'SAVE';

  @override
  String get loginAboutYou => 'About you';

  @override
  String get loginPseudo => 'Nickname or First Name';

  @override
  String get loginEstimatedLevel => 'Estimated level';

  @override
  String get loginObjectiveExample => 'Objective (e.g., Travel)';

  @override
  String get loginPreferredStyles => 'Preferred styles';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginConfirmPassword => 'Confirm password';

  @override
  String get loginConnect => 'SIGN IN';

  @override
  String get loginValidateProfile => 'VALIDATE MY PROFILE';

  @override
  String get loginWelcomeBack => 'Welcome back! 👋';

  @override
  String get loginCreateProfileTitle => 'Create my Profile 🚀';

  @override
  String get loginNoAccount => 'No account? ';

  @override
  String get loginAlreadyMember => 'Already a member? ';

  @override
  String get loginCreateProfile => 'Create a profile';

  @override
  String get loginSignIn => 'Sign in';

  @override
  String get chatScreenTitle => 'NORDLYS';

  @override
  String chatAiConnectionError(Object error) {
    return 'AI connection error: $error';
  }

  @override
  String chatGenericError(Object error) {
    return 'Error: $error';
  }

  @override
  String get chatHello => 'Hello, I am ready.';

  @override
  String get chatCoachIsPreparing => 'The coach is preparing your session...';

  @override
  String get chatTypeHere => 'Type here...';

  @override
  String get profileLanguage => 'App language';

  @override
  String get langueFr => '🇫🇷  French';

  @override
  String get langueEn => '🇬🇧  English';

  @override
  String get profileProgression => 'Your progress';

  @override
  String get levelMotivationA0 => 'Every journey begins with a single step! 🚀';

  @override
  String get levelMotivationA1 => 'Great start! The foundations are set. 🧱';

  @override
  String get levelMotivationA2 => 'You\'re starting to get the hang of it! 🗣️';

  @override
  String get levelMotivationB1 => 'Impressive! You are independent. 🎒';

  @override
  String get levelMotivationB2 =>
      'Very fluent! Norway has no more secrets. 🇳🇴';

  @override
  String get levelMotivationC1 => 'Expert level reached! Almost bilingual. 🎓';

  @override
  String get levelMotivationC2 => 'Total mastery. Gratulerer! 👑';

  @override
  String get levelMotivationDefault => 'Keep it up! 💪';
}
