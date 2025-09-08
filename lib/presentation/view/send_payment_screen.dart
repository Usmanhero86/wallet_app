import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/providers.dart';
import '../widget/app_button.dart';
import '../widget/input_field.dart';
import '../widget/narration_input.dart';
import '../widget/u_app_bar.dart';

class SendPaymentScreen extends ConsumerStatefulWidget {
  const SendPaymentScreen({super.key});

  @override
  ConsumerState<SendPaymentScreen> createState() => _SendPaymentScreenState();
}

class _SendPaymentScreenState extends ConsumerState<SendPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amount = TextEditingController();
  final _recipient = TextEditingController();
  final _narration = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void dispose() {
    _amount.dispose();
    _recipient.dispose();
    _narration.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submitPayment(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a date")),
        );
        return;
      }

      final notifier = ref.read(accountNotifierProvider.notifier);

      final result = await notifier.sendPayment(
        double.tryParse(_amount.text) ?? 0.0,
        _narration.text,
        _recipient.text,
      );

      if (!mounted) return;

      if (result == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment sent successfully")),
        );
        Navigator.pop(context, true); // ✅ Return true so dashboard refreshes
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result == "error"
                  ? "Payment failed. Please try again."
                  : result,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountNotifierProvider);
    return Scaffold(
      appBar: UAppBar(title: const Text("Send Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            children: [
              InputField(
                controller: _amount,
                labelText: 'Amount',
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Amount is required' : null,
              ),
              InputField(
                controller: _recipient,
                labelText: 'Recipient Account',
                validator: (value) =>
                value!.isEmpty ? 'Recipient is required' : null,
              ),
              NarrationInput(controller: _narration),

              GestureDetector(
                onTap: () => _pickDate(context),
                child: AbsorbPointer(
                  child: InputField(
                    controller: _dateController,
                    labelText: 'Transaction Date',
                    validator: (value) => value!.isEmpty
                        ? 'Please pick a transaction date'
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                onPressed: () => _submitPayment(context),
                text: 'Send Payment',
              ),
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
