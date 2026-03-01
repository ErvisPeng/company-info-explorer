import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:company_info_explorer/data/models/company_model.dart';

void main() {
  group('CompanyModel.fromJson', () {
    late Map<String, dynamic> jsonMap;

    setUp(() {
      final file = File('test/fixtures/company_sample.json');
      final jsonList = jsonDecode(file.readAsStringSync()) as List;
      jsonMap = jsonList[0] as Map<String, dynamic>;
    });

    test('should parse stock code correctly', () {
      final model = CompanyModel.fromJson(jsonMap);
      expect(model.stockCode, '1101');
    });

    test('should parse company name correctly', () {
      final model = CompanyModel.fromJson(jsonMap);
      expect(model.name, '臺灣水泥股份有限公司');
    });

    test('should parse short name correctly', () {
      final model = CompanyModel.fromJson(jsonMap);
      expect(model.shortName, '台泥');
    });

    test('should parse industry code correctly', () {
      final model = CompanyModel.fromJson(jsonMap);
      expect(model.industryCode, '01');
    });

    test('should parse paid-in capital as double', () {
      final model = CompanyModel.fromJson(jsonMap);
      expect(model.paidInCapital, 73561817420.0);
    });

    test('should parse par value from description string', () {
      final model = CompanyModel.fromJson(jsonMap);
      expect(model.parValue, 10.0);
      expect(model.parValueDesc, '新台幣 10.0000元');
    });

    test('should parse website URL', () {
      final model = CompanyModel.fromJson(jsonMap);
      expect(model.website, 'https://www.taiwancement.com');
    });

    test('should set website to null when empty', () {
      jsonMap['網址'] = '';
      final model = CompanyModel.fromJson(jsonMap);
      expect(model.website, isNull);
    });

    test('should set website to null when dash', () {
      jsonMap['網址'] = '－';
      final model = CompanyModel.fromJson(jsonMap);
      expect(model.website, isNull);
    });

    test('should set website to null when "無" with trailing space', () {
      jsonMap['網址'] = '無　';
      final model = CompanyModel.fromJson(jsonMap);
      expect(model.website, isNull);
    });

    test('should parse special shares and private shares', () {
      final model = CompanyModel.fromJson(jsonMap);
      expect(model.specialShares, 0);
      expect(model.privateShares, 0);
    });

    test('should parse chairman and general manager', () {
      final model = CompanyModel.fromJson(jsonMap);
      expect(model.chairman, '張安平');
      expect(model.generalManager, '張安平');
    });

    test('should parse address and phone', () {
      final model = CompanyModel.fromJson(jsonMap);
      expect(model.address, '臺北市中山北路2段113號');
      expect(model.phone, '(02)2531-7099');
    });

    test('should parse tax ID', () {
      final model = CompanyModel.fromJson(jsonMap);
      expect(model.taxId, '11913502');
    });

    test('should parse founded date and listed date', () {
      final model = CompanyModel.fromJson(jsonMap);
      expect(model.foundedDate, '19501229');
      expect(model.listedDate, '19620209');
    });
  });
}
