import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/rated_movie_model.dart';
import 'package:intl/intl.dart';

class RatedMovieCard extends StatelessWidget {
  final RatedMovieModel movie;
  final VoidCallback? onDelete;

  const RatedMovieCard({
    Key? key,
    required this.movie,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: movie.moviePosterPath != null
                  ? CachedNetworkImage(
                      imageUrl: movie.fullPosterUrl,
                      width: 70,
                      height: 105,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 70,
                        height: 105,
                        color: Colors.grey.shade300,
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 70,
                        height: 105,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.movie, size: 30),
                      ),
                    )
                  : Container(
                      width: 70,
                      height: 105,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.movie, size: 30),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.movieTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  RatingBarIndicator(
                    rating: movie.userRating,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 20.0,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Avaliado em ${DateFormat('dd/MM/yyyy').format(movie.ratedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (movie.userReview != null && movie.userReview!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      movie.userReview!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}