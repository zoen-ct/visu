import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '/visu.dart';

class AuthService {
  /// User login method
  ///
  /// Params:
  /// - email: user's email address
  /// - password: user's password
  ///
  /// Returns a Future&lt;bool&gt; indicating whether the login was successful
  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final Map<String, String> body = {'email': email, 'password': password};

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('token')) {
          final String token = data['token'];

          if (token.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(ApiConfig.tokenKey, token);

            return true;
          }
        }
      }

      return false;
    } catch (e) {
      debugPrint('Erreur lors de la connexion: $e');
      return false;
    }
  }

  /// Vérifie si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(ApiConfig.tokenKey);

      if (token != null && token.isNotEmpty) {
        final bool isExpired = JwtDecoder.isExpired(token);
        return !isExpired;
      }

      return false;
    } catch (e) {
      debugPrint('Erreur lors de la vérification de connexion: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConfig.tokenKey);
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(ApiConfig.tokenKey);
    } catch (e) {
      debugPrint('Erreur lors de la récupération du token: $e');
      return null;
    }
  }
}
