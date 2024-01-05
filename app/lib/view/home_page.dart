import 'package:app/model/catatan.dart';
import 'package:app/view/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/model/item_list.dart';
import 'calculator_page.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  bool isComplete = false;

  @override
  Widget build(BuildContext context) {
    CollectionReference todoCollection = _firestore.collection('catatan');
    final User? user = _auth.currentUser;

    Future<void> _signOut() async {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }

    Future<QuerySnapshot>? searchResultsFuture;

    Future<void> searchResult(String textEntered) async {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("catatan")
          .where("title", isGreaterThanOrEqualTo: textEntered)
          .where("title", isLessThan: textEntered + 'z')
          .get();

      setState(() {
        searchResultsFuture = Future.value(querySnapshot);
      });
    }

    void cleartext() {
      _titleController.clear();
      _descriptionController.clear();
    }

    Future<void> addTodo() async {
      try {
        await todoCollection.add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'isComplete': isComplete,
          'uid': _auth.currentUser!.uid,
        });
      } catch (error) {
        print('Failed to catatan harian $error');
      }
    }

    void getTodo() {
      setState(() {});
    }

    void initState() {
      super.initState();
      getTodo();
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Catatan Harianmu'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              bool confirmLogout = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Logout'),
                  content: Text('Apakah anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Tidak'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Ya'),
                    ),
                  ],
                ),
              );

              if (confirmLogout == true) {
                await _auth.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.calculate),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalculatorPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Cari Catatan',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (textEntered) {
                searchResult(textEntered);

                setState(() {
                  _searchController.text = textEntered;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _searchController.text.isEmpty
                  ? _firestore
                      .collection('catatan')
                      .where('uid', isEqualTo: user!.uid)
                      .snapshots()
                  : searchResultsFuture != null
                      ? searchResultsFuture!
                          .asStream()
                          .cast<QuerySnapshot<Map<String, dynamic>>>()
                      : Stream.empty(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                List<Todo> listTodo = snapshot.data!.docs.map((document) {
                  final data = document.data();
                  final String title = data['title'];
                  final String description = data['description'];
                  final bool isComplete = data['isComplete'];
                  final String uid = user!.uid;

                  return Todo(
                    description: description,
                    title: title,
                    isComplete: isComplete,
                    uid: uid,
                  );
                }).toList();
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: listTodo.length,
                  itemBuilder: (context, index) {
                    return ItemList(
                      todo: listTodo[index],
                      transaksiDocId: snapshot.data!.docs[index].id,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Tambah Catatan'),
              content: SizedBox(
                width: 200,
                height: 100,
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(hintText: 'Judul Catatan'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(hintText: 'Isi Catatan'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Batalkan'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text('Tambah'),
                  onPressed: () {
                    addTodo();
                    cleartext();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
