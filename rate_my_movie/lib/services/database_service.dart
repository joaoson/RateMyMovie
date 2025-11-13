import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/rated_movie_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rate_my_movie.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullType = 'TEXT';
    const doubleType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name $textType,
        email $textType,
        password $textType,
        profileImagePath $textNullType
      )
    ''');

    await db.execute('''
      CREATE TABLE rated_movies (
        id $idType,
        userId $intType,
        movieId $intType,
        movieTitle $textType,
        moviePosterPath $textNullType,
        userRating $doubleType,
        userReview $textNullType,
        ratedAt $textType,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // User operations
  Future<UserModel> createUser(UserModel user) async {
    final db = await instance.database;
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  // Rated Movies operations
  Future<int> addRatedMovie(RatedMovieModel movie) async {
    final db = await instance.database;
    return await db.insert('rated_movies', movie.toMap());
  }

  Future<List<RatedMovieModel>> getUserRatedMovies(int userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'rated_movies',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'ratedAt DESC',
    );

    return maps.map((map) => RatedMovieModel.fromMap(map)).toList();
  }

  Future<RatedMovieModel?> getRatedMovie(int userId, int movieId) async {
    final db = await instance.database;
    final maps = await db.query(
      'rated_movies',
      where: 'userId = ? AND movieId = ?',
      whereArgs: [userId, movieId],
    );

    if (maps.isNotEmpty) {
      return RatedMovieModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateRatedMovie(RatedMovieModel movie) async {
    final db = await instance.database;
    return await db.update(
      'rated_movies',
      movie.toMap(),
      where: 'id = ?',
      whereArgs: [movie.id],
    );
  }

  Future<int> deleteRatedMovie(int id) async {
    final db = await instance.database;
    return await db.delete(
      'rated_movies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

// Extension for UserModel
extension UserModelExtension on UserModel {
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? profileImagePath,
    bool clearProfileImagePath = false,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      profileImagePath: clearProfileImagePath ? null : (profileImagePath ?? this.profileImagePath),
    );
  }
}