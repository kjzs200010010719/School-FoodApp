import 'package:flutter/material.dart';
import 'package:my_app/models/merchant_account.dart';
import 'package:my_app/screens/admin_product_screen.dart';
import 'package:my_app/services/merchant_auth_service.dart';
import 'package:my_app/screens/merchant_products_screen.dart';

class MerchantLoginScreen extends StatefulWidget {
  const MerchantLoginScreen({super.key});

  @override
  State<MerchantLoginScreen> createState() => _MerchantLoginScreenState();
}

class _MerchantLoginScreenState extends State<MerchantLoginScreen> {
  final TextEditingController _emailController = TextEditingController(
    text: 'store@mcu-food.local',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'demo1234',
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MerchantAuthService.instance.useCloud) {
      return const CloudMerchantLoginScreen();
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F4),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2E3A2F)),
        title: const Text(
          '商家登入',
          style: TextStyle(
            color: Color(0xFF2E3A2F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _buildIntroCard(),
            const SizedBox(height: 16),
            _buildLoginForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.storefront_rounded, color: Color(0xFF4E8D57), size: 48),
          SizedBox(height: 12),
          Text(
            '商家後台入口',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A2F),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '商家帳戶與一般會員分開管理，未來可串接正式帳號、店家資料與商品上架審核流程。',
            style: TextStyle(color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '登入資訊',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A2F),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: '商家 Email',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: '密碼',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _goToAdminProductScreen,
              icon: const Icon(Icons.inventory_2_rounded),
              label: const Text('進入商家後台'),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '目前為專題展示用測試登入，正式版本會依商家帳戶權限決定可管理的門市與商品。',
            style: TextStyle(color: Colors.black45, height: 1.45),
          ),
        ],
      ),
    );
  }

  void _goToAdminProductScreen() {
    MerchantAuthService.instance.loginWithDemo(email: _emailController.text);
    final merchant =
        MerchantAuthService.instance.account ?? MerchantAccount.demo;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AdminProductScreen(merchant: merchant),
      ),
    );
  }
}
