# 公司基本資料查詢 App

一個使用 Flutter 開發的台灣上市公司基本資料查詢應用程式。使用者可透過產業分類瀏覽公司資訊，並將感興趣的公司加入追蹤列表，方便日後快速查閱。

資料來源為台灣證券交易所（TWSE）公開 API。

## 功能列表

- **產業分類瀏覽** — 依產業別分組顯示上市公司，涵蓋 30+ 產業類別
- **公司基本資料** — 查看公司代號、名稱、董事長、總經理、資本額、發行股數等完整資訊
- **追蹤列表** — 將公司加入追蹤清單，資料持久化於本機儲存
- **左滑移除** — 追蹤列表支援左滑手勢移除公司
- **外部連結** — 一鍵開啟公司官方網站
- **數值格式化** — 金額與股數自動加上千分位逗點

## 系統架構

本專案採用 **Clean Architecture** 三層式架構，確保關注點分離與高測試性。

```
┌─────────────────────────────────────────────┐
│              Presentation Layer              │
│   BLoC + UI Widgets                         │
│   依賴：flutter_bloc, Domain Layer           │
├─────────────────────────────────────────────┤
│               Domain Layer                  │
│   Entities, Repository 介面, UseCases        │
│   依賴：無（純 Dart）                         │
├─────────────────────────────────────────────┤
│                Data Layer                   │
│   Models, DataSources, Repository 實作       │
│   依賴：http, shared_preferences             │
└─────────────────────────────────────────────┘
```

**依賴方向：** `Presentation → Domain ← Data`

| 層級 | 職責 | 關鍵特性 |
|------|------|---------|
| **Domain** | 定義 Entity、Repository 介面、UseCase 商業邏輯 | 純 Dart，不依賴任何框架 |
| **Data** | 實作 API 呼叫、本地儲存、JSON 解析 | 實作 Domain 定義的介面 |
| **Presentation** | 管理 UI 狀態（BLoC）、畫面渲染 | 僅透過 UseCase 存取資料 |

### 資料流

```
TWSE API → RemoteDataSource → Repository（內存快取）→ UseCase → BLoC → UI
                                    ↑
             LocalDataSource ───────┘
             (shared_preferences)
```

App 啟動時一次載入全部公司資料，快取於 Repository 內存中。後續的產業列表、公司列表皆從快取 filter/group，不再重複呼叫 API。

## 技術選型

| 用途 | 套件 | 選擇理由 |
|------|------|---------|
| 狀態管理 | `flutter_bloc` | Event/State 模式明確，與 Clean Architecture 搭配佳，測試性極高 |
| 依賴注入 | `get_it` | 輕量 Service Locator，方便測試時替換 mock 實作 |
| 本地儲存 | `shared_preferences` | 追蹤列表僅需存公司代號 `List<String>`，不需要完整資料庫 |
| HTTP 請求 | `http` | 只有一支 API，不需要 `dio` 的進階功能（interceptor、retry 等） |
| 相等比較 | `equatable` | BLoC state/event 物件比較必備 |
| 外部連結 | `url_launcher` | 開啟公司官方網站 |
| 測試 Mock | `mocktail` | 語法比 `mockito` 簡潔，不需要 code generation |
| BLoC 測試 | `bloc_test` | 提供 `blocTest()` 簡化 BLoC 狀態流測試 |

## 目錄結構

```
lib/
├── core/                              # 共用模組
│   ├── constants/
│   │   └── industry_codes.dart        # 產業代碼對照表
│   ├── error/
│   │   └── failures.dart              # 自定義 Exception
│   └── utils/
│       ├── number_formatter.dart       # 千分位格式化
│       └── par_value_parser.dart       # 面額字串解析
├── domain/                            # 領域層（純 Dart）
│   ├── entities/
│   │   ├── company.dart
│   │   └── industry.dart
│   ├── repositories/
│   │   └── company_repository.dart     # 抽象介面
│   └── usecases/
│       ├── load_companies_usecase.dart
│       ├── get_industries_usecase.dart
│       ├── get_companies_by_industry_usecase.dart
│       ├── get_watchlist_usecase.dart
│       ├── add_to_watchlist_usecase.dart
│       └── remove_from_watchlist_usecase.dart
├── data/                              # 資料層
│   ├── models/
│   │   └── company_model.dart          # JSON 反序列化
│   ├── datasources/
│   │   ├── twse_remote_datasource.dart
│   │   └── watchlist_local_datasource.dart
│   └── repositories/
│       └── company_repository_impl.dart
├── presentation/                      # 表現層
│   ├── blocs/
│   │   ├── app/                        # App 啟動載入
│   │   ├── industry_list/              # 產業列表
│   │   ├── company_list/               # 公司列表
│   │   ├── company_detail/             # 公司詳情 + 追蹤
│   │   └── watchlist/                  # 追蹤列表
│   ├── pages/
│   │   ├── launch_page.dart
│   │   ├── home_page.dart
│   │   ├── industry_list_page.dart
│   │   ├── company_list_page.dart
│   │   ├── company_detail_page.dart
│   │   └── watchlist_page.dart
│   └── widgets/                        # 共用 UI 元件（預留）
├── di/
│   └── injection_container.dart        # get_it 依賴注入設定
└── main.dart

test/
├── core/utils/                         # 工具函數測試
├── data/models/                        # JSON 解析測試
├── data/repositories/                  # Repository 測試
├── domain/usecases/                    # UseCase 測試
├── presentation/blocs/                 # BLoC 狀態流測試
├── fixtures/                           # 測試用 JSON 資料
└── helpers/                            # 測試共用輔助
```

## 執行方式

### 環境需求

- Flutter 3.41+ (Dart SDK ^3.11.0)

### 安裝與執行

```bash
# 安裝依賴
flutter pub get

# 執行 App
flutter run
```

## 測試

```bash
# 執行全部測試
flutter test
```

### 測試涵蓋範圍

共 **51 個測試**，涵蓋 4 個層級：

| 層級 | 測試檔案 | 測試內容 |
|------|---------|---------|
| Core Utils | `number_formatter_test.dart`, `par_value_parser_test.dart` | 千分位格式化、面額字串解析 |
| Data — Model | `company_model_test.dart` | TWSE API JSON 解析，含各欄位與邊界情境 |
| Data — Repository | `company_repository_impl_test.dart` | 遠端資料載入、內存快取、追蹤列表 CRUD |
| Domain — UseCase | `get_industries_usecase_test.dart`, `get_watchlist_usecase_test.dart`, `toggle_watchlist_usecase_test.dart` | 產業分組邏輯、追蹤列表查詢與增刪 |
| Presentation — BLoC | `app_bloc_test.dart`, `industry_list_bloc_test.dart`, `watchlist_bloc_test.dart` | 各 BLoC 狀態流轉正確性 |

每一層的測試皆透過 `mocktail` mock 掉下層依賴，確保單元測試的隔離性。

## 開發流程

本專案採用 **TDD（Test-Driven Development）** 開發，從 commit 歷史可以觀察到完整的開發脈絡：

1. 架構設計文件先行（`misc: 新增架構設計文件`）
2. 由內而外逐層實作：Domain → Data → Presentation → UI
3. 每一層皆先寫測試，再實作功能
4. 依賴注入最後設定，整合所有模組

```
misc: 新增架構設計文件
feat: 建立 Flutter 專案與依賴設定
feat: 新增產業代碼常數與數字格式化工具（含測試）
feat: 建立 Domain Layer — Entities 與 Repository 介面
feat: 實作 Domain Layer UseCases（含測試）
feat: 實作 CompanyModel JSON 解析（含測試）
feat: 實作 Data Layer — DataSources 與 Repository（含測試）
feat: 實作 Presentation Layer BLoCs（含測試）
feat: 設定依賴注入容器（get_it）
feat: 實作 Launch 頁面與 App Shell
feat: 實作產業列表頁面
feat: 實作個別產業公司列表頁面
feat: 實作公司基本資料頁面（含追蹤與網址功能）
feat: 實作追蹤列表頁面（含左滑移除）
```

## 可改善方向

以下為受限於時間未實作但值得改善的項目：

| 項目 | 說明 |
|------|------|
| **Error Handling 強化** | 引入 `Either<Failure, T>` 型別（如 `dartz` 或 `fpdart`），讓錯誤處理更加型別安全 |
| **離線快取** | 將 API 資料快取至本機（`sqflite` 或 `hive`），支援離線瀏覽 |
| **搜尋功能** | 新增公司名稱 / 代號的即時搜尋功能 |
| **分頁載入** | 當資料量增大時，實作 lazy loading 或 pagination |
| **Widget Tests** | 補充 UI 元件的 Widget Test，驗證畫面渲染正確性 |
| **Integration Tests** | 端對端整合測試，驗證完整使用者操作流程 |
| **CI/CD** | 設定 GitHub Actions 自動執行測試與靜態分析 |
| **主題切換** | 支援 Dark Mode 與動態主題切換 |

## API 資料來源

- [台灣證券交易所 — 公開發行公司基本資料](https://openapi.twse.com.tw/v1/opendata/t187ap03_P)
