import 'package:equatable/equatable.dart';

abstract class PaymentMethod extends Equatable{
  final String bankName;
  final String name;

  const PaymentMethod({required this.bankName, required this.name});

  String uuid();
  Future<String?> validate();
  Map<String,dynamic> toJson();
  
  @override
  List<Object?> get props => [uuid()];
}