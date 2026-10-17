import 'package:bsmart/core/l10n/app_l10n.dart';

/// Typed failures every repository maps Dio/NestJS errors into, so
/// presentation-layer code never touches Dio or raw HTTP status codes.
///
/// [serverMessage] is the backend's own text (Uzbek, shown as-is). Without
/// one, [message] falls back to a generic line in the active UI language.
sealed class ApiException implements Exception {
  const ApiException([this.serverMessage]);

  final String? serverMessage;

  String get message => serverMessage ?? fallbackMessage;

  String get fallbackMessage;

  @override
  String toString() => message;
}

/// 400 — NestJS `class-validator` field errors, e.g. `{fieldErrors: {phone: [...]}}`.
final class ValidationApiException extends ApiException {
  const ValidationApiException(super.serverMessage, {this.fieldErrors = const {}});

  final Map<String, List<String>> fieldErrors;

  @override
  String get fallbackMessage => appL10n.errorInvalidData;
}

/// 401 — missing/expired/invalid credentials. The refresh interceptor already
/// tried and failed by the time this reaches a repository.
final class UnauthorizedApiException extends ApiException {
  const UnauthorizedApiException([super.serverMessage]);

  @override
  String get fallbackMessage => appL10n.errorSessionExpired;
}

/// 403 — authenticated but not permitted (role/tenant/store scoping).
final class ForbiddenApiException extends ApiException {
  const ForbiddenApiException([super.serverMessage]);

  @override
  String get fallbackMessage => appL10n.errorForbidden;
}

/// 404.
final class NotFoundApiException extends ApiException {
  const NotFoundApiException([super.serverMessage]);

  @override
  String get fallbackMessage => appL10n.errorNotFound;
}

/// 409 — e.g. duplicate barcode, deleting a store with dependents.
final class ConflictApiException extends ApiException {
  const ConflictApiException([super.serverMessage]);

  @override
  String get fallbackMessage => appL10n.errorConflict;
}

/// No connectivity / timeout — distinct from [UnknownApiException] so the UI
/// can show a retry affordance and, where applicable, fall back to a Hive
/// read-cache (see the offline-strategy section of the implementation plan).
final class NetworkApiException extends ApiException {
  const NetworkApiException([super.serverMessage]);

  @override
  String get fallbackMessage => appL10n.errorNoInternet;
}

final class UnknownApiException extends ApiException {
  const UnknownApiException([super.serverMessage]);

  @override
  String get fallbackMessage => appL10n.commonUnknownError;
}
