/// Typed failures every repository maps Dio/NestJS errors into, so
/// presentation-layer code never touches Dio or raw HTTP status codes.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 400 — NestJS `class-validator` field errors, e.g. `{fieldErrors: {phone: [...]}}`.
final class ValidationApiException extends ApiException {
  const ValidationApiException(super.message, {this.fieldErrors = const {}});

  final Map<String, List<String>> fieldErrors;
}

/// 401 — missing/expired/invalid credentials. The refresh interceptor already
/// tried and failed by the time this reaches a repository.
final class UnauthorizedApiException extends ApiException {
  const UnauthorizedApiException([super.message = 'Sessiya tugagan, qayta kiring.']);
}

/// 403 — authenticated but not permitted (role/tenant/store scoping).
final class ForbiddenApiException extends ApiException {
  const ForbiddenApiException([super.message = "Bu amalni bajarishga ruxsat yo'q."]);
}

/// 404.
final class NotFoundApiException extends ApiException {
  const NotFoundApiException([super.message = 'Topilmadi.']);
}

/// 409 — e.g. duplicate barcode, deleting a store with dependents.
final class ConflictApiException extends ApiException {
  const ConflictApiException([super.message = "Amalni bajarib bo'lmadi, ziddiyat mavjud."]);
}

/// No connectivity / timeout — distinct from [UnknownApiException] so the UI
/// can show a retry affordance and, where applicable, fall back to a Hive
/// read-cache (see the offline-strategy section of the implementation plan).
final class NetworkApiException extends ApiException {
  const NetworkApiException([super.message = "Internet aloqasi yo'q."]);
}

final class UnknownApiException extends ApiException {
  const UnknownApiException([super.message = "Noma'lum xatolik yuz berdi."]);
}
