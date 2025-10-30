import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/rated_movies_controller.dart';
import '../../components/rated_movie_card.dart';

class MyMoviesScreen extends StatelessWidget {
  const MyMoviesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Filmes Assistidos'),
        elevation: 0,
      ),
      body: Consumer<RatedMoviesController>(
        builder: (context, ratedMoviesController, child) {
          if (ratedMoviesController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (ratedMoviesController.ratedMovies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.movie_creation_outlined,
                    size: 100,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum filme avaliado ainda',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Busque e avalie seus filmes favoritos',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: ratedMoviesController.ratedMovies.length,
            itemBuilder: (context, index) {
              final movie = ratedMoviesController.ratedMovies[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: RatedMovieCard(
                  movie: movie,
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Remover Avaliação'),
                        content: const Text(
                          'Tem certeza que deseja remover esta avaliação?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              ratedMoviesController.deleteRatedMovie(movie.id!);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Avaliação removida'),
                                ),
                              );
                            },
                            child: const Text(
                              'Remover',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}