import 'dart:convert'; //fornisce jsonDecode
import 'package:http/http.dart' as http;
import 'dart:async';

//https://docs.flutter.dev/cookbook/networking/fetch-data

class DrupalService {
  static const String baseUrl = 'https://diyeta.ddev.site';

  Future<List<Article>> fetchArticles() async {
    final url = Uri.parse('$baseUrl/jsonapi/node/article');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> articlesJson = jsonData['data'] ?? [];
      
      return articlesJson
          .map((article) => Article.fromJson(article as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load articles');
    }
  }

  Future<List<Alimento>> fetchAlimenti() async {
    final url = Uri.parse('$baseUrl/jsonapi/node/alimento?include=field_marca,field_valori_nutrizionali');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> alimentiJson = jsonData['data'] ?? [];
      final List<dynamic> included = jsonData['included'] as List<dynamic>? ?? [];
      final Map<String, Map<String, dynamic>> includedById = {};
      for (final inc in included) {
        if (inc is Map<String, dynamic> && inc['id'] != null) {
          includedById[inc['id'] as String] = inc;
        }
      }

      return alimentiJson
          .map((alimento) => Alimento.fromJson(alimento as Map<String, dynamic>, includedById))
          .toList();
    } else {
      throw Exception('Failed to load alimenti');
    }
  }
}

class Article {
  final String id;
  final String title;
  final String? body;

  const Article({required this.id, required this.title, this.body});

  factory Article.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};
    
    return Article(
      id: json['id'] as String? ?? '',
      title: attributes['title'] as String? ?? 'No title',
      body: attributes['body']?['value'] as String?,
    );
  }
}

class Alimento {
  final String id;
  final String title;
  final String? marca;
  final List<ValoreNutrizionale> valoriNutrizionali;

  const Alimento({
    required this.id,
    required this.title,
    this.marca,
    this.valoriNutrizionali = const [],
  });

  factory Alimento.fromJson(Map<String, dynamic> json, Map<String, Map<String, dynamic>> includedById) {
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};
    final relationships = json['relationships'] as Map<String, dynamic>? ?? {};
    
    String? marcaName;
    final marcaRefId = relationships['field_marca']?['data']?['id'] as String?;
    if (marcaRefId != null) {
      final inc = includedById[marcaRefId];
      marcaName = inc?['attributes']?['name'] as String?;
    }

    List<ValoreNutrizionale> valori = [];
    final valoriRelationship = relationships['field_valori_nutrizionali'] as Map<String, dynamic>? ?? {};
    final valoriData = valoriRelationship['data'] as Map<String, dynamic>?;
    
    if (valoriData != null) {
      final valoriId = valoriData['id'] as String?;
      if (valoriId != null && includedById.containsKey(valoriId)) {
        final valoriObj = includedById[valoriId];
        final valore = ValoreNutrizionale.fromJson(valoriObj!);
        valori.add(valore);
      }
    }

    return Alimento(
      id: json['id'] as String? ?? '',
      title: attributes['title'] as String? ?? 'No title',
      marca: marcaName,
      valoriNutrizionali: valori,
    );
  }
}

class ValoreNutrizionale {
  final String id;
  final double? kcal;
  final double? carboidrati;
  final double? grassi;
  final double? proteine;

  const ValoreNutrizionale({
    required this.id,
    this.kcal,
    this.carboidrati,
    this.grassi,
    this.proteine,
  });

  factory ValoreNutrizionale.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};

    return ValoreNutrizionale(
      id: json['id'] as String? ?? '',
      kcal: _toDouble(attributes['field_kcal']),
      carboidrati: _toDouble(attributes['field_carboidrati']),
      grassi: _toDouble(attributes['field_grassi']),
      proteine: _toDouble(attributes['field_proteine']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}