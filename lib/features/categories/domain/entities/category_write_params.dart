/// Mirrors `CreateCategoryDto`. [icon] is one of the backend's fixed
/// `CATEGORY_ICON_NAMES` (lucide-react keys) — not rendered as an actual
/// icon glyph client-side (no Lucide-to-Material mapping exists in this
/// app), just stored/round-tripped as the string key.
class CreateCategoryParams {
  const CreateCategoryParams({
    required this.name,
    this.icon,
    this.sortOrder,
    this.isActive,
    this.parentId,
  });

  final String name;
  final String? icon;
  final int? sortOrder;
  final bool? isActive;
  final String? parentId;

  Map<String, dynamic> toRequestBody() => {
        'name': name,
        if (icon != null) 'icon': icon,
        if (sortOrder != null) 'sortOrder': sortOrder,
        if (isActive != null) 'isActive': isActive,
        'parentId': parentId,
      };
}

/// Mirrors `UpdateCategoryDto` — `parentId` is sent as an explicit `null`
/// only when [clearParentId] is set, matching the backend's "omit means
/// unchanged, explicit null means clear" convention (see that DTO's own doc
/// comment).
class UpdateCategoryParams {
  const UpdateCategoryParams({
    this.name,
    this.icon,
    this.sortOrder,
    this.isActive,
    this.parentId,
    this.clearParentId = false,
  });

  final String? name;
  final String? icon;
  final int? sortOrder;
  final bool? isActive;
  final String? parentId;
  final bool clearParentId;

  Map<String, dynamic> toRequestBody() => {
        if (name != null) 'name': name,
        if (icon != null) 'icon': icon,
        if (sortOrder != null) 'sortOrder': sortOrder,
        if (isActive != null) 'isActive': isActive,
        if (clearParentId) 'parentId': null else if (parentId != null) 'parentId': parentId,
      };
}
