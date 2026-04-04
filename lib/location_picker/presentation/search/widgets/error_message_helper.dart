/// Converts API errors to user-friendly Persian messages.
///
/// This function is used in the UI layer to display appropriate error
/// messages to users based on the type of API error encountered.
String getUserFriendlyErrorMessage(String errorString) {
  // Try to parse the error string to determine the error type
  if (errorString.contains('NetworkError')) {
    return 'خطا در برقراری ارتباط. لطفاً اتصال اینترنت خود را بررسی کنید.';
  } else if (errorString.contains('InvalidApiKeyError')) {
    return 'کلید API نامعتبر است.';
  } else if (errorString.contains('RateLimitExceededError')) {
    return 'تعداد درخواست‌ها از حد مجاز گذشته است. لطفاً کمی صبر کنید.';
  } else if (errorString.contains('NotFoundError')) {
    return 'نتیجه‌ای یافت نشد.';
  } else if (errorString.contains('InvalidArgumentError')) {
    return 'پارامترهای جستجو نامعتبر است.';
  } else if (errorString.contains('CoordinateParseError')) {
    return 'مختصات جغرافیایی نامعتبر است.';
  } else if (errorString.contains('ApiServiceError')) {
    return 'خطا در سرویس API.';
  } else if (errorString.contains('ParseError')) {
    return 'خطا در پردازش پاسخ سرور.';
  } else if (errorString.contains('UnknownError')) {
    return 'خطای ناشناخته رخ داده است.';
  } else {
    // For unexpected errors, return a generic message
    return 'خطای غیرمنتظره رخ داده است. لطفاً دوباره تلاش کنید.';
  }
}
