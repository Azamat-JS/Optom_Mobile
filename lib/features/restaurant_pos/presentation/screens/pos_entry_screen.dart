import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/restaurant_pos/presentation/screens/restaurant_pos_screen.dart';
import 'package:bsmart/features/sales/presentation/screens/pos_screen.dart';

/// The Kassa route: a restaurant sells by table (Optom_Savdo "Restaurant POS"), every other
/// business keeps the product register.
class PosEntryScreen extends ConsumerWidget {
  const PosEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessType = ref.watch(sessionNotifierProvider.select((s) => s.valueOrNull?.user?.businessType));
    return businessType == BusinessType.restaurant ? const RestaurantPosScreen() : const PosScreen();
  }
}
