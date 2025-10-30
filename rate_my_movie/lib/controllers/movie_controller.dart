import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/tmdb_service.dart';

class MovieController with ChangeNotifier {
  final TMDBService _tmdbService = TMDBService();
  
  List<MovieModel> _searchResults = [];
  List<MovieModel> _topRatedMovies = [];
  bool _isSearching = false;
  bool _isLoadingTopRated = false;
  String _searchQuery = '';

  List<MovieModel> get searchResults => _searchResults;
  List<MovieModel> get topRatedMovies => _topRatedMovies;
  bool get isSearching => _isSearching;
  bool get isLoadingTopRated => _isLoadingTopRated;
  String get searchQuery => _searchQuery;

  Future<void> loadTopRatedMovies() async {
    _isLoadingTopRated = true;
    notifyListeners();

    try {
      _topRatedMovies = await _tmdbService.getTopRatedMovies();
    } catch (e) {
      print('Error loading top rated movies: $e');
      _topRatedMovies = [];
    }

    _isLoadingTopRated = false;
    notifyListeners();
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }

    _searchQuery = query;
    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await _tmdbService.searchMovies(query);
    } catch (e) {
      print('Error in searchMovies: $e');
      _searchResults = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    notifyListeners();
  }
}
