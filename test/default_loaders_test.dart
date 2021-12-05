import 'package:asset_builder/src/default_loaders.dart';
import 'package:asset_data/asset_data.dart';
import 'package:build/build.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import 'default_loaders_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<BuildStep>(fallbackGenerators: {#trackStage: trackStageShim})
])
void main() {
  group('loadBinary', () {
    late AssetIdMock asset;
    late ConstantReaderMock options;
    late BuildStep buildStep;
    late Future<List<int>> Function(List<int> source) encodeAndDecode;
    setUp(() {
      asset = AssetIdMock();
      options = ConstantReaderMock();
      buildStep = MockBuildStep();
      encodeAndDecode = (source) async {
        when(buildStep.readAsBytes(asset))
            .thenAnswer((_) => Future.value(source));

        final encoded = await loadBinary(buildStep, asset, options);
        return BinaryAsset(AssetData('', encoded)).decode().toList();
      };
    });

    test('handles files with length % 4 == 0', () async {
      final source = ''.codeUnits;
      final result = await encodeAndDecode(source);

      expect(result, equals(source));
    });

    test('handles files with length % 4 == 1', () async {
      final source = 'A'.codeUnits;
      final result = await encodeAndDecode(source);

      expect(result, equals(source));
    });

    test('handles files with length % 4 == 2', () async {
      final source = 'AB'.codeUnits;
      final result = await encodeAndDecode(source);

      expect(result, equals(source));
    });

    test('handles files with length % 4 == 3', () async {
      final source = 'ABC'.codeUnits;
      final result = await encodeAndDecode(source);

      expect(result, equals(source));
    });
  });
}

// ignore: avoid_implementing_value_types
class AssetIdMock extends Mock implements AssetId {}

class ConstantReaderMock extends Mock implements ConstantReader {}

T trackStageShim<T>(String? label, T Function()? action,
    {bool? isExternal = false}) {
  throw Exception('not supported');
}
