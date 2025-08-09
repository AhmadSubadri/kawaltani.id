import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<bool> _showPassword = ValueNotifier<bool>(false);

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.white,
                title: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade900,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  message,
                  style: TextStyle(color: Colors.teal.shade800),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.teal.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.8, 0.8)),
    );
  }

  Future<void> _handleLogin(AuthProvider authProvider) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      print('Validation failed: Username or password is empty');
      _showErrorDialog(
        'Form Tidak Lengkap',
        'Nama pengguna dan kata sandi harus diisi.',
      );
      return;
    }

    authProvider.setLoading(true);
    try {
      print('Attempting login with username: $username');
      final user = await ApiService().login(username, password);
      print('Login successful, user: ${user.username}, token: ${user.token}');
      authProvider.setUser(user);
      // Paksa pembaruan state dan navigasi
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      });
    } catch (e) {
      print('Login error: $e');
      String errorMessage = 'Login gagal. Silakan coba lagi.';
      if (e.toString().contains('Login failed')) {
        errorMessage = 'Nama pengguna atau kata sandi salah.';
      } else if (e.toString().contains('network')) {
        errorMessage =
            'Gagal terhubung ke server. Periksa koneksi internet Anda.';
      } else if (e.toString().contains('Token not found')) {
        errorMessage = 'Respons server tidak valid. Hubungi administrator.';
      }
      _showErrorDialog('Login Gagal', errorMessage);
    } finally {
      authProvider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade300,
                    Colors.teal.shade400,
                    Colors.brown.shade200,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: -50,
                    left: -50,
                    child: Image.asset(
                      'assets/images/leaf.png',
                      width: size.width * 0.5,
                      height: size.width * 0.5,
                      color: Colors.green.shade100.withOpacity(0.4),
                      colorBlendMode: BlendMode.overlay,
                    ).animate().fadeIn(duration: 1000.ms),
                  ),
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Image.asset(
                      'assets/images/leaf.png',
                      width: size.width * 0.5,
                      height: size.width * 0.5,
                      color: Colors.teal.shade100.withOpacity(0.4),
                      colorBlendMode: BlendMode.overlay,
                    ).animate().fadeIn(duration: 1000.ms),
                  ),
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(color: Colors.black.withOpacity(0.05)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.teal.shade50,
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                          ),
                          Image.asset(
                            'assets/images/leaf.png',
                            width: 100,
                            height: 100,
                            color: Colors.teal.shade700,
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Kawal',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade900,
                            fontSize: 36,
                          ),
                        ),
                        TextSpan(
                          text: 'Tani',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                            fontSize: 36,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  Text(
                    'Pantau Pertanian Anda dengan Cerdas',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.teal.shade800,
                      fontSize: 16,
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      width: size.width * 0.9,
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withOpacity(0.95),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Nama Pengguna',
                              prefixIcon: const Icon(
                                Icons.agriculture_rounded,
                                color: Colors.teal,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.teal.shade50,
                            ),
                          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<bool>(
                            valueListenable: _showPassword,
                            builder:
                                (context, value, child) => TextField(
                                  controller: _passwordController,
                                  obscureText: !value,
                                  decoration: InputDecoration(
                                    labelText: 'Kata Sandi',
                                    prefixIcon: const Icon(
                                      Icons.lock_rounded,
                                      color: Colors.teal,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed:
                                          () => _showPassword.value = !value,
                                      icon: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        child: Icon(
                                          value
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          key: ValueKey<bool>(value),
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.teal.shade50,
                                  ),
                                ),
                          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
                          const SizedBox(height: 24),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return GestureDetector(
                                onTap:
                                    authProvider.isLoading
                                        ? null
                                        : () => _handleLogin(authProvider),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width:
                                      authProvider.isLoading
                                          ? 60
                                          : size.width * 0.9,
                                  height: 50,
                                  constraints: const BoxConstraints(
                                    maxWidth: 400,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      authProvider.isLoading ? 30 : 12,
                                    ),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.teal.shade600,
                                        Colors.green.shade600,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.teal.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child:
                                        authProvider.isLoading
                                            ? const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3,
                                            )
                                            : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.eco_rounded,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'MASUK',
                                                  style: theme
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ],
                                            ),
                                  ),
                                ),
                              ).animate().fadeIn(delay: 1000.ms).scale();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildDataIndicator('Tanah', '24°C', Icons.grass),
                        _buildDataIndicator('Udara', '65%', Icons.water_drop),
                        _buildDataIndicator('Suhu', '28°C', Icons.thermostat),
                      ],
                    ),
                  ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataIndicator(String title, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.teal.shade700, size: 20),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.teal.shade800),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade900,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _showPassword.dispose();
    super.dispose();
  }
}
