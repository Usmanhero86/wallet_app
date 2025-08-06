import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../themes/theme_provider.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../services/account_provider.dart';
import '../widget/app_button.dart';
import '../widget/input_field.dart';
import 'login_screen.dart';

class SendPaymentScreen extends StatefulWidget {
  const SendPaymentScreen({super.key});

  @override
  _SendPaymentScreenState createState() => _SendPaymentScreenState();
}

class _SendPaymentScreenState extends State<SendPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final recipientController = TextEditingController();
  final amountController = TextEditingController();
  final referenceController = TextEditingController();
  bool _isLoading = false;
  String _message = '';
  bool _isSuccess = false;

  Future<void> sendPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) {
        // Handle case where user is not authenticated
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>  LoginScreen()),
        );
        return;
      }
      final response = await ApiService.sendPayment(
        recipientController.text,
        double.parse(amountController.text),
        referenceController.text,
        token,

      );

      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _message = response['message'];
      });

      // Optionally refresh balance after successful payment
      Provider.of<AccountProvider>(context, listen: false).fetchWalletBalance(context);
    } on PlatformException catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _message = e.message ?? 'Failed to send payment';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _message = 'An unexpected error occurred';
      });


    }
  }

  @override
  void dispose() {
    recipientController.dispose();
    amountController.dispose();
    referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Send Payment'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(themeProvider.isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode),
                onPressed: () {
                  themeProvider.toggleTheme(!themeProvider.isDarkMode);
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextFormField(
                controller: recipientController,
                labelText: 'Recipient Account',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter recipient account';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: amountController,
                labelText: 'Amount',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextFormField(
                controller: referenceController,
                labelText: 'Reference (Optional)',
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : AppButton(
                onPressed: sendPayment,
                text: 'Send Payment',
              ),
              if (_message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _message,
                    style: TextStyle(
                      color: _isSuccess ? Colors.green : Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}