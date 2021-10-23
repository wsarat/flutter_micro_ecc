import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_micro_ecc/flutter_micro_ecc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  EcdhKeyPair? _alice;
  EcdhKeyPair? _bob;

  Uint8List? _aliceSharedSecret;
  Uint8List? _bobSharedSecret;

  final _ecdh = Ecdh();
  final _curve = EcdhCurve.SECP256R1;

  @override
  void initState() {
    super.initState();
  }

  void _generateAliceKeys() {
    _clearSharedSecret();
    setState(() {
      _alice = _ecdh.generateKeyPair(_curve);
    });
  }

  void _generateBobKeys() {
    _clearSharedSecret();
    setState(() {
      _bob = _ecdh.generateKeyPair(_curve);
    });
  }

  void _computeSharedSecret() {
    setState(() {
      _aliceSharedSecret = _ecdh.computeSharedSecret(
        _alice!.privateKey,
        _bob!.publicKey,
        _curve,
      );
      _bobSharedSecret = _ecdh.computeSharedSecret(
        _bob!.privateKey,
        _alice!.publicKey,
        _curve,
      );
    });
  }

  void _clearSharedSecret() {
    setState(() {
      _aliceSharedSecret = null;
      _bobSharedSecret = null;
    });
  }

  bool _keysEqual() {
    return _aliceSharedSecret?.toHex() == _bobSharedSecret?.toHex();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ECDH Keypair Generation'),
        ),
        body: SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  UserKeyPairView(
                    name: "Alice",
                    keyPair: _alice,
                    sharedSecret: _aliceSharedSecret,
                    regenerate: _generateAliceKeys,
                  ),
                  UserKeyPairView(
                    name: "Bob",
                    keyPair: _bob,
                    sharedSecret: _bobSharedSecret,
                    regenerate: _generateBobKeys,
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton:
            (_aliceSharedSecret == null || _bobSharedSecret == null)
                ? FloatingActionButton.extended(
                    label: const Text('Compute'),
                    onPressed: _computeSharedSecret,
                  )
                : FloatingActionButton(
                    onPressed: () {},
                    backgroundColor: _keysEqual() ? Colors.green : Colors.red,
                    child: _keysEqual()
                        ? const Icon(Icons.check)
                        : const Icon(
                            Icons.cancel,
                          ),
                  ),
      ),
    );
  }
}

class UserKeyPairView extends StatelessWidget {
  final String name;
  final EcdhKeyPair? keyPair;
  final Uint8List? sharedSecret;
  final Function regenerate;

  final _valueStyle = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    fontFamily: 'Source Code Pro',
  );

  const UserKeyPairView({
    Key? key,
    required this.name,
    required this.keyPair,
    required this.sharedSecret,
    required this.regenerate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(name),
            trailing: TextButton.icon(
              onPressed: () => regenerate(),
              label: Text(keyPair == null ? "Generate" : "Re-Generate"),
              icon: const Icon(Icons.refresh),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.red),
            title: const Text("Private key"),
            subtitle: Text(
              keyPair?.privateKey.toHex().prettify() ?? "-",
              style: _valueStyle,
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.vpn_key,
              color: Colors.green,
            ),
            title: const Text("Public key"),
            subtitle: Text(
              keyPair?.publicKey.toHex().prettify() ?? "-",
              style: _valueStyle,
            ),
          ),
          ListTile(
            leading: Icon(
              sharedSecret == null
                  ? Icons.mark_email_unread_outlined
                  : Icons.mark_email_read_outlined,
              color: sharedSecret == null ? Colors.amber : Colors.blue,
            ),
            title: const Text("Shared Secret"),
            subtitle: Text(
              sharedSecret?.toHex().prettify() ?? "-",
              style: _valueStyle,
            ),
          ),
        ],
      ),
    );
  }
}

extension Uint8ListExtension on Uint8List {
  String toHex() {
    return map((e) => e.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
  }
}

extension StringExtension on String {
  String prettify() {
    return replaceAllMapped(RegExp(r'(..)', multiLine: true), (match) {
      return '${match.group(1)} ';
    });
  }
}
