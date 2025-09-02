import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import '../themes/theme_provider.dart';
import '../services/account_provider.dart';
import '../widget/app_button.dart';
import '../widget/input_field.dart';
import '../widget/u_app_bar.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _surname = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _bvn = TextEditingController();
  final address = TextEditingController();
  final title = TextEditingController();
  final dob = TextEditingController();
  final state = TextEditingController();
  final gender = TextEditingController();
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
    gender.dispose();
    dob.dispose();
    address.dispose();
    state.dispose();
    title.dispose();
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

      final provider = Provider.of<AccountProvider>(context, listen: false);
      final payload = {
        "bankType": _selectedBank,
        "firstName": _firstName.text,
        "surname": _surname.text,
        "email": _email.text,
        "mobileNumber": _mobile.text,
        "dob": dob.text,
        "gender": gender.text,
        "address": address.text,
        "title": title.text,
        "state": state.text,
        "bvn": _bvn.text,
        "zainboxCode": "EXM_p5GDESXZzc0JKbB50DNS",
      };

      await provider.createVirtualAccount(payload, context);

      if (provider.accountResponse != null) {
        // Save account info locally
        storage.write("account", {
          "accountNumber": provider.accountResponse!.accountNumber,
          "accountName": provider.accountResponse!.accountName,
          "bankType": _selectedBank,
        });

        // ✅ Clear form after success
        _formKey.currentState?.reset();
        setState(() {
          _selectedBank = 'Select Bank';
        });
        _firstName.clear();
        _surname.clear();
        _email.clear();
        _mobile.clear();
        _bvn.clear();
        gender.clear();
        dob.clear();
        address.clear();
        state.clear();
        title.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AccountProvider>(context);
    final savedAccount = storage.read("account");

    return Scaffold(
      appBar: UAppBar(
        title: const Text("Create Virtual Account"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            children: [
              // Bank Type Dropdown
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
                    setState(() {
                      _selectedBank = newValue!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value == 'Select Bank') {
                      return 'Please select a bank';
                    }
                    return null;
                  },
                ),
              ),
              InputField(
                controller: _firstName,
                labelText: 'First Name',
                validator: (value) =>
                value!.isEmpty ? 'Required' : null,
              ),
              InputField(
                controller: _surname,
                labelText: 'Surname',
                validator: (value) =>
                value!.isEmpty ? 'Required' : null,
              ),
              InputField(
                controller: _mobile,
                labelText: 'Mobile Number',
                validator: (value) =>
                value!.isEmpty ? 'Required' : null,
              ),
              InputField(
                controller: _bvn,
                labelText: 'BVN',
                validator: (value) =>
                value!.isEmpty ? 'Required' : null,
              ),
              InputField(
                controller: _email,
                labelText: 'Email',
                validator: (value) =>
                value!.isEmpty ? 'Required' : null,
              ),
              InputField(
                controller: dob,
                labelText: 'Date of Birth',
                validator: (value) =>
                value!.isEmpty ? 'Required' : null,
              ),
              InputField(
                controller: title,
                labelText: 'Title',
                validator: (value) =>
                value!.isEmpty ? 'Required' : null,
              ),
              InputField(
                controller: address,
                labelText: 'Address',
                validator: (value) =>
                value!.isEmpty ? 'Required' : null,
              ),
              InputField(
                controller: gender,
                labelText: 'Gender',
                validator: (value) =>
                value!.isEmpty ? 'Required' : null,
              ),
              InputField(
                controller: state,
                labelText: 'State',
                validator: (value) =>
                value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              AppButton(
                onPressed: () => _submitForm(context),
                text: 'Create Account',
              ),
              const SizedBox(height: 20),

              // ✅ Show newly created account
              if (savedAccount != null)
                Card(
                  child: ListTile(
                    title: Text(
                        "Account Number: ${savedAccount["accountNumber"]}"),
                    subtitle:
                    Text("Name: ${savedAccount["accountName"]}"),
                    trailing: Text("Bank: ${savedAccount["bankType"]}"),
                  ),
                ),

              if (provider.errorMessage != null)
                Text(provider.errorMessage!,
                    style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
