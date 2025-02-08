bool isValidEmail(String email) {
  final emailRegexp =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegexp.hasMatch(email);
}

bool isStrongPassword(String password) {
  final passwordRegexp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%?&.#*])[A-Za-z\d@$!%?&.#*]{8,}$');
  return passwordRegexp.hasMatch(password);
}
