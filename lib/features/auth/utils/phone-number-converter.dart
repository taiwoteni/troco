class PhoneNumberConverter {
  static String convertToNormal(String no) {
    final String phone = no.trim();
    bool is11 = phone.length == 11 && !phone.contains("+");
    return is11 ? phone : "0${phone.trim().substring(1, 11)}";
  }

  static String convertToFull(String no) {
    final String phone = no.trim();
    bool is11 = phone.length == 11 && !phone.contains("+");
    bool isNotHavePlus = phone.length == 13 && !phone.startsWith("+");
    return is11
        ? "+234${phone.trim().substring(1, 11)}"
        : isNotHavePlus
            ? "+$phone"
            : phone;
  }
}
