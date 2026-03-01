import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:company_info_explorer/domain/usecases/load_companies_usecase.dart';
import 'package:company_info_explorer/presentation/blocs/app/app_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/app/app_event.dart';
import 'package:company_info_explorer/presentation/blocs/app/app_state.dart';
import '../../helpers/test_data.dart';

class MockLoadCompaniesUseCase extends Mock implements LoadCompaniesUseCase {}

void main() {
  late MockLoadCompaniesUseCase mockUseCase;
  setUp(() {
    mockUseCase = MockLoadCompaniesUseCase();
  });

  group('AppBloc', () {
    blocTest<AppBloc, AppState>(
      'emits [AppLoading, AppLoaded] when AppStarted succeeds',
      build: () {
        when(() => mockUseCase()).thenAnswer((_) async => testCompanies);
        return AppBloc(loadCompanies: mockUseCase);
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [isA<AppLoading>(), isA<AppLoaded>()],
      verify: (_) {
        verify(() => mockUseCase()).called(1);
      },
    );

    blocTest<AppBloc, AppState>(
      'emits [AppLoading, AppError] when AppStarted fails',
      build: () {
        when(() => mockUseCase()).thenThrow(Exception('Network error'));
        return AppBloc(loadCompanies: mockUseCase);
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [isA<AppLoading>(), isA<AppError>()],
    );
  });
}
