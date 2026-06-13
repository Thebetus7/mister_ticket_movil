import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../state/auth_provider.dart';
import '../../core/constants/api_constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  
  bool? _isBackendConnected;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkBackendConnection();
  }

  Future<void> _checkBackendConnection() async {
    if (_isChecking) return;
    setState(() {
      _isChecking = true;
      _isBackendConnected = null;
    });
    try {
      final response = await http.get(Uri.parse(ApiConstants.baseUrl)).timeout(const Duration(seconds: 4));
      // Cualquier respuesta HTTP válida (incluso códigos de error como 404 o 405) confirma que el servidor responde
      setState(() {
        _isBackendConnected = true;
      });
    } catch (_) {
      setState(() {
        _isBackendConnected = false;
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo o Icono
                const Icon(
                  Icons.local_activity_rounded,
                  size: 80,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'MisterTicket',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bienvenido de nuevo, ingresa a tu cuenta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Indicador de conexión al backend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _isBackendConnected == null
                            ? Colors.grey
                            : (_isBackendConnected! ? Colors.green : Colors.red),
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (_isBackendConnected != null && _isBackendConnected!)
                            BoxShadow(
                              color: Colors.green.withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          if (_isBackendConnected != null && !_isBackendConnected!)
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isChecking ? null : _checkBackendConnection,
                      child: Text(
                        _isBackendConnected == null
                            ? 'Comprobando conexión...'
                            : (_isBackendConnected!
                                ? 'Conexión activa con el servidor'
                                : 'Sin conexión (toca para reintentar)'),
                        style: TextStyle(
                          fontSize: 12,
                          color: _isBackendConnected == null
                              ? Colors.grey[600]
                              : (_isBackendConnected! ? Colors.green[700] : Colors.red[700]),
                          fontWeight: FontWeight.w500,
                          decoration: _isBackendConnected == false ? TextDecoration.underline : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Input Usuario
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Input Contraseña con alternador de visibilidad
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Botón Ingresar
                authProvider.isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        final success = await authProvider.login(
                          _usernameController.text, 
                          _passwordController.text
                        );
                        if (success) {
                          Navigator.pushReplacementNamed(context, '/dashboard');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Error al iniciar sesión'))
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
