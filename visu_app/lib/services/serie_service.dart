import '/visu.dart';

class SerieService {
  Future<List<Serie>> getWatchlist() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      Serie(
        id: 1,
        title: 'The Last of Us',
        imageUrl:
            'https://fr.web.img6.acsta.net/pictures/22/11/02/15/37/0544148.jpg',
        rating: 8.7,
        releaseDate: '15 janvier 2023',
        description:
            'Vingt ans après la destruction de la civilisation moderne, Joel, un survivant aguerri, est engagé pour faire sortir Ellie, une jeune fille de 14 ans, d\'une zone de quarantaine oppressante.',
        genres: ['Drame', 'Action', 'Aventure'],
      ),
      Serie(
        id: 2,
        title: 'Breaking Bad',
        imageUrl:
            'https://m.media-amazon.com/images/I/61oZBZ+iewL._AC_UF894,1000_QL80_.jpg',
        rating: 9.5,
        releaseDate: '20 janvier 2008',
        description:
            'Un professeur de chimie atteint d\'un cancer devient fabricant et vendeur de méthamphétamine pour assurer l\'avenir financier de sa famille.',
        genres: ['Drame', 'Crime', 'Thriller'],
      ),
      Serie(
        id: 3,
        title: 'Game of Thrones',
        imageUrl:
            'https://m.media-amazon.com/images/I/91DjGXn-0nL._AC_UF894,1000_QL80_.jpg',
        rating: 9.2,
        releaseDate: '17 avril 2011',
        description:
            'Neuf familles nobles rivalisent pour le contrôle du Trône de Fer dans les sept royaumes de Westeros.',
        genres: ['Drame', 'Fantastique', 'Aventure'],
      ),
      Serie(
        id: 4,
        title: 'Stranger Things',
        imageUrl:
            'https://m.media-amazon.com/images/I/715PNtTCl7L._AC_UF894,1000_QL80_.jpg',
        rating: 8.7,
        releaseDate: '15 juillet 2016',
        description:
            'Quand un jeune garçon disparaît, une petite ville découvre une affaire mystérieuse, des expériences secrètes, des forces surnaturelles terrifiantes et une étrange petite fille.',
        genres: ['Drame', 'Fantastique', 'Horreur'],
      ),
      Serie(
        id: 5,
        title: 'The Mandalorian',
        imageUrl:
            'https://m.media-amazon.com/images/I/81RnrCuPjqL._AC_UF894,1000_QL80_.jpg',
        rating: 8.7,
        releaseDate: '12 novembre 2019',
        description:
            'Après la chute de l\'Empire, un chasseur de primes solitaire voyage aux confins de la galaxie, loin de l\'autorité de la Nouvelle République.',
        genres: ['Action', 'Aventure', 'Science-Fiction'],
      ),
    ];
  }

  Future<List<Serie>> getUpcoming() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      Serie(
        id: 6,
        title: 'House of the Dragon - Saison 2',
        imageUrl:
            'https://m.media-amazon.com/images/I/81ucYvfZ4KL._AC_UF894,1000_QL80_.jpg',
        rating: 8.5,
        releaseDate: '16 juin 2025',
        description:
            'La saison 2 continue de raconter l\'histoire de la maison Targaryen, 200 ans avant les événements de Game of Thrones.',
        genres: ['Drame', 'Fantastique', 'Action'],
      ),
      Serie(
        id: 7,
        title: 'The Penguin',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/en/9/91/The_Penguin_%28TV_series%29_logo.jpg',
        rating: 8.2,
        releaseDate: '1 juillet 2025',
        description:
            'Une série dérivée du film The Batman qui se concentre sur le personnage du Pingouin et son ascension dans le monde criminel de Gotham.',
        genres: ['Crime', 'Drame', 'Action'],
      ),
      Serie(
        id: 8,
        title: 'The Lord of the Rings: The Rings of Power - Saison 2',
        imageUrl:
            'https://m.media-amazon.com/images/I/71VzL2xO13L._AC_UF894,1000_QL80_.jpg',
        rating: 7.5,
        releaseDate: '29 août 2025',
        description:
            'Des milliers d\'années avant les événements du Hobbit et du Seigneur des Anneaux, cette épopée dramatique suit un casting de personnages confrontés à la réapparition du mal en Terre du Milieu.',
        genres: ['Fantastique', 'Aventure', 'Drame'],
      ),
      Serie(
        id: 9,
        title: 'Dune: Prophecy',
        imageUrl:
            'https://cdn.vox-cdn.com/uploads/chorus_asset/file/24626606/dune_prophecy_bene_gesserit_hbo.jpg',
        rating: 8.9,
        releaseDate: '15 septembre 2025',
        description:
            'Préquelle de Dune qui explore l\'univers de Frank Herbert à travers les yeux d\'un ordre mystérieux de femmes connu sous le nom de Bene Gesserit.',
        genres: ['Science-Fiction', 'Drame', 'Aventure'],
      ),
      Serie(
        id: 10,
        title: 'The Last of Us - Saison 2',
        imageUrl:
            'https://media.gq-magazine.co.uk/photos/6423b2b0d432fee4a15f2f0a/16:9/w_2560%2Cc_limit/EDIT_The-Last-of-Us-Season-2-what-we-know-1366-1366.jpg',
        rating: 9.0,
        releaseDate: '20 octobre 2025',
        description:
            'La suite des aventures de Joel et Ellie dans un monde post-apocalyptique, basée sur le jeu vidéo The Last of Us Part II.',
        genres: ['Drame', 'Action', 'Horreur'],
      ),
    ];
  }
}
