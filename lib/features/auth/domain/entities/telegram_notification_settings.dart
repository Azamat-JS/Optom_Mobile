/// Delivery status messages from the verify bot (Phase 7 N1/N3). [linked] = this account's phone was
/// verified through the bot, so it can message them; [enabled] = not switched off (🔕 / /stop / app).
class TelegramNotificationSettings {
  const TelegramNotificationSettings({required this.linked, required this.enabled, this.botUrl});

  final bool linked;
  final bool enabled;

  /// `https://t.me/<verify bot>` — null while the bot is unavailable.
  final String? botUrl;
}
