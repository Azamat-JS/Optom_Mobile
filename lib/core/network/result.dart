import 'package:bsmart/core/network/api_exception.dart';

/// Lightweight `Either`-style result every repository returns instead of
/// throwing, so presentation code handles failures via exhaustive `switch`
/// rather than scattered `try/catch`.
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.err(ApiException failure) = Err<T>;

  R fold<R>(R Function(T value) onOk, R Function(ApiException failure) onErr) => switch (this) {
        Ok<T>(:final value) => onOk(value),
        Err<T>(:final failure) => onErr(failure),
      };

  bool get isOk => this is Ok<T>;
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final ApiException failure;
}
