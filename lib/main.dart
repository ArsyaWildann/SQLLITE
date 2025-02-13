import 'package:flutter/material.dart';
import 'package:sqllite/sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter SQLite Demo',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _items = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _voteAverageController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  void _refreshItems() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _items = data;
      _isLoading = false;
    });
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingItem = _items.firstWhere((element) => element['id'] == id);
      _titleController.text = existingItem['title'];
      _descriptionController.text = existingItem['description'];
      _genreController.text = existingItem['genre'];
      _voteAverageController.text = existingItem['voteAverage'].toString();
      _imageController.text = existingItem['image'] ?? '';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 20.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                        labelText: 'Title', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(
                  controller: _genreController,
                  decoration: const InputDecoration(
                      labelText: 'Genre', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _voteAverageController,
                  decoration: const InputDecoration(
                      labelText: 'Vote Average', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _imageController,
                  decoration: const InputDecoration(
                      labelText: 'Image', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    if (id == null) {
                      await SQLHelper.createItem(
                        _titleController.text,
                        _descriptionController.text,
                        _genreController.text,
                        double.parse(_voteAverageController.text),
                        _imageController.text,
                      );
                    } else {
                      await SQLHelper.updateItem(
                        id,
                        _titleController.text,
                        _descriptionController.text,
                        _genreController.text,
                        double.parse(_voteAverageController.text),
                        _imageController.text,
                      );
                    }
                    _titleController.clear();
                    _descriptionController.clear();
                    _genreController.clear();
                    _voteAverageController.clear();
                    _imageController.clear();
                    Navigator.of(context).pop();
                    _refreshItems();
                  },
                  child: Text(id == null ? 'Add Item' : 'Update Item',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    _refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Center(
              child: Row(
            children: [
              Text(
                'Movie',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          )),
          backgroundColor: Colors.blue[900]),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(backgroundColor: Colors.blueAccent))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) => Card(
                color: Colors.blue[200],
                margin: const EdgeInsets.all(20),
                child: ListTile(
                  leading: _items[index]['image'] != null &&
                          _items[index]['image'].toString().isNotEmpty
                      ? _items[index]['image'].startsWith('http')
                          ? Image.network(
                              _items[index]['image'],
                              width: 50,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.image_not_supported, size: 50),
                            )
                          : Image.asset(
                              'assets/images/${_items[index]['image']}',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.image_not_supported, size: 50),
                            )
                      : Icon(Icons.image, size: 50),
                  title: Text(
                    _items[index]['title'],
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_items[index]['description']),
                      Text('Genre: ${_items[index]['genre']}'),
                      Text('Vote Average: ${_items[index]['voteAverage']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          onPressed: () => _showForm(_items[index]['id'])),
                      IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          onPressed: () => _deleteItem(_items[index]['id'])),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
