import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:company_info_explorer/data/models/company_model.dart';

class TwseRemoteDataSource {
  final http.Client client;

  TwseRemoteDataSource(this.client);

  static const String _url =
      'https://openapi.twse.com.tw/v1/opendata/t187ap03_P';

  Future<List<CompanyModel>> fetchCompanies() async {
    final response = await client.get(Uri.parse(_url));
    if (response.statusCode != 200) {
      throw Exception('API 回應錯誤: ${response.statusCode}');
    }
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList
        .map((json) => CompanyModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
