import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/di/injection_container.dart' as di;
import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/presentation/blocs/company_list/company_list_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/company_list/company_list_event.dart';
import 'package:company_info_explorer/presentation/blocs/company_list/company_list_state.dart';
import 'package:company_info_explorer/presentation/pages/company_detail_page.dart';

class CompanyListPage extends StatelessWidget {
  final List<Company> companies;
  final String industryCode;
  final String industryName;

  const CompanyListPage({
    super.key,
    required this.companies,
    required this.industryCode,
    required this.industryName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<CompanyListBloc>()
        ..add(LoadCompanyList(companies, industryCode)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('產業別'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                industryName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<CompanyListBloc, CompanyListState>(
                builder: (context, state) {
                  if (state is CompanyListLoaded) {
                    return ListView.separated(
                      itemCount: state.companies.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final company = state.companies[index];
                        return ListTile(
                          title: Text(
                            '${company.stockCode} ${company.shortName}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CompanyDetailPage(
                                  company: company,
                                  industryName: industryName,
                                  allCompanies: companies,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
