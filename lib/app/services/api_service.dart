import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../model/menu_item.dart';
import '../model/product.dart';

class ApiService {

  static const String baseUrl = "http://192.168.222.85:5000/api";
  String baseUrl1 = baseUrl;
  String imageUrl = "${baseUrl.replaceAll("/api", "")}/uploads/";

/*  static const String baseUrl = "https://book-my-event-api.onrender.com/api";
  String baseUrl1 = baseUrl;
  String imageUrl = "${baseUrl.replaceAll("/api", "")}/uploads/";*/



  final box = GetStorage();

  Map<String, String> getHeaders({bool withAuth = false}) {
    final userData = box.read("userData");
    final headers = {"Content-Type": "application/json"};
    if (withAuth) {
      final token = userData["token"];
      print("token_1: $token");
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body,
      {bool withAuth = false}) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    final response = await http.post(url,
        headers: getHeaders(withAuth: withAuth), body: jsonEncode(body));
    print("status: ${response.statusCode}");
    print("body: ${response.body}");
    return _processResponse(response);
  }

  Future<Map<String, dynamic>> get(
      String endpoint, {
        bool withAuth = false,
        Map<String, String>? queryParams,
      }) async {
    final uri = Uri.parse("$baseUrl/$endpoint").replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: getHeaders(withAuth: withAuth));

    return _processResponse(response);
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body,
      {bool withAuth = false}) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    final response = await http.put(
      url,
      headers: getHeaders(withAuth: withAuth),
      body: jsonEncode(body),
    );

    print("PUT $endpoint -> status: ${response.statusCode}");
    print("PUT $endpoint -> body: ${response.body}");

    return _processResponse(response);
  }



  Map<String, dynamic> _processResponse(http.Response response) {
    final data = jsonDecode(response.body);
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    print("response.statusCode: ${response.statusCode}");
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // directly return the server’s response
      //return body;
      return {
        "success": true,
        "data": body, // <-- always wrap under "data"
      };
    } else {
      return {
        "success": false,
        "message": data["message"] ?? "Something went wrong"
      };
    }
  }

  // 🔹 Login
  Future<Map<String, dynamic>?> loginUser({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/login");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": username,
          "password": password,
         /* "clientName": "BME",
          "inputSource": "M",*/
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error: ${response.statusCode}, ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> postMultipart({
    required String endpoint,
    required Map<String, dynamic> body,
    required List<http.MultipartFile> files,
    required String token,
  }) async {
    final uri = Uri.parse("$baseUrl/$endpoint");
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(getHeaders(withAuth: true));

    // Add body fields
    body.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add files
    request.files.addAll(files);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {
        "success": true,
        "data": jsonDecode(response.body),
      };
    } else {
      final error = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      return {
        "success": false,
        "message": error["message"] ?? "Something went wrong",
      };
    }
  }


  // 🔹 Fetch products for seller
  Future<Map<String, List<dynamic>>?> fetchSellerProducts({required String token}) async {
    final url = Uri.parse("$baseUrl/products/seller");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        // Convert values to List<dynamic> (optional)
        return jsonData.map((key, value) => MapEntry(key, List<dynamic>.from(value)));
      } else {
        print("❌ Error fetching seller products: ${response.statusCode}, ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Exception fetching seller products: $e");
      return null;
    }
  }


  // 🔹 Fetch Menu Items
  Future<List<MenuItem>> fetchMenuItems(String token) async {
    const String menuUrl =
        "http://51.20.214.87:8080/BookEvent/ui/layout/v1/menus/role";

    final response = await http.get(
      Uri.parse(menuUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => MenuItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load menu items: ${response.statusCode}');
    }
  }




  Future<bool> saveProduct({
    required String token,
    required String productName,
    required String category,
    required String price,
    required String description,
    required String address,
    required String documentName,
  }) async {
    final url = Uri.parse("http://51.20.214.87:8080/BookEvent/api/v1/products");

    final Map<String, dynamic> body = {
      "name": productName.trim(),
      "category": category.trim(),
      "attributes": {
        "price": price,
        "description": description,
        "address": address,
        "documentName": documentName,
      }
    };

    print("➡️ Sending body: ${jsonEncode(body)}");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json; charset=UTF-8", // important
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body), // encode to match Postman exactly
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Response: ${response.body}");
        return true;
      } else {
        print("❌ Error: ${response.statusCode}, ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Exception: $e");
      return false;
    }
  }

  Future<List<Product>> fetchProductsByCategory(String category, String token) async {
    final url = Uri.parse("http://51.20.214.87:8080/BookEvent/api/v1/products/seller/$category");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("response: ${response.body}");
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

}
