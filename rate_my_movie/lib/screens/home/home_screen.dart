import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/rated_movies_controller.dart';
import 'search_screen.dart';
import 'my_movies_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRatedMovies();
  }

  Future<void> _loadRatedMovies() async {
    // Aguarda um frame para garantir que o build está completo
    await Future.delayed(Duration.zero);
    
    if (!mounted) return;
    
    final authController = Provider.of<AuthController>(context, listen: false);
    final ratedMoviesController = Provider.of<RatedMoviesController>(context, listen: false);
    
    if (authController.currentUser != null) {
      await ratedMoviesController.loadUserRatedMovies(authController.currentUser!.id!);
    }
  }

  final List<Widget> _screens = [
    const SearchScreen(),
    const MyMoviesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Meus Filmes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}