import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../../di/providers.dart';
import '../widget/app_button.dart';
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
  final storage = GetStorage();

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

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
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

          // ✅ Navigate instantly to dashboard & pass account details
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardScreen(),
            ),
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
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountNotifierProvider);
    final savedAccount = storage.read("account");

    return Scaffold(
      appBar: UAppBar(title: const Text("Create Virtual Account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            children: [
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
              InputField(controller: _firstName, labelText: 'First Name', validator: (value) => value!.isEmpty ? 'Required' : null,),
              InputField(controller: _surname, labelText: 'Surname', validator: (value) => value!.isEmpty ? 'Required' : null,),
              InputField(controller: _mobile, labelText: 'Mobile Number', validator: (value) => value!.isEmpty ? 'Required' : null,),
              InputField(controller: _bvn, labelText: 'BVN', validator: (value) => value!.isEmpty ? 'Required' : null,),
              InputField(controller: _email, labelText: 'Email', validator: (value) => value!.isEmpty ? 'Required' : null,),
              InputField(controller: _dob, labelText: 'Date of Birth', validator: (value) => value!.isEmpty ? 'Required' : null,),
              InputField(controller: _title, labelText: 'Title', validator: (value) => value!.isEmpty ? 'Required' : null,),
              InputField(controller: _address, labelText: 'Address', validator: (value) => value!.isEmpty ? 'Required' : null,),
              InputField(controller: _gender, labelText: 'Gender', validator: (value) => value!.isEmpty ? 'Required' : null,),
              InputField(controller: _state, labelText: 'State', validator: (value) => value!.isEmpty ? 'Required' : null,),
              const SizedBox(height: 20),
              AppButton(onPressed: () => _submitForm(context), text: 'Create Account',),
              const SizedBox(height: 20),

              // ✅ Show saved account
              if (savedAccount != null)
                Card(
                  child: ListTile(
                    title: Text(
                        "Account Number: ${savedAccount["accountNumber"]}"),
                    subtitle:
                    Text("Name: ${savedAccount["accountName"]}"),
                    trailing:
                    Text("Bank: ${savedAccount["bankType"]}"),
                  ),
                ),

              if (state.errorMessage != null)
                Text(state.errorMessage!,
                    style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
