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
                      if (food.valoriNutrizionali.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Valori Nutrizionali:',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            SizedBox(height: 4.0),
                            ...food.valoriNutrizionali.map((valore) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (valore.kcal != null)
                                      Text('Kcal: ${valore.kcal}', style: Theme.of(context).textTheme.bodySmall),
                                    if (valore.proteine != null)
                                      Text('Proteine: ${valore.proteine}g', style: Theme.of(context).textTheme.bodySmall),
                                    if (valore.grassi != null)
                                      Text('Grassi: ${valore.grassi}g', style: Theme.of(context).textTheme.bodySmall),
                                    if (valore.carboidrati != null)
                                      Text('Carboidrati: ${valore.carboidrati}g', style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        )
                      else
                        Text('Nessun valore nutrizionale disponibile', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
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
