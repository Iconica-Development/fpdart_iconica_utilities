import "package:fpdart/fpdart.dart";

enum Proto {
  http,
  https,
}

sealed class const InvalidForwardedValue();

final class const InvalidValue() extends InvalidForwardedValue;

final class const InvalidForwardedFor() extends InvalidForwardedValue;

final class const InvalidForwardedBy() extends InvalidForwardedValue;

final class const InvalidProto() extends InvalidForwardedValue;

class ForwardedEntry {
  const ForwardedEntry({
    required this.forwardedFor,
    required this.forwardedBy,
    required this.host,
    required this.proto,
  });

  /// The identifier for the client making the request.
  /// This is typically an IP address but can also be an obfuscated identifier (such as "hidden" or "secret") and the token "unknown".
  final String forwardedFor;

  /// The interface where the request entered the proxy.
  /// This is typically an IP address but can also be an obfuscated identifier (such as "hidden" or "secret") and the token "unknown".
  final String forwardedBy;

  /// The original value of the `Host` header field as received by the proxy.
  final String? host;

  /// The protocol the client used to connect to the proxy.
  final Proto? proto;

  static Either<InvalidForwardedValue, ForwardedEntry> parseEntry(String value) {
    final values = value.trim().split(";");

    String? forwardedFor;
    String? forwardedBy;
    String? host;
    Proto? proto;

    bool isValidIpValue(String value) {
      try {
        return value.startsWith("_") ||
            value == "unknown" ||
            Uri.parseIPv4Address(value).isNotEmpty ||
            Uri.parseIPv6Address(value).isNotEmpty;
      } on FormatException {
        return false;
      }
    }

    for (final field in values) {
      final [key, value] = field.split("=");

      switch (key) {
        case "for":
          if (isValidIpValue(value)) {
            forwardedFor = value;
          } else {
            return .left(const InvalidForwardedFor());
          }
        case "by":
          if (isValidIpValue(value)) {
            forwardedBy = value;
          } else {
            return .left(const InvalidForwardedBy());
          }
        case "host":
          host = value;
        case "proto":
          proto = Proto.values.where((p) => p.name == value.toLowerCase()).firstOrNull;
          if (proto == null) {
            return .left(const InvalidProto());
          }
      }
    }

    return .right(
      ForwardedEntry(
        forwardedFor: forwardedFor ?? "hidden",
        forwardedBy: forwardedBy ?? "hidden",
        host: host,
        proto: proto,
      ),
    );
  }

  static Either<InvalidForwardedValue, List<ForwardedEntry>> parse(String value) => Either.Do(
    ($) =>
        value //
            .split(",")
            .map((e) => $(parseEntry(e)))
            .toList(),
  );

  @override
  bool operator ==(Object other) {
    if (other is! ForwardedEntry) return false;

    return forwardedFor == other.forwardedFor &&
        forwardedBy == other.forwardedBy &&
        host == other.host &&
        proto == other.proto;
  }

  @override
  int get hashCode => forwardedFor.hashCode + forwardedBy.hashCode + host.hashCode + proto.hashCode;

  @override
  String toString() => "ForwardedEntry: for=$forwardedFor;by=$forwardedBy;host=$host;proto=$proto";
}
