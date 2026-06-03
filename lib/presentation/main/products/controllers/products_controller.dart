import 'package:get/get.dart';
import 'package:viteezy/core/repositories/product_repository.dart';
import 'package:viteezy/core/utils/dialog_service.dart';

import '../../../../core/models/product_response_model.dart';

/// Products Controller - Simple usage of ProductRepository
class ProductsController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
}
