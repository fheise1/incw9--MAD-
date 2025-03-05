import 'package:flutter/material.dart';
import 'helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'In classwork 9',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Card Organizer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Map<String, dynamic>>> _folders;

  @override
  void initState() {
    super.initState();
    _folders = _fetchFolders();
  }

  Future<List<Map<String, dynamic>>> _fetchFolders() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('folders');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _folders,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<Map<String, dynamic>> folders = snapshot.data!;
          return ListView.builder(
            itemCount: folders.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(folders[index]['name']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CardsScreen(
                        folderId: folders[index]['id'],
                        folderName: folders[index]['name'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class CardsScreen extends StatefulWidget {
  final int folderId;
  final String folderName;

  CardsScreen({required this.folderId, required this.folderName});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  late Future<List<Map<String, dynamic>>> _cards;

  @override
  void initState() {
    super.initState();
    _cards = _fetchCards();
  }

  Future<List<Map<String, dynamic>>> _fetchCards() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('cards', where: 'folderId = ?', whereArgs: [widget.folderId]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folderName)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cards,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<Map<String, dynamic>> cards = snapshot.data!;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return Card(
                child: Column(
                  children: [
                    Image.network(cards[index]['image']),
                    Text(cards[index]['name']),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}