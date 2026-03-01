import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/di/injection_container.dart' as di;
import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/presentation/blocs/industry_list/industry_list_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/industry_list/industry_list_event.dart';
import 'package:company_info_explorer/presentation/blocs/industry_list/industry_list_state.dart';
import 'package:company_info_explorer/presentation/pages/company_list_page.dart';

class IndustryListPage extends StatelessWidget {
  final List<Company> companies;

  const IndustryListPage({super.key, required this.companies});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          di.sl<IndustryListBloc>()..add(LoadIndustries(companies)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '產業別',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<IndustryListBloc, IndustryListState>(
          builder: (context, state) {
            if (state is IndustryListLoaded) {
              return ListView.separated(
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
                            companies: companies,
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
        ),
      ),
    );
  }
}
