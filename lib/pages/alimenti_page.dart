import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(FontAwesomeIcons.tags, size: 14, color: const Color(0xFF5F7581)),
                            SizedBox(width: 6.0),
                            Text('Marca: ${food.marca}', style: Theme.of(context).textTheme.bodyMedium),
                          ],
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
                            Wrap(
                              spacing: 12.0,
                              runSpacing: 6.0,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: food.valoriNutrizionali.expand((valore) {
                                final items = <Widget>[];
                                if (valore.kcal != null) {
                                  items.add(Row(mainAxisSize: MainAxisSize.min, children: [FaIcon(FontAwesomeIcons.fire, size: 14, color: const Color(0xFFEF4444)), SizedBox(width: 6.0), Text('Kcal: ${valore.kcal}', style: Theme.of(context).textTheme.bodySmall)]));
                                }
                                if (valore.proteine != null) {
                                  items.add(Row(mainAxisSize: MainAxisSize.min, children: [FaIcon(FontAwesomeIcons.drumstickBite, size: 14, color: const Color(0xFF5E1D07)), SizedBox(width: 6.0), Text('Proteine: ${valore.proteine}g', style: Theme.of(context).textTheme.bodySmall)]));
                                }
                                if (valore.grassi != null) {
                                  items.add(Row(mainAxisSize: MainAxisSize.min, children: [FaIcon(FontAwesomeIcons.bacon, size: 14, color: const Color(0xFFA13738)), SizedBox(width: 6.0), Text('Grassi: ${valore.grassi}g', style: Theme.of(context).textTheme.bodySmall)]));
                                }
                                if (valore.carboidrati != null) {
                                  items.add(Row(mainAxisSize: MainAxisSize.min, children: [FaIcon(FontAwesomeIcons.breadSlice, size: 14, color: const Color(0xFFEDAA58)), SizedBox(width: 6.0), Text('Carboidrati: ${valore.carboidrati}g', style: Theme.of(context).textTheme.bodySmall)]));
                                }
                                return items;
                              }).toList(),
                            ),
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
