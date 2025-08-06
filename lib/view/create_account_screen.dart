import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import '../themes/theme_provider.dart';
import '../services/account_provider.dart';
import '../widget/app_button.dart';
import '../widget/input_field.dart';

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

  // List of banks for dropdown
  final List<String> _banks = [
    'Select Bank',
    'fcmb',
    'fidelity',
    'GTBank'
  ];
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

  void _submitForm(BuildContext context) {
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
      provider.createVirtualAccount(payload,context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AccountProvider>(context);
    return Scaffold(
        appBar: AppBar(title: const Text("Create Virtual Account"),
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
      CustomTextFormField(
    controller: _firstName,
          labelText: 'First Name',
        validator: (value) => value!.isEmpty ? 'Required' : null,
    ),
    CustomTextFormField(
    controller: _surname,
        labelText: 'Surname',
      validator: (value) => value!.isEmpty ? 'Required' : null,
    ),
    CustomTextFormField(
    controller: _mobile,
        labelText: 'Mobile Number',
      validator: (value) => value!.isEmpty ? 'Required' : null,
    ),
    CustomTextFormField(
    controller: _bvn,
        labelText: 'BVN',
      validator: (value) => value!.isEmpty ? 'Required' : null,
    ),
      CustomTextFormField(
    controller: _email,
          labelText: 'Email',
        validator: (value) => value!.isEmpty ? 'Required' : null,
    ),
    CustomTextFormField(
    controller: dob,
        labelText: 'Date of Birth',
      validator: (value) => value!.isEmpty ? 'Required' : null,
    ),
    CustomTextFormField(
    controller: title,
        labelText: 'Title',
      validator: (value) => value!.isEmpty ?'Required' : null,
    ),
      CustomTextFormField(
        controller: address,
          labelText: 'Address',
        validator: (value) => value!.isEmpty ? 'Required' : null,
      ),
      CustomTextFormField(
        controller: gender,
          labelText: 'Gender',
        validator: (value) => value!.isEmpty ? 'Required' : null,
      ),
      CustomTextFormField(
        controller: state,
          labelText: 'State',
        validator: (value) => value!.isEmpty ? 'Required' : null,
      ),
      const SizedBox(height: 20),
      AppButton(
        onPressed: () => _submitForm(context), text: 'Create Account',
      ),
      const SizedBox(height: 20),
      if (provider.accountResponse != null)
        Card(
          child: ListTile(
            title: Text("Account Number: ${provider.accountResponse!.accountNumber}"),
            subtitle: Text("Name: ${provider.accountResponse!.accountName}"),
          ),
        ),
      if (provider.error != null)
        Text(provider.error!, style: const TextStyle(color: Colors.red)),

      const SizedBox(height: 20),

      // Display the last created account
      if (provider.accountResponse != null)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Created Successfully!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text('Account Number: ${provider.accountResponse!.accountNumber}'),
                Text('Account Name: ${provider.accountResponse!.accountName}'),
                Text('Bank: ${_selectedBank.val}'),
              ],
            ),
          ),
        ),
    ],)
    )
        )
    );
  }

  void submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBank == 'Select Bank') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a bank')),
        );
        return;
      }
      final provider = Provider.of<AccountProvider>(context, listen: true);
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

      // Clear form after successful creation

      if (provider.accountResponse != null) {
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
      }
    }
  }

}