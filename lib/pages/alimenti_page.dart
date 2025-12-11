import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../services/drupal_service.dart';

class AlimentiPage extends StatefulWidget {
  const AlimentiPage({super.key});

  @override
  State<AlimentiPage> createState() => _AlimentiPageState();
}

class _AlimentiPageState extends State<AlimentiPage> {
    late final DrupalService _drupalService;

    @override
    void initState() {
      super.initState();
      _drupalService = DrupalService();
    }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Alimento>>(
      future: _drupalService.fetchAlimenti(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Errore: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Nessun alimento trovato'),
          );
        } else {
          final alimenti = snapshot.data!;
          return ListView.builder(
            itemCount: alimenti.length,
            itemBuilder: (context, index) {
              final food = alimenti[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 6.0),
                      if (food.marca != null)
                        Text(
                          'Marca: ${food.marca}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
