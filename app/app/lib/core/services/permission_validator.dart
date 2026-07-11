import 'dart:convert';
import 'dart:math';

import '../models/permission_record.dart';

abstract final class PermissionValidator {
  static PermissionValidationResult evaluate({
    required PermissionRecord permission,
    required String receivedToken,
    required DateTime now,
  }) {
    if (!_constantTimeEquals(permission.qrToken, receivedToken)) {
      return PermissionValidationResult(
        status: PermissionValidationStatus.unauthorized,
        message: 'El token no pertenece a este permiso.',
        permission: permission,
      );
    }
    if (permission.status == 'cancelled' || permission.status == 'used') {
      return PermissionValidationResult(
        status: PermissionValidationStatus.invalid,
        message:
            'El permiso está ${permission.status == 'cancelled' ? 'cancelado' : 'utilizado'}.',
        permission: permission,
      );
    }
    if (permission.status == 'expired') {
      return PermissionValidationResult(
        status: PermissionValidationStatus.expired,
        message: 'El permiso está marcado como expirado.',
        permission: permission,
      );
    }
    if (!now.isBefore(permission.validUntil)) {
      return PermissionValidationResult(
        status: PermissionValidationStatus.expired,
        message: 'El período autorizado ya terminó.',
        permission: permission,
      );
    }
    if (now.isBefore(permission.validFrom)) {
      return PermissionValidationResult(
        status: PermissionValidationStatus.notYetValid,
        message: 'El permiso todavía no ha iniciado.',
        permission: permission,
      );
    }
    if (permission.status != 'active') {
      return PermissionValidationResult(
        status: PermissionValidationStatus.invalid,
        message: 'El permiso no se encuentra activo.',
        permission: permission,
      );
    }

    return PermissionValidationResult(
      status: PermissionValidationStatus.valid,
      message: 'Permiso válido dentro del período autorizado.',
      permission: permission,
    );
  }

  static bool _constantTimeEquals(String expected, String received) {
    final expectedBytes = utf8.encode(expected);
    final receivedBytes = utf8.encode(received);
    var difference = expectedBytes.length ^ receivedBytes.length;
    final length = max(expectedBytes.length, receivedBytes.length);
    for (var index = 0; index < length; index++) {
      final expectedByte = index < expectedBytes.length ? expectedBytes[index] : 0;
      final receivedByte = index < receivedBytes.length ? receivedBytes[index] : 0;
      difference |= expectedByte ^ receivedByte;
    }
    return difference == 0;
  }
}
