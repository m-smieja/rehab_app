import 'package:flutter/material.dart';
import 'package:rehab_app/ui/screens/home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final List<String> _roles = ['Klient', 'Trener'];

Future<void> _handleLogin() async {
  String email = _emailController.text;
  String password = _passwordController.text;

  // Adres serwera Spring Boot (10.0.2.2 to odpowiednik localhost dla emulatora)
  final url = Uri.parse('http://10.0.2.2:8080/api/users/login');

  try {
    // Wysyłamy zapytanie POST z danymi z formularza
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      print('Zalogowano! ID: ${responseData['id']}, Rola: ${responseData['role']}');

      // Sukces -> Przenosimy na ekran główny
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
    else if (response.statusCode == 403) {
      // 403 z dokumentacji -> Błędne hasło
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błędne hasło!')),
      );
    }
    else if (response.statusCode == 400) {
      // 400 z dokumentacji -> Konto nie istnieje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Takie konto nie istnieje!')),
      );
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nieznany błąd serwera: ${response.statusCode}')),
      );
    }
  } catch (e) {
    print('Błąd połączenia: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Brak połączenia z serwerem!')),
    );
  }
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