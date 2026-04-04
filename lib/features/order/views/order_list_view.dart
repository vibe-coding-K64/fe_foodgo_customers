import 'package:flutter/material.dart';

class OrderListView extends StatelessWidget {
  const OrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sach don hang'),
      ),
      body: const Center(
        child: Text('Danh sach don hang'),
      ),
    );
  }
}
