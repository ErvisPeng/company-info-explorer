import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/di/injection_container.dart' as di;
import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/core/constants/industry_codes.dart';
import 'package:company_info_explorer/presentation/blocs/watchlist/watchlist_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/watchlist/watchlist_event.dart';
import 'package:company_info_explorer/presentation/blocs/watchlist/watchlist_state.dart';
import 'package:company_info_explorer/presentation/pages/company_detail_page.dart';

class WatchlistPage extends StatefulWidget {
  final List<Company> allCompanies;

  const WatchlistPage({super.key, required this.allCompanies});

  @override
  State<WatchlistPage> createState() => WatchlistPageState();
}

class WatchlistPageState extends State<WatchlistPage> {
  late final WatchlistBloc _watchlistBloc;

  @override
  void initState() {
    super.initState();
    _watchlistBloc = di.sl<WatchlistBloc>();
    _watchlistBloc.add(LoadWatchlist(widget.allCompanies));
  }

  @override
  void dispose() {
    _watchlistBloc.close();
    super.dispose();
  }

  void refreshWatchlist() {
    _watchlistBloc.add(LoadWatchlist(widget.allCompanies));
  }

  Future<bool> _confirmRemove(
    BuildContext context,
    Company company,
  ) async {
    final label = '${company.stockCode} ${company.shortName}';
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('移除追蹤'),
        content: Text('是否將 $label 從追蹤列表中移除？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('移除'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _watchlistBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '追蹤',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<WatchlistBloc, WatchlistState>(
          builder: (context, state) {
            if (state is WatchlistLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is WatchlistLoaded) {
              if (state.companies.isEmpty) {
                return const Center(
                  child: Text(
                    '尚無追蹤的公司',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                );
              }
              return _buildWatchlist(state.companies);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildWatchlist(List<Company> companies) {
    return ListView.separated(
      itemCount: companies.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final company = companies[index];
        return Dismissible(
          key: Key(company.stockCode),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Text(
              '移除',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          confirmDismiss: (_) => _confirmRemove(context, company),
          onDismissed: (_) {
            _watchlistBloc.add(
              RemoveFromWatchlistEvent(
                company.stockCode,
                widget.allCompanies,
              ),
            );
          },
          child: ListTile(
            title: Text(
              '${company.stockCode} ${company.shortName}',
              style: const TextStyle(fontSize: 16),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final industryName =
                  industryCodeToName[company.industryCode] ?? '';
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CompanyDetailPage(
                    company: company,
                    industryName: industryName,
                    allCompanies: widget.allCompanies,
                  ),
                ),
              );
              refreshWatchlist();
            },
          ),
        );
      },
    );
  }
}
