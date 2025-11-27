// product_detail_controller.dart
import 'package:get/get.dart';

import '../../../app/services/api_service.dart';

class ProductDetailController extends GetxController {
  var product = <String, dynamic>{}.obs;
  ApiService apiService = ApiService();
  void setProduct(Map<String, dynamic> newProduct) {
    print("newProduct: $newProduct");
    product.value = newProduct;
  }

}
