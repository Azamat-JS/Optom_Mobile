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

  static const orders = '/orders';
  static const orderNewSellerPicker = '/orders/new';
  static const orderCatalogBrowse = '/orders/new/catalog';
  static const orderReview = '/orders/new/review';
  static const orderDetailPattern = '/orders/:id';

  static String orderDetail(String id) => '/orders/$id';

  static const customers = '/customers';
  static const pos = '/pos';
  static const sales = '/sales';
  static const debts = '/debts';
}
