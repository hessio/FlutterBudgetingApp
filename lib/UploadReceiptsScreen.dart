import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as ims;

class AddDataPage extends StatefulWidget {
  @override
  _AddDataPageState createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage> {
  File? _image;
  String _name = '';
  String _tag = '';
  double _amount = 0.0;
  bool _isLoading = false;
  FirebaseStorage storage = FirebaseStorage.instance;
  final firestore = FirebaseFirestore.instance;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  final ImagePicker _picker = ImagePicker();
  File? _imageFile = null;

  Future<String> _storeImageLocally(String name, File _image) async {

    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/${name}.jpg';

    final File newImage = await _image.copy(imagePath);
    return newImage.path;
  }

  // Function to upload the selected image to Firebase Storage
  Future<String> _uploadImage(File imageFile, String name) async {

    Reference reference = storage.ref().child('images/$name');
    UploadTask uploadTask = reference.putFile(imageFile);
    TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _submitData() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must select an image')));
      return;
    }
    else if(_name.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name cannot be empty')));
      return;
    }
    else if(_tag.isEmpty || _amount == 0.0){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tags are helpful for searching through receipts')));
    }

    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('receipts');
    final QuerySnapshot snapshot = await usersCollection.get();

    final currentUser = FirebaseAuth.instance.currentUser;
    final CollectionReference usersCollection_ = FirebaseFirestore.instance.collection('users');
    final DocumentReference userDocument = await usersCollection_.doc(currentUser!.uid);

    final CollectionReference userDataCollection = userDocument.collection('receipts');

    final names = [];
    final docs = snapshot.docs;
    docs.forEach((element)  {
      names.add(element.id);
    });

    print('done names');
    if(names.contains(_name)){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name already used. Names must be unique')));
      return;
    }

    setState(() {
      _isLoading = true; // Set the loading state to true
    });

    // if(_image.)
    // final image = ims.decodeImage(File('test.png').readAsBytesSync())!;
    //
    // File('thumbnail.jpg').writeAsBytesSync(ims.encodeJpg(image));

    String localImage = await _storeImageLocally(_name, _image!);
    CollectionReference receiptsCollection = firestore.collection('receipts');

    String imageUrl = await _uploadImage(_image!, _name);

    await userDataCollection.doc(_name).set({
      'name': _name,
      'tag': _tag,
      'amount': _amount,
      'image': imageUrl,
      'localImage': localImage,
      // Add any other necessary fields here
    });

    // Upload the data to Firestore with the custom ID

    setState(() {
      _isLoading = false; // Set the loading state back to false
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Data'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_image != null) ...[
                Image.file(
                  _image!,
                  height: 200.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16.0),
              ],
              ElevatedButton.icon(
                onPressed: _getImage,
                icon: const Icon(Icons.image),
                label: const Text('Select Image'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Tag',
                ),
                onChanged: (value) {
                  setState(() {
                    _tag = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Amount',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    _amount = double.parse(value);
                  });
                },
              ),
              const SizedBox(height: 16.0),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator() // Show a loading spinner if isLoading is true
                    : ElevatedButton(
                        onPressed: _submitData,
                        child: const Text('Save'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

