import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/app/app_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/app/app_event.dart';
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
                return _buildError(context, state.message);
              }
              return _buildLoading();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.business_center,
          size: 120,
          color: Colors.grey,
        ),
        SizedBox(height: 32),
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text(
          '載入公司資料中...',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 80,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            context.read<AppBloc>().add(AppStarted());
          },
          icon: const Icon(Icons.refresh),
          label: const Text('重試'),
        ),
      ],
    );
  }
}
