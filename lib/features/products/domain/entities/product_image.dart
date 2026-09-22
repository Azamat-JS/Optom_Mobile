class ProductImage {
  const ProductImage({
    required this.id,
    required this.url,
    this.altText,
    required this.sortOrder,
    required this.isPrimary,
  });

  final String id;
  final String url;
  final String? altText;
  final int sortOrder;
  final bool isPrimary;
}
