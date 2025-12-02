import 'package:flutter/material.dart';
import 'services/drupal_service.dart';

//https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DIYeta',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // indice della pagina selezionata
  late final DrupalService _drupalService;

  @override
  void initState() {
    super.initState();
    _drupalService = DrupalService();
  }

  // Lista delle pagine associate ai pulsanti
  late final List<Widget> _pages = [
    HomePage(drupalService: _drupalService),
    Center(child: Text('Alimenti Page')),
    Center(child: Text('Pasti Page')),
    Center(child: Text('Giornate Page')),
    Center(child: Text('User Page')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( //barra in alto
        title: Text('DIYeta'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _pages[_selectedIndex], // mostra la pagina selezionata
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem> [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Alimenti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Pasti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Giornate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final DrupalService drupalService;

  const HomePage({super.key, required this.drupalService});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Article>>(
      future: drupalService.fetchArticles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Errore: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Nessun articolo trovato'),
          );
        } else {
          final articles = snapshot.data!;
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(article.title),
                  subtitle: article.body != null
                      ? Text(
                          article.body!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                ),
              );
            },
          );
        }
      },
    );
  }
}
