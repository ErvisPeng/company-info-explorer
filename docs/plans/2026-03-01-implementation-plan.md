# 公司基本資料查詢 App — 實作計畫

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 建立一個 Flutter App，讓使用者透過產業分類查詢台灣證交所上市公司基本資料，並可追蹤感興趣的公司。

**Architecture:** Clean Architecture 三層架構（Domain / Data / Presentation），搭配 flutter_bloc 做狀態管理，get_it 做依賴注入，TDD 先寫測試再實作。

**Tech Stack:** Flutter 3.41.2, Dart 3.11.0, flutter_bloc, get_it, shared_preferences, http, equatable, mocktail, bloc_test

---

## Task 1: 建立 Flutter 專案並設定依賴

**Files:**
- Create: `pubspec.yaml`（flutter create 產生後修改）
- Create: `analysis_options.yaml`（flutter create 產生）

**Step 1: 建立 Flutter 專案**

```bash
cd /Users/ervispeng/Documents/Codex/company-info-explorer
flutter create --project-name company_info_explorer --org com.example .
```

Expected: 產生標準 Flutter 專案結構

**Step 2: 加入依賴套件**

```bash
cd /Users/ervispeng/Documents/Codex/company-info-explorer
flutter pub add flutter_bloc equatable get_it http shared_preferences
flutter pub add --dev bloc_test mocktail
```

**Step 3: 驗證依賴安裝**

```bash
flutter pub get
```

Expected: 無錯誤

**Step 4: 建立目錄結構**

```bash
mkdir -p lib/core/constants lib/core/utils lib/core/error
mkdir -p lib/domain/entities lib/domain/repositories lib/domain/usecases
mkdir -p lib/data/models lib/data/datasources lib/data/repositories
mkdir -p lib/presentation/blocs/app lib/presentation/blocs/industry_list
mkdir -p lib/presentation/blocs/company_list lib/presentation/blocs/company_detail
mkdir -p lib/presentation/blocs/watchlist
mkdir -p lib/presentation/pages lib/presentation/widgets
mkdir -p lib/di
mkdir -p test/core/utils test/domain/usecases test/data/models
mkdir -p test/data/repositories test/presentation/blocs
mkdir -p test/fixtures
```

**Step 5: 確認專案可編譯**

```bash
flutter analyze
```

Expected: 無 error

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: 建立 Flutter 專案與依賴設定"
```

---

## Task 2: Core — 產業代碼常數與數字格式化工具

**Files:**
- Create: `lib/core/constants/industry_codes.dart`
- Create: `lib/core/utils/number_formatter.dart`
- Create: `lib/core/utils/par_value_parser.dart`
- Create: `test/core/utils/number_formatter_test.dart`
- Create: `test/core/utils/par_value_parser_test.dart`

**Step 1: 寫 number_formatter 的失敗測試**

```dart
// test/core/utils/number_formatter_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:company_info_explorer/core/utils/number_formatter.dart';

void main() {
  group('formatWithCommas', () {
    test('should format large numbers with commas', () {
      expect(formatWithCommas(73561817420), '73,561,817,420');
    });

    test('should format zero', () {
      expect(formatWithCommas(0), '0');
    });

    test('should format numbers less than 1000 without commas', () {
      expect(formatWithCommas(999), '999');
    });

    test('should format exactly 1000', () {
      expect(formatWithCommas(1000), '1,000');
    });

    test('should handle negative numbers', () {
      expect(formatWithCommas(-1234567), '-1,234,567');
    });
  });
}
```

**Step 2: 跑測試確認失敗**

```bash
flutter test test/core/utils/number_formatter_test.dart
```

Expected: FAIL（找不到 import）

**Step 3: 實作 number_formatter**

```dart
// lib/core/utils/number_formatter.dart
String formatWithCommas(num value) {
  final isNegative = value < 0;
  final absString = value.abs().toInt().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < absString.length; i++) {
    if (i > 0 && (absString.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(absString[i]);
  }

  return isNegative ? '-${buffer.toString()}' : buffer.toString();
}
```

**Step 4: 跑測試確認通過**

```bash
flutter test test/core/utils/number_formatter_test.dart
```

Expected: All tests passed

**Step 5: 寫 par_value_parser 的失敗測試**

```dart
// test/core/utils/par_value_parser_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:company_info_explorer/core/utils/par_value_parser.dart';

void main() {
  group('parseParValue', () {
    test('should parse "新台幣 10.0000元" to 10.0', () {
      expect(parseParValue('新台幣 10.0000元'), 10.0);
    });

    test('should parse "新台幣 1.0000元" to 1.0', () {
      expect(parseParValue('新台幣 1.0000元'), 1.0);
    });

    test('should return 0 for empty string', () {
      expect(parseParValue(''), 0.0);
    });

    test('should return 0 for unparseable string', () {
      expect(parseParValue('－'), 0.0);
    });
  });

  group('calculateIssuedShares', () {
    test('should calculate issued shares correctly', () {
      // (73,561,817,420 / 10) - 0 = 7,356,181,742
      expect(calculateIssuedShares(73561817420, 10.0, 0), 7356181742);
    });

    test('should subtract special shares', () {
      // (100,000,000 / 10) - 200,000 = 9,800,000
      expect(calculateIssuedShares(100000000, 10.0, 200000), 9800000);
    });

    test('should return 0 when par value is 0', () {
      expect(calculateIssuedShares(100000000, 0.0, 0), 0);
    });
  });
}
```

**Step 6: 跑測試確認失敗**

```bash
flutter test test/core/utils/par_value_parser_test.dart
```

Expected: FAIL

**Step 7: 實作 par_value_parser**

```dart
// lib/core/utils/par_value_parser.dart
double parseParValue(String raw) {
  if (raw.isEmpty || raw == '－') return 0.0;
  final match = RegExp(r'[\d.]+').firstMatch(raw);
  if (match == null) return 0.0;
  return double.tryParse(match.group(0)!) ?? 0.0;
}

int calculateIssuedShares(
  double paidInCapital,
  double parValue,
  int specialShares,
) {
  if (parValue == 0.0) return 0;
  return (paidInCapital / parValue).toInt() - specialShares;
}
```

**Step 8: 跑測試確認通過**

```bash
flutter test test/core/utils/par_value_parser_test.dart
```

Expected: All tests passed

**Step 9: 建立產業代碼常數**

```dart
// lib/core/constants/industry_codes.dart
const Map<String, String> industryCodeToName = {
  '01': '水泥工業',
  '02': '食品工業',
  '03': '塑膠工業',
  '04': '紡織纖維',
  '05': '電機機械',
  '06': '電器電纜',
  '08': '玻璃陶瓷',
  '09': '造紙工業',
  '10': '鋼鐵工業',
  '11': '橡膠工業',
  '12': '汽車工業',
  '14': '建材營造',
  '15': '航運業',
  '16': '觀光餐旅',
  '17': '金融保險',
  '18': '貿易百貨',
  '19': '綜合',
  '20': '其他',
  '21': '化學工業',
  '22': '生技醫療業',
  '23': '油電燃氣業',
  '24': '半導體業',
  '25': '電腦及週邊設備業',
  '26': '光電業',
  '27': '通信網路業',
  '28': '電子零組件業',
  '29': '電子通路業',
  '30': '資訊服務業',
  '31': '其他電子業',
  '32': '文化創意業',
  '33': '農業科技業',
  '34': '電子商務',
  '35': '綠能環保',
  '36': '數位雲端',
  '37': '運動休閒',
  '38': '居家生活',
  '80': '管理股票',
};

/// 產業代碼排序順序（依 wireframe 規範）
const List<String> industryCodeOrder = [
  '01', '02', '03', '04', '05', '06', '08', '09', '10', '11',
  '12', '14', '15', '16', '17', '18', '19', '20',
  '21', '22', '23', '24', '25', '26', '27', '28', '29', '30',
  '31', '32', '33', '34', '35', '36', '37', '38', '80',
];
```

**Step 10: Commit**

```bash
git add lib/core/ test/core/
git commit -m "feat: 新增產業代碼常數與數字格式化工具（含測試）"
```

---

## Task 3: Domain — Entities 與 Repository 介面

**Files:**
- Create: `lib/domain/entities/company.dart`
- Create: `lib/domain/entities/industry.dart`
- Create: `lib/domain/repositories/company_repository.dart`
- Create: `lib/core/error/failures.dart`

**Step 1: 建立 Failure 基礎類別**

```dart
// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = '伺服器錯誤']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = '本地儲存錯誤']);
}
```

**Step 2: 建立 Company Entity**

```dart
// lib/domain/entities/company.dart
import 'package:equatable/equatable.dart';

class Company extends Equatable {
  final String stockCode;
  final String name;
  final String shortName;
  final String industryCode;
  final String chairman;
  final String generalManager;
  final String address;
  final String phone;
  final String taxId;
  final String foundedDate;
  final String listedDate;
  final double paidInCapital;
  final String parValueDesc;
  final double parValue;
  final int specialShares;
  final int privateShares;
  final String? website;

  const Company({
    required this.stockCode,
    required this.name,
    required this.shortName,
    required this.industryCode,
    required this.chairman,
    required this.generalManager,
    required this.address,
    required this.phone,
    required this.taxId,
    required this.foundedDate,
    required this.listedDate,
    required this.paidInCapital,
    required this.parValueDesc,
    required this.parValue,
    required this.specialShares,
    required this.privateShares,
    this.website,
  });

  @override
  List<Object?> get props => [
        stockCode, name, shortName, industryCode,
        chairman, generalManager, address, phone, taxId,
        foundedDate, listedDate, paidInCapital, parValueDesc,
        parValue, specialShares, privateShares, website,
      ];
}
```

**Step 3: 建立 Industry Entity**

```dart
// lib/domain/entities/industry.dart
import 'package:equatable/equatable.dart';

class Industry extends Equatable {
  final String code;
  final String name;
  final int companyCount;

  const Industry({
    required this.code,
    required this.name,
    required this.companyCount,
  });

  @override
  List<Object> get props => [code, name, companyCount];
}
```

**Step 4: 建立 Repository 介面**

```dart
// lib/domain/repositories/company_repository.dart
import 'package:company_info_explorer/domain/entities/company.dart';

abstract class CompanyRepository {
  Future<List<Company>> fetchAllCompanies();
  Future<List<String>> getWatchlist();
  Future<void> addToWatchlist(String stockCode);
  Future<void> removeFromWatchlist(String stockCode);
}
```

**Step 5: 確認編譯通過**

```bash
flutter analyze
```

**Step 6: Commit**

```bash
git add lib/domain/ lib/core/error/
git commit -m "feat: 建立 Domain Layer — Entities 與 Repository 介面"
```

---

## Task 4: Domain — UseCases（含測試）

**Files:**
- Create: `lib/domain/usecases/load_companies_usecase.dart`
- Create: `lib/domain/usecases/get_industries_usecase.dart`
- Create: `lib/domain/usecases/get_companies_by_industry_usecase.dart`
- Create: `lib/domain/usecases/get_watchlist_usecase.dart`
- Create: `lib/domain/usecases/add_to_watchlist_usecase.dart`
- Create: `lib/domain/usecases/remove_from_watchlist_usecase.dart`
- Create: `test/domain/usecases/get_industries_usecase_test.dart`
- Create: `test/domain/usecases/get_watchlist_usecase_test.dart`
- Create: `test/domain/usecases/toggle_watchlist_usecase_test.dart`
- Create: `test/helpers/test_data.dart`

**Step 1: 建立共用測試資料**

```dart
// test/helpers/test_data.dart
import 'package:company_info_explorer/domain/entities/company.dart';

const testCompany1 = Company(
  stockCode: '1101',
  name: '臺灣水泥股份有限公司',
  shortName: '台泥',
  industryCode: '01',
  chairman: '張安平',
  generalManager: '張安平',
  address: '台北市中山北路2段113號',
  phone: '(02)2531-7099',
  taxId: '11913502',
  foundedDate: '19501229',
  listedDate: '19620209',
  paidInCapital: 73561817420,
  parValueDesc: '新台幣 10.0000元',
  parValue: 10.0,
  specialShares: 0,
  privateShares: 0,
  website: 'https://www.taiwancement.com',
);

const testCompany2 = Company(
  stockCode: '1102',
  name: '亞洲水泥股份有限公司',
  shortName: '亞泥',
  industryCode: '01',
  chairman: '徐旭東',
  generalManager: '李坤炎',
  address: '台北市民生東路1段27號',
  phone: '(02)2521-7271',
  taxId: '03706301',
  foundedDate: '19570209',
  listedDate: '19620209',
  paidInCapital: 33646617490,
  parValueDesc: '新台幣 10.0000元',
  parValue: 10.0,
  specialShares: 0,
  privateShares: 0,
  website: 'https://www.acc.com.tw',
);

const testCompany3 = Company(
  stockCode: '2330',
  name: '台灣積體電路製造股份有限公司',
  shortName: '台積電',
  industryCode: '24',
  chairman: '魏哲家',
  generalManager: '魏哲家',
  address: '新竹市新竹科學工業園區力行六路8號',
  phone: '(03)563-6688',
  taxId: '22099131',
  foundedDate: '19870221',
  listedDate: '19940905',
  paidInCapital: 259303804580,
  parValueDesc: '新台幣 10.0000元',
  parValue: 10.0,
  specialShares: 0,
  privateShares: 0,
  website: 'https://www.tsmc.com',
);

final testCompanies = [testCompany1, testCompany2, testCompany3];
```

**Step 2: 寫 UseCases 的失敗測試**

```dart
// test/domain/usecases/get_industries_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:company_info_explorer/domain/usecases/get_industries_usecase.dart';
import '../../helpers/test_data.dart';

void main() {
  late GetIndustriesUseCase useCase;

  setUp(() {
    useCase = GetIndustriesUseCase();
  });

  group('GetIndustriesUseCase', () {
    test('should group companies by industry and return sorted industries', () {
      final result = useCase(testCompanies);

      expect(result.length, 2); // 01 水泥工業, 24 半導體業
      expect(result[0].code, '01');
      expect(result[0].name, '水泥工業');
      expect(result[0].companyCount, 2);
      expect(result[1].code, '24');
      expect(result[1].name, '半導體業');
      expect(result[1].companyCount, 1);
    });

    test('should return empty list for empty input', () {
      final result = useCase([]);
      expect(result, isEmpty);
    });

    test('should skip companies with unknown industry codes', () {
      const unknownCompany = Company(
        stockCode: '9999',
        name: 'Test',
        shortName: 'Test',
        industryCode: 'XX',
        chairman: '',
        generalManager: '',
        address: '',
        phone: '',
        taxId: '',
        foundedDate: '',
        listedDate: '',
        paidInCapital: 0,
        parValueDesc: '',
        parValue: 0,
        specialShares: 0,
        privateShares: 0,
      );
      final result = useCase([unknownCompany]);
      expect(result, isEmpty);
    });
  });
}
```

```dart
// test/domain/usecases/get_watchlist_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';
import 'package:company_info_explorer/domain/usecases/get_watchlist_usecase.dart';
import '../../helpers/test_data.dart';

class MockCompanyRepository extends Mock implements CompanyRepository {}

void main() {
  late GetWatchlistUseCase useCase;
  late MockCompanyRepository mockRepository;

  setUp(() {
    mockRepository = MockCompanyRepository();
    useCase = GetWatchlistUseCase(mockRepository);
  });

  group('GetWatchlistUseCase', () {
    test('should return watched companies from repository', () async {
      when(() => mockRepository.getWatchlist())
          .thenAnswer((_) async => ['1101', '2330']);

      final result = await useCase(testCompanies);

      expect(result.length, 2);
      expect(result[0].stockCode, '1101');
      expect(result[1].stockCode, '2330');
      verify(() => mockRepository.getWatchlist()).called(1);
    });

    test('should return empty list when no companies are watched', () async {
      when(() => mockRepository.getWatchlist())
          .thenAnswer((_) async => []);

      final result = await useCase(testCompanies);

      expect(result, isEmpty);
    });

    test('should skip watchlist IDs that do not match any company', () async {
      when(() => mockRepository.getWatchlist())
          .thenAnswer((_) async => ['9999']);

      final result = await useCase(testCompanies);

      expect(result, isEmpty);
    });
  });
}
```

```dart
// test/domain/usecases/toggle_watchlist_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';
import 'package:company_info_explorer/domain/usecases/add_to_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/usecases/remove_from_watchlist_usecase.dart';

class MockCompanyRepository extends Mock implements CompanyRepository {}

void main() {
  late MockCompanyRepository mockRepository;

  setUp(() {
    mockRepository = MockCompanyRepository();
  });

  group('AddToWatchlistUseCase', () {
    test('should call repository addToWatchlist', () async {
      when(() => mockRepository.addToWatchlist('1101'))
          .thenAnswer((_) async {});

      final useCase = AddToWatchlistUseCase(mockRepository);
      await useCase('1101');

      verify(() => mockRepository.addToWatchlist('1101')).called(1);
    });
  });

  group('RemoveFromWatchlistUseCase', () {
    test('should call repository removeFromWatchlist', () async {
      when(() => mockRepository.removeFromWatchlist('1101'))
          .thenAnswer((_) async {});

      final useCase = RemoveFromWatchlistUseCase(mockRepository);
      await useCase('1101');

      verify(() => mockRepository.removeFromWatchlist('1101')).called(1);
    });
  });
}
```

**Step 3: 跑測試確認失敗**

```bash
flutter test test/domain/
```

Expected: FAIL（找不到 usecase 類別）

**Step 4: 實作所有 UseCases**

```dart
// lib/domain/usecases/load_companies_usecase.dart
import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';

class LoadCompaniesUseCase {
  final CompanyRepository repository;

  LoadCompaniesUseCase(this.repository);

  Future<List<Company>> call() {
    return repository.fetchAllCompanies();
  }
}
```

```dart
// lib/domain/usecases/get_industries_usecase.dart
import 'package:company_info_explorer/core/constants/industry_codes.dart';
import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/domain/entities/industry.dart';

class GetIndustriesUseCase {
  List<Industry> call(List<Company> companies) {
    final grouped = <String, int>{};
    for (final company in companies) {
      if (!industryCodeToName.containsKey(company.industryCode)) continue;
      grouped[company.industryCode] =
          (grouped[company.industryCode] ?? 0) + 1;
    }

    final industries = <Industry>[];
    for (final code in industryCodeOrder) {
      if (grouped.containsKey(code)) {
        industries.add(Industry(
          code: code,
          name: industryCodeToName[code]!,
          companyCount: grouped[code]!,
        ));
      }
    }
    return industries;
  }
}
```

```dart
// lib/domain/usecases/get_companies_by_industry_usecase.dart
import 'package:company_info_explorer/domain/entities/company.dart';

class GetCompaniesByIndustryUseCase {
  List<Company> call(List<Company> companies, String industryCode) {
    return companies
        .where((c) => c.industryCode == industryCode)
        .toList()
      ..sort((a, b) => a.stockCode.compareTo(b.stockCode));
  }
}
```

```dart
// lib/domain/usecases/get_watchlist_usecase.dart
import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';

class GetWatchlistUseCase {
  final CompanyRepository repository;

  GetWatchlistUseCase(this.repository);

  Future<List<Company>> call(List<Company> allCompanies) async {
    final watchlistIds = await repository.getWatchlist();
    final idSet = watchlistIds.toSet();
    return allCompanies
        .where((c) => idSet.contains(c.stockCode))
        .toList();
  }
}
```

```dart
// lib/domain/usecases/add_to_watchlist_usecase.dart
import 'package:company_info_explorer/domain/repositories/company_repository.dart';

class AddToWatchlistUseCase {
  final CompanyRepository repository;

  AddToWatchlistUseCase(this.repository);

  Future<void> call(String stockCode) {
    return repository.addToWatchlist(stockCode);
  }
}
```

```dart
// lib/domain/usecases/remove_from_watchlist_usecase.dart
import 'package:company_info_explorer/domain/repositories/company_repository.dart';

class RemoveFromWatchlistUseCase {
  final CompanyRepository repository;

  RemoveFromWatchlistUseCase(this.repository);

  Future<void> call(String stockCode) {
    return repository.removeFromWatchlist(stockCode);
  }
}
```

**Step 5: 跑測試確認通過**

```bash
flutter test test/domain/
```

Expected: All tests passed

**Step 6: Commit**

```bash
git add lib/domain/usecases/ test/domain/ test/helpers/
git commit -m "feat: 實作 Domain Layer UseCases（含測試）"
```

---

## Task 5: Data — CompanyModel JSON 解析（含測試）

**Files:**
- Create: `lib/data/models/company_model.dart`
- Create: `test/data/models/company_model_test.dart`
- Create: `test/fixtures/company_sample.json`

**Step 1: 建立測試用假 JSON**

```json
// test/fixtures/company_sample.json
[
  {
    "出表日期": "1150227",
    "公司代號": "1101",
    "公司名稱": "臺灣水泥股份有限公司",
    "公司簡稱": "台泥",
    "外國企業註冊地國": "－",
    "產業別": "01",
    "住址": "臺北市中山北路2段113號",
    "營利事業統一編號": "11913502",
    "董事長": "張安平",
    "總經理": "張安平",
    "發言人": "黃健強",
    "發言人職稱": "財務長暨發言人",
    "代理發言人": "呂克甫",
    "總機電話": "(02)2531-7099",
    "成立日期": "19501229",
    "上市日期": "19620209",
    "普通股每股面額": "新台幣 10.0000元",
    "實收資本額": "73561817420",
    "私募股數": "0",
    "特別股": "0",
    "編制財務報表類型": "1",
    "股票過戶機構": "中國信託商業銀行代理部",
    "簽證會計師事務所": "勤業眾信聯合會計師事務所",
    "簽證會計師1": "郭政弘",
    "簽證會計師2": "楊淑婷",
    "英文簡稱": "TCC",
    "英文通訊地址": "No.113, Sec. 2, Zhongshan N. Rd., Taipei City",
    "傳真機號碼": "(02)2531-7099",
    "電子郵件信箱": "tcc@taiwancement.com",
    "網址": "https://www.taiwancement.com"
  }
]
```

**Step 2: 寫 CompanyModel 的失敗測試**

```dart
// test/data/models/company_model_test.dart
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

    test('should set website to null when empty or dash', () {
      jsonMap['網址'] = '';
      final model = CompanyModel.fromJson(jsonMap);
      expect(model.website, isNull);
    });

    test('should parse special shares and private shares', () {
      final model = CompanyModel.fromJson(jsonMap);
      expect(model.specialShares, 0);
      expect(model.privateShares, 0);
    });
  });
}
```

**Step 3: 跑測試確認失敗**

```bash
flutter test test/data/models/company_model_test.dart
```

Expected: FAIL

**Step 4: 實作 CompanyModel**

```dart
// lib/data/models/company_model.dart
import 'package:company_info_explorer/core/utils/par_value_parser.dart';
import 'package:company_info_explorer/domain/entities/company.dart';

class CompanyModel extends Company {
  const CompanyModel({
    required super.stockCode,
    required super.name,
    required super.shortName,
    required super.industryCode,
    required super.chairman,
    required super.generalManager,
    required super.address,
    required super.phone,
    required super.taxId,
    required super.foundedDate,
    required super.listedDate,
    required super.paidInCapital,
    required super.parValueDesc,
    required super.parValue,
    required super.specialShares,
    required super.privateShares,
    super.website,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    final parValueDesc = json['普通股每股面額'] as String? ?? '';
    final websiteRaw = json['網址'] as String? ?? '';

    return CompanyModel(
      stockCode: json['公司代號'] as String? ?? '',
      name: json['公司名稱'] as String? ?? '',
      shortName: json['公司簡稱'] as String? ?? '',
      industryCode: json['產業別'] as String? ?? '',
      chairman: json['董事長'] as String? ?? '',
      generalManager: json['總經理'] as String? ?? '',
      address: json['住址'] as String? ?? '',
      phone: json['總機電話'] as String? ?? '',
      taxId: json['營利事業統一編號'] as String? ?? '',
      foundedDate: json['成立日期'] as String? ?? '',
      listedDate: json['上市日期'] as String? ?? '',
      paidInCapital: double.tryParse(json['實收資本額'] as String? ?? '0') ?? 0,
      parValueDesc: parValueDesc,
      parValue: parseParValue(parValueDesc),
      specialShares: int.tryParse(json['特別股'] as String? ?? '0') ?? 0,
      privateShares: int.tryParse(json['私募股數'] as String? ?? '0') ?? 0,
      website: (websiteRaw.isEmpty || websiteRaw == '－') ? null : websiteRaw,
    );
  }
}
```

**Step 5: 跑測試確認通過**

```bash
flutter test test/data/models/company_model_test.dart
```

Expected: All tests passed

**Step 6: Commit**

```bash
git add lib/data/models/ test/data/models/ test/fixtures/
git commit -m "feat: 實作 CompanyModel JSON 解析（含測試）"
```

---

## Task 6: Data — DataSources 與 Repository 實作（含測試）

**Files:**
- Create: `lib/data/datasources/twse_remote_datasource.dart`
- Create: `lib/data/datasources/watchlist_local_datasource.dart`
- Create: `lib/data/repositories/company_repository_impl.dart`
- Create: `test/data/repositories/company_repository_impl_test.dart`

**Step 1: 實作 RemoteDataSource**

```dart
// lib/data/datasources/twse_remote_datasource.dart
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
```

**Step 2: 實作 LocalDataSource**

```dart
// lib/data/datasources/watchlist_local_datasource.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WatchlistLocalDataSource {
  final SharedPreferences prefs;
  static const String _key = 'watchlist_stock_codes';

  WatchlistLocalDataSource(this.prefs);

  List<String> getWatchlist() {
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> list = jsonDecode(jsonString);
    return list.cast<String>();
  }

  Future<void> saveWatchlist(List<String> stockCodes) {
    return prefs.setString(_key, jsonEncode(stockCodes));
  }
}
```

**Step 3: 寫 Repository 的失敗測試**

```dart
// test/data/repositories/company_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:company_info_explorer/data/datasources/twse_remote_datasource.dart';
import 'package:company_info_explorer/data/datasources/watchlist_local_datasource.dart';
import 'package:company_info_explorer/data/models/company_model.dart';
import 'package:company_info_explorer/data/repositories/company_repository_impl.dart';

class MockRemoteDataSource extends Mock implements TwseRemoteDataSource {}

class MockLocalDataSource extends Mock implements WatchlistLocalDataSource {}

void main() {
  late CompanyRepositoryImpl repository;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    repository = CompanyRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  final testModels = [
    const CompanyModel(
      stockCode: '1101',
      name: '臺灣水泥股份有限公司',
      shortName: '台泥',
      industryCode: '01',
      chairman: '張安平',
      generalManager: '張安平',
      address: '台北市中山北路2段113號',
      phone: '(02)2531-7099',
      taxId: '11913502',
      foundedDate: '19501229',
      listedDate: '19620209',
      paidInCapital: 73561817420,
      parValueDesc: '新台幣 10.0000元',
      parValue: 10.0,
      specialShares: 0,
      privateShares: 0,
      website: 'https://www.taiwancement.com',
    ),
  ];

  group('fetchAllCompanies', () {
    test('should return companies from remote data source', () async {
      when(() => mockRemote.fetchCompanies())
          .thenAnswer((_) async => testModels);

      final result = await repository.fetchAllCompanies();

      expect(result.length, 1);
      expect(result[0].stockCode, '1101');
      verify(() => mockRemote.fetchCompanies()).called(1);
    });

    test('should cache companies after first fetch', () async {
      when(() => mockRemote.fetchCompanies())
          .thenAnswer((_) async => testModels);

      await repository.fetchAllCompanies();
      final result = await repository.fetchAllCompanies();

      expect(result.length, 1);
      verify(() => mockRemote.fetchCompanies()).called(1); // 只呼叫一次
    });
  });

  group('watchlist operations', () {
    test('addToWatchlist should add stock code and save', () async {
      when(() => mockLocal.getWatchlist()).thenReturn([]);
      when(() => mockLocal.saveWatchlist(any()))
          .thenAnswer((_) async {});

      await repository.addToWatchlist('1101');

      verify(() => mockLocal.saveWatchlist(['1101'])).called(1);
    });

    test('addToWatchlist should not add duplicate', () async {
      when(() => mockLocal.getWatchlist()).thenReturn(['1101']);
      when(() => mockLocal.saveWatchlist(any()))
          .thenAnswer((_) async {});

      await repository.addToWatchlist('1101');

      verifyNever(() => mockLocal.saveWatchlist(any()));
    });

    test('removeFromWatchlist should remove stock code and save', () async {
      when(() => mockLocal.getWatchlist()).thenReturn(['1101', '2330']);
      when(() => mockLocal.saveWatchlist(any()))
          .thenAnswer((_) async {});

      await repository.removeFromWatchlist('1101');

      verify(() => mockLocal.saveWatchlist(['2330'])).called(1);
    });

    test('getWatchlist should return list from local data source', () async {
      when(() => mockLocal.getWatchlist()).thenReturn(['1101']);

      final result = await repository.getWatchlist();

      expect(result, ['1101']);
    });
  });
}
```

**Step 4: 跑測試確認失敗**

```bash
flutter test test/data/repositories/
```

Expected: FAIL

**Step 5: 實作 CompanyRepositoryImpl**

```dart
// lib/data/repositories/company_repository_impl.dart
import 'package:company_info_explorer/data/datasources/twse_remote_datasource.dart';
import 'package:company_info_explorer/data/datasources/watchlist_local_datasource.dart';
import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final TwseRemoteDataSource remoteDataSource;
  final WatchlistLocalDataSource localDataSource;

  List<Company>? _cachedCompanies;

  CompanyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Company>> fetchAllCompanies() async {
    if (_cachedCompanies != null) return _cachedCompanies!;
    final models = await remoteDataSource.fetchCompanies();
    _cachedCompanies = models;
    return models;
  }

  @override
  Future<List<String>> getWatchlist() async {
    return localDataSource.getWatchlist();
  }

  @override
  Future<void> addToWatchlist(String stockCode) async {
    final current = localDataSource.getWatchlist();
    if (current.contains(stockCode)) return;
    await localDataSource.saveWatchlist([...current, stockCode]);
  }

  @override
  Future<void> removeFromWatchlist(String stockCode) async {
    final current = localDataSource.getWatchlist();
    final updated = current.where((id) => id != stockCode).toList();
    await localDataSource.saveWatchlist(updated);
  }
}
```

**Step 6: 跑測試確認通過**

```bash
flutter test test/data/repositories/
```

Expected: All tests passed

**Step 7: Commit**

```bash
git add lib/data/ test/data/repositories/
git commit -m "feat: 實作 Data Layer — DataSources 與 Repository（含測試）"
```

---

## Task 7: Presentation — BLoCs（含測試）

**Files:**
- Create: `lib/presentation/blocs/app/app_bloc.dart`
- Create: `lib/presentation/blocs/app/app_event.dart`
- Create: `lib/presentation/blocs/app/app_state.dart`
- Create: `lib/presentation/blocs/industry_list/industry_list_bloc.dart`
- Create: `lib/presentation/blocs/industry_list/industry_list_event.dart`
- Create: `lib/presentation/blocs/industry_list/industry_list_state.dart`
- Create: `lib/presentation/blocs/company_list/company_list_bloc.dart`
- Create: `lib/presentation/blocs/company_list/company_list_event.dart`
- Create: `lib/presentation/blocs/company_list/company_list_state.dart`
- Create: `lib/presentation/blocs/company_detail/company_detail_bloc.dart`
- Create: `lib/presentation/blocs/company_detail/company_detail_event.dart`
- Create: `lib/presentation/blocs/company_detail/company_detail_state.dart`
- Create: `lib/presentation/blocs/watchlist/watchlist_bloc.dart`
- Create: `lib/presentation/blocs/watchlist/watchlist_event.dart`
- Create: `lib/presentation/blocs/watchlist/watchlist_state.dart`
- Create: `test/presentation/blocs/app_bloc_test.dart`
- Create: `test/presentation/blocs/industry_list_bloc_test.dart`
- Create: `test/presentation/blocs/watchlist_bloc_test.dart`

**Step 1: 實作 AppBloc（Event/State/Bloc）**

```dart
// lib/presentation/blocs/app/app_event.dart
import 'package:equatable/equatable.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AppEvent {}
```

```dart
// lib/presentation/blocs/app/app_state.dart
import 'package:equatable/equatable.dart';
import 'package:company_info_explorer/domain/entities/company.dart';

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

class AppInitial extends AppState {}

class AppLoading extends AppState {}

class AppLoaded extends AppState {
  final List<Company> companies;
  const AppLoaded(this.companies);

  @override
  List<Object> get props => [companies];
}

class AppError extends AppState {
  final String message;
  const AppError(this.message);

  @override
  List<Object> get props => [message];
}
```

```dart
// lib/presentation/blocs/app/app_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/domain/usecases/load_companies_usecase.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final LoadCompaniesUseCase loadCompanies;

  AppBloc({required this.loadCompanies}) : super(AppInitial()) {
    on<AppStarted>(_onAppStarted);
  }

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AppState> emit,
  ) async {
    emit(AppLoading());
    try {
      final companies = await loadCompanies();
      emit(AppLoaded(companies));
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }
}
```

**Step 2: 實作 IndustryListBloc**

```dart
// lib/presentation/blocs/industry_list/industry_list_event.dart
import 'package:equatable/equatable.dart';
import 'package:company_info_explorer/domain/entities/company.dart';

abstract class IndustryListEvent extends Equatable {
  const IndustryListEvent();

  @override
  List<Object> get props => [];
}

class LoadIndustries extends IndustryListEvent {
  final List<Company> companies;
  const LoadIndustries(this.companies);

  @override
  List<Object> get props => [companies];
}
```

```dart
// lib/presentation/blocs/industry_list/industry_list_state.dart
import 'package:equatable/equatable.dart';
import 'package:company_info_explorer/domain/entities/industry.dart';

abstract class IndustryListState extends Equatable {
  const IndustryListState();

  @override
  List<Object> get props => [];
}

class IndustryListInitial extends IndustryListState {}

class IndustryListLoaded extends IndustryListState {
  final List<Industry> industries;
  const IndustryListLoaded(this.industries);

  @override
  List<Object> get props => [industries];
}
```

```dart
// lib/presentation/blocs/industry_list/industry_list_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/domain/usecases/get_industries_usecase.dart';
import 'industry_list_event.dart';
import 'industry_list_state.dart';

class IndustryListBloc extends Bloc<IndustryListEvent, IndustryListState> {
  final GetIndustriesUseCase getIndustries;

  IndustryListBloc({required this.getIndustries})
      : super(IndustryListInitial()) {
    on<LoadIndustries>(_onLoadIndustries);
  }

  void _onLoadIndustries(
    LoadIndustries event,
    Emitter<IndustryListState> emit,
  ) {
    final industries = getIndustries(event.companies);
    emit(IndustryListLoaded(industries));
  }
}
```

**Step 3: 實作 CompanyListBloc**

```dart
// lib/presentation/blocs/company_list/company_list_event.dart
import 'package:equatable/equatable.dart';
import 'package:company_info_explorer/domain/entities/company.dart';

abstract class CompanyListEvent extends Equatable {
  const CompanyListEvent();

  @override
  List<Object> get props => [];
}

class LoadCompanyList extends CompanyListEvent {
  final List<Company> allCompanies;
  final String industryCode;
  const LoadCompanyList(this.allCompanies, this.industryCode);

  @override
  List<Object> get props => [allCompanies, industryCode];
}
```

```dart
// lib/presentation/blocs/company_list/company_list_state.dart
import 'package:equatable/equatable.dart';
import 'package:company_info_explorer/domain/entities/company.dart';

abstract class CompanyListState extends Equatable {
  const CompanyListState();

  @override
  List<Object> get props => [];
}

class CompanyListInitial extends CompanyListState {}

class CompanyListLoaded extends CompanyListState {
  final List<Company> companies;
  const CompanyListLoaded(this.companies);

  @override
  List<Object> get props => [companies];
}
```

```dart
// lib/presentation/blocs/company_list/company_list_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/domain/usecases/get_companies_by_industry_usecase.dart';
import 'company_list_event.dart';
import 'company_list_state.dart';

class CompanyListBloc extends Bloc<CompanyListEvent, CompanyListState> {
  final GetCompaniesByIndustryUseCase getCompaniesByIndustry;

  CompanyListBloc({required this.getCompaniesByIndustry})
      : super(CompanyListInitial()) {
    on<LoadCompanyList>(_onLoadCompanyList);
  }

  void _onLoadCompanyList(
    LoadCompanyList event,
    Emitter<CompanyListState> emit,
  ) {
    final companies =
        getCompaniesByIndustry(event.allCompanies, event.industryCode);
    emit(CompanyListLoaded(companies));
  }
}
```

**Step 4: 實作 CompanyDetailBloc**

```dart
// lib/presentation/blocs/company_detail/company_detail_event.dart
import 'package:equatable/equatable.dart';

abstract class CompanyDetailEvent extends Equatable {
  const CompanyDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadCompanyDetail extends CompanyDetailEvent {
  final String stockCode;
  const LoadCompanyDetail(this.stockCode);

  @override
  List<Object> get props => [stockCode];
}

class ToggleWatchlist extends CompanyDetailEvent {
  final String stockCode;
  final bool currentlyWatched;
  const ToggleWatchlist(this.stockCode, this.currentlyWatched);

  @override
  List<Object> get props => [stockCode, currentlyWatched];
}
```

```dart
// lib/presentation/blocs/company_detail/company_detail_state.dart
import 'package:equatable/equatable.dart';

abstract class CompanyDetailState extends Equatable {
  const CompanyDetailState();

  @override
  List<Object> get props => [];
}

class CompanyDetailInitial extends CompanyDetailState {}

class CompanyDetailLoaded extends CompanyDetailState {
  final bool isWatched;
  const CompanyDetailLoaded({required this.isWatched});

  @override
  List<Object> get props => [isWatched];
}
```

```dart
// lib/presentation/blocs/company_detail/company_detail_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/domain/usecases/add_to_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/usecases/remove_from_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';
import 'company_detail_event.dart';
import 'company_detail_state.dart';

class CompanyDetailBloc
    extends Bloc<CompanyDetailEvent, CompanyDetailState> {
  final CompanyRepository repository;
  final AddToWatchlistUseCase addToWatchlist;
  final RemoveFromWatchlistUseCase removeFromWatchlist;

  CompanyDetailBloc({
    required this.repository,
    required this.addToWatchlist,
    required this.removeFromWatchlist,
  }) : super(CompanyDetailInitial()) {
    on<LoadCompanyDetail>(_onLoad);
    on<ToggleWatchlist>(_onToggle);
  }

  Future<void> _onLoad(
    LoadCompanyDetail event,
    Emitter<CompanyDetailState> emit,
  ) async {
    final watchlist = await repository.getWatchlist();
    final isWatched = watchlist.contains(event.stockCode);
    emit(CompanyDetailLoaded(isWatched: isWatched));
  }

  Future<void> _onToggle(
    ToggleWatchlist event,
    Emitter<CompanyDetailState> emit,
  ) async {
    if (event.currentlyWatched) {
      await removeFromWatchlist(event.stockCode);
    } else {
      await addToWatchlist(event.stockCode);
    }
    emit(CompanyDetailLoaded(isWatched: !event.currentlyWatched));
  }
}
```

**Step 5: 實作 WatchlistBloc**

```dart
// lib/presentation/blocs/watchlist/watchlist_event.dart
import 'package:equatable/equatable.dart';
import 'package:company_info_explorer/domain/entities/company.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object> get props => [];
}

class LoadWatchlist extends WatchlistEvent {
  final List<Company> allCompanies;
  const LoadWatchlist(this.allCompanies);

  @override
  List<Object> get props => [allCompanies];
}

class RemoveFromWatchlistEvent extends WatchlistEvent {
  final String stockCode;
  final List<Company> allCompanies;
  const RemoveFromWatchlistEvent(this.stockCode, this.allCompanies);

  @override
  List<Object> get props => [stockCode, allCompanies];
}
```

```dart
// lib/presentation/blocs/watchlist/watchlist_state.dart
import 'package:equatable/equatable.dart';
import 'package:company_info_explorer/domain/entities/company.dart';

abstract class WatchlistState extends Equatable {
  const WatchlistState();

  @override
  List<Object> get props => [];
}

class WatchlistInitial extends WatchlistState {}

class WatchlistLoading extends WatchlistState {}

class WatchlistLoaded extends WatchlistState {
  final List<Company> companies;
  const WatchlistLoaded(this.companies);

  @override
  List<Object> get props => [companies];
}
```

```dart
// lib/presentation/blocs/watchlist/watchlist_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/domain/usecases/get_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/usecases/remove_from_watchlist_usecase.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final GetWatchlistUseCase getWatchlist;
  final RemoveFromWatchlistUseCase removeFromWatchlist;

  WatchlistBloc({
    required this.getWatchlist,
    required this.removeFromWatchlist,
  }) : super(WatchlistInitial()) {
    on<LoadWatchlist>(_onLoad);
    on<RemoveFromWatchlistEvent>(_onRemove);
  }

  Future<void> _onLoad(
    LoadWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(WatchlistLoading());
    final companies = await getWatchlist(event.allCompanies);
    emit(WatchlistLoaded(companies));
  }

  Future<void> _onRemove(
    RemoveFromWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    await removeFromWatchlist(event.stockCode);
    final companies = await getWatchlist(event.allCompanies);
    emit(WatchlistLoaded(companies));
  }
}
```

**Step 6: 寫 BLoC 測試**

```dart
// test/presentation/blocs/app_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:company_info_explorer/domain/usecases/load_companies_usecase.dart';
import 'package:company_info_explorer/presentation/blocs/app/app_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/app/app_event.dart';
import 'package:company_info_explorer/presentation/blocs/app/app_state.dart';
import '../../helpers/test_data.dart';

class MockLoadCompaniesUseCase extends Mock implements LoadCompaniesUseCase {}

void main() {
  late MockLoadCompaniesUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockLoadCompaniesUseCase();
  });

  group('AppBloc', () {
    blocTest<AppBloc, AppState>(
      'emits [AppLoading, AppLoaded] when AppStarted succeeds',
      build: () {
        when(() => mockUseCase()).thenAnswer((_) async => testCompanies);
        return AppBloc(loadCompanies: mockUseCase);
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [
        isA<AppLoading>(),
        isA<AppLoaded>(),
      ],
      verify: (_) {
        verify(() => mockUseCase()).called(1);
      },
    );

    blocTest<AppBloc, AppState>(
      'emits [AppLoading, AppError] when AppStarted fails',
      build: () {
        when(() => mockUseCase()).thenThrow(Exception('Network error'));
        return AppBloc(loadCompanies: mockUseCase);
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [
        isA<AppLoading>(),
        isA<AppError>(),
      ],
    );
  });
}
```

```dart
// test/presentation/blocs/industry_list_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:company_info_explorer/domain/usecases/get_industries_usecase.dart';
import 'package:company_info_explorer/presentation/blocs/industry_list/industry_list_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/industry_list/industry_list_event.dart';
import 'package:company_info_explorer/presentation/blocs/industry_list/industry_list_state.dart';
import '../../helpers/test_data.dart';

void main() {
  group('IndustryListBloc', () {
    blocTest<IndustryListBloc, IndustryListState>(
      'emits [IndustryListLoaded] with grouped industries',
      build: () => IndustryListBloc(getIndustries: GetIndustriesUseCase()),
      act: (bloc) => bloc.add(LoadIndustries(testCompanies)),
      expect: () => [
        isA<IndustryListLoaded>().having(
          (s) => s.industries.length,
          'industry count',
          2,
        ),
      ],
    );
  });
}
```

```dart
// test/presentation/blocs/watchlist_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:company_info_explorer/domain/usecases/get_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/usecases/remove_from_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';
import 'package:company_info_explorer/presentation/blocs/watchlist/watchlist_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/watchlist/watchlist_event.dart';
import 'package:company_info_explorer/presentation/blocs/watchlist/watchlist_state.dart';
import '../../helpers/test_data.dart';

class MockCompanyRepository extends Mock implements CompanyRepository {}

void main() {
  late MockCompanyRepository mockRepo;

  setUp(() {
    mockRepo = MockCompanyRepository();
  });

  group('WatchlistBloc', () {
    blocTest<WatchlistBloc, WatchlistState>(
      'emits [WatchlistLoading, WatchlistLoaded] on LoadWatchlist',
      build: () {
        when(() => mockRepo.getWatchlist())
            .thenAnswer((_) async => ['1101']);
        return WatchlistBloc(
          getWatchlist: GetWatchlistUseCase(mockRepo),
          removeFromWatchlist: RemoveFromWatchlistUseCase(mockRepo),
        );
      },
      act: (bloc) => bloc.add(LoadWatchlist(testCompanies)),
      expect: () => [
        isA<WatchlistLoading>(),
        isA<WatchlistLoaded>().having(
          (s) => s.companies.length,
          'watched count',
          1,
        ),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'emits updated list after RemoveFromWatchlistEvent',
      build: () {
        when(() => mockRepo.removeFromWatchlist('1101'))
            .thenAnswer((_) async {});
        when(() => mockRepo.getWatchlist())
            .thenAnswer((_) async => []);
        return WatchlistBloc(
          getWatchlist: GetWatchlistUseCase(mockRepo),
          removeFromWatchlist: RemoveFromWatchlistUseCase(mockRepo),
        );
      },
      act: (bloc) =>
          bloc.add(RemoveFromWatchlistEvent('1101', testCompanies)),
      expect: () => [
        isA<WatchlistLoaded>().having(
          (s) => s.companies.length,
          'watched count',
          0,
        ),
      ],
    );
  });
}
```

**Step 7: 跑全部測試**

```bash
flutter test
```

Expected: All tests passed

**Step 8: Commit**

```bash
git add lib/presentation/blocs/ test/presentation/blocs/
git commit -m "feat: 實作 Presentation Layer BLoCs（含測試）"
```

---

## Task 8: 依賴注入設定

**Files:**
- Create: `lib/di/injection_container.dart`

**Step 1: 實作 DI 設定**

```dart
// lib/di/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:company_info_explorer/data/datasources/twse_remote_datasource.dart';
import 'package:company_info_explorer/data/datasources/watchlist_local_datasource.dart';
import 'package:company_info_explorer/data/repositories/company_repository_impl.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';
import 'package:company_info_explorer/domain/usecases/load_companies_usecase.dart';
import 'package:company_info_explorer/domain/usecases/get_industries_usecase.dart';
import 'package:company_info_explorer/domain/usecases/get_companies_by_industry_usecase.dart';
import 'package:company_info_explorer/domain/usecases/get_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/usecases/add_to_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/usecases/remove_from_watchlist_usecase.dart';
import 'package:company_info_explorer/presentation/blocs/app/app_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/industry_list/industry_list_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/company_list/company_list_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/company_detail/company_detail_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/watchlist/watchlist_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);
  sl.registerLazySingleton(() => http.Client());

  // Data Sources
  sl.registerLazySingleton(() => TwseRemoteDataSource(sl()));
  sl.registerLazySingleton(() => WatchlistLocalDataSource(sl()));

  // Repository
  sl.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoadCompaniesUseCase(sl()));
  sl.registerLazySingleton(() => GetIndustriesUseCase());
  sl.registerLazySingleton(() => GetCompaniesByIndustryUseCase());
  sl.registerLazySingleton(() => GetWatchlistUseCase(sl()));
  sl.registerLazySingleton(() => AddToWatchlistUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromWatchlistUseCase(sl()));

  // BLoCs
  sl.registerFactory(() => AppBloc(loadCompanies: sl()));
  sl.registerFactory(() => IndustryListBloc(getIndustries: sl()));
  sl.registerFactory(() => CompanyListBloc(getCompaniesByIndustry: sl()));
  sl.registerFactory(
    () => CompanyDetailBloc(
      repository: sl(),
      addToWatchlist: sl(),
      removeFromWatchlist: sl(),
    ),
  );
  sl.registerFactory(
    () => WatchlistBloc(
      getWatchlist: sl(),
      removeFromWatchlist: sl(),
    ),
  );
}
```

**Step 2: 確認編譯通過**

```bash
flutter analyze
```

**Step 3: Commit**

```bash
git add lib/di/
git commit -m "feat: 設定依賴注入容器（get_it）"
```

---

## Task 9: UI — Launch 頁面與 App Shell

**Files:**
- Modify: `lib/main.dart`
- Create: `lib/presentation/pages/launch_page.dart`
- Create: `lib/presentation/pages/home_page.dart`

**Step 1: 實作 main.dart**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/di/injection_container.dart' as di;
import 'package:company_info_explorer/presentation/blocs/app/app_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/app/app_event.dart';
import 'package:company_info_explorer/presentation/pages/launch_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AppBloc>()..add(AppStarted()),
      child: MaterialApp(
        title: '公司基本資料查詢',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const LaunchPage(),
      ),
    );
  }
}
```

**Step 2: 實作 LaunchPage**

```dart
// lib/presentation/pages/launch_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/app/app_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/app/app_state.dart';
import 'package:company_info_explorer/presentation/pages/home_page.dart';

class LaunchPage extends StatelessWidget {
  const LaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        if (state is AppLoaded) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => HomePage(companies: state.companies),
            ),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: BlocBuilder<AppBloc, AppState>(
            builder: (context, state) {
              if (state is AppError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('載入失敗: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<AppBloc>().add(
                            const AppStarted(),
                          ),
                      child: const Text('重試'),
                    ),
                  ],
                );
              }
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 120, color: Colors.grey),
                  SizedBox(height: 32),
                  CircularProgressIndicator(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
```

注意：`AppStarted` 需要加上 `const` 建構式或移除上面的 `const`。

**Step 3: 實作 HomePage（底部導航）**

```dart
// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/presentation/pages/industry_list_page.dart';
import 'package:company_info_explorer/presentation/pages/watchlist_page.dart';

class HomePage extends StatefulWidget {
  final List<Company> companies;
  const HomePage({super.key, required this.companies});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      IndustryListPage(companies: widget.companies),
      WatchlistPage(companies: widget.companies),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: '產業',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            label: '追蹤',
          ),
        ],
      ),
    );
  }
}
```

**Step 4: 建立暫時的 placeholder 頁面（IndustryListPage, WatchlistPage）**

先建立空殼讓 app 能跑起來，後續 Task 再完善。

**Step 5: 跑 app 確認啟動正常**

```bash
flutter run
```

**Step 6: Commit**

```bash
git add lib/main.dart lib/presentation/pages/
git commit -m "feat: 實作 Launch 頁面與 App Shell（底部導航）"
```

---

## Task 10: UI — 產業列表頁面

**Files:**
- Create: `lib/presentation/pages/industry_list_page.dart`

**Step 1: 實作 IndustryListPage**

使用 `IndustryListBloc`，頁面載入時觸發 `LoadIndustries` event，
`ListView` 顯示每個產業名稱與公司數，點擊跳轉到 `CompanyListPage`。

格式：`水泥工業(30)` + 右箭頭 chevron

**Step 2: 跑 app 確認頁面顯示正確**

**Step 3: Commit**

```bash
git add lib/presentation/pages/industry_list_page.dart
git commit -m "feat: 實作產業列表頁面"
```

---

## Task 11: UI — 個別產業公司列表頁面

**Files:**
- Create: `lib/presentation/pages/company_list_page.dart`

**Step 1: 實作 CompanyListPage**

使用 `CompanyListBloc`，接收 `industryCode` 和 `industryName` 參數。
`ListView` 顯示 `stockCode shortName`，點擊跳轉到 `CompanyDetailPage`。

Navigation bar: 返回按鈕 + "產業別" 文字
標題: 產業名稱（如 "水泥工業"）

**Step 2: 跑 app 確認頁面與導航正確**

**Step 3: Commit**

```bash
git add lib/presentation/pages/company_list_page.dart
git commit -m "feat: 實作個別產業公司列表頁面"
```

---

## Task 12: UI — 公司基本資料頁面

**Files:**
- Create: `lib/presentation/pages/company_detail_page.dart`

**Step 1: 實作 CompanyDetailPage**

接收 `Company` 物件、`industryName` 參數。
使用 `CompanyDetailBloc` 管理追蹤狀態。

顯示內容（依 wireframe 排列）：
- Navigation bar: 返回 + `industryName` + `stockCode shortName` + 星號
- 基本資料區塊：公司名稱（含地球 icon 若有網址）
- 董事長、總經理、產業類別
- 公司成立日期、上市日期
- 總機、統一編號
- 地址
- 實收資本額（千分位格式）+ "元"
- 普通股每股面額
- 已發行普通股數或 TDR 原股發行股數（計算公式）
- 特別股（千分位格式）+ "股"

星號按鈕：
- 未追蹤 → 顯示空心星號 `Icons.star_border`
- 已追蹤 → 顯示實心星號 `Icons.star`
- 點擊時彈出確認 Dialog

公式：`已發行股數 = (實收資本額 / 每股面額) - 特別股`

使用 `url_launcher` 或直接用 `launchUrl` 開啟公司網站。

**Step 2: 跑 app 確認資料顯示與追蹤功能**

**Step 3: Commit**

```bash
git add lib/presentation/pages/company_detail_page.dart
git commit -m "feat: 實作公司基本資料頁面（含追蹤功能）"
```

---

## Task 13: UI — 追蹤列表頁面

**Files:**
- Create: `lib/presentation/pages/watchlist_page.dart`

**Step 1: 實作 WatchlistPage**

使用 `WatchlistBloc`，切換到追蹤 tab 時觸發 `LoadWatchlist`。

`ListView` 顯示 `stockCode shortName`，點擊跳轉到 `CompanyDetailPage`。

左滑顯示紅色「移除」按鈕（`Dismissible` widget），
確認 Dialog: "是否將 {stockCode}{shortName} 從追蹤列表中移除？"
按鈕: 取消 / 移除

**Step 2: 跑 app 確認追蹤列表功能**

**Step 3: Commit**

```bash
git add lib/presentation/pages/watchlist_page.dart
git commit -m "feat: 實作追蹤列表頁面（含左滑移除功能）"
```

---

## Task 14: 整合測試與最終確認

**Step 1: 跑全部測試**

```bash
flutter test
```

Expected: All tests passed

**Step 2: 跑靜態分析**

```bash
flutter analyze
```

Expected: 無 error

**Step 3: 整體功能測試**

```bash
flutter run
```

手動確認：
- [ ] Launch 頁載入成功後跳轉到產業列表
- [ ] 產業列表正確顯示所有產業與公司數
- [ ] 點擊產業進入公司列表
- [ ] 點擊公司進入詳情頁
- [ ] 詳情頁數字千分位格式化正確
- [ ] 已發行股數計算正確
- [ ] 追蹤星號按鈕加入/移除正常
- [ ] 追蹤 tab 顯示已追蹤公司
- [ ] 左滑移除追蹤功能正常
- [ ] 有網址的公司顯示地球 icon

**Step 4: Commit**

```bash
git add -A
git commit -m "test: 整合測試通過，全功能驗證完成"
```

---

## Task 15: README 與最終文件

**Files:**
- Modify: `README.md`

**Step 1: 撰寫 README.md**

內容包含：
- 專案簡介
- 架構設計（含分層架構圖）
- 技術選型與理由
- 目錄結構說明
- 如何執行（`flutter run`）
- 如何跑測試（`flutter test`）
- 測試涵蓋範圍說明
- 開發過程說明（TDD 流程）
- 可改善的方向（展現思考深度）

**Step 2: Commit**

```bash
git add README.md docs/
git commit -m "misc: 撰寫 README 與專案文件"
```
