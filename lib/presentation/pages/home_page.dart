import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/di/injection_container.dart' as di;
import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/presentation/blocs/watchlist/watchlist_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/watchlist/watchlist_event.dart';
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
  late final WatchlistBloc _watchlistBloc;

  @override
  void initState() {
    super.initState();
    _watchlistBloc = di.sl<WatchlistBloc>();
    _watchlistBloc.add(LoadWatchlist(widget.companies));
  }

  @override
  void dispose() {
    _watchlistBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _watchlistBloc,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            IndustryListPage(companies: widget.companies),
            WatchlistPage(allCompanies: widget.companies),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 1) {
              _watchlistBloc.add(LoadWatchlist(widget.companies));
            }
          },
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
      ),
    );
  }
}
