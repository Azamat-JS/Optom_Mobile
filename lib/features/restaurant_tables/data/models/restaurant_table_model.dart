import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table.dart';

RestaurantTable restaurantTableFromJson(Map<String, dynamic> json) => RestaurantTable(
      id: json['id'] as String,
      name: json['name'] as String,
      percent: parseDecimal(json['percent']),
      storeId: json['storeId'] as String,
    );
