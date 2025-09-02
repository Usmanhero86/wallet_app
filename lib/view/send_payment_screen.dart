import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/widget/input_field.dart';
import '../services/account_provider.dart';
import '../widget/u_app_bar.dart';

class SendPaymentScreen extends StatefulWidget {
  const SendPaymentScreen({super.key});

  @override
  State<SendPaymentScreen> createState() => _SendPaymentScreenState();
}

class _SendPaymentScreenState extends State<SendPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _narrationController = TextEditingController();
  final _recipientController = TextEditingController();


  bool _isSending = false;

  Future<void> _sendPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    final provider = Provider.of<AccountProvider>(context, listen: false);

    final amount = double.parse(_amountController.text.trim());
    final narration = _narrationController.text.trim();
    final recipientAccount = _recipientController.text.trim();

    final result = await provider.sendPayment(amount, narration, recipientAccount);

    if (!mounted) return;

    switch (result) {
      case 'success':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment sent successfully!')),
        );
        Navigator.pop(context, 'success'); // return success to dashboard
        break;
      case 'insufficient':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insufficient funds')),
        );
        Navigator.pop(context, 'insufficient');
        break;
      case 'invalid_amount':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid amount entered')),
        );
        break;
      case 'no_account':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please create an account first')),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction failed. Please try again.')),
        );
    }

    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UAppBar(title:  Text('Send Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InputField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  final val = double.tryParse(value);
                  if (val == null || val <= 0) return 'Enter valid amount';
                  return null;
                }, labelText: 'Amount',
              ),
              const SizedBox(height: 16),
              InputField(
                controller: _recipientController,
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter recipient account number' : null,
                labelText: 'Recipient Account Number',
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              InputField(
                controller: _narrationController,
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter narration' : null,
                labelText: 'Narration',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSending ? null : _sendPayment,
                child: _isSending
                    ? const CircularProgressIndicator()
                    : const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
