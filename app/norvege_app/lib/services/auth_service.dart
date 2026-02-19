import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';

class AuthService {
  // Singleton : On s'assure qu'il n'y a qu'une seule instance de ce service
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  // Récupérer l'utilisateur actuel
  User? get currentUser => _client.auth.currentUser;

  // Écouter les changements d'état (Connexion/Déconnexion)
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Connexion
  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  // Inscription
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required String objective, // NOUVEAU
    required String startingLevel, // NOUVEAU
    required String learningMode, // NOUVEAU
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'display_name': displayName,
        'objective': objective,
        'starting_level': startingLevel,
        'learning_mode': learningMode,
      },
    );
  }

  // Déconnexion
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ... (code existant)

  // 1. Récupérer le profil complet
  Future<Map<String, dynamic>> getProfile() async {
    final user = currentUser;
    if (user == null) throw Exception("Non connecté");

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    return data;
  }

  // 2. Mettre à jour le profil
  Future<void> updateProfile({
    required String username,
    required String targetLevel,
    required String learningMode, // Ex: Sérieux, Ludique...
    String? avatarUrl, // <--- 1. LE NOUVEAU PARAMÈTRE EST ICI
  }) async {
    final user = currentUser;
    if (user == null) throw Exception("Non connecté");

    // 1. On prépare le paquet de données de base
    final Map<String, dynamic> updates = {
      'username': username,
      'target_level': targetLevel,
      'learning_mode': learningMode,
      // On touche pas au current_level, c'est l'IA qui le décide !
    };

    // 2. LE TRUC OUBLIÉ EST ICI 👇
    // Si on a bien reçu une URL, on l'ajoute au paquet !
    if (avatarUrl != null) {
      updates['avatarUrl'] =
          avatarUrl; // Assurez-vous que la colonne s'appelle bien 'avatar_url' sur Supabase
    }

    // 3. On envoie la requête à Supabase
    await _client.from('profiles').update(updates).eq('id', user.id);
  }

  // --- NOUVELLE FONCTION À AJOUTER ---
  Future<void> updateCurrentLevel(String newLevel) async {
    final user = currentUser; // Utilise votre getter existant
    if (user == null) return;

    try {
      await _client
          .from('profiles')
          .update(
            {'current_level': newLevel},
          ) // Assurez-vous que la colonne s'appelle bien comme ça sur Supabase !
          .eq('id', user.id);

      AppLogger.success('Niveau mis à jour en base de données : $newLevel');
    } catch (e) {
      AppLogger.error('Erreur maj niveau: $e');
    }
  }
}
