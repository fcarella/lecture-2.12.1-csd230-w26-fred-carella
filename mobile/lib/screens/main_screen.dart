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
    _loadData();
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

  // ==========================================
  // FORMS FOR ADDING / EDITING
  // ==========================================

  void _showBookForm({Book? book}) {
    final titleCtrl = TextEditingController(text: book?.title ?? '');
    final authorCtrl = TextEditingController(text: book?.author ?? '');
    final priceCtrl = TextEditingController(text: book?.price.toString() ?? '');
    final copiesCtrl = TextEditingController(text: book?.copies.toString() ?? '10');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(book == null ? 'Add Book' : 'Edit Book'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Title')),
              TextField(controller: authorCtrl, decoration: InputDecoration(labelText: 'Author')),
              TextField(controller: priceCtrl, decoration: InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
              TextField(controller: copiesCtrl, decoration: InputDecoration(labelText: 'Copies'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final api = ApiService(Provider.of<AuthProvider>(context, listen: false));
              final data = {
                'title': titleCtrl.text,
                'author': authorCtrl.text,
                'price': double.tryParse(priceCtrl.text) ?? 0.0,
                'copies': int.tryParse(copiesCtrl.text) ?? 10,
              };

              try {
                if (book == null) {
                  await api.post('/books', data); // ADD
                } else {
                  await api.put('/books/${book.id}', data); // EDIT
                }
                Navigator.pop(ctx);
                _loadData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving book')));
              }
            },
            child: Text('Save'),
          )
        ],
      ),
    );
  }

  void _showMagazineForm({Magazine? magazine}) {
    final titleCtrl = TextEditingController(text: magazine?.title ?? '');
    final priceCtrl = TextEditingController(text: magazine?.price.toString() ?? '');
    final copiesCtrl = TextEditingController(text: magazine?.copies.toString() ?? '10');
    final orderQtyCtrl = TextEditingController(text: magazine?.orderQty.toString() ?? '100');

    // Default issue to right now, formatted as the Spring Boot backend expects
    String defaultDate = DateTime.now().toIso8601String().substring(0, 19);
    final issueCtrl = TextEditingController(text: magazine?.currentIssue ?? defaultDate);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(magazine == null ? 'Add Magazine' : 'Edit Magazine'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Title')),
              TextField(controller: priceCtrl, decoration: InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
              TextField(controller: copiesCtrl, decoration: InputDecoration(labelText: 'Copies'), keyboardType: TextInputType.number),
              TextField(controller: orderQtyCtrl, decoration: InputDecoration(labelText: 'Order Qty'), keyboardType: TextInputType.number),
              TextField(controller: issueCtrl, decoration: InputDecoration(labelText: 'Issue Date (yyyy-MM-ddTHH:mm:ss)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final api = ApiService(Provider.of<AuthProvider>(context, listen: false));

              // Ensure date has seconds (React did this as well)
              String dateString = issueCtrl.text;
              if (dateString.length == 16) dateString += ":00";

              final data = {
                'title': titleCtrl.text,
                'price': double.tryParse(priceCtrl.text) ?? 0.0,
                'copies': int.tryParse(copiesCtrl.text) ?? 10,
                'orderQty': int.tryParse(orderQtyCtrl.text) ?? 100,
                'currentIssue': dateString,
              };

              try {
                if (magazine == null) {
                  await api.post('/magazines', data); // ADD
                } else {
                  await api.put('/magazines/${magazine.id}', data); // EDIT
                }
                Navigator.pop(ctx);
                _loadData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving magazine')));
              }
            },
            child: Text('Save'),
          )
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET BUILDERS
  // ==========================================

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
      // NEW: Floating Action Button to Add items based on the current tab
      floatingActionButton: auth.isAdmin && _currentIndex != 2
          ? FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          if (_currentIndex == 0) _showBookForm();
          if (_currentIndex == 1) _showMagazineForm();
        },
      )
          : null,
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
            subtitle: Text('${b.author} | \$${b.price.toStringAsFixed(2)} | Copies: ${b.copies}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.add_shopping_cart, color: Colors.green), onPressed: () => _addToCart(b.id!)),
                if (isAdmin) ...[
                  IconButton(icon: Icon(Icons.edit, color: Colors.amber), onPressed: () => _showBookForm(book: b)), // EDIT
                  IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteItem('books', b.id!)),
                ]
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
            subtitle: Text('Issue: ${m.currentIssue.replaceAll('T', ' ')}\n\$${m.price.toStringAsFixed(2)} | Qty: ${m.orderQty} | Copies: ${m.copies}'),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.add_shopping_cart, color: Colors.green), onPressed: () => _addToCart(m.id!)),
                if (isAdmin) ...[
                  IconButton(icon: Icon(Icons.edit, color: Colors.amber), onPressed: () => _showMagazineForm(magazine: m)), // EDIT
                  IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteItem('magazines', m.id!)),
                ]
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