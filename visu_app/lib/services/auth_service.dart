import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:visu/services/api_config.dart';

class AuthService {
  // Contrôleur de flux pour les changements d'état d'authentification
  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();

  // Expose un flux de changements d'état d'authentification
  Stream<bool> get authStateChanges => _authStateController.stream;

  // Cache pour l'état d'authentification
  bool? _isLoggedInCache;

  // Constructeur
  AuthService() {
    // Initialisation du cache d'état
    _initAuthState();
  }

  // Initialise l'état d'authentification au démarrage
  Future<void> _initAuthState() async {
    _isLoggedInCache = await isLoggedIn();
    _authStateController.add(_isLoggedInCache ?? false);
  }

  /// Méthode de connexion utilisateur
  ///
  /// Params:
  /// - email: adresse email de l'utilisateur
  /// - password: mot de passe de l'utilisateur
  ///
  /// Retourne un Future<bool> indiquant si la connexion a réussi
  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Préparer les données d'authentification
      final Map<String, String> body = {'email': email, 'password': password};

      // Envoyer la requête POST au serveur
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      // Vérifier si la requête a réussi (code 200)
      if (response.statusCode == 200) {
        // Décoder la réponse JSON
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Vérifier si le token est présent dans la réponse
        if (data.containsKey('token')) {
          final String token = data['token'];

          // Vérifier si le token est valide
          if (token.isNotEmpty) {
            // Stocker le token dans SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(ApiConfig.tokenKey, token);

            // Mettre à jour le cache et notifier les auditeurs
            _isLoggedInCache = true;
            _authStateController.add(true);

            return true;
          }
        }
      }

      // Si on arrive ici, c'est que l'authentification a échoué
      return false;
    } catch (e) {
      debugPrint('Erreur lors de la connexion: $e');
      return false;
    }
  }

  /// Vérifie si l'utilisateur est connecté (version asynchrone)
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(ApiConfig.tokenKey);

      if (token != null && token.isNotEmpty) {
        // Vérifier si le token n'est pas expiré
        bool isExpired = JwtDecoder.isExpired(token);
        _isLoggedInCache = !isExpired;
        return !isExpired;
      }

      _isLoggedInCache = false;
      return false;
    } catch (e) {
      debugPrint('Erreur lors de la vérification de connexion: $e');
      _isLoggedInCache = false;
      return false;
    }
  }

  /// Vérifie si l'utilisateur est connecté (version synchrone pour le router)
  bool isLoggedInSync() {
    // Utilise la valeur en cache, ou renvoie false si aucune valeur n'est disponible
    return _isLoggedInCache ?? false;
  }

  /// Déconnecte l'utilisateur en supprimant le token
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConfig.tokenKey);

      // Mettre à jour le cache et notifier les auditeurs
      _isLoggedInCache = false;
      _authStateController.add(false);
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
    }
  }

  /// Récupère le token JWT stocké
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(ApiConfig.tokenKey);
    } catch (e) {
      debugPrint('Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  /// Libère les ressources lors de la destruction
  void dispose() {
    _authStateController.close();
  }
}
