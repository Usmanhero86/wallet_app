import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/account_provider.dart';

class SendPaymentScreen extends StatefulWidget {
  const SendPaymentScreen({super.key});

  @override
  State<SendPaymentScreen> createState() => _SendPaymentScreenState();
}

class _SendPaymentScreenState extends State<SendPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _narrationController = TextEditingController();

  bool _isSending = false;

  Future<void> _sendPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    final provider = Provider.of<AccountProvider>(context, listen: false);

    try {
      final amount = double.parse(_amountController.text.trim());
      final narration = _narrationController.text.trim();

      await provider.sendPayment(amount, narration, ' ');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment sent successfully')),
      );

      Navigator.pop(context, true); // ✅ Return true to trigger dashboard refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  final val = double.tryParse(value);
                  if (val == null || val <= 0) return 'Enter valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _narrationController,
                decoration: const InputDecoration(
                  labelText: 'Narration',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter narration' : null,
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
