import 'dart:convert'; //fornisce jsonDecode
import 'package:http/http.dart' as http;
import 'dart:async';

//https://docs.flutter.dev/cookbook/networking/fetch-data

class DrupalService {
  static const String baseUrl = 'https://diyeta.ddev.site';

  Future<List<Article>> fetchArticles() async {
    final url = Uri.parse('$baseUrl/jsonapi/node/article');

    final response = await http.get(url);

    print('Response: ${response.body}');

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
