import 'package:flutter/material.dart';
import '../../checkout/views/checkout_view.dart';

/// Man hinh Gio hang. Hien tai chuyen huong sang CheckoutView.
class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    // Chuyen huong sang trang thanh toan (CheckoutView).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CheckoutView(),
        ),
      );
    });

    // Tra ve man hinh trong trong khi chuyen huong.
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
