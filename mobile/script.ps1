# Create directories
$libPath = "lib"
Write-Host "Creating directories..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path "$libPath/services" | Out-Null
New-Item -ItemType Directory -Force -Path "$libPath/screens" | Out-Null

# ---------------------------------------------------------
# 1. lib/models.dart
# ---------------------------------------------------------
Write-Host "Creating lib/models.dart..." -ForegroundColor Green
$modelsContent = @'
class Book {
  final int? id;
  final String title;
  final String author;
  final double price;
  final int copies;

  Book({this.id, required this.title, required this.author, required this.price, required this.copies});

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'],
    title: json['title'] ?? '',
    author: json['author'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    copies: json['copies'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'author': author, 'price': price, 'copies': copies,
  };
}

class Magazine {
  final int? id;
  final String title;
  final double price;
  final int copies;
  final int orderQty;
  final String currentIssue;

  Magazine({this.id, required this.title, required this.price, required this.copies, required this.orderQty, required this.currentIssue});

  factory Magazine.fromJson(Map<String, dynamic> json) => Magazine(
    id: json['id'],
    title: json['title'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    copies: json['copies'] ?? 0,
    orderQty: json['orderQty'] ?? 0,
    currentIssue: json['currentIssue'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'price': price, 'copies': copies, 'orderQty': orderQty, 'currentIssue': currentIssue,
  };
}

class CartItem {
  final int id;
  final String title;
  final String type;
  final double price;

  CartItem({required this.id, required this.title, required this.type, required this.price});

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'],
    title: json['title'] ?? json['description'] ?? 'Unknown Item',
    type: json['productType'] ?? 'Unknown',
    price: (json['price'] ?? 0).toDouble(),
  );
}
'@
Set-Content -Path "$libPath/models.dart" -Value $modelsContent -Encoding UTF8

# ---------------------------------------------------------
# 2. lib/services/auth_provider.dart
# ---------------------------------------------------------
Write-Host "Creating lib/services/auth_provider.dart..." -ForegroundColor Green
$authProviderContent = @'
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthProvider with ChangeNotifier {
  String? _token;

  String? get token => _token;
  bool get isAuthenticated => _token != null && !JwtDecoder.isExpired(_token!);
  
  bool get isAdmin {
    if (_token == null) return false;
    try {
      Map<String, dynamic> payload = JwtDecoder.decode(_token!);
      List<dynamic> roles = payload['roles'] ?? [];
      return roles.contains('ROLE_ADMIN');
    } catch (e) {
      return false;
    }
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    if (_token != null && JwtDecoder.isExpired(_token!)) {
      _token = null;
      prefs.remove('jwt_token');
    }
    notifyListeners();
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    _token = token;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _token = null;
    notifyListeners();
  }
}
'@
Set-Content -Path "$libPath/services/auth_provider.dart" -Value $authProviderContent -Encoding UTF8

# ---------------------------------------------------------
# 3. lib/services/api_service.dart
# ---------------------------------------------------------
Write-Host "Creating lib/services/api_service.dart..." -ForegroundColor Green
$apiServiceContent = @'
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_provider.dart';

class ApiService {
  final AuthProvider authProvider;
  
  // 10.0.2.2 maps to localhost for Android Emulators. Use 127.0.0.1 for iOS.
  static String get baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/rest';
    return 'http://127.0.0.1:8080/api/rest';
  }

  ApiService(this.authProvider);

  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      if (authProvider.token != null) 'Authorization': 'Bearer ${authProvider.token}',
    };
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      authProvider.logout(); // Auto-logout if token is expired/invalid
      throw Exception('Session expired. Please login again.');
    }
    if (response.statusCode >= 400) {
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'), headers: await _getHeaders());
    _checkResponse(response);
    return jsonDecode(response.body);
  }

  Future<dynamic> post(String endpoint, [Map<String, dynamic>? body]) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: body != null ? jsonEncode(body) : null,
    );
    _checkResponse(response);
    if (response.body.isNotEmpty) return jsonDecode(response.body);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    _checkResponse(response);
    return jsonDecode(response.body);
  }

  Future<void> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl$endpoint'), headers: await _getHeaders());
    _checkResponse(response);
  }
}
'@
Set-Content -Path "$libPath/services/api_service.dart" -Value $apiServiceContent -Encoding UTF8

# ---------------------------------------------------------
# 4. lib/screens/login_screen.dart
# ---------------------------------------------------------
Write-Host "Creating lib/screens/login_screen.dart..." -ForegroundColor Green
$loginScreenContent = @'
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
'@
Set-Content -Path "$libPath/screens/login_screen.dart" -Value $loginScreenContent -Encoding UTF8

# ---------------------------------------------------------
# 5. lib/screens/main_screen.dart
# ---------------------------------------------------------
Write-Host "Creating lib/screens/main_screen.dart..." -ForegroundColor Green
$mainScreenContent = @'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../models.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Book> books = [];
  List<Magazine> magazines = [];
  List<CartItem> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final api = ApiService(Provider.of<AuthProvider>(context, listen: false));
    try {
      final bRes = await api.get('/books');
      final mRes = await api.get('/magazines');
      final cRes = await api.get('/cart');

      setState(() {
        books = (bRes as List).map((j) => Book.fromJson(j)).toList();
        magazines = (mRes as List).map((j) => Magazine.fromJson(j)).toList();
        cartItems = (cRes['products'] as List).map((j) => CartItem.fromJson(j)).toList();
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  Future<void> _addToCart(int id) async {
    final api = ApiService(Provider.of<AuthProvider>(context, listen: false));
    await api.post('/cart/add/$id');
    _loadData(); // Refresh cart count
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to Cart!')));
  }

  Future<void> _removeFromCart(int id) async {
    final api = ApiService(Provider.of<AuthProvider>(context, listen: false));
    await api.delete('/cart/remove/$id');
    _loadData();
  }

  Future<void> _deleteItem(String type, int id) async {
    final api = ApiService(Provider.of<AuthProvider>(context, listen: false));
    await api.delete('/$type/$id');
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    if (isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    final List<Widget> tabs = [
      _buildBooksTab(auth.isAdmin),
      _buildMagazinesTab(auth.isAdmin),
      _buildCartTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Bookstore Admin'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => auth.logout(),
          )
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Magazines'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart (${cartItems.length})'),
        ],
      ),
    );
  }

  // --- BOOKS TAB ---
  Widget _buildBooksTab(bool isAdmin) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (ctx, i) {
        final b = books[i];
        return Card(
          child: ListTile(
            title: Text(b.title),
            subtitle: Text('${b.author} | \$${b.price.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.add_shopping_cart, color: Colors.green), onPressed: () => _addToCart(b.id!)),
                if (isAdmin) 
                  IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteItem('books', b.id!)),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- MAGAZINES TAB ---
  Widget _buildMagazinesTab(bool isAdmin) {
    return ListView.builder(
      itemCount: magazines.length,
      itemBuilder: (ctx, i) {
        final m = magazines[i];
        return Card(
          child: ListTile(
            title: Text(m.title),
            subtitle: Text('Issue: ${m.currentIssue.replaceAll('T', ' ')}\n\$${m.price.toStringAsFixed(2)} | Qty: ${m.orderQty}'),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.add_shopping_cart, color: Colors.green), onPressed: () => _addToCart(m.id!)),
                if (isAdmin) 
                  IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteItem('magazines', m.id!)),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- CART TAB ---
  Widget _buildCartTab() {
    if (cartItems.isEmpty) return Center(child: Text("Cart is empty."));
    return ListView.builder(
      itemCount: cartItems.length,
      itemBuilder: (ctx, i) {
        final c = cartItems[i];
        return ListTile(
          title: Text(c.title),
          subtitle: Text('${c.type} | \$${c.price.toStringAsFixed(2)}'),
          trailing: IconButton(
            icon: Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () => _removeFromCart(c.id),
          ),
        );
      },
    );
  }
}
'@
Set-Content -Path "$libPath/screens/main_screen.dart" -Value $mainScreenContent -Encoding UTF8

# ---------------------------------------------------------
# 6. lib/main.dart
# ---------------------------------------------------------
Write-Host "Creating lib/main.dart..." -ForegroundColor Green
$mainContent = @'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authProvider = AuthProvider();
  await authProvider.loadToken(); // Check if user was already logged in

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookstore Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return MainScreen();
          }
          return LoginScreen();
        },
      ),
    );
  }
}
'@
Set-Content -Path "$libPath/main.dart" -Value $mainContent -Encoding UTF8


# ---------------------------------------------------------
# 7. Add Dependencies
# ---------------------------------------------------------
Write-Host "Adding required Flutter packages (this may take a moment)..." -ForegroundColor Cyan
flutter pub add provider http shared_preferences jwt_decoder

Write-Host "`nAll files generated successfully!" -ForegroundColor Green
Write-Host "You can now run your app using: flutter run" -ForegroundColor Yellow