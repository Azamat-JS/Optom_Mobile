/// A shareable public tracking URL (Phase 6 V6) for a customer without the
/// app. The backend shows the URL only once — it stores just a hash — so it is
/// shared right away and never cached.
class DeliveryTrackingLink {
  const DeliveryTrackingLink({required this.url, required this.expiresAt});

  final String url;
  final DateTime expiresAt;
}
