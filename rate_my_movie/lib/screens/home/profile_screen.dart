import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/rated_movies_controller.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<void> _pickProfileImage(BuildContext context, AuthController authController) async {
    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            Semantics(
              label: 'Tirar foto com a câmera',
              button: true,
              child: ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tirar Foto'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 512,
                    maxHeight: 512,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    final error = await authController.updateProfileImage(image.path);
                    if (context.mounted && error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
              ),
            ),
            Semantics(
              label: 'Escolher foto da galeria',
              button: true,
              child: ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da Galeria'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 512,
                    maxHeight: 512,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    final error = await authController.updateProfileImage(image.path);
                    if (context.mounted && error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
              ),
            ),
            if (authController.currentUser?.profileImagePath != null)
              Semantics(
                label: 'Remover foto de perfil',
                button: true,
                child: ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remover Foto', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    final error = await authController.removeProfileImage();
                    if (context.mounted && error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error), backgroundColor: Colors.red),
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showUpdateEmailDialog(BuildContext context, AuthController authController) {
    final emailController = TextEditingController(text: authController.currentUser?.email);
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atualizar Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'Campo de novo email',
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Novo Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Campo de senha atual para confirmação',
              child: TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha Atual',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ),
          ],
        ),
        actions: [
          Semantics(
            label: 'Cancelar atualização de email',
            button: true,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ),
          Semantics(
            label: 'Confirmar atualização de email',
            button: true,
            child: TextButton(
              onPressed: () async {
                final error = await authController.updateEmail(
                  emailController.text,
                  passwordController.text,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email atualizado com sucesso!')),
                  );
                }
              },
              child: const Text('Atualizar'),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdatePasswordDialog(BuildContext context, AuthController authController) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atualizar Senha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'Campo de senha atual',
              child: TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Senha Atual',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Campo de nova senha',
              child: TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Nova Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Campo para confirmar nova senha',
              child: TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Nova Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ),
          ],
        ),
        actions: [
          Semantics(
            label: 'Cancelar atualização de senha',
            button: true,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ),
          Semantics(
            label: 'Confirmar atualização de senha',
            button: true,
            child: TextButton(
              onPressed: () async {
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('As senhas não coincidem'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final error = await authController.updatePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Senha atualizada com sucesso!')),
                  );
                }
              },
              child: const Text('Atualizar'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthController authController) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Esta ação é irreversível. Todos os seus dados serão perdidos.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Campo de senha para confirmar exclusão da conta',
              child: TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Confirme sua senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ),
          ],
        ),
        actions: [
          Semantics(
            label: 'Cancelar exclusão de conta',
            button: true,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ),
          Semantics(
            label: 'Confirmar exclusão de conta',
            button: true,
            child: TextButton(
              onPressed: () async {
                final error = await authController.deleteAccount(passwordController.text);
                if (!context.mounted) return;
                Navigator.pop(context);
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                } else {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        elevation: 0,
      ),
      body: Consumer<AuthController>(
        builder: (context, authController, child) {
          final user = authController.currentUser;
          
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  child: Column(
                    children: [
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
                                  color: Colors.grey.shade200,
                                  image: user.profileImagePath != null
                                      ? DecorationImage(
                                          image: FileImage(File(user.profileImagePath!)),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: user.profileImagePath == null
                                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Consumer<RatedMoviesController>(
                  builder: (context, ratedMoviesController, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '${ratedMoviesController.ratedMovies.length}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Filmes Avaliados',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Semantics(
                        label: 'Atualizar email',
                        button: true,
                        child: ListTile(
                          leading: const Icon(Icons.email, color: Colors.blue),
                          title: const Text('Atualizar Email'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showUpdateEmailDialog(context, authController),
                        ),
                      ),
                      const Divider(height: 1),
                      Semantics(
                        label: 'Atualizar senha',
                        button: true,
                        child: ListTile(
                          leading: const Icon(Icons.lock, color: Colors.blue),
                          title: const Text('Atualizar Senha'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showUpdatePasswordDialog(context, authController),
                        ),
                      ),
                      const Divider(height: 1),
                      Semantics(
                        label: 'Sair da conta',
                        button: true,
                        child: ListTile(
                          leading: const Icon(Icons.logout, color: Colors.orange),
                          title: const Text(
                            'Sair',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Sair'),
                                content: const Text('Tem certeza que deseja sair?'),
                                actions: [
                                  Semantics(
                                    label: 'Cancelar saída',
                                    button: true,
                                    child: TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancelar'),
                                    ),
                                  ),
                                  Semantics(
                                    label: 'Confirmar saída',
                                    button: true,
                                    child: TextButton(
                                      onPressed: () async {
                                        await authController.logout();
                                        if (!context.mounted) return;
                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) => const LoginScreen(),
                                          ),
                                          (route) => false,
                                        );
                                      },
                                      child: const Text(
                                        'Sair',
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      Semantics(
                        label: 'Excluir conta permanentemente',
                        button: true,
                        child: ListTile(
                          leading: const Icon(Icons.delete_forever, color: Colors.red),
                          title: const Text(
                            'Excluir Conta',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => _showDeleteAccountDialog(context, authController),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}