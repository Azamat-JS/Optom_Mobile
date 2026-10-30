import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/crm/domain/crm_due.dart';
import 'package:bsmart/features/crm/domain/entities/crm_driver.dart';
import 'package:bsmart/features/crm/domain/entities/crm_visit.dart';
import 'package:bsmart/features/crm/domain/usecases/delete_crm_driver_usecase.dart';
import 'package:bsmart/features/crm/domain/usecases/delete_crm_vehicle_usecase.dart';
import 'package:bsmart/features/crm/domain/usecases/remove_crm_driver_photo_usecase.dart';
import 'package:bsmart/features/crm/domain/usecases/upload_crm_driver_photo_usecase.dart';
import 'package:bsmart/features/crm/presentation/providers/crm_providers.dart';
import 'package:bsmart/features/crm/presentation/screens/crm_driver_form_screen.dart';
import 'package:bsmart/features/crm/presentation/screens/crm_visit_form_screen.dart';
import 'package:bsmart/features/crm/presentation/widgets/crm_widgets.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// One driver: photo, contact, whether Telegram reminders reach them, their cars (next reminder +
/// "Xizmat yozish") and the service history.
class CrmDriverDetailScreen extends ConsumerStatefulWidget {
  const CrmDriverDetailScreen({required this.driverId, super.key});

  final String driverId;

  @override
  ConsumerState<CrmDriverDetailScreen> createState() => _CrmDriverDetailScreenState();
}

class _CrmDriverDetailScreenState extends ConsumerState<CrmDriverDetailScreen> {
  bool _photoBusy = false;

  void _reload({bool visits = false}) {
    ref.invalidate(crmDriverProvider(widget.driverId));
    ref.invalidate(crmDriverTelegramProvider(widget.driverId));
    if (visits) {
      ref.invalidate(crmVisitsProvider(widget.driverId));
      ref.invalidate(crmRemindersProvider);
    }
    ref.read(crmDriversListProvider.notifier).refresh();
  }

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<bool> _confirm(String title, String message) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _edit(CrmDriver driver) async {
    final saved = await Navigator.of(context).push<CrmDriver>(
      MaterialPageRoute(builder: (_) => CrmDriverFormScreen(editing: driver)),
    );
    if (saved != null) _reload();
  }

  Future<void> _delete(CrmDriver driver) async {
    final l10n = context.l10n;
    if (!await _confirm(l10n.crmDeleteDriverTitle, l10n.crmDeleteDriverConfirm(driver.fullName))) return;
    final result = await getIt<DeleteCrmDriverUseCase>().call(driver.id);
    if (!mounted) return;
    result.fold((_) {
      ref.read(crmDriversListProvider.notifier).refresh();
      ref.invalidate(crmRemindersProvider);
      Navigator.of(context).pop();
    }, (failure) => _snack(failure.message));
  }

  Future<void> _photo(CrmDriver driver) async {
    final l10n = context.l10n;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(driver.imageUrl == null ? l10n.crmPhotoAdd : l10n.crmPhotoChange),
              onTap: () => Navigator.of(context).pop('pick'),
            ),
            if (driver.imageUrl != null)
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                title: Text(l10n.crmPhotoRemove, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () => Navigator.of(context).pop('remove'),
              ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    String? path;
    if (choice == 'pick') {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1200);
      if (picked == null) return;
      path = picked.path;
    }
    setState(() => _photoBusy = true);
    final result = path != null
        ? await getIt<UploadCrmDriverPhotoUseCase>().call(driver.id, filePath: path)
        : await getIt<RemoveCrmDriverPhotoUseCase>().call(driver.id);
    if (!mounted) return;
    setState(() => _photoBusy = false);
    result.fold((_) => _reload(), (failure) => _snack(failure.message));
  }

  Future<void> _vehicleForm(CrmDriver driver, {CrmVehicle? vehicle}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CrmVehicleFormScreen(driverId: driver.id, editing: vehicle)),
    );
    if (saved == true) _reload(visits: true);
  }

  Future<void> _deleteVehicle(CrmVehicle vehicle) async {
    final l10n = context.l10n;
    final plate = formatPlate(vehicle.plateNumber);
    if (!await _confirm(l10n.crmDeleteVehicleTitle, l10n.crmDeleteVehicleConfirm(plate))) return;
    final result = await getIt<DeleteCrmVehicleUseCase>().call(vehicle.id);
    if (!mounted) return;
    result.fold((_) => _reload(visits: true), (failure) => _snack(failure.message));
  }

  Future<void> _recordService(CrmDriver driver, CrmVehicle vehicle) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CrmVisitFormScreen(driver: driver, vehicleId: vehicle.id)),
    );
    if (saved == true && mounted) {
      _snack(context.l10n.crmVisitSaved);
      _reload(visits: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final driverAsync = ref.watch(crmDriverProvider(widget.driverId));
    final driver = driverAsync.valueOrNull;

    return DashPage(
      title: driver?.fullName ?? l10n.navCrmDrivers,
      actions: [
        if (driver != null)
          DashMenuButton(
            items: [
              (value: 'edit', icon: Icons.edit_rounded, label: l10n.commonEdit, destructive: false),
              (value: 'delete', icon: Icons.delete_outline_rounded, label: l10n.commonDelete, destructive: true),
            ],
            onSelected: (v) => v == 'edit' ? _edit(driver) : _delete(driver),
          ),
      ],
      body: driverAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(
          icon: Icons.person_off_rounded,
          text: crmErrorText(context, error),
          action: TextButton(onPressed: _reload, child: Text(l10n.commonRetry)),
        ),
        data: (driver) => RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () async => _reload(visits: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              _HeaderCard(driver: driver, photoBusy: _photoBusy, onPhoto: () => _photo(driver)),
              const SizedBox(height: 12),
              _TelegramCard(driverId: driver.id),
              DashSectionTitle(
                l10n.crmVehicles,
                trailing: TextButton.icon(
                  onPressed: () => _vehicleForm(driver),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.crmAddVehicle),
                ),
              ),
              if (driver.vehicles.isEmpty)
                DashCard(child: Text(l10n.crmNoVehicles, style: TextStyle(color: BrandColors.of(context).textSecondary)))
              else
                for (final (i, v) in driver.vehicles.indexed) ...[
                  _VehicleCard(
                    vehicle: v,
                    canRecord: driver.isActive,
                    onRecord: () => _recordService(driver, v),
                    onEdit: () => _vehicleForm(driver, vehicle: v),
                    onDelete: () => _deleteVehicle(v),
                  ).animate().fadeIn(delay: (40 * i).ms, duration: AppMotion.standard),
                  const SizedBox(height: 10),
                ],
              if (!driver.isActive)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(l10n.crmInactiveNoService, style: TextStyle(color: BrandColors.of(context).textSecondary)),
                ),
              DashSectionTitle(l10n.crmHistory),
              _History(driverId: driver.id),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.driver, required this.photoBusy, required this.onPhoto});

  final CrmDriver driver;
  final bool photoBusy;
  final VoidCallback onPhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    return DashCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: photoBusy ? null : onPhoto,
            child: Stack(
              children: [
                DriverPhoto(name: driver.fullName, url: driver.imageUrl, active: driver.isActive, size: 72),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: AppColors.brandYellow, shape: BoxShape.circle),
                    child: photoBusy
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.photo_camera_rounded, size: 14, color: AppColors.onBrand),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        driver.fullName,
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: colors.textPrimary),
                      ),
                    ),
                    if (!driver.isActive) ...[
                      const SizedBox(width: 8),
                      DashTag(label: l10n.commonInactive, color: Theme.of(context).colorScheme.error),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => launchUrl(Uri(scheme: 'tel', path: driver.phone)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone_rounded, size: 16, color: colors.textSecondary),
                        const SizedBox(width: 6),
                        Text(driver.phone, style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                if (driver.customer != null)
                  Text(
                    l10n.crmLinkedCustomer(driver.customer!.fullName),
                    style: TextStyle(color: colors.textMuted, fontSize: 12.5),
                  ),
                if (driver.notes != null) ...[
                  const SizedBox(height: 6),
                  Text(driver.notes!, style: TextStyle(color: colors.textPrimary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TelegramCard extends ConsumerWidget {
  const _TelegramCard({required this.driverId});

  final String driverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final status = ref.watch(crmDriverTelegramProvider(driverId)).valueOrNull;
    if (status == null) return const SizedBox.shrink();
    if (status.botLink == null) {
      return DashCard(
        child: Row(
          children: [
            Icon(Icons.send_rounded, color: colors.textMuted),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.crmTgNoBot, style: TextStyle(color: colors.textSecondary))),
          ],
        ),
      );
    }
    final ok = status.linked;
    final tint = ok ? colors.success : const Color(0xFFB86E00);
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ok ? Icons.mark_chat_read_rounded : Icons.send_rounded, color: tint),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ok ? l10n.crmTgLinked : status.blocked ? l10n.crmTgBlocked : l10n.crmTgNotLinked,
                  style: TextStyle(color: tint, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          if (!ok) ...[
            const SizedBox(height: 6),
            Text(l10n.crmTgHowTo, style: TextStyle(color: colors.textSecondary)),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Share.share(status.botLink!),
              icon: const Icon(Icons.ios_share_rounded),
              label: Text(l10n.crmTgShareLink),
            ),
          ],
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.canRecord,
    required this.onRecord,
    required this.onEdit,
    required this.onDelete,
  });

  final CrmVehicle vehicle;
  final bool canRecord;
  final VoidCallback onRecord;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final next = vehicle.nextDue;
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PlateBadge(plate: vehicle.plateNumber, large: true),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  vehicle.model,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, color: colors.textPrimary),
                ),
              ),
              DashMenuButton(
                items: [
                  (value: 'edit', icon: Icons.edit_rounded, label: l10n.commonEdit, destructive: false),
                  (value: 'delete', icon: Icons.delete_outline_rounded, label: l10n.commonDelete, destructive: true),
                ],
                onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.speed_rounded, size: 17, color: vehicle.dailyKm == null ? const Color(0xFFB86E00) : colors.textSecondary),
              const SizedBox(width: 6),
              Text(
                vehicle.dailyKm == null ? l10n.crmDailyKmMissing : l10n.crmDailyKmValue('${vehicle.dailyKm}'),
                style: TextStyle(
                  color: vehicle.dailyKm == null ? const Color(0xFFB86E00) : colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (next != null) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notifications_active_outlined, size: 17, color: colors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.crmNextDue(next.productName), style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600)),
                      DueText(dueDate: next.dueDate),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (vehicle.notes != null) ...[
            const SizedBox(height: 6),
            Text(vehicle.notes!, style: TextStyle(color: colors.textSecondary)),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: canRecord ? onRecord : null,
            icon: const Icon(Icons.build_rounded),
            label: Text(l10n.crmRecordService),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
          ),
        ],
      ),
    );
  }
}

class _History extends ConsumerWidget {
  const _History({required this.driverId});

  final String driverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final visitsAsync = ref.watch(crmVisitsProvider(driverId));
    return visitsAsync.when(
      loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
      error: (error, _) => Text(crmErrorText(context, error), style: TextStyle(color: colors.textSecondary)),
      data: (state) {
        if (state.items.isEmpty) {
          return DashCard(child: Text(l10n.crmNoVisits, style: TextStyle(color: colors.textSecondary)));
        }
        return Column(
          children: [
            for (final visit in state.items) ...[_VisitCard(visit: visit), const SizedBox(height: 10)],
            if (state.hasNext)
              TextButton(
                onPressed: state.isLoadingMore ? null : () => ref.read(crmVisitsProvider(driverId).notifier).loadMore(),
                child: state.isLoadingMore
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.commonLoadMore),
              ),
          ],
        );
      },
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.visit});

  final CrmVisit visit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final sale = visit.sale;
    final debtOpen = sale?.debtBalance != null && sale!.debtBalance! > 0;
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crmDayFormat.format(visit.serviceDate),
                      style: TextStyle(fontWeight: FontWeight.w800, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        PlateBadge(plate: visit.vehicle.plateNumber),
                        if (visit.odometerKm != null)
                          Text(
                            l10n.crmKmValue(crmKmFormat.format(visit.odometerKm)),
                            style: TextStyle(color: colors.textSecondary, fontSize: 12.5),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (sale == null)
                Text(l10n.crmNoSale, style: TextStyle(color: colors.textMuted, fontSize: 12.5))
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(sale.total, sale.currency),
                      style: TextStyle(fontWeight: FontWeight.w800, color: colors.textPrimary),
                    ),
                    Text(
                      !sale.isDebt
                          ? l10n.commonPaid
                          : debtOpen
                              ? l10n.crmSaleDebtLeft(CurrencyFormatter.format(sale.debtBalance!, sale.currency))
                              : l10n.crmSaleDebtSettled,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: debtOpen ? const Color(0xFFB86E00) : colors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in visit.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.productName} × ${crmQtyFormat.format(item.quantity)}',
                    style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  _ItemStatus(item: item),
                ],
              ),
            ),
          if (visit.notes != null) Text(visit.notes!, style: TextStyle(color: colors.textSecondary)),
        ],
      ),
    );
  }
}

class _ItemStatus extends StatelessWidget {
  const _ItemStatus({required this.item});

  final CrmVisitItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = TextStyle(color: BrandColors.of(context).textMuted, fontSize: 12.5);
    return switch (item.status) {
      CrmItemStatus.done => Text(item.closedByVisitId != null ? l10n.crmItemReplaced : l10n.crmItemDone, style: muted),
      CrmItemStatus.cancelled => Text(l10n.crmItemCancelled, style: muted.copyWith(decoration: TextDecoration.lineThrough)),
      CrmItemStatus.active when item.dueDate == null => Text(l10n.crmNoReminder, style: muted),
      CrmItemStatus.active => DueText(dueDate: item.dueDate!, fontSize: 12.5),
    };
  }
}
