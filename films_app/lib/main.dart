import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Film',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

@immutable
class Film {
  final String id;
  final String title;
  final String decription;
  final bool isFavorite;

  const Film({
    required this.id,
    required this.title,
    required this.decription,
    required this.isFavorite,
  });

  Film copy({required bool isFavorite}) => Film(
        id: id,
        title: title,
        decription: decription,
        isFavorite: isFavorite,
      );

  @override
  String toString() => '''Film(
        id: $id,
        title: $title,
        decription: $decription,
        isFavorite: $isFavorite,
      )''';

  @override
  bool operator ==(covariant Film other) =>
      id == other.id && isFavorite == other.isFavorite;

  @override
  int get hashCode => Object.hashAll([id, isFavorite]);
}

const allFilms = [
  Film(
    id: '1',
    title: 'The Shawshank Redemption',
    decription: 'Decription for The Shawshank Redemption',
    isFavorite: false,
  ),
  Film(
    id: '2',
    title: 'Fast and slow',
    decription: 'Decription for Fast and slow',
    isFavorite: false,
  ),
  Film(
    id: '3',
    title: 'Alchemy of Souls',
    decription: 'Decription for Alchemy of Souls',
    isFavorite: false,
  ),
  Film(
    id: '4',
    title: 'The great wall',
    decription: 'Decription for The great wall',
    isFavorite: false,
  ),
];

class FilmNotifier extends StateNotifier<List<Film>> {
  FilmNotifier() : super(allFilms);

  void update({required Film film, required bool isFavorite}) {
    state = state
        .map(
          (thisFilm) => thisFilm.id == film.id
              ? thisFilm.copy(
                  isFavorite: isFavorite,
                )
              : thisFilm,
        )
        .toList();
  }
}

enum FavoriteStatus {
  all,
  favorite,
  notfavorite,
}

final favoriteStatusProvider = StateProvider<FavoriteStatus>(
  (ref) => FavoriteStatus.all,
);

final allFilmsProvider = StateNotifierProvider<FilmNotifier, List<Film>>(
  (ref) => FilmNotifier(),
);

final favoriteFilmsProvider = Provider<Iterable<Film>>(
  (ref) {
    return ref.watch(allFilmsProvider).where(
          (film) => film.isFavorite,
        );
  },
);
final notFavoriteFilmsProvider = Provider<Iterable<Film>>(
  (ref) {
    return ref.watch(allFilmsProvider).where(
          (film) => !film.isFavorite,
        );
  },
);

class MyHomePage extends ConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Films'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const FilterWidget(),
          Consumer(
            builder: (context, ref, child) {
              final filter = ref.watch(favoriteStatusProvider);
              switch (filter) {
                case FavoriteStatus.all:
                  return FilmsWidget(provider: allFilmsProvider);
                  
                case FavoriteStatus.favorite:
                  return FilmsWidget(provider: favoriteFilmsProvider);
                  
                
                case FavoriteStatus.notfavorite:
                  return FilmsWidget(provider: notFavoriteFilmsProvider);
                 
                 
              }
            },
          )
        ],
      ),
    );
  }
}

class FilmsWidget extends ConsumerWidget {
  final AlwaysAliveProviderBase<Iterable<Film>> provider;
  const FilmsWidget({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final films = ref.watch(provider);
    return Expanded(
      child: ListView.builder(
        itemCount: films.length,
        itemBuilder: (context, index) {
          final film = films.elementAt(index);
          final favoriteIcon = film.isFavorite
              ? const Icon(Icons.favorite)
              : const Icon(Icons.favorite_border);

          return ListTile(
            title: Text(film.title),
            subtitle: Text(film.decription),
            trailing: IconButton(
              icon: favoriteIcon,
              onPressed: () {
                final isFavorite = !film.isFavorite;
                ref
                    .read(allFilmsProvider.notifier)
                    .update(film: film, isFavorite: isFavorite);
              },
            ),
          );
        },
      ),
    );
  }
}

class FilterWidget extends StatelessWidget {
  const FilterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return DropdownButton(
            value: ref.watch(favoriteStatusProvider),
            items: FavoriteStatus.values
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e.toString().split('.').last,
                    ),
                  ),
                )
                .toList(),
            onChanged: (FavoriteStatus? fs) {
              ref
                  .read(
                    favoriteStatusProvider.state,
                  )
                  .state = fs!;
            });
      },
    );
  }
}
