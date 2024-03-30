import 'dart:convert';

import 'package:flutter_clean_architecture_reso_coder/core/error/exceptions.dart';
import 'package:flutter_clean_architecture_reso_coder/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:flutter_clean_architecture_reso_coder/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_local_data_source_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SharedPreferences>()])
void main() {
  late NumberTriviaLocalDataSourceImpl dataSourceImpl;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    dataSourceImpl =
        NumberTriviaLocalDataSourceImpl(sharedPreferences: mockPrefs);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      jsonDecode(fixture('trivia.json')) as Map<String, dynamic>,
    );
    test(
        'should return NumberTriviaModel from Shared Preferences when one exists in cache',
        () async {
      when(mockPrefs.getString(any)).thenReturn(fixture('trivia.json'));
      final result = await dataSourceImpl.getLastNumberTrivia();
      expect(result, equals(tNumberTriviaModel));
      verify(mockPrefs.getString(CACHED_NUMBER_TRIVIA));
    });

    test(
        'should throw a CacheException when there is no NumberTriviaModel in cache',
        () async {
      when(mockPrefs.getString(any)).thenReturn(null);
      final call = dataSourceImpl.getLastNumberTrivia;
      expect(call, throwsA(const TypeMatcher<CacheException>()));
      verify(mockPrefs.getString(CACHED_NUMBER_TRIVIA));
    });
  });

  group('cacheNumberTrivia', () {
    const tNumberTriviaModel =
        NumberTriviaModel(number: 1, text: 'Test Trivia');
    test('should call SharedPreferences to cache the data', () {
      dataSourceImpl.cacheNumberTrivia(tNumberTriviaModel);
      verify(
        mockPrefs.setString(
          CACHED_NUMBER_TRIVIA,
          jsonEncode(tNumberTriviaModel),
        ),
      );
    });
  });
}
