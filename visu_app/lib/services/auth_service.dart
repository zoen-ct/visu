import 'package:flutter/material.dart';

class AuthService {
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
    // TODO: Implémenter la connexion avec le backend
    // Simulation d'un appel réseau
    await Future.delayed(const Duration(seconds: 1));

    // Pour test, on considère que la connexion réussit si l'email contient "test"
    return email.contains('test');
  }
}
