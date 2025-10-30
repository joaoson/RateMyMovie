import 'package:flutter/material.dart';
import '../models/rated_movie_model.dart';
import '../services/database_service.dart';

class RatedMoviesController with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  
  List<RatedMovieModel> _ratedMovies = [];
  bool _isLoading = false;

  List<RatedMovieModel> get ratedMovies => _ratedMovies;
  bool get isLoading => _isLoading;

  Future<void> loadUserRatedMovies(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _ratedMovies = await _databaseService.getUserRatedMovies(userId);
    } catch (e) {
      print('Error loading rated movies: $e');
      _ratedMovies = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addRatedMovie(RatedMovieModel movie) async {
    try {
      // Check if movie is already rated
      final existing = await _databaseService.getRatedMovie(
        movie.userId,
        movie.movieId,
      );

      if (existing != null) {
        // Update existing rating
        final updated = movie.copyWith(id: existing.id);
        await _databaseService.updateRatedMovie(updated);
        
        // Update in list
        final index = _ratedMovies.indexWhere((m) => m.id == existing.id);
        if (index != -1) {
          _ratedMovies[index] = updated;
        }
      } else {
        // Add new rating
        final id = await _databaseService.addRatedMovie(movie);
        _ratedMovies.insert(0, movie.copyWith(id: id));
      }

      notifyListeners();
      return true;
    } catch (e) {
      print('Error adding rated movie: $e');
      return false;
    }
  }

  Future<void> deleteRatedMovie(int id) async {
    try {
      await _databaseService.deleteRatedMovie(id);
      _ratedMovies.removeWhere((movie) => movie.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting rated movie: $e');
    }
  }

  RatedMovieModel? getRatedMovie(int userId, int movieId) {
    try {
      return _ratedMovies.firstWhere(
        (movie) => movie.userId == userId && movie.movieId == movieId,
      );
    } catch (e) {
      return null;
    }
  }
}

// Extension for RatedMovieModel
extension RatedMovieModelExtension on RatedMovieModel {
  RatedMovieModel copyWith({
    int? id,
    int? userId,
    int? movieId,
    String? movieTitle,
    String? moviePosterPath,
    double? userRating,
    String? userReview,
    DateTime? ratedAt,
  }) {
    return RatedMovieModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      moviePosterPath: moviePosterPath ?? this.moviePosterPath,
      userRating: userRating ?? this.userRating,
      userReview: userReview ?? this.userReview,
      ratedAt: ratedAt ?? this.ratedAt,
    );
  }
}