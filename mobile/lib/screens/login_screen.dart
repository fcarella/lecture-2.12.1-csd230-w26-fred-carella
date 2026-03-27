import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _error = '';

  Future<void> _login() async {
    setState(() { _isLoading = true; _error = ''; });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final api = ApiService(authProvider);

    try {
      final res = await api.post('/auth/login', {
        'email': _emailController.text,
        'password': _passwordController.text,
      });
      await authProvider.setToken(res['token']);
    } catch (e) {
      setState(() => _error = 'Invalid username or password.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bookstore Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_error.isNotEmpty) 
              Text(_error, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Username (e.g. admin or user)'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            _isLoading 
              ? CircularProgressIndicator() 
              : ElevatedButton(onPressed: _login, child: Text('Sign In')),
          ],
        ),
      ),
    );
  }
}
