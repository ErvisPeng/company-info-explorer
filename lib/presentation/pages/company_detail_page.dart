import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/di/injection_container.dart' as di;
import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/core/utils/number_formatter.dart';
import 'package:company_info_explorer/core/utils/par_value_parser.dart';
import 'package:company_info_explorer/core/utils/date_formatter.dart';
import 'package:company_info_explorer/core/utils/url_launcher_helper.dart';
import 'package:company_info_explorer/presentation/blocs/company_detail/company_detail_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/company_detail/company_detail_event.dart';
import 'package:company_info_explorer/presentation/blocs/company_detail/company_detail_state.dart';

class CompanyDetailPage extends StatelessWidget {
  final Company company;
  final String industryName;
  final List<Company> allCompanies;

  const CompanyDetailPage({
    super.key,
    required this.company,
    required this.industryName,
    required this.allCompanies,
  });

  void _showWatchlistDialog(
    BuildContext context,
    bool isWatched,
  ) {
    final label = '${company.stockCode} ${company.shortName}';
    final title = isWatched ? '移除追蹤' : '加入追蹤';
    final content = isWatched
        ? '是否將 $label 從追蹤列表中移除？'
        : '是否將 $label 加入追蹤列表內？';
    final confirmText = isWatched ? '移除' : '加入';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<CompanyDetailBloc>().add(
                    ToggleWatchlist(company.stockCode, isWatched),
                  );
              Navigator.of(dialogContext).pop();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<CompanyDetailBloc>()
        ..add(LoadCompanyDetail(company.stockCode)),
      child: BlocBuilder<CompanyDetailBloc, CompanyDetailState>(
        builder: (context, state) {
          final isWatched =
              state is CompanyDetailLoaded ? state.isWatched : false;

          return Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    industryName,
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    '${company.stockCode} ${company.shortName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isWatched ? Icons.star : Icons.star_border,
                    color: isWatched ? Colors.amber : null,
                  ),
                  onPressed: () {
                    _showWatchlistDialog(context, isWatched);
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildDetailContent(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context) {
    final issuedShares = calculateIssuedShares(
      company.paidInCapital,
      company.parValue,
      company.specialShares,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company full name + website
        Row(
          children: [
            Expanded(
              child: Text(
                company.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (company.website != null && company.website!.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.language, color: Colors.blue),
                onPressed: () => openWebsite(company.website!),
                tooltip: '開啟公司網站',
              ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        _buildInfoRow('董事長', company.chairman),
        _buildInfoRow('總經理', company.generalManager),
        _buildInfoRow('產業類別', industryName),
        const Divider(),
        _buildInfoRow('成立日期', formatDate(company.foundedDate)),
        _buildInfoRow('上市日期', formatDate(company.listedDate)),
        const Divider(),
        _buildInfoRow('電話', company.phone),
        _buildInfoRow('統一編號', company.taxId),
        _buildInfoRow('地址', company.address),
        const Divider(),
        _buildInfoRow(
          '實收資本額',
          '${formatWithCommas(company.paidInCapital)} 元',
        ),
        _buildInfoRow('每股面額', company.parValueDesc),
        _buildInfoRow(
          '已發行普通股數',
          '${formatWithCommas(issuedShares)} 股'
          '（含私募 ${formatWithCommas(company.privateShares)} 股）',
        ),
        if (company.specialShares > 0)
          _buildInfoRow(
            '特別股',
            '${formatWithCommas(company.specialShares)} 股',
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
