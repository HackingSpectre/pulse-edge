/// Lightweight Result/Either type for surface-level service returns.
sealed class Result<T> {
  const Result();
  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;
  T? get value => switch (this) {
    Ok<T>(:final v) => v,
    _ => null,
  };
  String? get error => switch (this) {
    Err<T>(:final message) => message,
    _ => null,
  };
}

class Ok<T> extends Result<T> {
  const Ok(this.v);
  final T v;
}

class Err<T> extends Result<T> {
  const Err(this.message, [this.cause]);
  final String message;
  final Object? cause;
}
