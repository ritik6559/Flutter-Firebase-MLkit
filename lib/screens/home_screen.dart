import 'package:flutter/material.dart';
import 'package:flutter_firebase_ml_kit/screens/details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> itemList = [
    'Text Scanner',
    'Barcode Scanner',
    'Label Scanner',
    'Face Detection'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML kit'),
      ),
      body: ListView.builder(
        itemCount: itemList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(itemList[index]),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DetailScreen(),
                    settings: RouteSettings(
                      arguments: itemList[index],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
