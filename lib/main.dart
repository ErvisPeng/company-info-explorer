import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/di/injection_container.dart' as di;
import 'package:company_info_explorer/presentation/blocs/app/app_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/app/app_event.dart';
import 'package:company_info_explorer/presentation/pages/launch_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AppBloc>()..add(AppStarted()),
      child: MaterialApp(
        title: '公司基本資料查詢',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const LaunchPage(),
      ),
    );
  }
}
