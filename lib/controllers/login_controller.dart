import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_request_model.dart';
import '../network/login_repository.dart';
import '../views/dashboard_view.dart';

class LoginController extends GetxController {
  final LoginRepository _repository = LoginRepository();
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter both email and password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    final request = LoginRequestModel(email: email, password: password);
    final response = await _repository.login(request);

    isLoading.value = false;

    if (response.success) {
      // Save token to SharedPreferences
      if (response.token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', response.token!);
        if (response.user != null) {
          await prefs.setInt('user_id', response.user!.id);
          await prefs.setString('user_name', response.user!.firstName);
        }
      }

      Get.snackbar(
        'Success',
        'Logged in successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // Navigate to dashboard
      Get.offAll(() => DashboardView());
    } else {
      Get.snackbar(
        'Login Failed',
        response.error ?? 'Unknown error',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
