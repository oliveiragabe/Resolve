import '../constants/app_strings.dart';

class Validators {
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }

    return null;
  }

  static String? title(String? value) {
    final requiredError = requiredField(value);

    if (requiredError != null) {
      return requiredError;
    }

    if (value!.trim().length < 3) {
      return AppStrings.titleMinLength;
    }

    return null;
  }
}
