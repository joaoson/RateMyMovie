# 🎬 RateMyMovie

> Um aplicativo multiplataforma para gerenciar seu catálogo pessoal de filmes, com avaliações e sincronização.

# [Video de Demonstração](https://www.youtube.com/watch?v=Ux1nDswYow0)

## 📋 Visão Geral

RateMyMovie é um projeto acadêmico (PjBL) que demonstra desenvolvimento de aplicação mobile/web completa com:

- ✅ Autenticação local de usuários
- ✅ Busca de filmes via API TMDB
- ✅ Sistema de avaliação (1-5 estrelas)
- ✅ Gerenciamento de lista pessoal de filmes
- ✅ Persistência local com SQLite
- ✅ Multi-plataforma (iOS, Android, Web, macOS, Windows, Linux)
- ✅ Acessibilidade (a11y) para leitores de tela
- ✅ Gerenciamento de estado com Provider

## 🎯 Requisitos Funcionais (MVP)

### RF01 - Fluxo de Autenticação Local ✓
Login e cadastro com persistência, foto de perfil, múltiplos usuários locais

### RF02 - Tela de Perfil ✓
Exibição e edição de dados (nome, email, senha), gerenciamento de foto

### RF03 - Busca de Filmes ✓
Campo de busca em tempo real integrado com TMDB API

### RF04 - Detalhes e Avaliação ✓
Tela detalhada com rating 1-5 estrelas e campo de review

### RF05 - Meus Filmes Assistidos ✓
Lista de filmes avaliados do usuário logado, exclusão de avaliações

### RF06 - Persistência de Dados Local ✓
Filmes e avaliações salvos localmente, associados ao usuário

### RF07 - Acessibilidade (a11y) ✓
Leitores de tela, rótulos descritivos, alt text, foco gerenciado, alvos 44x44px

## 🏗️ Arquitetura

**MVC + Provider Pattern**

### Componentes Principais

#### Models
- **UserModel**: Dados do usuário cadastrado
- **MovieModel**: Dados do filme da API TMDB
- **RatedMovieModel**: Avaliação do usuário sobre um filme

#### Controllers (State Management)
- **AuthController**: Gerencia login, register, perfil
- **MovieController**: Gerencia busca de filmes
- **RatedMoviesController**: Gerencia filmes avaliados do usuário

#### Services (Business Logic)
- **AuthService**: Autenticação e gerenciamento de usuários (SQLite)
- **DatabaseService**: Operações com banco de dados (SQLite)
- **TMDBService**: Requisições à API TMDB (HTTP)

#### Screens (UI)
- **Auth Flow**: SplashScreen, LoginScreen, RegisterScreen
- **Home Flow**: HomeScreen, SearchScreen, MyMoviesScreen, ProfileScreen, MovieDetailsScreen

#### Components (Reusable Widgets)
- **MovieCard**: Exibe filme em busca (título, data, cartaz, sinopse)
- **RatedMovieCard**: Exibe filme avaliado (rating visual, review)
- **CompactMovieCard**: Versão compacta de um cartão
- **CustomButton**: Botão customizado com estilos
- **CustomTextField**: Campo de texto com validação
- **ProfileImagePicker**: Seletor de foto (câmera/galeria)

## 🛠️ Stack Tecnológico

- **Dart** 3.0+
- **Flutter** com Material Design 3
- **SQLite** para banco de dados local
- **Provider** para state management
- **HTTP** para requisições da API
- **image_picker** para seleção de fotos
- **Plataformas**: Android, iOS, Web, macOS, Windows, Linux

## 📦 Modelos de Dados

### UserModel
```dart
class UserModel {
  int? id;                    // ID único do usuário
  String name;               // Nome completo
  String email;              // Email (único no banco)
  String password;           // Senha (texto plano no MVP)
  String? profileImagePath;  // Caminho da foto de perfil
}
```

### MovieModel
```dart
class MovieModel {
  int id;                    // ID da API TMDB
  String title;              // Título do filme
  String overview;           // Sinopse/descrição
  String? posterPath;        // URL do cartaz
  String? backdropPath;      // URL da imagem de fundo
  double voteAverage;        // Nota média (0-10)
  String releaseDate;        // Data de lançamento
  List<int> genreIds;        // IDs dos gêneros
}
```

### RatedMovieModel
```dart
class RatedMovieModel {
  int? id;                   // ID da avaliação no BD local
  int userId;                // ID do usuário que avaliou
  int movieId;               // ID do filme (TMDB)
  String movieTitle;         // Título do filme (cache)
  String? moviePosterPath;   // URL do cartaz (cache)
  double userRating;         // Avaliação do usuário (1-5)
  String? userReview;        // Comentário do usuário
  DateTime ratedAt;          // Data e hora da avaliação
}
```

## 🗄️ Banco de Dados (SQLite)

### Tabela: users
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  profileImagePath TEXT
);
```

### Tabela: rated_movies
```sql
CREATE TABLE rated_movies (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  userId INTEGER NOT NULL,
  movieId INTEGER NOT NULL,
  movieTitle TEXT NOT NULL,
  moviePosterPath TEXT,
  userRating REAL NOT NULL,
  userReview TEXT,
  ratedAt TEXT NOT NULL,
  FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
);
```

## 🔐 Segurança

⚠️ MVP: API key hardcoded, senhas em texto plano, sem criptografia local

✅ Para Produção: Hash de senhas, API key em variáveis de ambiente, Firebase/Supabase, criptografia local

## 🚀 Funcionalidades Avançadas (Plus)

**Opção A**: Sincronização em Nuvem com Firebase/Supabase
**Opção B**: Recomendações com IA (Gemini/OpenAI)

## ♿ Acessibilidade (WCAG 2.1)

- Rótulos semânticos, alt text em imagens, foco gerenciado, alvos mínimos 44x44 dp
- Compatibilidade TalkBack (Android) e VoiceOver (iOS)

## 🔧 Instalação

```bash
git clone https://github.com/seu-usuario/RateMyMovie.git
cd RateMyMovie/rate_my_movie
flutter pub get
flutter run
```

## 📊 State Management (Provider)

- AuthController: Login, register, profile
- MovieController: Busca de filmes
- RatedMoviesController: Gerenciamento de avaliações

## 📝 Fluxos Principais

### Fluxo de Autenticação
```
SplashScreen → Verificar autenticação
├─ Autenticado → HomeScreen
└─ Não autenticado → LoginScreen
   ├─ Login válido → HomeScreen
   └─ Criar conta → RegisterScreen → Selecionar foto → HomeScreen
```

### Fluxo de Busca e Avaliação
```
SearchScreen (digitação)
  ↓ MovieController.searchMovies()
  ↓ TMDBService (API HTTP)
  ↓ MovieCard (lista de resultados)
  ↓ Toque em filme
  ↓ MovieDetailsScreen
  ↓ Rating (1-5⭐) + Review
  ↓ RatedMoviesController.addRatedMovie()
  ↓ DatabaseService.insert() (SQLite)
  ↓ MyMoviesScreen (atualiza automaticamente)
```

### Fluxo Multi-usuário
```
User A logado (filmes: 1, 2, 3)
  ↓ Logout
User B faz Login
  ↓ MyMoviesScreen mostra apenas filmes de B
User A faz Login novamente
  ↓ MyMoviesScreen volta aos filmes de A
```

## 📱 Dependências Principais

```yaml
dependencies:
  # State Management
  provider: ^6.1.1              # Gerenciamento de estado reativo

  # Persistência Local
  shared_preferences: ^2.2.2    # Preferências do aplicativo
  sqflite: ^2.3.0               # Banco de dados SQLite

  # Sistema de Arquivos e Mídia
  path_provider: ^2.1.1         # Acesso ao sistema de arquivos
  image_picker: ^1.0.4          # Seletor de imagens (câmera/galeria)

  # Networking
  http: ^1.1.0                  # Requisições HTTP/HTTPS

  # UI & Widgets
  cached_network_image: ^3.3.0  # Cache e carregamento de imagens
  flutter_rating_bar: ^4.0.1    # Widget de rating visual

  # Utilities
  intl: ^0.18.1                 # Internacionalização de datas

  # iOS Specific
  cupertino_icons: ^1.0.2       # Ícones iOS (Cupertino)
```

## 🏆 Diferenciais do Projeto

- ✨ **Architecture**: Padrão MVC + Provider bem estruturado
- ✨ **Acessibilidade**: Implementação WCAG 2.1 AA completa
- ✨ **Multi-plataforma**: Mesmo código em 6 plataformas diferentes
- ✨ **Offline-first**: Funciona completamente sem internet
- ✨ **UI/UX**: Material Design 3 com componentes customizados
- ✨ **Code Quality**: Padrões Flutter e Dart recomendados
