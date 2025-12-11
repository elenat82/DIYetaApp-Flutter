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
    final url = Uri.parse('$baseUrl/jsonapi/node/alimento?include=field_marca');

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

  const Alimento({required this.id, required this.title, this.marca});

  factory Alimento.fromJson(Map<String, dynamic> json, Map<String, Map<String, dynamic>> includedById) {
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};
    final relationships = json['relationships'] as Map<String, dynamic>? ?? {};
    String? marcaName;
    final marcaRefId = relationships['field_marca']?['data']?['id'] as String?;
    if (marcaRefId != null) {
      final inc = includedById[marcaRefId];
      marcaName = inc?['attributes']?['name'] as String?;
    }

    return Alimento(
      id: json['id'] as String? ?? '',
      title: attributes['title'] as String? ?? 'No title',
      marca: marcaName,
    );
  }
}