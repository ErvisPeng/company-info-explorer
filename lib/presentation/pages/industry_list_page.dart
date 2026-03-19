import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/di/injection_container.dart' as di;
import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/core/constants/industry_codes.dart';
import 'package:company_info_explorer/presentation/blocs/industry_list/industry_list_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/industry_list/industry_list_event.dart';
import 'package:company_info_explorer/presentation/blocs/industry_list/industry_list_state.dart';
import 'package:company_info_explorer/presentation/blocs/stock_search/stock_search_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/stock_search/stock_search_event.dart';
import 'package:company_info_explorer/presentation/blocs/stock_search/stock_search_state.dart';
import 'package:company_info_explorer/presentation/pages/company_detail_page.dart';
import 'package:company_info_explorer/presentation/pages/company_list_page.dart';

class IndustryListPage extends StatefulWidget {
  final List<Company> companies;

  const IndustryListPage({super.key, required this.companies});

  @override
  State<IndustryListPage> createState() => _IndustryListPageState();
}

class _IndustryListPageState extends State<IndustryListPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  late final IndustryListBloc _industryListBloc;
  late final StockSearchBloc _stockSearchBloc;

  @override
  void initState() {
    super.initState();
    _industryListBloc = di.sl<IndustryListBloc>()
      ..add(LoadIndustries(widget.companies));
    _stockSearchBloc = di.sl<StockSearchBloc>();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _industryListBloc.close();
    _stockSearchBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _industryListBloc),
        BlocProvider.value(value: _stockSearchBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '產業別',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            _buildSearchField(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          filled: true,
          fillColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (suffixContext, value, _) {
              return value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _stockSearchBloc.add(const ClearSearch());
                        FocusScope.of(suffixContext).unfocus();
                      },
                    )
                  : const SizedBox.shrink();
            },
          ),
          hintText: '搜尋股票代號或公司名稱',
        ),
        onChanged: (value) {
          _debounceTimer?.cancel();
          if (value.isEmpty) {
            _stockSearchBloc.add(const ClearSearch());
            return;
          }
          _debounceTimer = Timer(
            const Duration(milliseconds: 300),
            () {
              if (!mounted) return;
              _stockSearchBloc
                  .add(SearchStocks(value, widget.companies));
            },
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<StockSearchBloc, StockSearchState>(
      builder: (context, searchState) {
        if (searchState is StockSearchResults) {
          return _buildSearchResults(context, searchState.results);
        }
        if (searchState is StockSearchEmpty) {
          return Center(
            child: Text(
              '查無「${searchState.query}」相關結果',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }
        // StockSearchInitial → show industry list
        return _buildIndustryList(context);
      },
    );
  }

  Widget _buildIndustryList(BuildContext context) {
    return BlocBuilder<IndustryListBloc, IndustryListState>(
      builder: (context, state) {
        if (state is IndustryListLoaded) {
          return ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: state.industries.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final industry = state.industries[index];
              return ListTile(
                title: Text(
                  '${industry.name}(${industry.companyCount})',
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CompanyListPage(
                        companies: widget.companies,
                        industryCode: industry.code,
                        industryName: industry.name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    List<Company> results,
  ) {
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final company = results[index];
        return ListTile(
          title: Text(
            '${company.stockCode}  ${company.shortName}',
            style: const TextStyle(fontSize: 16),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                industryCodeToName[company.industryCode] ?? '',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {
            final industryName =
                industryCodeToName[company.industryCode] ?? '';
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CompanyDetailPage(
                  company: company,
                  industryName: industryName,
                  allCompanies: widget.companies,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
