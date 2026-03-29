import 'package:flutter/material.dart';
import 'screens/party_feed_screen.dart';

void main() {
  runApp(HousePartyApp());
}

class HousePartyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'District House Party',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: PartyFeedScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
