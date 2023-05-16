import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
// import 'package:cached_network_image/cached_network_image.dart';

class Receipt {
  final double amount;
  final String name;
  final String tag;
  final String image;
  String localImage;

  Receipt({required this.amount, required this.name, required this.tag, required this.image, required this.localImage});
}
// //
class MyListView extends StatefulWidget {
  @override
  _MyListViewState createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView> {
  final List<Receipt> _myList = [];
  bool imageLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _delete(Receipt item) async {

    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final CollectionReference usersCollection = FirebaseFirestore.instance
          .collection('users');
      final DocumentReference userDocument = usersCollection.doc(user.uid);
      final CollectionReference userDataCollection = userDocument.collection(
          'receipts');
      userDataCollection.doc(item.name).delete();
    }

    setState(() {
      _myList.remove(item);
    });
  }

  Future<void> _openImage(String im) async {

    File image = File(im);
    print('next print checks if image exists');
    print(await image.exists());
    // Check if the image file exists
    if (await image.exists()) {
      // If the file existsopen it using the platform's default app
      await OpenFile.open(image.path);
    } else {
      // If the file doesn't exist, show an error message
      print('Error: Image file does not exist.');
    }
  }

  bool checkIfImageExists(String imagePath) {
    File file = File(imagePath);
    bool exists = file.existsSync();
    return exists;
  }

  Future<String> getImage(Receipt re) async {

    String imageUrl = re.image;
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final fileName = imageUrl.split('/').last;
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File downloaded successfully')),
      );
      return '${directory.path}/$fileName';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download file')),
      );
      return '';
    }
  }

  Future<bool> checkForLocalFile(String localImage) async {

    final directory = await getApplicationDocumentsDirectory(); // get the application documents directory

    print('this is the directory');
    print('this is the local image: $localImage');
    directory.list().forEach((element) {
      print(element);
      // if()
    });
    if(await directory.list().contains(localImage)){
      return true;
    }
    return false;
  }

  Future<void> saveImage(Uint8List imageData, String fileName, int index) async {
    final directory = await getApplicationDocumentsDirectory(); // get the application documents directory

    print('this is the directory');
    directory.list().forEach((element) {
      print(element);
    });
    print('that was the directory');

    final String encodedFilename = Uri.encodeFull(fileName);
    final file = File('${directory.path}/$encodedFilename.jpg'); // create a new file in the directory
    await file.writeAsBytes(imageData);
    setState(() {
      _myList[index].localImage = "${file.path}";
    });
  }

  void _loadData() async {
    CollectionReference<Map<String, dynamic>> collectionRef = FirebaseFirestore.instance.collection('receipts');
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await collectionRef.get();

    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
      final DocumentReference userDocument = usersCollection.doc(user.uid);
      final CollectionReference userDataCollection = userDocument.collection('receipts');
      final QuerySnapshot userDataSnapshot = await userDataCollection.get();
      final List<QueryDocumentSnapshot> userDataDocs = userDataSnapshot.docs;
      for (var doc in userDataDocs) {
        Receipt re = Receipt(image: doc.get('image'), amount: doc.get('amount'), name: doc.get('name'), tag: doc.get('tag'), localImage: doc.get('localImage'));
        setState(() {
          _myList.add(re);
          print('print my list: $_myList');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: const Text('My List'),
    ),
      body: ListView.builder(
        itemCount: _myList.length,
        itemBuilder: (BuildContext context, int index) {
          final File imageFile = File(_myList[index].localImage);
          final Reference storageRef = FirebaseStorage.instance.ref().child('/images/${_myList[index].name}');

          File fff = File(_myList[index].localImage);
          // print('${fff.existsSync()}');
          print('check for localImage');
          checkForLocalFile(_myList[index].localImage);
          return ListTile(
            leading: FutureBuilder<bool>(
              future: imageFile.exists(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                // print('${imageFile.exists()}');
                if (snapshot.hasData && snapshot.data!) {
                  // If the image file exists in the local file system, display it in the app
                  // print('Image exists in Local Storage!');
                  return GestureDetector(
                    onTap: (){
                      _openImage(_myList[index].localImage);
                    },
                    child: Image.file(
                      File(_myList[index].localImage),
                      width: 50,
                      height: 50,
                    ),
                  );
                } else {
                  // If the image file doesn't exist in the local file system, download it from Firebase Storage
                  return FutureBuilder<String>(
                    future: storageRef.getDownloadURL(),
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        final String downloadUrl = snapshot.data!;
                        return FutureBuilder<Uint8List>(
                          future: http.get(Uri.parse(downloadUrl)).then((response) => response.bodyBytes),
                          builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                            if (snapshot.hasData) {
                              final Uint8List bytes = snapshot.data!;
                              // print(snapshot.data);
                              // print(_myList[index].localImage);
                              // saveImage(bytes, _myList[index].name, index);
                              print(_myList[index].localImage);
                              return GestureDetector(
                                onTap: (){
                                  _openImage(_myList[index].localImage);
                                },
                                child:
                                // CachedNetworkImage(
                                //   imageUrl: "http://via.placeholder.com/350x150",
                                //   progressIndicatorBuilder: (context, url, downloadProgress) =>
                                //       CircularProgressIndicator(value: downloadProgress.progress),
                                //   errorWidget: (context, url, error) => Icon(Icons.error),
                                // ),
                                Image.file(
                                  File(_myList[index].localImage),
                                  width: 50,
                                  height: 50,
                                ),
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  );
                }
              },
            ),
            title: Text(_myList[index].name),
            subtitle: Text(_myList[index].tag.toString()),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('My Alert Dialog'),
                        content: const Text('Are you sure you want to delete this receipt?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                            Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                            _delete(_myList[index]);
                            Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
          );
        },
      ),
    );
  }
}