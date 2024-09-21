import 'package:flutter/material.dart';
import 'furniture.dart'; // Import the Furniture class
import 'api_service.dart';

void main() {
  runApp(const FurnitureApp());
}

class FurnitureApp extends StatelessWidget {
  const FurnitureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Furniture App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
        iconTheme: const IconThemeData(color: Colors.pink),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.pink,
          textTheme: ButtonTextTheme.primary,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FurnitureListScreen(),
    );
  }
}

class FurnitureListScreen extends StatefulWidget {
  @override
  _FurnitureListScreenState createState() => _FurnitureListScreenState();
}

class _FurnitureListScreenState extends State<FurnitureListScreen> {
  late Future<List<Furniture>> futureFurniture;
  List<Furniture> _furnitureList = [];
  List<Furniture> _filteredFurniture = [];
  List<Furniture> _savedFurniture = [];

  @override
  void initState() {
    super.initState();
    futureFurniture = ApiService.fetchFurniture();
    futureFurniture.then((data) {
      setState(() {
        _furnitureList = data;
        _filteredFurniture = data;
      });
    }).catchError((error) {
      print('Error fetching furniture: $error');
    });
  }

  void _toggleSave(Furniture furniture) {
    setState(() {
      furniture.isSaved = !furniture.isSaved;
      if (furniture.isSaved) {
        _savedFurniture.add(furniture);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${furniture.name} saved!'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _savedFurniture.remove(furniture);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${furniture.name} removed from saved!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: FurnitureSearch(_furnitureList));
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavedFurnitureScreen(savedFurniture: _savedFurniture),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Furniture>>(
        future: futureFurniture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return AnimatedListView(
              furniture: _filteredFurniture,
              onSaveToggle: _toggleSave,
            );
          } else {
            return const Center(child: Text('No data found'));
          }
        },
      ),
    );
  }
}

class AnimatedListView extends StatelessWidget {
  final List<Furniture> furniture;
  final void Function(Furniture) onSaveToggle;

  AnimatedListView({required this.furniture, required this.onSaveToggle});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: furniture.length,
      itemBuilder: (context, index) {
        final item = furniture[index];
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Card(
            key: ValueKey<int>(item.id), // Key to help AnimatedSwitcher identify changes
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              leading: Hero(
                tag: 'image-${item.id}',
                child: FadeTransition(
                  opacity: const AlwaysStoppedAnimation<double>(1.0), // Example opacity animation
                  child: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                ),
              ),
              title: Text(item.name),
              subtitle: Text(item.description),
              contentPadding: const EdgeInsets.all(16.0),
              trailing: IconButton(
                icon: Icon(
                  item.isSaved ? Icons.favorite : Icons.favorite_border,
                  color: item.isSaved ? Colors.pink : null,
                ),
                onPressed: () => onSaveToggle(item),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FurnitureDetailScreen(furniture: item),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class FurnitureDetailScreen extends StatelessWidget {
  final Furniture furniture;

  FurnitureDetailScreen({required this.furniture});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(furniture.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'image-${furniture.id}',
              child: FadeTransition(
                opacity: const AlwaysStoppedAnimation<double>(1.0), // Example opacity animation
                child: Image.network(furniture.imageUrl, width: double.infinity, height: 300, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              furniture.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink),
            ),
            const SizedBox(height: 8.0),
            Text(
              furniture.description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Price: \$${furniture.price.toString()}',
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

class FurnitureSearch extends SearchDelegate {
  final List<Furniture> furnitureList;

  FurnitureSearch(this.furnitureList);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Furniture> results = furnitureList.where((furniture) {
      return furniture.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return results.isEmpty
        ? const Center(child: Text('No results found', style: TextStyle(fontSize: 18, color: Colors.grey)))
        : ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: results.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: Hero(
                  tag: 'image-${results[index].id}',
                  child: FadeTransition(
                    opacity: const AlwaysStoppedAnimation<double>(1.0), // Example opacity animation
                    child: Image.network(
                      results[index].imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(results[index].name),
                subtitle: Text(results[index].description),
                contentPadding: const EdgeInsets.all(16.0),
                tileColor: Colors.grey[100],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FurnitureDetailScreen(furniture: results[index]),
                    ),
                  );
                },
              );
            },
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Furniture> suggestions = furnitureList.where((furniture) {
      return furniture.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return suggestions.isEmpty
        ? const Center(child: Text('No suggestions found', style: TextStyle(fontSize: 18, color: Colors.grey)))
        : ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: suggestions.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: Hero(
                  tag: 'image-${suggestions[index].id}',
                  child: FadeTransition(
                    opacity: const AlwaysStoppedAnimation<double>(1.0), // Example opacity animation
                    child: Image.network(
                      suggestions[index].imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(suggestions[index].name),
                subtitle: Text(suggestions[index].description),
                contentPadding: const EdgeInsets.all(16.0),
                tileColor: Colors.grey[100],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FurnitureDetailScreen(furniture: suggestions[index]),
                    ),
                  );
                },
              );
            },
          );
  }
}

class SavedFurnitureScreen extends StatelessWidget {
  final List<Furniture> savedFurniture;

  SavedFurnitureScreen({required this.savedFurniture});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Furniture'),
      ),
      body: savedFurniture.isEmpty
          ? const Center(child: Text('No saved items'))
          : ListView.builder(
              itemCount: savedFurniture.length,
              itemBuilder: (context, index) {
                final item = savedFurniture[index];
                return ListTile(
                  leading: Hero(
                    tag: 'image-${item.id}',
                    child: FadeTransition(
                      opacity: const AlwaysStoppedAnimation<double>(1.0), // Example opacity animation
                      child: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                    ),
                  ),
                  title: Text(item.name),
                  subtitle: Text(item.description),
                  contentPadding: const EdgeInsets.all(16.0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FurnitureDetailScreen(furniture: item),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
