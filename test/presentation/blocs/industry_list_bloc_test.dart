import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:company_info_explorer/domain/usecases/get_industries_usecase.dart';
import 'package:company_info_explorer/presentation/blocs/industry_list/industry_list_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/industry_list/industry_list_event.dart';
import 'package:company_info_explorer/presentation/blocs/industry_list/industry_list_state.dart';
import '../../helpers/test_data.dart';

void main() {
  group('IndustryListBloc', () {
    blocTest<IndustryListBloc, IndustryListState>(
      'emits [IndustryListLoaded] with grouped industries',
      build: () => IndustryListBloc(getIndustries: GetIndustriesUseCase()),
      act: (bloc) => bloc.add(LoadIndustries(testCompanies)),
      expect: () => [
        isA<IndustryListLoaded>()
            .having((s) => s.industries.length, 'industry count', 2),
      ],
    );
  });
}
