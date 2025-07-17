import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
import 'package:comparador_cfdis/bloc/cfdi_state.dart';
import 'package:comparador_cfdis/repositories/cfdi_repository.dart';
import 'package:comparador_cfdis/models/cfdi.dart';

class MockCFDIRepository extends Mock implements CFDIRepository {}

void main() {
  late CFDIBloc cfdiBloc;
  late MockCFDIRepository mockRepository;

  setUp(() {
    mockRepository = MockCFDIRepository();
    cfdiBloc = CFDIBloc(mockRepository, {});
  });

  tearDown(() {
    cfdiBloc.close();
  });

  group('CFDIBloc', () {
    blocTest<CFDIBloc, CFDIState>(
      'emits [CFDILoading, CFDILoaded] when LoadCFDIsFromDirectory succeeds',
      build: () {
        when(() => mockRepository.loadCFDIsFromDirectory())
            .thenAnswer((_) async => [
          CFDI(
            version: '4.0',
            serie: 'A',
            folio: '123',
            total: '116.00',
          ),
        ]);
        return cfdiBloc;
      },
      act: (bloc) => bloc.add(LoadCFDIsFromDirectory()),
      expect: () => [
        CFDILoading(),
        isA<CFDILoaded>(),
      ],
    );

    blocTest<CFDIBloc, CFDIState>(
      'emits [CFDILoading, CFDIError] when LoadCFDIsFromDirectory fails',
      build: () {
        when(() => mockRepository.loadCFDIsFromDirectory())
            .thenThrow(Exception('Test error'));
        return cfdiBloc;
      },
      act: (bloc) => bloc.add(LoadCFDIsFromDirectory()),
      expect: () => [
        CFDILoading(),
        isA<CFDIError>(),
      ],
    );

    blocTest<CFDIBloc, CFDIState>(
      'emits [CFDILoading, CFDIError] when no CFDIs found',
      build: () {
        when(() => mockRepository.loadCFDIsFromDirectory())
            .thenAnswer((_) async => []);
        return cfdiBloc;
      },
      act: (bloc) => bloc.add(LoadCFDIsFromDirectory()),
      expect: () => [
        CFDILoading(),
        CFDIError('No se encontraron CFDIs en el directorio seleccionado'),
      ],
    );
  });
}
