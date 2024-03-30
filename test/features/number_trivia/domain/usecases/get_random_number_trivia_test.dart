import 'package:dartz/dartz.dart';
import 'package:flutter_clean_architecture_reso_coder/core/usecases/usecase.dart';
import 'package:flutter_clean_architecture_reso_coder/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_clean_architecture_reso_coder/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:flutter_clean_architecture_reso_coder/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_random_number_trivia_test.mocks.dart';

@GenerateNiceMocks([MockSpec<NumberTriviaRepository>()])
void main() {
  late MockNumberTriviaRepository repo;
  late GetRandomNumberTrivia useCase;

  setUp(() {
    repo = MockNumberTriviaRepository();
    useCase = GetRandomNumberTrivia(repo);
  });

  const testNumberTrivia = NumberTrivia(number: 1, text: 'test');

  test('get trivia for a random number from the repo', () async {
    when(repo.getRandomNumberTrivia())
        .thenAnswer((_) async => const Right(testNumberTrivia));

    final result = await useCase(NoParams());

    expect(result, const Right(testNumberTrivia));
    verify(repo.getRandomNumberTrivia());
    verifyNoMoreInteractions(repo);
  });
}
