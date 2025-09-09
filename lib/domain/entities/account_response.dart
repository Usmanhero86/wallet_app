import 'package:equatable/equatable.dart';
import '../../data/model/account_model.dart';

class AccountResponse extends Equatable {
  final String accountNumber;
  final String accountName;
  final String bankType;
  final String firstName;
  final String surname;
  final String email;
  final DateTime createdAt;

  const AccountResponse({
    required this.accountNumber,
    required this.accountName,
    required this.bankType,
    required this.firstName,
    required this.surname,
    required this.email,
    required this.createdAt,
  });

  factory AccountResponse.fromModel(AccountModel model) {
    return AccountResponse(
      accountNumber: model.accountNumber,
      accountName: model.accountName,
      bankType: model.bankType,
      firstName: model.firstName,
      surname: model.surname,
      email: model.email,
      createdAt: model.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    accountNumber,
    accountName,
    bankType,
    firstName,
    surname,
    email,
    createdAt,
  ];
}
