import 'package:dartz/dartz.dart';
import 'package:flutter_clean_architecture_reso_coder/core/error/failures.dart';
import 'package:flutter_clean_architecture_reso_coder/core/usecases/usecase.dart';
import 'package:flutter_clean_architecture_reso_coder/core/util/input_converter.dart';
import 'package:flutter_clean_architecture_reso_coder/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_clean_architecture_reso_coder/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:flutter_clean_architecture_reso_coder/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:flutter_clean_architecture_reso_coder/features/number_trivia/presentation/bloc/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<GetConcreteNumberTrivia>(),
  MockSpec<GetRandomNumberTrivia>(),
  MockSpec<InputConverter>(),
])
void main() {
  late NumberTriviaBloc bLoC;
  late MockGetConcreteNumberTrivia concreteNumberTrivia;
  late MockGetRandomNumberTrivia randomNumberTrivia;
  late MockInputConverter inputConverter;

  setUp(() {
    concreteNumberTrivia = MockGetConcreteNumberTrivia();
    randomNumberTrivia = MockGetRandomNumberTrivia();
    inputConverter = MockInputConverter();
    bLoC = NumberTriviaBloc(
      getConcreteNumberTrivia: concreteNumberTrivia,
      getRandomNumberTrivia: randomNumberTrivia,
      inputConverter: inputConverter,
    );
  });

  test('initialState should be empty', () {
    expect(bLoC.state, Empty());
    // expectLater(
    //   bLoC.stream.asBroadcastStream(),
    //   emitsInOrder([Error(message: INVALID_INPUT_FAILURE_MESSAGE)]),
    // );
  });

  void setUpInputConversionSuccess(int tNumber) {
    when(inputConverter.stringToUnsignedInteger(any))
        .thenReturn(Right(tNumber));
  }

  void setUpInputConversionFailure() {
    when(inputConverter.stringToUnsignedInteger(any))
        .thenReturn(Left(InvalidInputFailure()));
  }

  group('GetTriviaForConcreteNumberEvent', () {
    const tNumberString = '1';
    const tNumber = 1;
    const tNumberTrivia = NumberTrivia(number: tNumber, text: 'Test Trivia');

    test(
      'should call the input converter to validate and convert the string to '
      'an unsigned int',
      () async* {
        setUpInputConversionSuccess(tNumber);
        bLoC.add(GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(inputConverter.stringToUnsignedInteger(any));
        verify(inputConverter.stringToUnsignedInteger(tNumberString));
        verifyNoMoreInteractions(inputConverter);
      },
    );

    test(
      'should emit [Error] when the input is invalid',
      () async* {
        setUpInputConversionFailure();
        await expectLater(
          bLoC.stream.asBroadcastStream(),
          emitsInOrder([Error(message: INVALID_INPUT_FAILURE_MESSAGE)]),
        );

        bLoC.add(GetTriviaForConcreteNumber(tNumberString));
      },
      timeout: const Timeout(Duration(milliseconds: 1500)),
    );

    test(
      'should get data from the concrete use case',
      () async {
        setUpInputConversionSuccess(tNumber);
        when(concreteNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));

        bLoC.add(GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(concreteNumberTrivia(any));

        verify(concreteNumberTrivia(const Params(number: tNumber)));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async* {
        setUpInputConversionSuccess(tNumber);
        when(concreteNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        await expectLater(
          bLoC.stream.asBroadcastStream(),
          emitsInOrder([Empty(), Loading(), Loaded(trivia: tNumberTrivia)]),
        );
        bLoC.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test('should emits [Loading, Loaded] when data is gotten successfully',
        () async* {
      //arrange
      when(randomNumberTrivia(any))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      //assert later
      final expected = [Empty(), Loading(), Loaded(trivia: tNumberTrivia)];
      expectLater(bLoC, emitsInOrder(expected));
      //act
      bLoC.add(GetTriviaForRandomNumber());
    });
    test(
      'should emit [Loading, Error] when getting data fails',
      () async* {
        setUpInputConversionSuccess(tNumber);
        when(concreteNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        await expectLater(
          bLoC.stream.asBroadcastStream(),
          emitsInOrder([Loading(), Error(message: SERVER_FAILURE_MESSAGE)]),
        );
        bLoC.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test('should emits [Loading, Error] when getting data fails', () async* {
      //arrange
      when(randomNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      //assert later
      final expected = [
        Empty(),
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE)
      ];
      expectLater(bLoC, emitsInOrder(expected));
      //act
      bLoC.add(GetTriviaForRandomNumber());
    });
    test(
      'should emit [Loading, Error] with the proper message when getting '
      'data fails',
      () async* {
        setUpInputConversionSuccess(tNumber);
        when(concreteNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
        await expectLater(
          bLoC.stream.asBroadcastStream(),
          emitsInOrder([Loading(), Error(message: CACHE_FAILURE_MESSAGE)]),
        );
        bLoC.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );
  });

  group('GetTriviaForRandomNumberEvent', () {
    const tNumberTrivia = NumberTrivia(number: 1, text: 'Test Trivia');

    test(
      'should get data from the random use case',
      () async {
        when(randomNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        bLoC.add(GetTriviaForRandomNumber());
        await untilCalled(randomNumberTrivia(any));
        verify(randomNumberTrivia(NoParams()));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully ',
      () async* {
        when(randomNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        await expectLater(
          bLoC.stream.asBroadcastStream(),
          emitsInOrder([Empty(), Loading(), Loaded(trivia: tNumberTrivia)]),
        );
        bLoC.add(GetTriviaForRandomNumber());
      },
    );

    test(
      'should emit [Loading, Error] when getting data fails',
      () async* {
        when(randomNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        await expectLater(
          bLoC.stream.asBroadcastStream(),
          emitsInOrder([Loading(), Error(message: SERVER_FAILURE_MESSAGE)]),
        );
        bLoC.add(GetTriviaForRandomNumber());
      },
    );

    test(
      'should emit [Loading, Error] with the proper message when getting '
      'data fails',
      () async* {
        when(randomNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
        await expectLater(
          bLoC.stream.asBroadcastStream(),
          emitsInOrder([Loading(), Error(message: CACHE_FAILURE_MESSAGE)]),
        );
        bLoC.add(GetTriviaForRandomNumber());
      },
    );
  });
}
