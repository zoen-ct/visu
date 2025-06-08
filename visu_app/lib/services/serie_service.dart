import '/visu.dart';

class SerieService {
  Future<List<Serie>> getWatchlist() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      Serie(
        id: 1396,
        title: 'Breaking Bad',
        imageUrl:
            'https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg',
        rating: 8.5,
        releaseDate: '2008-01-20',
        description:
            'Walter White, professeur de chimie dans un lycée, devient fabricant de méthamphétamine après avoir appris qu\'il est atteint d\'un cancer du poumon en phase terminale.',
        genres: ['Drame', 'Crime'],
      ),
      Serie(
        id: 1399,
        title: 'Game of Thrones',
        imageUrl:
            'https://image.tmdb.org/t/p/w500/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg',
        rating: 8.3,
        releaseDate: '2011-04-17',
        description:
            'Sur le continent de Westeros, le roi Robert Baratheon gouverne le Royaume des Sept Couronnes depuis plus de dix-sept ans, à la suite de la rébellion qu\'il a menée contre le roi fou, Aerys II Targaryen.',
        genres: ['Drame', 'Fantastique', 'Action & Aventure'],
      ),
      Serie(
        id: 66732,
        title: 'Stranger Things',
        imageUrl:
            'https://image.tmdb.org/t/p/w500/49WJfeN0moxb9IPfGn8AIqMGskD.jpg',
        rating: 8.6,
        releaseDate: '2016-07-15',
        description:
            'À Hawkins, dans l\'Indiana, en 1983. Lorsque Will Byers disparaît de son domicile, ses amis se lancent dans une recherche pour le retrouver. Dans leur quête de réponses, ils rencontrent une étrange jeune fille en fuite.',
        genres: ['Drame', 'Fantastique', 'Mystère'],
      ),
      Serie(
        id: 60735,
        title: 'The Flash',
        imageUrl:
            'https://image.tmdb.org/t/p/w500/lJA2RCMfsWoskqlQhXPSLFQGXEJ.jpg',
        rating: 7.7,
        releaseDate: '2014-10-07',
        description:
            'Neuf mois après avoir été frappé par la foudre, Barry Allen se réveille d\'un coma et découvre qu\'il a le pouvoir de se déplacer à une vitesse surhumaine.',
        genres: ['Drame', 'Science-Fiction', 'Fantastique'],
      ),
      Serie(
        id: 1416,
        title: 'Grey\'s Anatomy',
        imageUrl:
            'https://image.tmdb.org/t/p/w500/clnyhPqj1SNgpAdeSS6a6fwE6Bo.jpg',
        rating: 8.2,
        releaseDate: '2005-03-27',
        description:
            'Meredith Grey, fille d\'un chirurgien très réputé, commence son internat de première année en médecine chirurgicale dans un hôpital de Seattle.',
        genres: ['Drame'],
      ),
    ];
  }

  Future<List<Serie>> getUpcoming() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      Serie(
        id: 84958,
        title: 'Loki (Saison 2)',
        imageUrl:
            'https://image.tmdb.org/t/p/w500/voHUmluYmKyleFkTu3lO1wC8lYq.jpg',
        rating: 8.2,
        releaseDate: '2023-10-05',
        description:
            'Après avoir volé le Tesseract pendant les événements d\'Avengers: Endgame, une version alternative de Loki est amenée à la mystérieuse Time Variance Authority.',
        genres: ['Science-Fiction', 'Fantastique', 'Action & Aventure'],
      ),
      Serie(
        id: 94605,
        title: 'Arcane (Saison 2)',
        imageUrl:
            'https://image.tmdb.org/t/p/w500/fqldf2t8ztc9aiwn3k6mlX3tvRT.jpg',
        rating: 9.1,
        releaseDate: '2023-11-18',
        description:
            'Au milieu du conflit entre les villes jumelles de Piltover et Zaun, deux sœurs se battent dans des camps opposés.',
        genres: ['Animation', 'Science-Fiction', 'Action & Aventure', 'Drame'],
      ),
      Serie(
        id: 76479,
        title: 'The Boys (Saison 4)',
        imageUrl:
            'https://image.tmdb.org/t/p/w500/stTEycfG9928HYGEISBFaG1ngjM.jpg',
        rating: 8.4,
        releaseDate: '2023-09-22',
        description:
            'Dans un monde où les super-héros sont corrompus et gérés par une puissante corporation, un groupe de justiciers s\'unissent pour les combattre.',
        genres: ['Science-Fiction', 'Action & Aventure', 'Drame'],
      ),
      Serie(
        id: 71912,
        title: 'The Witcher (Saison 3)',
        imageUrl:
            'https://image.tmdb.org/t/p/w500/cZ0d3rtvXPVvuiX22sP79K3Hmvt.jpg',
        rating: 8.0,
        releaseDate: '2023-07-27',
        description:
            'Le sorceleur Geralt, un chasseur de monstres, se bat pour trouver sa place dans un monde où les humains se révèlent souvent plus vicieux que les bêtes.',
        genres: ['Drame', 'Fantastique', 'Action & Aventure'],
      ),
      Serie(
        id: 63174,
        title: 'Lucifer (Final)',
        imageUrl:
            'https://image.tmdb.org/t/p/w500/ekZobS8isE6mA53RAiGDG93hBxL.jpg',
        rating: 8.5,
        releaseDate: '2023-12-15',
        description:
            'Lassé d\'être le Seigneur des Enfers, le diable s\'installe à Los Angeles où il ouvre un nightclub et se lie avec une policière.',
        genres: ['Crime', 'Science-Fiction', 'Fantastique'],
      ),
    ];
  }

  Future<List<Serie>> getPopularSeries() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      Serie(
        id: 1,
        title: 'Stranger Things',
        imageUrl:
            'https://image.tmdb.org/t/p/w500/49WJfeN0moxb9IPfGn8AIqMGskD.jpg',
        rating: 8.6,
        releaseDate: '2016-07-15',
        description:
            'Quand un jeune garçon disparaît, une petite ville découvre une affaire mystérieuse, des expériences secrètes, des forces surnaturelles terrifiantes... et une fillette.',
        genres: ['Drame', 'Fantastique', 'Mystère'],
      ),
      Serie(
        id: 2,
        title: 'The Witcher',
        imageUrl:
            'https://image.tmdb.org/t/p/w500/7vjaCdMw15FEbXyLQTVa04URsPm.jpg',
        rating: 8.2,
        releaseDate: '2019-12-20',
        description:
            'Geralt de Riv, un chasseur de monstres mutant, poursuit son destin dans un monde chaotique où les humains sont souvent plus vicieux que les bêtes.',
        genres: ['Action', 'Aventure', 'Drame'],
      ),
      Serie(
        id: 3,
        title: 'Breaking Bad',
        imageUrl:
            'https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg',
        rating: 8.8,
        releaseDate: '2008-01-20',
        description:
            'Un professeur de chimie atteint d\'un cancer s\'associe à un ancien élève pour fabriquer et vendre de la méthamphétamine afin d\'assurer l\'avenir financier de sa famille.',
        genres: ['Drame', 'Crime', 'Thriller'],
      ),
      Serie(
        id: 4,
        title: 'Game of Thrones',
        imageUrl:
            'https://image.tmdb.org/t/p/w500/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg',
        rating: 8.4,
        releaseDate: '2011-04-17',
        description:
            'Neuf familles nobles rivalisent pour le contrôle du Trône de Fer dans les sept royaumes de Westeros.',
        genres: ['Drame', 'Fantastique', 'Action'],
      ),
      Serie(
        id: 5,
        title: 'The Crown',
        imageUrl:
            'https://image.tmdb.org/t/p/w500/5aUP5gFrG5hXeKnhNHj4C7QjIDg.jpg',
        rating: 8.1,
        releaseDate: '2016-11-04',
        description:
            'La série se concentre sur la reine Élisabeth II, alors âgée de 25 ans et confrontée à la tâche ardue de diriger la plus célèbre monarchie du monde tout en forgeant une relation avec le Premier ministre britannique Sir Winston Churchill.',
        genres: ['Drame', 'Histoire', 'Biographie'],
      ),
    ];
  }

  Future<List<Serie>> searchSeries(String query) async {
    await Future.delayed(const Duration(seconds: 1));

    final allSeries = await getPopularSeries();
    if (query.isEmpty) return allSeries;

    return allSeries
        .where(
          (serie) => serie.title.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
