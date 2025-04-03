class TFormatException implements Exception {
  final String message;

  TFormatException([
    this.message = 'Something went wrong! Please check your input.',
  ]);

  factory TFormatException.fromMessage(String message) {
    return TFormatException(message);
  }

  String get formattedMessage => message;

  factory TFormatException.fromCode(String code) {
    switch (code) {
      case 'invalid-email-format':
        return TFormatException(
          'The email format is invalid. Please enter a valid email address.',
        );
      case 'invalid-phone-number-format':
        return TFormatException(
          'The phone number format is invalid. Please enter a valid phone number.',
        );
      case 'invalid-date-format':
        return TFormatException(
          'The date format is invalid. Please enter a valid date.',
        );
      case 'invalid-url-format':
        return TFormatException(
          'The URL format is invalid. Please enter a valid URL.',
        );
      case 'invalid-username-format':
        return TFormatException(
          'The username format is invalid. Please enter a valid username.',
        );
      default:
        return TFormatException(
          'The format is invalid. Please check your input.',
        );
    }
  }
}
