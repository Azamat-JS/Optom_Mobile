import 'package:dio/dio.dart';

import 'package:bsmart/core/entities/geo_point.dart';
import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/fleet/domain/fleet_courier.dart';
import 'package:bsmart/features/fleet/domain/fleet_repository.dart';

/// `GET /tracking/fleet` — owner: whole tenant, store admin: own store (server-scoped).
class FleetRepositoryImpl implements FleetRepository {
  FleetRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<List<FleetCourier>>> fleet() async {
    try {
      final response = await _dio.get<List<dynamic>>('/tracking/fleet');
      return Result.ok(response.data!.cast<Map<String, dynamic>>().map(_fromJson).toList());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  static FleetCourier _fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>?;
    final ctx = json['context'] as Map<String, dynamic>? ?? const {};
    return FleetCourier(
      id: json['subjectId'] as String,
      name: json['name'] as String? ?? 'Kuryer',
      phone: json['phone'] as String?,
      location: loc == null ? null : GeoPoint((loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble()),
      heading: (loc?['heading'] as num?)?.toDouble(),
      lastPointAt: loc?['recordedAt'] is num
          ? DateTime.fromMillisecondsSinceEpoch((loc!['recordedAt'] as num).toInt())
          : null,
      serverOnline: json['status'] == 'online',
      deliveryIds: (ctx['deliveryIds'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? const [],
    );
  }
}
