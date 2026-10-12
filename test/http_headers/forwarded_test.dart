import "package:fpdart/fpdart.dart";
import "package:fpdart_iconica_utilities/src/http_headers/forwarded.dart";
import "package:test/test.dart";

void main() {
  test(
    "parse valid single entry",
    () {
      final result = ForwardedEntry.parse("by=1.1.1.1;for=8.8.8.8;host=test.com;proto=https").toNullable();

      expect(
        result,
        [
          const ForwardedEntry(
            forwardedFor: "8.8.8.8",
            forwardedBy: "1.1.1.1",
            host: "test.com",
            proto: Proto.https,
          ),
        ],
      );
    },
  );

  test(
    "parse valid list",
    () {
      final result = ForwardedEntry.parse("by=1.1.1.1;for=8.8.8.8;host=test.com;proto=https, for=198.51.100.17")
          .toNullable();

      expect(
        result,
        [
          const ForwardedEntry(
            forwardedFor: "8.8.8.8",
            forwardedBy: "1.1.1.1",
            host: "test.com",
            proto: Proto.https,
          ),
          const ForwardedEntry(
            forwardedFor: "198.51.100.17",
            forwardedBy: "hidden",
            host: null,
            proto: null,
          ),
        ],
      );
    },
  );

  test(
    "parse valid entry with missing for and by",
    () {
      final result = ForwardedEntry.parse("host=test.com;proto=https").toNullable();

      expect(
        result,
        [
          const ForwardedEntry(
            forwardedFor: "hidden",
            forwardedBy: "hidden",
            host: "test.com",
            proto: Proto.https,
          ),
        ],
      );
    },
  );

  test(
    "parse invalid by",
    () {
      final result = ForwardedEntry.parse("by=1.1.1.f");

      expect(
        result,
        Either<InvalidForwardedValue, List<ForwardedEntry>>.left(const InvalidForwardedBy()),
      );
    },
  );

  test(
    "parse invalid for",
    () {
      final result = ForwardedEntry.parse("for=1.1.1.f");

      expect(
        result,
        Either<InvalidForwardedValue, List<ForwardedEntry>>.left(const InvalidForwardedFor()),
      );
    },
  );

  test(
    "parse invalid proto",
    () {
      final result = ForwardedEntry.parse("proto=ssl");

      expect(
        result,
        Either<InvalidForwardedValue, List<ForwardedEntry>>.left(const InvalidProto()),
      );
    },
  );
}
