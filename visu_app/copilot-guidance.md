GitHub Copilot - Guide de style et de contexte pour Visu
Contexte du projet
Nom de l'application : Visu

Type : Application mobile Flutter

Description : Application de suivi de films, séries et animes (similaire à TV Time)

Fonctionnalités principales :

Authentification (connexion, inscription)

Page séries avec épisodes à voir, vus, en cours

Page films avec statuts similaires

Détail des films, séries et épisodes

Recherche via l’API TMDb

Profil utilisateur avec historique et favoris

API principale : The Movie Database (TMDb)

Backend personnalisé : Node.js (Express) + JWT + MongoDB

Design system :

Couleurs : #F8C13A (jaune), #16232E (bleu très foncé), #F4F6F8 (blanc), #101010 (noir doux)

Icônes : 20x20

Typography : Roboto

Style général : Flat design moderne, cartes avec bords arrondis (radius 12), ombres douces

Bonnes pratiques attendues pour Copilot
Respecter l’architecture Flutter MVC ou MVVM légère :

View (UI) = Widgets

ViewModel = Gestion d'état (via Riverpod, Provider ou setState temporairement)

Model = Objets TMDb + classes locales (Film, Serie, User, Episode)

Modularité :

Découper chaque composant en Widget réutilisable

Éviter les Widgets de plus de 100 lignes

Utiliser un dossier components pour stocker : buttons, cards, inputs, etc.

Gestion d’état :

Privilégier le pattern notifier/provider/riverpod si utilisé

Utiliser setState uniquement pour des cas très simples et isolés

Accès aux APIs :

Créer un service TmdbService avec des méthodes :

searchContent(query)

getMovieDetails(id)

getSerieDetails(id)

getEpisodeDetails(serieId, season, episode)

Le backend perso doit être isolé dans AuthService, UserService, etc.

UI :

Respecter la charte graphique :

Padding minimum : 12 px

Taille de texte selon la hiérarchie :

Title large : 20px bold

Subtitle : 16px medium

Caption : 12px regular

Buttons avec icône : icône 20x20, texte 14px, spacing 8px

Utiliser SizedBox ou gap de 8px à 16px entre les composants

Navigation :

Utiliser go_router ou Navigator 2.0

Empêcher l’accès aux pages protégées si non connecté

UX :

Gérer les erreurs des appels HTTP (afficher un message utilisateur)

Utiliser des skeletons (shimmers) pour simuler le contenu en attente de chargement.

Recommandation : utiliser des packages comme shimmer (pub.dev/packages/shimmer) ou skeletons (pub.dev/packages/skeletons).

Exemples de skeletons à créer :

MovieCardSkeleton

SerieCardSkeleton

EpisodeTileSkeleton

Les skeletons doivent respecter le layout des composants réels (même taille, structure).

Un shimmer doit être visible pendant que l'appel API se termine.

En cas d’erreur d’API :

Afficher une erreur claire (« Impossible de charger les films. Réessayez. »)

Ajouter un bouton de rechargement si pertinent

Exemple de bon comportement attendu de Copilot :

Si on crée une liste de films avec appel async :

Afficher un MovieCardSkeleton tant que le contenu est null / en attente

Remplacer par MovieCard une fois les données chargées

Exemple minimal de skeleton avec shimmer :

dart
import 'package:shimmer/shimmer.dart';

class MovieCardSkeleton extends StatelessWidget {
@override
Widget build(BuildContext context) {
return Shimmer.fromColors(
baseColor: Colors.grey.shade800,
highlightColor: Colors.grey.shade700,
child: Container(
height: 180,
width: 120,
decoration: BoxDecoration(
color: Colors.grey.shade800,
borderRadius: BorderRadius.circular(12),
),
),
);
}
}

Test :

Générer des fichiers tests pour les services (unitaires)

Utiliser le widget test pour les écrans avec interaction

Comportement attendu de Copilot
Suggérer du code structuré et typé (fortement typé avec classes)

Éviter les fonctions longues (diviser en fonctions courtes)

Utiliser des noms de variables clairs et cohérents

Ne pas proposer de hardcode API_KEY (utiliser const ou .env)

Préférer des widgets stateless par défaut

Exemples de widgets recommandés
MovieCard

SerieCard

EpisodeTile

FavoriteButton

VisuSearchField

Si des commentaires sont mis, ils doivent impérativement être en anglais