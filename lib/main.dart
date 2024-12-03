import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'models/user.dart';
import 'models/product.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/second': (context) => SecondPage(),
        '/combined-list': (context) => CombinedListPage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/second');
              },
              child: Text('Next'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/combined-list');
              },
              child: Text('View Combined List'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Back'),
        ),
      ),
    );
  }
}

class CombinedListPage extends StatefulWidget {
  @override
  _CombinedListPageState createState() => _CombinedListPageState();
}

class _CombinedListPageState extends State<CombinedListPage> {
  late Future<Map<User, List<Product>>> _futureUserProductMap;

  @override
  void initState() {
    super.initState();
    _futureUserProductMap = fetchUserProductMap();
  }

  Future<Map<User, List<Product>>> fetchUserProductMap() async {
    try {
      final userResponse = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
      final productResponse =
          await http.get(Uri.parse('https://fakestoreapi.com/products'));

      if (userResponse.statusCode == 200 && productResponse.statusCode == 200) {
        final List<User> users = (json.decode(userResponse.body) as List)
            .map((json) => User.fromJson(json))
            .toList();
        final List<Product> products =
            (json.decode(productResponse.body) as List)
                .map((json) => Product.fromJson(json))
                .toList();

        // Прив'язуємо продукти до користувачів
        final Map<User, List<Product>> userProductMap = {};
        int productIndex = 0;

        for (final user in users) {
          userProductMap[user] = [];
          for (int i = 0; i < 2; i++) {
            if (productIndex < products.length) {
              userProductMap[user]!.add(products[productIndex]);
              productIndex++;
            }
          }
        }

        return userProductMap;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users and Products'),
      ),
      body: FutureBuilder<Map<User, List<Product>>>(
        future: _futureUserProductMap,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final userProductMap = snapshot.data!;
            return ListView(
              children: userProductMap.entries.map((entry) {
                final user = entry.key;
                final products = entry.value;

                return ExpansionTile(
                  leading: Icon(Icons.person, color: Colors.blue),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  children: products.map((product) {
                    return ListTile(
                      leading: Icon(Icons.shopping_cart, color: Colors.green),
                      title: Text(product.title),
                      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    );
                  }).toList(),
                );
              }).toList(),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
