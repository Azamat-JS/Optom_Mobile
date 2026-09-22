import 'package:dio/dio.dart';

import 'package:bsmart/core/network/api_exception.dart';

/// Maps a [DioException] to a typed [ApiException]. NestJS's default
/// exception filter returns `{statusCode, message, error}`, where `message`
/// is either a string or (on `class-validator` failures) an array of
/// per-field strings — normalized here into [ValidationApiException.fieldErrors]
/// on a best-effort basis (exact field-name grouping isn't in the payload,
/// just the messages).
ApiException mapDioException(DioException error) {
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.connectionError) {
    return const NetworkApiException();
  }

  final response = error.response;
  if (response == null) return const UnknownApiException();

  final body = response.data;
  final message = _extractMessage(body);

  return switch (response.statusCode) {
    400 => ValidationApiException(message ?? "Ma'lumotlar noto'g'ri kiritildi."),
    401 => UnauthorizedApiException(message ?? const UnauthorizedApiException().message),
    403 => ForbiddenApiException(message ?? const ForbiddenApiException().message),
    404 => NotFoundApiException(message ?? const NotFoundApiException().message),
    409 => ConflictApiException(message ?? const ConflictApiException().message),
    _ => UnknownApiException(message ?? const UnknownApiException().message),
  };
}

String? _extractMessage(dynamic body) {
  if (body is! Map<String, dynamic>) return null;
  final message = body['message'];
  if (message is String) return message;
  if (message is List) return message.map((e) => e.toString()).join('\n');
  return null;
}
