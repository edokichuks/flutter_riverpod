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
      title: 'Timer App',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

const names = [
  'chuks',
  'Jerry',
  'Godson',
  'Micheal',
  'Edoki',
  'Emma',
  'Efe',
  'Collins',
  'Favour',
  'Wisdom',
];

final tickerProvider = StreamProvider(
  (ref) {
    return Stream.periodic(const Duration(seconds: 1), (i) => i + 1);
  },
);

final namesProvider = StreamProvider(
  (ref) => ref.watch(tickerProvider.stream).map(
        (count) => names.getRange(
          0,
          count,
        ),
      ),
);

class MyHomePage extends ConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = ref.watch(namesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer App (StreamProvider)'),
        centerTitle: true,
      ),
      body: names.when(
          data: (named) {
            return ListView.builder(
              itemCount: named.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(named.elementAt(index)),
                );
              },
            );
          },
          error: (error, stackTrace) =>
              const Center(child: Text('Reached the end of the list')),
          loading: () => const Center(child: CircularProgressIndicator())),
    );
  }
}
