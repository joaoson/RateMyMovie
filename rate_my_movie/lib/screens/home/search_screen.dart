import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/movie_controller.dart';
import '../../components/movie_card.dart';
import '../../components/compact_movie_card.dart';
import 'movie_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load top rated movies on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<MovieController>(context, listen: false).loadTopRatedMovies();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    Provider.of<MovieController>(context, listen: false).searchMovies(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar filmes...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            Provider.of<MovieController>(context, listen: false)
                                .clearSearch();
                            setState(() {});
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onSubmitted: _onSearch,
                onChanged: (value) {
                  setState(() {});
                  if (value.isEmpty) {
                    Provider.of<MovieController>(context, listen: false)
                        .clearSearch();
                  }
                },
              ),
            ),
            
            // Content
            Expanded(
              child: Consumer<MovieController>(
                builder: (context, movieController, child) {
                  // Show search results if searching
                  if (movieController.searchQuery.isNotEmpty) {
                    if (movieController.isSearching) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (movieController.searchResults.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum filme encontrado',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: movieController.searchResults.length,
                      itemBuilder: (context, index) {
                        final movie = movieController.searchResults[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: MovieCard(
                            movie: movie,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => MovieDetailsScreen(movie: movie),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }

                  // Show top rated movies when no search
                  if (movieController.isLoadingTopRated) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (movieController.topRatedMovies.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.movie_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erro ao carregar filmes',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Filmes Mais Bem Avaliados',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: movieController.topRatedMovies.length,
                            itemBuilder: (context, index) {
                              final movie = movieController.topRatedMovies[index];
                              return CompactMovieCard(
                                movie: movie,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MovieDetailsScreen(movie: movie),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}