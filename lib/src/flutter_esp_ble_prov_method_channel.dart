import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_esp_ble_prov_platform_interface.dart';
import 'np_bluetooth_exception.dart';

/// An implementation of [FlutterEspBleProvPlatform] that uses method channels.
class MethodChannelFlutterEspBleProv extends FlutterEspBleProvPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_esp_ble_prov');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<String>> scanBleDevices(String prefix) async {
    final hasBluetooth = await isBluetoothAvailable();
    if (!hasBluetooth) {
      throw NPBluetoothException(4444, 'Bluetooth not available on this device.');
    }

    final isEnabled = await isBluetoothEnabled();
    if (!isEnabled) {
      throw NPBluetoothException(5555, 'Bluetooth is turned off.');
    }

    final args = {'prefix': prefix};
    final raw = await methodChannel.invokeMethod<List<Object?>>('scanBleDevices', args);
    final List<String> devices = [];
    if (raw != null) {
      devices.addAll(raw.cast<String>());
    }
    return devices;
  }

  @override
  Future<List<Map<String, dynamic>>> scanWifiNetworks(String deviceName, String proofOfPossession) async {
    final args = {
      'deviceName': deviceName,
      'proofOfPossession': proofOfPossession,
    };
    final raw = await methodChannel.invokeMethod<List<Object?>>('scanWifiNetworks', args);
    List<Map<String, dynamic>> networks = [];
    if (raw != null) {
      networks = (raw as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return networks;
  }

  @override
  Future<bool?> provisionWifi(String deviceName, String proofOfPossession, String ssid, String passphrase) async {
    final hasBluetooth = await isBluetoothAvailable();
    if (!hasBluetooth) {
      throw NPBluetoothException(4444, 'Bluetooth not available on this device.');
    }

    final isEnabled = await isBluetoothEnabled();
    if (!isEnabled) {
      throw NPBluetoothException(5555, 'Bluetooth is turned off.');
    }

    final args = {
      'deviceName': deviceName,
      'proofOfPossession': proofOfPossession,
      'ssid': ssid,
      'passphrase': passphrase
    };
    return await methodChannel.invokeMethod<bool?>('provisionWifi', args);
  }

  @override
  Future<bool> isBluetoothAvailable() async {
    return await methodChannel.invokeMethod<bool>('isBluetoothAvailable') ?? false;
  }

  @override
  Future<bool> isBluetoothEnabled() async {
    return await methodChannel.invokeMethod<bool>('isBluetoothEnabled') ?? false;
  }
}
