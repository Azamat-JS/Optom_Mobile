abstract final class RouteNames {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';

  // --- Phase 2: CUSTOMER storefront (guest-eligible — see app_router.dart's
  // redirect allowlist) ---
  static const customerHome = '/customer';
  static const customerProductDetailPattern = '/customer/products/:id';
  static const customerCartReview = '/customer/cart/review';
  static const customerDebts = '/customer/debts';

  static String customerProductDetail(String id) => '/customer/products/$id';

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
  static const stores = '/stores';
  static const admins = '/admins';
  static const expenditures = '/expenditures';
  static const reports = '/reports';

  // --- Phase 3: SUPER_ADMIN panel ---
  static const superAdminHome = '/admin';
  static const superAdminUsers = '/admin/users';
  static const superAdminCategories = '/admin/categories';
  static const superAdminCatalog = '/admin/catalog';
}
