// ignore_for_file: constant_identifier_names

import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

import 'bindings/micro_ecc.bindings.g.dart';

/// Wrapper class for Ecdh operations.
class Ecdh {
  final DynamicLibrary _lib = Platform.isAndroid
      ? DynamicLibrary.open("libmicro_ecc.so")
      : DynamicLibrary.process();

  late final _ecc = MicroEcc(_lib);

  Ecdh() {
    uECC_RNG_Function rng = Pointer.fromFunction(_rng, 0);
    _ecc.uECC_set_rng(rng);
  }

  static int _rng(Pointer<Uint8> buffer, int size) {
    final buf = buffer.asTypedList(size);
    buf.setAll(0, List.generate(size, (index) => Random().nextInt(UINT8_MAX)));
    return 1;
  }

  /// Generate a new Public/Private Key pair based on the curve
  EcdhKeyPair generateKeyPair(
    EcdhCurve curve,
  ) {
    final _curve = curve.getNative(_ecc);

    final privateSize = _ecc.uECC_curve_private_key_size(_curve);
    final publicSize = _ecc.uECC_curve_public_key_size(_curve);

    final privateKey = calloc.allocate(privateSize).cast<Uint8>();
    final publicKey = calloc.allocate(publicSize).cast<Uint8>();

    bool err = _ecc.uECC_make_key(publicKey, privateKey, _curve) == 0;

    final Uint8List private = Uint8List(privateSize);
    final Uint8List public = Uint8List(publicSize);

    private.setAll(0, privateKey.asTypedList(privateSize));
    public.setAll(0, publicKey.asTypedList(publicSize));

    calloc.free(privateKey);
    calloc.free(publicKey);

    if (err) {
      throw Exception("Failed to generate key pair");
    }

    return EcdhKeyPair(private, public, curve);
  }

  /// Compute a shared secret basd on local private key and remote public key on the curve
  Uint8List computeSharedSecret(
    Uint8List private,
    Uint8List public,
    EcdhCurve curve,
  ) {
    final _curve = curve.getNative(_ecc);
    final privateSize = _ecc.uECC_curve_private_key_size(_curve);
    final publicSize = _ecc.uECC_curve_public_key_size(_curve);

    final privateKey = calloc.allocate(privateSize).cast<Uint8>();
    final publicKey = calloc.allocate(publicSize).cast<Uint8>();
    final secretKey = calloc.allocate(privateSize).cast<Uint8>();

    privateKey.asTypedList(privateSize).setAll(0, private);
    publicKey.asTypedList(publicSize).setAll(0, public);

    bool err =
        _ecc.uECC_shared_secret(publicKey, privateKey, secretKey, _curve) == 0;

    final Uint8List secret = Uint8List(privateSize);

    secret.setAll(0, secretKey.asTypedList(privateSize));

    calloc.free(privateKey);
    calloc.free(publicKey);
    calloc.free(secretKey);

    if (err) {
      throw Exception("Failed to compute shared secret");
    }

    return secret;
  }
}

/// Container for a public/private key pair
class EcdhKeyPair {
  Uint8List privateKey;
  Uint8List publicKey;
  EcdhCurve curve;

  /// Create a new key pair
  EcdhKeyPair(this.privateKey, this.publicKey, this.curve);
}

/// Opaque pointers to Ecdh curves
class EcdhCurve {
  /// SECP160R1
  static const SECP160R1 = EcdhCurve._(1);

  /// SECP192R1
  static const SECP192R1 = EcdhCurve._(2);

  /// SECP224R1
  static const SECP224R1 = EcdhCurve._(3);

  /// SECP256R1
  static const SECP256R1 = EcdhCurve._(4);

  /// SECP256K1
  static const SECP256K1 = EcdhCurve._(5);

  final int _curveId;

  const EcdhCurve._(this._curveId);

  Pointer<uECC_Curve_t> getNative(MicroEcc ecc) {
    switch (_curveId) {
      case 1:
        return ecc.uECC_secp160r1();
      case 2:
        return ecc.uECC_secp192r1();
      case 3:
        return ecc.uECC_secp224r1();
      case 4:
        return ecc.uECC_secp256r1();
      case 5:
        return ecc.uECC_secp256k1();
    }
    throw UnimplementedError();
  }
}
