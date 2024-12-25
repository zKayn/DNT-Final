import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shoppingapp/Admin/admin_login.dart';
import 'package:shoppingapp/pages/onboarding.dart';
import 'firebase_options.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:shoppingapp/providers/cart_provider.dart'; // Import CartProvider
import 'package:shoppingapp/Admin/home_admin.dart'; // Import trang mặc định

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

  // Khởi tạo Stripe
  if (!kIsWeb) {
    Stripe.publishableKey = 'pk_test_51QL1oRBTMJPu3L7nAjK7wIDGvgX2bYMKhW2bERUp40JGkSh4BF74Pn8fkQEeAyWsBfqmW90VXi49uWMQZwJHi9wT00N9o52pjl'; // Đặt khóa công khai
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Onboarding(), // Trang mặc định
    );
  }
}
