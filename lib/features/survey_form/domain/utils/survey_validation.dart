class SurveyValidation {
  static String? validateInput(String input, Map<String, dynamic> validation) {
    if (input.isEmpty) {
      return 'This field cannot be empty';
    }

    final type = validation['type'];
    try {
      if (type == 'int') {
        final value = int.parse(input);
        if (validation.containsKey('min') && value < validation['min']) {
          return 'Value must be at least ${validation['min']}';
        }
        if (validation.containsKey('max') && value > validation['max']) {
          return 'Value must be at most ${validation['max']}';
        }
      } else if (type == 'double') {
        final value = double.parse(input);
        if (validation.containsKey('min') && value < validation['min']) {
          return 'Value must be at least ${validation['min']}';
        }
        if (validation.containsKey('max') && value > validation['max']) {
          return 'Value must be at most ${validation['max']}';
        }
      }
    } catch (e) {
      return 'Invalid input. Please enter a valid ${type == 'int' ? 'integer' : 'number'}.';
    }

    return null; // Input is valid
  }
}
