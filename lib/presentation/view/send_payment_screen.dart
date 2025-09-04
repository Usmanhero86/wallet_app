import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/providers.dart';
import '../providers/account_repository_provider.dart';
import '../widget/input_field.dart';
import '../widget/app_button.dart';
import '../widget/u_app_bar.dart';

class SendPaymentScreen extends ConsumerStatefulWidget {
  const SendPaymentScreen({super.key});

  @override
  ConsumerState<SendPaymentScreen> createState() => _SendPaymentScreenState();
}

class _SendPaymentScreenState extends ConsumerState<SendPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _narrationController = TextEditingController();
  final _recipientController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _narrationController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  Future<void> _sendPayment(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(accountNotifierProvider.notifier);

    final result = await notifier.sendPayment(
      double.tryParse(_amountController.text) ?? 0.0,
      _narrationController.text,
      _recipientController.text,
    );

    if (!mounted) return;

    switch (result) {
      case 'success':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment sent successfully!')),
        );
        Navigator.pop(context, true); // ✅ Return to Dashboard and reload
        break;

      case 'no_account':
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Please create an account first.')),
        );
        break;
      case 'invalid_amount':
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Amount must be greater than 100.')),
        );
        break;
      case 'insufficient':
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Insufficient funds.')),
        );
        break;
      case 'failed':
      case 'error':
      default:
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Payment failed. Please try again.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountNotifierProvider);
    return Scaffold(
      appBar: UAppBar(title: Text('Send Payment')),
      body: Padding(
        padding:  EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InputField(
                controller: _amountController,
                labelText: "Amount",
                keyboardType: TextInputType.number,
                validator: (value) =>
                (value == null || value.isEmpty) ? "Enter amount" : null,
              ),
              InputField(
                controller: _narrationController,
                labelText: "Narration",
                validator: (value) => (value == null || value.isEmpty)
                    ? "Enter narration"
                    : null,
              ),
              InputField(
                controller: _recipientController,
                labelText: "Recipient Account",
                validator: (value) => (value == null || value.isEmpty)
                    ? "Enter recipient account"
                    : null,
              ),
               SizedBox(height: 24),
              state.isLoading
                  ?  CircularProgressIndicator()
                  : AppButton(
                onPressed: () => _sendPayment(context),
                text: 'Send',
                padding: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
