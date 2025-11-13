# Rate My Movie - Catálogo Pessoal de Filmes

# [Video de Demonstração](https://youtu.be/Ux1nDswYow0)

Aplicativo Flutter desenvolvido como Projeto Final Integrado (PjBL) que permite aos usuários buscar filmes, visualizar detalhes e manter uma lista pessoal de filmes assistidos com suas próprias avaliações.

## 📋 Índice

- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Requisitos Funcionais Implementados](#requisitos-funcionais-implementados)
  - [RF01 - Fluxo de Autenticação Local](#rf01---fluxo-de-autenticação-local)
  - [RF02 - Tela de Perfil do Usuário](#rf02---tela-de-perfil-do-usuário)
  - [RF03 - Tela de Busca de Filmes](#rf03---tela-de-busca-de-filmes)
  - [RF04 - Navegação e Tela de Detalhes](#rf04---navegação-e-tela-de-detalhes)
  - [RF05 - Tela "Meus Filmes Assistidos"](#rf05---tela-meus-filmes-assistidos)
  - [RF06 - Persistência de Dados Local e por Usuário](#rf06---persistência-de-dados-local-e-por-usuário)
  - [RF07 - Requisitos de Acessibilidade (a11y)](#rf07---requisitos-de-acessibilidade-a11y)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Como Executar](#como-executar)

---

## 🛠 Tecnologias Utilizadas

- **Flutter** - Framework de desenvolvimento multiplataforma
- **Provider** - Gerenciamento de estado global
- **SQLite (sqflite)** - Banco de dados local para persistência
- **SharedPreferences** - Armazenamento de preferências do usuário
- **TMDb API** - API para busca e informações de filmes
- **Image Picker** - Seleção de fotos da câmera/galeria
- **Cached Network Image** - Cache de imagens de rede

---

## ✅ Requisitos Funcionais Implementados

### RF01 - Fluxo de Autenticação Local

#### 📍 Localização
- **Tela de Login**: `lib/screens/auth/login_screen.dart`
- **Tela de Cadastro**: `lib/screens/auth/register_screen.dart`
- **Serviço de Autenticação**: `lib/services/auth_service.dart`
- **Controller de Autenticação**: `lib/controllers/auth_controller.dart`
- **Banco de Dados**: `lib/services/database_service.dart`
- **Componente de Seleção de Imagem**: `lib/components/profile_image_picker.dart`

#### ✅ Funcionalidades Implementadas

**1. Tela de Login**
- Campo de email e senha com validação
- Botão de login com feedback visual de carregamento
- Link para tela de cadastro
- Validação de campos obrigatórios

**Exemplo de código** (`lib/screens/auth/login_screen.dart:88-114`):
```dart
CustomTextField(
  controller: _emailController,
  label: 'Email',
  hint: 'seu@email.com',
  keyboardType: TextInputType.emailAddress,
  prefixIcon: const Icon(Icons.email),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu email';
    }
    return null;
  },
),
```

**2. Tela de Cadastro**
- Campos: Nome, Email, Senha, Confirmar Senha
- Validação de email com regex
- Validação de senha mínima (6 caracteres)
- Validação de confirmação de senha
- **Seleção de foto de perfil** com opções:
  - Tirar foto com a câmera
  - Escolher da galeria

**Exemplo de código** (`lib/screens/auth/register_screen.dart:80-84`):
```dart
ProfileImagePicker(
  onImageSelected: (path) {
    _profileImagePath = path;
  },
),
```

**3. Persistência de Usuários**
- Armazenamento local usando **SQLite** (`database_service.dart`)
- Tabela `users` com campos: id, name, email, password, profileImagePath
- Caminho da imagem de perfil salvo no banco de dados
- Imagens copiadas para armazenamento permanente do aplicativo

**Exemplo de código** (`lib/services/database_service.dart:36-44`):
```dart
await db.execute('''
  CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    password TEXT NOT NULL,
    profileImagePath TEXT
  )
''');
```

**4. Lembrar Usuário Logado**
- Uso de **SharedPreferences** para manter sessão
- Verificação automática de autenticação no splash screen
- Redirecionamento automático para HomeScreen se já estiver logado

**Exemplo de código** (`lib/services/auth_service.dart:23-36`):
```dart
Future<UserModel?> login(String email, String password) async {
  final user = await DatabaseService.instance.getUserByEmail(email);
  if (user != null && user.password == password) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_loggedInUserKey, user.id!);
    return user;
  }
  return null;
}
```

---

### RF02 - Tela de Perfil do Usuário

#### 📍 Localização
- **Tela de Perfil**: `lib/screens/home/profile_screen.dart`

#### ✅ Funcionalidades Implementadas

**1. Exibição de Informações do Usuário**
- Nome do usuário exibido em destaque
- Email do usuário
- **Foto de perfil** exibida em formato circular
- Contador de filmes avaliados

**Exemplo de código** (`lib/screens/home/profile_screen.dart:356-401`):
```dart
Semantics(
  label: 'Foto de perfil. Toque para alterar',
  button: true,
  image: true,
  child: GestureDetector(
    onTap: () => _pickProfileImage(context, authController),
    child: Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: user.profileImagePath != null
                ? DecorationImage(
                    image: FileImage(File(user.profileImagePath!)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),
      ],
    ),
  ),
),
```

**2. Funcionalidades Adicionais**
- Atualização de foto de perfil (câmera ou galeria)
- Atualização de email
- Atualização de senha
- Logout
- Exclusão de conta

---

### RF03 - Tela de Busca de Filmes

#### 📍 Localização
- **Tela de Busca**: `lib/screens/home/search_screen.dart`
- **Serviço TMDb**: `lib/services/tmdb_service.dart`
- **Controller de Filmes**: `lib/controllers/movie_controller.dart`

#### ✅ Funcionalidades Implementadas

**1. Campo de Busca**
- TextField para inserir o termo de busca
- Busca em tempo real conforme o usuário digita
- Botão de limpar busca
- Integração com API do TMDb

**Exemplo de código** (`lib/screens/home/search_screen.dart:48-83`):
```dart
TextField(
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
            },
          )
        : null,
  ),
  onSubmitted: _onSearch,
  onChanged: (value) {
    if (value.isEmpty) {
      Provider.of<MovieController>(context, listen: false)
          .clearSearch();
    }
  },
),
```

**2. Exibição de Resultados**
- Lista de filmes encontrados na busca
- Exibição de filmes mais bem avaliados quando não há busca
- Cards com poster, título, ano, nota e sinopse
- Feedback visual de carregamento
- Mensagem quando nenhum resultado é encontrado

**Exemplo de código** (`lib/services/tmdb_service.dart:9-27`):
```dart
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
```

---

### RF04 - Navegação e Tela de Detalhes

#### 📍 Localização
- **Tela de Detalhes**: `lib/screens/home/movie_details_screen.dart`
- **Navegação**: Implementada via `Navigator.push()` em múltiplas telas

#### ✅ Funcionalidades Implementadas

**1. Navegação**
- Navegação da lista de busca para tela de detalhes
- Navegação de filmes mais bem avaliados para detalhes
- Botão de voltar funcional

**Exemplo de código** (`lib/screens/home/search_screen.dart:130-136`):
```dart
MovieCard(
  movie: movie,
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(movie: movie),
      ),
    );
  },
),
```

**2. Tela de Detalhes do Filme**
- Exibição de informações completas do filme:
  - Pôster do filme
  - Título
  - Ano de lançamento
  - Nota média (TMDb)
  - Sinopse completa
- **Sistema de Avaliação**:
  - RatingBar para avaliar de 0.5 a 5 estrelas
  - Campo de texto para resenha opcional
  - Botão para salvar avaliação
  - Carregamento de avaliação existente se o filme já foi avaliado

**Exemplo de código** (`lib/screens/home/movie_details_screen.dart:291-312`):
```dart
Semantics(
  label: 'Avaliar filme. Nota atual: ${_userRating == 0 ? "nenhuma" : "${_userRating.toStringAsFixed(1)} estrelas"}',
  child: Center(
    child: RatingBar.builder(
      initialRating: _userRating,
      minRating: 0.5,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        setState(() {
          _userRating = rating;
        });
      },
    ),
  ),
),
```

**3. Salvamento de Avaliação**
- Avaliação associada ao usuário logado
- Persistência no banco de dados local
- Atualização de avaliação existente se o filme já foi avaliado

**Exemplo de código** (`lib/screens/home/movie_details_screen.dart:59-113`):
```dart
Future<void> _saveRating() async {
  if (_userRating == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por favor, dê uma nota ao filme'),
      ),
    );
    return;
  }

  final ratedMovie = RatedMovieModel(
    userId: authController.currentUser!.id!,
    movieId: widget.movie.id,
    movieTitle: widget.movie.title,
    moviePosterPath: widget.movie.posterPath,
    userRating: _userRating,
    userReview: _reviewController.text.trim().isEmpty 
        ? null 
        : _reviewController.text.trim(),
    ratedAt: DateTime.now(),
  );

  final success = await ratedMoviesController.addRatedMovie(ratedMovie);
  // ...
}
```

---

### RF05 - Tela "Meus Filmes Assistidos" (por Usuário)

#### 📍 Localização
- **Tela de Meus Filmes**: `lib/screens/home/my_movies_screen.dart`
- **Controller**: `lib/controllers/rated_movies_controller.dart`
- **Estado Global**: Gerenciado via **Provider**

#### ✅ Funcionalidades Implementadas

**1. Exibição de Lista de Filmes Avaliados**
- Lista de todos os filmes avaliados pelo usuário logado
- Cards com poster, título, avaliação do usuário, data de avaliação e resenha
- Ordenação por data de avaliação (mais recentes primeiro)
- Estado vazio quando não há filmes avaliados

**Exemplo de código** (`lib/screens/home/my_movies_screen.dart:16-53`):
```dart
Consumer<RatedMoviesController>(
  builder: (context, ratedMoviesController, child) {
    if (ratedMoviesController.ratedMovies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_creation_outlined, size: 100),
            Text('Nenhum filme avaliado ainda'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: ratedMoviesController.ratedMovies.length,
      itemBuilder: (context, index) {
        final movie = ratedMoviesController.ratedMovies[index];
        return RatedMovieCard(movie: movie);
      },
    );
  },
),
```

**2. Gerenciamento de Estado Global**
- Uso do **Provider** para gerenciar estado global
- Controller `RatedMoviesController` notifica mudanças
- Atualização automática da lista quando novos filmes são avaliados

**Exemplo de código** (`lib/main.dart:19-24`):
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthController()),
    ChangeNotifierProvider(create: (_) => MovieController()),
    ChangeNotifierProvider(create: (_) => RatedMoviesController()),
  ],
  // ...
)
```

**3. Funcionalidades Adicionais**
- Remoção de avaliação com confirmação
- Navegação para detalhes do filme (se implementado)

---

### RF06 - Persistência de Dados Local e por Usuário

#### 📍 Localização
- **Banco de Dados**: `lib/services/database_service.dart`
- **Tabelas**: `users` e `rated_movies`
- **Controller**: `lib/controllers/rated_movies_controller.dart`

#### ✅ Funcionalidades Implementadas

**1. Estrutura do Banco de Dados**
- Tabela `users`: Armazena informações dos usuários
- Tabela `rated_movies`: Armazena avaliações de filmes
- **Chave estrangeira** (`userId`) associando avaliações aos usuários
- **CASCADE DELETE**: Ao excluir um usuário, suas avaliações são removidas automaticamente

**Exemplo de código** (`lib/services/database_service.dart:46-58`):
```dart
await db.execute('''
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
  )
''');
```

**2. Isolamento de Dados por Usuário**
- Todas as consultas de filmes avaliados filtram por `userId`
- Cada usuário vê apenas seus próprios filmes avaliados
- Ao fazer logout e login com outro usuário, a lista é atualizada automaticamente

**Exemplo de código** (`lib/services/database_service.dart:88-98`):
```dart
Future<List<RatedMovieModel>> getUserRatedMovies(int userId) async {
  final db = await instance.database;
  final maps = await db.query(
    'rated_movies',
    where: 'userId = ?',  // Filtro por usuário
    whereArgs: [userId],
    orderBy: 'ratedAt DESC',
  );

  return maps.map((map) => RatedMovieModel.fromMap(map)).toList();
}
```

**3. Carregamento Automático por Usuário**
- Ao fazer login, os filmes do usuário são carregados automaticamente
- Ao mudar de usuário, a lista é recarregada com os dados do novo usuário

**Exemplo de código** (`lib/screens/home/home_screen.dart:25-37`):
```dart
Future<void> _loadRatedMovies() async {
  await Future.delayed(Duration.zero);
  
  if (!mounted) return;
  
  final authController = Provider.of<AuthController>(context, listen: false);
  final ratedMoviesController = Provider.of<RatedMoviesController>(context, listen: false);
  
  if (authController.currentUser != null) {
    await ratedMoviesController.loadUserRatedMovies(
      authController.currentUser!.id!
    );
  }
}
```

**4. Persistência de Imagens de Perfil**
- Caminho da imagem salvo no banco de dados
- Imagens copiadas para diretório permanente do aplicativo
- Gerenciamento de arquivos (cópia, exclusão)

**Exemplo de código** (`lib/controllers/auth_controller.dart:180-218`):
```dart
Future<String?> updateProfileImage(String imagePath) async {
  // Copia a imagem para armazenamento permanente
  final appDir = await getApplicationDocumentsDirectory();
  final fileName = 'profile_${_currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imagePath)}';
  final permanentPath = path.join(appDir.path, fileName);
  
  final File sourceFile = File(imagePath);
  await sourceFile.copy(permanentPath);
  
  // Salva o caminho no banco de dados
  final success = await _authService.updateUserProfileImage(
    _currentUser!.id!, 
    permanentPath
  );
  // ...
}
```

---

### RF07 - Requisitos de Acessibilidade (a11y)

#### 📍 Localização
- Implementado em múltiplas telas usando o widget `Semantics`
- **29 ocorrências** de `Semantics` no código

#### ✅ Funcionalidades Implementadas

**1. Rótulos Descritivos para Botões e Elementos Interativos**
- Todos os botões de ícone possuem rótulos descritivos
- Campos de formulário possuem labels de acessibilidade
- Ações importantes são descritas claramente

**Exemplos de código**:

**Botão de voltar** (`lib/screens/home/movie_details_screen.dart:123-137`):
```dart
Semantics(
  label: 'Voltar',
  button: true,
  child: Container(
    margin: const EdgeInsets.all(8),
    child: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    ),
  ),
),
```

**Botões de ação no perfil** (`lib/screens/home/profile_screen.dart:464-473`):
```dart
Semantics(
  label: 'Atualizar email',
  button: true,
  child: ListTile(
    leading: const Icon(Icons.email, color: Colors.blue),
    title: const Text('Atualizar Email'),
    onTap: () => _showUpdateEmailDialog(context, authController),
  ),
),
```

**2. Imagens com Texto Alternativo**
- Foto de perfil possui descrição
- Pôsteres de filmes possuem texto alternativo descritivo

**Exemplo de código** (`lib/screens/home/movie_details_screen.dart:198-210`):
```dart
Semantics(
  label: 'Pôster do filme ${widget.movie.title}',
  image: true,
  child: ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: CachedNetworkImage(
      imageUrl: widget.movie.fullPosterUrl,
      width: 120,
      height: 180,
      fit: BoxFit.cover,
    ),
  ),
),
```

**3. Campos de Formulário com Labels**
- Todos os campos de texto possuem labels descritivos
- Campos de senha são identificados corretamente

**Exemplo de código** (`lib/screens/home/movie_details_screen.dart:314-329`):
```dart
Semantics(
  label: 'Campo de texto para escrever sua resenha do filme',
  textField: true,
  child: TextField(
    controller: _reviewController,
    maxLines: 4,
    decoration: InputDecoration(
      labelText: 'Sua Resenha (opcional)',
      hintText: 'O que você achou do filme?',
    ),
  ),
),
```

**4. Informações Contextuais**
- Notas e avaliações são descritas de forma clara
- Informações importantes são acessíveis via leitores de tela

**Exemplo de código** (`lib/screens/home/movie_details_screen.dart:229-255`):
```dart
Semantics(
  label: 'Nota média: ${widget.movie.voteAverage.toStringAsFixed(1)} de 10',
  child: Row(
    children: [
      const Icon(Icons.star, color: Colors.amber, size: 24),
      Text(widget.movie.voteAverage.toStringAsFixed(1)),
      Text('/10'),
    ],
  ),
),
```

**5. Alvos de Toque Mínimos**
- Botões e elementos interativos seguem o padrão mínimo de 44x44 pixels lógicos
- CustomButton possui altura de 56 pixels (`lib/components/custom_button.dart:23`)
- IconButtons seguem o padrão do Material Design

**Exemplo de código** (`lib/components/custom_button.dart:21-24`):
```dart
SizedBox(
  width: double.infinity,
  height: 56,  // Maior que o mínimo de 44x44
  child: ElevatedButton(
    // ...
  ),
),
```

**6. Foco Gerenciado**
- Navegação lógica entre elementos
- Formulários com validação e feedback claro
- Transições de tela gerenciadas adequadamente

---

## 📁 Estrutura do Projeto

```
lib/
├── components/          # Componentes reutilizáveis
│   ├── compact_movie_card.dart
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── movie_card.dart
│   ├── profile_image_picker.dart
│   └── rated_movie_card.dart
├── controllers/         # Gerenciamento de estado (Provider)
│   ├── auth_controller.dart
│   ├── movie_controller.dart
│   └── rated_movies_controller.dart
├── models/             # Modelos de dados
│   ├── movie_model.dart
│   ├── rated_movie_model.dart
│   └── user_model.dart
├── screens/            # Telas do aplicativo
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── home/
│       ├── home_screen.dart
│       ├── movie_details_screen.dart
│       ├── my_movies_screen.dart
│       ├── profile_screen.dart
│       └── search_screen.dart
├── services/           # Serviços e lógica de negócio
│   ├── auth_service.dart
│   ├── database_service.dart
│   └── tmdb_service.dart
└── main.dart           # Ponto de entrada do aplicativo
```

---

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK instalado (versão 3.0.0 ou superior)
- Dart SDK
- Android Studio / Xcode (para emuladores)
- Dispositivo físico ou emulador

### Passos

1. **Clone o repositório** (se aplicável)

2. **Instale as dependências**:
   ```bash
   flutter pub get
   ```

3. **Execute o aplicativo**:
   ```bash
   flutter run
   ```

4. **Para executar em um dispositivo específico**:
   ```bash
   flutter devices  # Lista dispositivos disponíveis
   flutter run -d <device_id>
   ```

### Notas Importantes
- O aplicativo utiliza a API do TMDb para buscar filmes
- A chave da API está configurada em `lib/services/tmdb_service.dart`
- Para produção, recomenda-se mover a chave para variáveis de ambiente

---

## 📝 Observações Finais

Todos os requisitos funcionais (RF01 a RF07) foram implementados e testados. O aplicativo oferece uma experiência completa de gerenciamento de catálogo pessoal de filmes com:

- ✅ Autenticação local segura
- ✅ Persistência de dados por usuário
- ✅ Interface acessível
- ✅ Integração com API externa (TMDb)
- ✅ Gerenciamento de estado global
- ✅ Experiência de usuário fluida

---

**Desenvolvido como Projeto Final Integrado (PjBL)**
