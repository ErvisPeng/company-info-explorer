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
    return Scaffold(
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
    );
  }
}
