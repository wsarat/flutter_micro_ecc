import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_micro_ecc/flutter_micro_ecc.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_micro_ecc');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('checkSharedSecretComputation', () async {
    final ecc = Ecdh();

    const curve = EcdhCurve.SECP256R1;

    final keyPair1 = ecc.generateKeyPair(curve);
    final keyPair2 = ecc.generateKeyPair(curve);

    final sharedSecret1 =
        ecc.computeSharedSecret(keyPair1.privateKey, keyPair2.publicKey, curve);
    final sharedSecret2 =
        ecc.computeSharedSecret(keyPair2.privateKey, keyPair1.publicKey, curve);

    expect(true, sharedSecret1.equals(sharedSecret2));
  });
}

extension CompareListExt on List {
  // Compare Two lists
  bool equals(List other) {
    if (length != other.length) {
      return false;
    }
    for (int i = 0; i < length; i++) {
      if (this[i] != other[i]) {
        return false;
      }
    }
    return true;
  }
}
