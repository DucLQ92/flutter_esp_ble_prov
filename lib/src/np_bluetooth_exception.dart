class NPBluetoothException implements Exception {
  final int code;
  final String message;

  NPBluetoothException(this.code, this.message);

  @override
  String toString() => 'NPBluetoothException(code: $code, message: $message)';
}
