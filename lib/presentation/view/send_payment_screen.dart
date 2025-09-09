import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/providers.dart';
import '../../domain/entities/bank.dart';
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
  Bank? selectedBank;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(bankNotifierProvider.notifier).loadBanks());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _narrationController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  Future<void> _sendPayment(BuildContext context) async {
    if (!_formKey.currentState!.validate() || selectedBank == null) return;

    final notifier = ref.read(accountNotifierProvider.notifier);

    final result = await notifier.sendPayment(
      recipientAccount: _recipientController.text,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      narration: _narrationController.text,
      bankCode: selectedBank!.code,
    );

    if (!mounted) return;

    switch (result) {
      case 'success':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment sent successfully!')),
        );
        Navigator.pop(context, true);
        break;
      case 'no_account':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please create an account first.')),
        );
        break;
      case 'invalid_amount':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Amount must be greater than 100.')),
        );
        break;
      case 'insufficient':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insufficient funds.')),
        );
        break;
      case 'failed':
      case 'error':
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed. Please try again.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bankState = ref.watch(bankNotifierProvider);
    final accountState = ref.watch(accountNotifierProvider);

    return Scaffold(
      appBar: UAppBar(title: const Text('Send Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              bankState.isLoading
                  ?  CircularProgressIndicator()
                  : bankState.error != null
                  ? Text('Error loading banks: ${bankState.error}')
                  : Padding(
                    padding:  EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<Bank>(
                                    value: selectedBank,
                                    decoration:  InputDecoration(labelText: 'Select Bank'),
                                    items: bankState.banks.map((bank) {
                    return DropdownMenuItem<Bank>(
                      value: bank,
                      child: Text(bank.name),
                    );
                                    }).toList(),
                                    onChanged: (Bank? value) {
                    setState(() {
                      selectedBank = value;
                    });
                                    },
                                    validator: (value) =>
                                    value == null ? 'Please select a bank' : null,
                                  ),
                  ),
               SizedBox(height: 16),
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
                validator: (value) =>
                (value == null || value.isEmpty) ? "Enter narration" : null,
              ),
              InputField(
                controller: _recipientController,
                labelText: "Recipient Account",
                validator: (value) =>
                (value == null || value.isEmpty) ? "Enter recipient account" : null,
              ),
               SizedBox(height: 24),
              accountState.isLoading
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
