import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _service = SupabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFF5F6FA), // light neutral background
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                SizedBox(height: 12),
                Container(
                  width: 340,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 24),
                      Image.asset(
                        'assets/visitante.png',
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 8),
                      Text('Iniciar sesión',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 1.2,
                          )),
                      SizedBox(height: 28),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                          filled: true,
                          fillColor: Color(0xFFF5F6FA),
                          labelStyle: TextStyle(color: Colors.black54),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF4F5BD5)),
                          ),
                        ),
                        style: TextStyle(color: Colors.black87),
                      ),
                      SizedBox(height: 18),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                          filled: true,
                          fillColor: Color(0xFFF5F6FA),
                          labelStyle: TextStyle(color: Colors.black54),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF4F5BD5)),
                          ),
                        ),
                        obscureText: true,
                        style: TextStyle(color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  await _service.signIn(_emailController.text, _passwordController.text);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => HomeScreen()),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error al iniciar sesión: ${e.toString()}')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF6600),
                                foregroundColor: Colors.white,
                                shape: StadiumBorder(),
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text('Iniciar sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            String email = '';
                            String password = '';
                            String displayName = '';
                            String role = 'visitor';
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Registrarse'),
                                  content: StatefulBuilder(
                                    builder: (context, setState) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            decoration: InputDecoration(labelText: 'Correo electrónico'),
                                            onChanged: (v) => email = v,
                                          ),
                                          TextField(
                                            decoration: InputDecoration(labelText: 'Contraseña'),
                                            obscureText: true,
                                            onChanged: (v) => password = v,
                                          ),
                                          TextField(
                                            decoration: InputDecoration(labelText: 'Nombre para mostrar'),
                                            onChanged: (v) => displayName = v,
                                          ),
                                          DropdownButton<String>(
                                            value: role,
                                            items: [
                                              DropdownMenuItem(value: 'visitor', child: Text('Visitante')),
                                              DropdownMenuItem(value: 'publisher', child: Text('Publicador')),
                                            ],
                                            onChanged: (v) => setState(() => role = v!),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          await _service.signUp(email, password, role, displayName);
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('¡Registro exitoso! Por favor inicia sesión.')),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error al registrarse: ${e.toString()}')),
                                          );
                                        }
                                      },
                                      child: Text('Registrarse', style: TextStyle(color: Theme.of(context).primaryColor)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text('Cancelar', style: TextStyle(color: Colors.black87)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            "¿No tienes una cuenta? Regístrate!",
                            style: TextStyle(color: Color(0xFF4F5BD5), fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
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