import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class TMDBService {
  // IMPORTANTE: Substitua pela sua API Key do TMDb
  static const String _apiKey = 'a0eda993e3361e6cb38eac4b37055c9d';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<MovieModel>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=$query&language=pt-BR'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => MovieModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error searching movies: $e');
      return [];
    }
  }

  Future<MovieModel?> getMovieDetails(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey&language=pt-BR'),
      );

      if (response.statusCode == 200) {
        return MovieModel.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error getting movie details: $e');
      return null;
    }
  }

  Future<List<MovieModel>> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/top_rated?api_key=$_apiKey&language=pt-BR&page=$page'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => MovieModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting top rated movies: $e');
      return [];
    }
  }

  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&language=pt-BR&page=$page'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => MovieModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting popular movies: $e');
      return [];
    }
  }
}
