class RatedMovieModel {
  final int? id;
  final int userId;
  final int movieId;
  final String movieTitle;
  final String? moviePosterPath;
  final double userRating;
  final String? userReview;
  final DateTime ratedAt;

  RatedMovieModel({
    this.id,
    required this.userId,
    required this.movieId,
    required this.movieTitle,
    this.moviePosterPath,
    required this.userRating,
    this.userReview,
    required this.ratedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'moviePosterPath': moviePosterPath,
      'userRating': userRating,
      'userReview': userReview,
      'ratedAt': ratedAt.toIso8601String(),
    };
  }

  factory RatedMovieModel.fromMap(Map<String, dynamic> map) {
    return RatedMovieModel(
      id: map['id'],
      userId: map['userId'],
      movieId: map['movieId'],
      movieTitle: map['movieTitle'],
      moviePosterPath: map['moviePosterPath'],
      userRating: map['userRating'],
      userReview: map['userReview'],
      ratedAt: DateTime.parse(map['ratedAt']),
    );
  }

  String get fullPosterUrl => moviePosterPath != null
      ? 'https://image.tmdb.org/t/p/w500$moviePosterPath'
      : '';
}