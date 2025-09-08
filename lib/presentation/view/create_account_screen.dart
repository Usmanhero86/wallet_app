import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../../di/providers.dart';
import '../widget/app_button.dart';
import '../widget/date_picker_input.dart';
import '../widget/input_field.dart';
import '../widget/u_app_bar.dart';
import 'dashboard_screen.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final storage = GetStorage();

  // Controllers
  final _firstName = TextEditingController();
  final _surname = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _bvn = TextEditingController();
  final _address = TextEditingController();
  final _title = TextEditingController();
  final _dob = TextEditingController();
  final _state = TextEditingController();
  final _gender = TextEditingController();

  final List<String> _banks = ['Select Bank', 'fcmb', 'fidelity', 'GTBank'];
  String _selectedBank = 'Select Bank';

  @override
  void dispose() {
    _firstName.dispose();
    _surname.dispose();
    _email.dispose();
    _mobile.dispose();
    _bvn.dispose();
    _gender.dispose();
    _dob.dispose();
    _address.dispose();
    _state.dispose();
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: DateTime(2000),
    );
    if (picked != null) {
      _dob.text = "${picked.year}-${picked.month}-${picked.day}";
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBank == 'Select Bank') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bank')),
      );
      return;
    }

    final notifier = ref.read(accountNotifierProvider.notifier);
    final payload = {
      "bankType": _selectedBank,
      "firstName": _firstName.text,
      "surname": _surname.text,
      "email": _email.text,
      "mobileNumber": _mobile.text,
      "dob": _dob.text,
      "gender": _gender.text,
      "address": _address.text,
      "title": _title.text,
      "state": _state.text,
      "bvn": _bvn.text,
      "zainboxCode": "EXM_p5GDESXZzc0JKbB50DNS",
    };

    final result = await notifier.createVirtualAccount(payload);

    if (!mounted) return;

    if (result == "success") {
      final account = ref.read(accountNotifierProvider).accountResponse;

      if (account != null) {
        // ✅ Save locally
        storage.write("account", {
          "accountNumber": account.accountNumber,
          "accountName": account.accountName,
          "bankType": _selectedBank,
        });

        // ✅ Navigate instantly to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result == "error" ? "Account creation failed" : result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountNotifierProvider);
    final savedAccount = storage.read("account");

    return Scaffold(
      appBar: const UAppBar(title: Text("Create Virtual Account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- Bank selection ---
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedBank,
                  decoration: InputDecoration(
                    labelText: 'Bank Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _banks.map((String bank) {
                    return DropdownMenuItem<String>(
                      value: bank,
                      child: Text(bank),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() => _selectedBank = newValue!);
                  },
                  validator: (value) {
                    if (value == null || value == 'Select Bank') {
                      return 'Please select a bank';
                    }
                    return null;
                  },
                ),
              ),

              // --- Personal details ---
              InputField(controller: _firstName, labelText: 'First Name', validator: _requiredValidator),
              InputField(controller: _surname, labelText: 'Surname', validator: _requiredValidator),
              InputField(controller: _mobile, labelText: 'Mobile Number', validator: _requiredValidator),
              InputField(controller: _bvn, labelText: 'BVN', validator: _requiredValidator),
              InputField(controller: _email, labelText: 'Email', validator: _requiredValidator),

              // --- Date picker ---
              GestureDetector(
                onTap: () => _pickDate(context),
                child: AbsorbPointer(
                  child: DatePickerInput(
                    controller: _dob,
                    labelText: 'Date of Birth',
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    lastDate: DateTime.now(), // prevent selecting future dates
                  ),

                ),
              ),

              InputField(controller: _title, labelText: 'Title', validator: _requiredValidator),
              InputField(controller: _address, labelText: 'Address', validator: _requiredValidator),
              InputField(controller: _gender, labelText: 'Gender', validator: _requiredValidator),
              InputField(controller: _state, labelText: 'State', validator: _requiredValidator),

              const SizedBox(height: 20),

              AppButton(
                onPressed: () => _submitForm(context),
                text: 'Create Account',
              ),

              const SizedBox(height: 20),

              // --- Saved account preview ---
              if (savedAccount != null)
                Card(
                  child: ListTile(
                    title: Text("Account Number: ${savedAccount["accountNumber"]}"),
                    subtitle: Text("Name: ${savedAccount["accountName"]}"),
                    trailing: Text("Bank: ${savedAccount["bankType"]}"),
                  ),
                ),

              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Required";
    }
    return null;
  }
}
