import 'package:flutter/material.dart';

class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiet don hang'),
      ),
      body: const Center(
        child: Text('Chi tiet don hang'),
      ),
    );
  }
}
