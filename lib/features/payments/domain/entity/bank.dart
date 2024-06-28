class Bank {
  final int id;
  final String code, name;
  final String? logo;
  const Bank({required this.id, required this.code, required this.name, this.logo});

  factory Bank.fromJson({required final Map<dynamic, dynamic> json}) {
    return Bank(
      id: json["id"],
      code:json["code"],
      name: json["name"],
      logo:json["logo"]
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      "name": name,
      "code": code,
      "id": id,
      "logo":logo
    };
  }
}
