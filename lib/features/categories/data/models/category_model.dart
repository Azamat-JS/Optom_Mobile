import 'package:bsmart/features/categories/domain/entities/category.dart';

/// Parses one row of `GET /categories`'s `data[]` — see `findAll`'s exact
/// shape (verified against `category.service.ts`): `children` is only ever
/// present/non-empty on a root category row.
Category categoryFromJson(Map<String, dynamic> json) {
  final parent = json['parent'] as Map<String, dynamic>?;
  final childrenJson = json['children'] as List<dynamic>? ?? const [];
  return Category(
    id: json['id'] as String,
    name: json['name'] as String,
    slug: json['slug'] as String,
    imageUrl: json['imageUrl'] as String?,
    icon: json['icon'] as String?,
    sortOrder: json['sortOrder'] as int? ?? 0,
    isActive: json['isActive'] as bool? ?? true,
    parentId: json['parentId'] as String?,
    parentName: parent?['name'] as String?,
    children: childrenJson
        .map(
          (e) => Category(
            id: e['id'] as String,
            name: e['name'] as String,
            slug: e['slug'] as String,
            sortOrder: e['sortOrder'] as int? ?? 0,
            isActive: e['isActive'] as bool? ?? true,
            parentId: json['id'] as String,
          ),
        )
        .toList(),
  );
}
