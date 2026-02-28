# 公司基本資料查詢 App — 架構設計文件

## 專案概述

一個簡易的公司基本資料查詢 App，使用者可以透過產業分類來查找台灣證交所上市公司的基本資料，
也可以將想要長期觀察的公司放進追蹤列表內，方便下次快速查找。

**資料來源：** [台灣證交所 — 公開發行公司基本資料 API](https://openapi.twse.com.tw/v1/opendata/t187ap03_P)

## 技術選型

| 用途 | 套件 | 選擇理由 |
|------|------|----------|
| 框架 | Flutter | 作業指定 |
| 狀態管理 | `flutter_bloc` | Event/State 模式明確，與 Clean Architecture 搭配佳，測試性極高 |
| 依賴注入 | `get_it` | 輕量，方便測試時替換 mock 實作 |
| 本地儲存 | `shared_preferences` | 追蹤列表只需存公司代號 list，不需要完整資料庫 |
| HTTP 請求 | `http` | 只有一支 API，不需要 dio 的進階功能 |
| 相等比較 | `equatable` | BLoC state/event 比較需要 |
| 測試 Mock | `mocktail` | 語法比 mockito 簡潔，不需要 code generation |

## 架構設計：Clean Architecture

### 分層架構圖

```
┌─────────────────────────────────────────────┐
│              Presentation Layer             │
│   (BLoC + UI Widgets)                       │
│   依賴：flutter_bloc, Domain Layer          │
├─────────────────────────────────────────────┤
│               Domain Layer                  │
│   (Entities, Repository 介面, UseCases)     │
│   依賴：無（純 Dart）                        │
├─────────────────────────────────────────────┤
│                Data Layer                   │
│   (Models, DataSources, Repository 實作)    │
│   依賴：http, shared_preferences            │
└─────────────────────────────────────────────┘
```

**依賴方向：** Presentation → Domain ← Data

Domain Layer 是核心，不依賴任何外部框架。Data Layer 與 Presentation Layer 都依賴 Domain Layer，
但彼此不直接依賴。這確保了商業邏輯可以獨立測試。

### 資料流

```
TWSE API ──→ RemoteDataSource ──→ Repository（內存快取）──→ UseCase ──→ BLoC ──→ UI
                                       ↑
              LocalDataSource ─────────┘
              (shared_preferences)
```

**資料載入策略：**
- App 啟動時（Launch 頁面）一次載入全部公司資料，快取在 Repository 的內存中
- 後續的產業列表、公司列表都從內存快取 filter/group，不再呼叫 API
- 追蹤列表只儲存公司代號的 `List<String>` 到 shared_preferences

## Domain Layer 設計

### Entities

```dart
class Company {
  final String stockCode;      // 公司代號
  final String name;           // 公司名稱
  final String shortName;      // 公司簡稱
  final String industryCode;   // 產業別代碼
  final String chairman;       // 董事長
  final String generalManager; // 總經理
  final String address;        // 住址
  final String phone;          // 總機電話
  final String taxId;          // 營利事業統一編號
  final String foundedDate;    // 成立日期
  final String listedDate;     // 上市日期
  final double paidInCapital;  // 實收資本額（數值）
  final String parValueDesc;   // 普通股每股面額（原始字串）
  final double parValue;       // 面額數值（解析後）
  final int specialShares;     // 特別股
  final int privateShares;     // 私募股數
  final String? website;       // 網址（可為 null）
}

class Industry {
  final String code;           // 產業代碼
  final String name;           // 產業名稱
  final int companyCount;      // 該產業公司數量
}
```

### Repository 介面

```dart
abstract class CompanyRepository {
  /// 從 API 載入全部公司資料（Launch 時呼叫一次）
  Future<List<Company>> fetchAllCompanies();

  /// 取得追蹤列表中的公司代號
  Future<List<String>> getWatchlist();

  /// 加入追蹤
  Future<void> addToWatchlist(String stockCode);

  /// 從追蹤移除
  Future<void> removeFromWatchlist(String stockCode);
}
```

### UseCases

| UseCase | 輸入 | 輸出 | 邏輯 |
|---------|------|------|------|
| `LoadCompaniesUseCase` | 無 | `List<Company>` | 呼叫 API 載入全部公司 |
| `GetIndustriesUseCase` | `List<Company>` | `List<Industry>` | group by 產業代碼，計算各產業公司數量 |
| `GetCompaniesByIndustryUseCase` | `String industryCode` | `List<Company>` | filter by 產業代碼 |
| `GetWatchlistUseCase` | 無 | `List<Company>` | 取得追蹤的公司代號，對應到完整公司資料 |
| `AddToWatchlistUseCase` | `String stockCode` | `void` | 加入追蹤列表 |
| `RemoveFromWatchlistUseCase` | `String stockCode` | `void` | 從追蹤列表移除 |

## Data Layer 設計

### Models

`CompanyModel` 繼承 `Company`，負責 JSON 反序列化：

```dart
class CompanyModel extends Company {
  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    // 解析 TWSE API 的中文欄位名
    // 處理 "普通股每股面額" 的字串解析（"新台幣 10.0000元" → 10.0）
    // 處理 "實收資本額" 的數值轉換
  }
}
```

### DataSources

```dart
// Remote — TWSE API
class TwseRemoteDataSource {
  Future<List<CompanyModel>> fetchCompanies();
}

// Local — 追蹤列表
class WatchlistLocalDataSource {
  Future<List<String>> getWatchlist();
  Future<void> saveWatchlist(List<String> stockCodes);
}
```

### Repository 實作

```dart
class CompanyRepositoryImpl implements CompanyRepository {
  final TwseRemoteDataSource remoteDataSource;
  final WatchlistLocalDataSource localDataSource;

  List<Company>? _cachedCompanies; // 內存快取
}
```

## Presentation Layer 設計

### BLoC 設計

| BLoC | 職責 | Events | States |
|------|------|--------|--------|
| `AppBloc` | Launch 載入資料 | `LoadData` | `AppInitial`, `AppLoading`, `AppLoaded`, `AppError` |
| `IndustryListBloc` | 產業列表 | `LoadIndustries` | `Initial`, `Loading`, `Loaded(industries)`, `Error` |
| `CompanyListBloc` | 公司列表 | `LoadCompanies(industryCode)` | `Initial`, `Loading`, `Loaded(companies)`, `Error` |
| `CompanyDetailBloc` | 公司詳情 + 追蹤狀態 | `LoadDetail(code)`, `ToggleWatchlist` | `Loading`, `Loaded(company, isWatched)`, `Error` |
| `WatchlistBloc` | 追蹤列表 | `LoadWatchlist`, `RemoveFromWatchlist(code)` | `Loading`, `Loaded(companies)`, `Empty`, `Error` |

### 畫面導航結構

```
LaunchPage（啟動載入）
    │
    ▼ 載入完成後
BottomNavigationBar
├── 產業 Tab
│   ├── IndustryListPage       ← 產業列表
│   └── CompanyListPage        ← Navigator.push 進入
│       └── CompanyDetailPage  ← Navigator.push 進入
└── 追蹤 Tab
    └── WatchlistPage          ← 追蹤列表
        └── CompanyDetailPage  ← Navigator.push 進入
```

## 產業代碼對照表

產業代碼與名稱的對照在 app 內以常數 Map 維護：

```dart
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
```

## 計算邏輯

### 已發行普通股數或 TDR 原股發行股數

```
已發行普通股數 = (實收資本額 / 普通股每股面額) - 特別股股數
```

### 數字格式化

所有金額與股數顯示時需加上千分位逗點，例如：`73,561,817,420`

## 單元測試策略

| 測試層級 | 測試目標 | Mock 對象 | 預估測試數 |
|---------|---------|----------|----------|
| **Model** | JSON 解析正確性 | 無（純函數） | 3-5 |
| **UseCase** | 商業邏輯 | `CompanyRepository` | 8-12 |
| **Repository** | 資料整合 | `RemoteDataSource` + `LocalDataSource` | 5-8 |
| **BLoC** | 狀態流轉 | `UseCase` | 10-15 |
| **工具函數** | 千分位格式化、面額解析 | 無（純函數） | 3-5 |

**測試開發流程（TDD）：**
1. 紅燈 — 先寫失敗的測試
2. 綠燈 — 寫最少的程式碼讓測試通過
3. 重構 — 整理程式碼，確保測試仍然通過

## 目錄結構

```
lib/
├── core/                       # 共用模組
│   ├── constants/              # 產業代碼對照表等常數
│   ├── error/                  # 自定義 Exception
│   └── utils/                  # 格式化工具函數
├── domain/                     # 領域層（純 Dart）
│   ├── entities/
│   │   ├── company.dart
│   │   └── industry.dart
│   ├── repositories/
│   │   └── company_repository.dart  # 抽象介面
│   └── usecases/
│       ├── load_companies_usecase.dart
│       ├── get_industries_usecase.dart
│       ├── get_companies_by_industry_usecase.dart
│       ├── get_watchlist_usecase.dart
│       ├── add_to_watchlist_usecase.dart
│       └── remove_from_watchlist_usecase.dart
├── data/                       # 資料層
│   ├── models/
│   │   └── company_model.dart
│   ├── datasources/
│   │   ├── twse_remote_datasource.dart
│   │   └── watchlist_local_datasource.dart
│   └── repositories/
│       └── company_repository_impl.dart
├── presentation/               # 表現層
│   ├── blocs/
│   │   ├── app/
│   │   ├── industry_list/
│   │   ├── company_list/
│   │   ├── company_detail/
│   │   └── watchlist/
│   ├── pages/
│   │   ├── launch_page.dart
│   │   ├── industry_list_page.dart
│   │   ├── company_list_page.dart
│   │   ├── company_detail_page.dart
│   │   └── watchlist_page.dart
│   └── widgets/                # 共用 UI 元件
├── di/                         # 依賴注入設定
│   └── injection_container.dart
└── main.dart

test/
├── domain/usecases/
├── data/models/
├── data/repositories/
├── presentation/blocs/
└── core/utils/
```
