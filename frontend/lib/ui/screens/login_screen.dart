import 'package:flutter/material.dart';
import 'package:rehab_app/ui/screens/coach/coach_main_screen.dart';
import 'package:rehab_app/ui/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Kontrolery do pobierania tekstu
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Zmienna przechowujaca wybrana role
  String _selectedRole = 'Klient';
  final List<String> _roles = ['Klient', 'Trener/Fizjoterapeuta'];

  void _handleLogin() {
    String email = _emailController.text;
    String password = _passwordController.text;
    
    // TODO: dodanie logiki sprawdzania poprawnosci danych
    print('Logowanie: $email, Rola: $_selectedRole');

    final Widget destination = _selectedRole == 'Trener/Fizjoterapeuta'
        ? const CoachMainScreen()
        : const HomeScreen();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zaloguj się'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            
            // Hasło
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Hasło',
                border: OutlineInputBorder(),
              ),
              obscureText: true, // Ukrywa wpisywane znaki
            ),
            const SizedBox(height: 16),

            // Wybór Roli (Dropdown)
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Wybierz rolę',
                border: OutlineInputBorder(),
              ),
              items: _roles.map((String role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue!;
                });
              },
            ),
            const SizedBox(height: 32),

            // Przycisk Logowania
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleLogin,
                child: const Text('Zaloguj', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}