import "dart:convert";

import "package:fpdart/fpdart.dart";

extension SafeJsonParsing on Map<String, dynamic> {
  Either<E, T> getAs<E, T>(String key, {required E error}) => switch (this[key]) {
    final T value => right(value),
    _ => left(error),
  };

  Either<E, DateTime?> getDateTime<E>(
    String key, {
    required E error,
    bool allowNull = false,
  }) => switch (this[key]) {
    final String value => .right(DateTime.tryParse(value)),
    null => allowNull ? .right(null) : .left(error),
    _ => .left(error),
  };

  Either<E, Map<String, dynamic>?> getMapFromJsonString<E>(
    String key, {
    required E error,
  }) => switch (this[key]) {
    final String value => switch (value.isNotEmpty) {
      true => Either.tryCatch(
        jsonDecode(value),
        (_, _) => error,
      ),
      false => .right({}),
    },
    _ => .left(error),
  };
}

extension ForceNonNull<E, T> on Either<E, T?> {
  Either<E, T> requireNotNull({required E error}) =>
      filterOrElse((T? value) => value != null, (_) => error).map((t) => t!);
}
