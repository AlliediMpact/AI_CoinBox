import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/wallet_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Header extends StatefulWidget {
  const Header({Key? key}) : super(key: key);

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  String _searchTerm = '';
  List<Map<String, dynamic>> _suggestions = [];

  void _onSearchChanged(String value) {
    setState(() {
      _searchTerm = value;
      _getSuggestions(value);
    });
  }

  Future<void> _getSuggestions(String searchTerm) async {
    if (searchTerm.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('coins')
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThan: searchTerm + 'z')
        .get();

    setState(() {
      _suggestions = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Function to remove a suggestion from the list
  void _removeSuggestion(Map<String, dynamic> suggestion) {
    setState(() {
      _suggestions.remove(suggestion);
    });
  }

  // Function to add text to the search bar
  void _addTextToSearchBar(String text) {
      setState(() {
          _searchTerm = text;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
            child: Image.asset(
              'assets/images/CoinBoxLogo01.png',
              height: 40,
            ),
          ),
          const SizedBox(width: 20),
          // Search Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: _onSearchChanged,
                ),
                if (_suggestions.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.all(5),
                    child: Wrap(
                      children: _suggestions
                          .map((suggestion) => Padding(
                                padding: const EdgeInsets.all(5),
                                child: Chip(
                                  label: Text('${suggestion['name']} (${suggestion['symbol']})'),
                                  onDeleted: () {
                                      _removeSuggestion(suggestion); // Handle suggestion selection
                                  },
                                  // remove this line
                                  //onTap: () {
                                  //    _addTextToSearchBar('${suggestion['name']} (${suggestion['symbol']})'); // Add the text to the search bar
                                  //},
                                ),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/wallet');
                      },
                      child: const Text('My Wallet'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      child: const Text('My Profile'),
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text('Login'),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
