import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<Map<String, String>>> fetchSupabaseData() async {
  final supabase = Supabase.instance.client;

  // Fetch data from 'products' table
  final List<Map<String, dynamic>> response = await supabase
      .from('products')
      .select()
      .timeout(const Duration(seconds: 10));

  if (response.isEmpty) {
    throw Exception('No data found');
  }

  // Convert response to List<Map<String, String>> by explicitly casting each value to a String
  List<Map<String, String>> data = response
      .map((item) => {
            'sku': item['sku']?.toString() ?? '',
            'product_name': item['product_name']?.toString() ?? '',
            'category': item['category']?.toString() ?? '',
            'sub_category': item['sub_category']?.toString() ?? '',
            // 'purpose': item['purpose']?.toString() ?? '',
            // 'assigned_to': item['assigned_to']?.toString() ?? '',
            // 'snId_IMEI_Mac': item['sn_id_imei_mac']?.toString() ?? '',
            'description': item['description']?.toString() ?? '',
            // 'description1': item['description1']?.toString() ?? '',
            // 'description2': item['description2']?.toString() ?? '',
            // 'description3': item['description3']?.toString() ?? '',
            // 'description4': item['description4']?.toString() ?? '',
          })
      .toList();

  return data;
}
