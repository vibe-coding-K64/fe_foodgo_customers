import 'package:flutter/material.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chinh sua tai khoan'),
      ),
      body: const Center(
        child: Text('Chinh sua tai khoan'),
      ),
    );
  }
}
