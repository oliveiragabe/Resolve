class Validators {
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo é obrigatório.';
    }

    return null;
  }

  static String? title(String? value) {
    final requiredError = requiredField(value);

    if (requiredError != null) {
      return requiredError;
    }

    if (value!.trim().length < 3) {
      return 'O título deve ter pelo menos 3 caracteres.';
    }

    return null;
  }
}
