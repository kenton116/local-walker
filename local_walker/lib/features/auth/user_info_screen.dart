import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../home/home_screen.dart';
import 'dart:io';

class UserInfoScreen extends StatefulWidget {
  final String uid;
  final String email;

  const UserInfoScreen({super.key, required this.uid, required this.email});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _usernameController = TextEditingController();
  File? _profileImage;
  DateTime? _birthDate;
  String? _selectedGender;
  final List<String> _genderOptions = ['男性', '女性', '回答しない', 'その他'];
  bool _isLoading = false;
  bool _isPickerActive = false;

  Future<void> _pickProfileImage() async {
    if (_isPickerActive) return;
    setState(() => _isPickerActive = true);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<String?> _uploadImage(String uid) async {
    if (_profileImage == null) return null;
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_profiles')
          .child('$uid.jpg');

      await ref.putFile(_profileImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('画像アップロードエラー: $e');
      return null;
    }
  }

  Future<void> _saveUserInfo() async {
    if (_usernameController.text.isEmpty ||
        _birthDate == null ||
        _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('全ての項目を入力してください')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? photoUrl = await _uploadImage(widget.uid);
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).set({
        'userId': widget.uid,
        'username': _usernameController.text.trim(),
        'email': widget.email,
        'profilePhotoUrl': photoUrl,
        'birthDate': _birthDate,
        'gender': _selectedGender,
        'preferences': {},
        'settings': {},
        'hasOnboarded': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(email: widget.email)),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ユーザー情報登録')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickProfileImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? const Icon(Icons.add_a_photo, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'ユーザー名'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              decoration: const InputDecoration(
                labelText: '性別',
                border: OutlineInputBorder(),
              ),
              items: _genderOptions.map((gender) {
                return DropdownMenuItem(value: gender, child: Text(gender));
              }).toList(),
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(_birthDate == null
                    ? '誕生日を選択'
                    : '${_birthDate!.year}/${_birthDate!.month}/${_birthDate!.day}'),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _pickBirthDate,
                  child: const Text('選択'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveUserInfo,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('次へ進む', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
