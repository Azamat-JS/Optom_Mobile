abstract final class RouteNames {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/home';

  static const products = '/products';
  static const productNew = '/products/new';
  static const productDetailPattern = '/products/:id';
  static const productEditPattern = '/products/:id/edit';

  static String productDetail(String id) => '/products/$id';
  static String productEdit(String id) => '/products/$id/edit';
}
