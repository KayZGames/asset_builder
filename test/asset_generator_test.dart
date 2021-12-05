import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:asset_builder/src/asset_generator.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:glob/glob.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import 'asset_generator_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<BuildStep>(fallbackGenerators: {#trackStage: trackStageShim})
])
void main() {
  group('AssetGenerator', () {
    late AssetGenerator generator;
    late MockBuildStep buildStep;

    setUp(() async {
      generator = AssetGenerator();
      buildStep = MockBuildStep();

      when(buildStep.inputId).thenReturn(AssetIdMock());
    });

    test('creates TextAsset', () async {
      final assetId = resolveAssetId('asset:packageName/assets//textAsset.txt');
      when(buildStep.canRead(assetId)).thenAnswer((_) => Future.value(true));
      when(buildStep.readAsString(assetId))
          .thenAnswer((_) => Future.value('content of textAsset.txt'));

      final result = await generate(textAsset, generator, buildStep);

      expect(
          result,
          equals(
              r"const _textAsset$asset = AssetData(r'packageName|assets/textAsset.txt', r'''content of textAsset.txt''');"));
    });

    test('creates BinaryAsset', () async {
      final assetId =
          resolveAssetId('asset:packageName/assets/binaryAsset.jpg');
      final fileContent = 'this is binary content'.codeUnits;
      final encoded = base64Encode(fileContent);
      when(buildStep.canRead(assetId)).thenAnswer((_) => Future.value(true));
      when(buildStep.readAsBytes(assetId))
          .thenAnswer((_) => Future.value(fileContent));

      final result = await generate(binaryAsset, generator, buildStep);

      expect(
          result,
          equals(
              "const _binaryAsset\$asset = AssetData(r'packageName|assets/binaryAsset.jpg', r'''$encoded''');"));
    });

    test('creates JsonAsset', () async {
      final assetId = resolveAssetId('asset:packageName/assets/jsonAsset.json');
      when(buildStep.canRead(assetId)).thenAnswer((_) => Future.value(true));
      when(buildStep.readAsString(assetId))
          .thenAnswer((_) => Future.value('["jsonAsset": true]'));

      final result = await generate(jsonAsset, generator, buildStep);

      expect(
          result,
          equals(
              // ignore: missing_whitespace_between_adjacent_strings
              r"const _jsonAsset$asset = AssetData(r'packageName|assets/jsonAsset.json', r'''["
              '"jsonAsset"'
              ": true]''');"));
    });

    group('creates DirAsset', () {
      test('with TextAssets', () async {
        mockFindAssets(buildStep, 'asset:packageName/assets/textAsset.txt',
            'content of textAsset.txt');

        final result = await generate(textAssetDir, generator, buildStep);

        expect(result, equals('''
enum MyAssets {
  textAsset\$txt
}
const _myAssets\$asset = {
  MyAssets.textAsset\$txt: TextAsset(AssetData(r'packageName|assets/textAsset.txt', r\'\'\'content of textAsset.txt\'\'\'))
};'''));
      });

      test('with TextAssets without wildcards in path defaults to path/*.*',
          () async {
        mockFindAssets(buildStep, 'asset:packageName/assets/textAsset.txt',
            'content of textAsset.txt');

        final result =
            await generate(textAssetDirWithoutWildcards, generator, buildStep);

        expect(result, equals('''
enum MyAssets {
  textAsset\$txt
}
const _myAssets\$asset = {
  MyAssets.textAsset\$txt: TextAsset(AssetData(r'packageName|assets/textAsset.txt', r\'\'\'content of textAsset.txt\'\'\'))
};'''));
      });

      test('sanitizes the enum value identifier', () async {
        mockFindAssets(
            buildStep,
            'asset:packageName/assets/textAsset Final 2020-11-05 (Copy 3).txt(1)',
            'content of textAsset.txt');

        final result = await generate(textAssetDir, generator, buildStep);

        expect(result, equals('''
enum MyAssets {
  textAssetFinal20201105Copy3\$txt1
}
const _myAssets\$asset = {
  MyAssets.textAssetFinal20201105Copy3\$txt1: TextAsset(AssetData(r'packageName|assets/textAsset Final 2020-11-05 (Copy 3).txt(1)', r\'\'\'content of textAsset.txt\'\'\'))
};'''));
      });

      test('handles files without extension correct', () async {
        mockFindAssets(buildStep, 'asset:packageName/assets/textAsset',
            'content of textAsset.txt');

        final result = await generate(textAssetDir, generator, buildStep);

        expect(result, equals('''
enum MyAssets {
  textAsset
}
const _myAssets\$asset = {
  MyAssets.textAsset: TextAsset(AssetData(r'packageName|assets/textAsset', r\'\'\'content of textAsset.txt\'\'\'))
};'''));
      });

      test('sorts enum values generated from files by name', () async {
        final assetId1 =
            resolveAssetId('asset:packageName/assets/level900.txt');
        final assetId2 =
            resolveAssetId('asset:packageName/assets/level100.txt');
        const content = '';
        when(buildStep.findAssets(any)).thenAnswer((realInvocation) {
          final glob = realInvocation.positionalArguments[0];
          if (glob is Glob && glob.pattern == 'assets/*.*') {
            return Stream.fromIterable([assetId1, assetId2]);
          }
          return const Stream.empty();
        });
        when(buildStep.inputId).thenReturn(assetId1);
        when(buildStep.canRead(assetId1)).thenAnswer((_) => Future.value(true));
        when(buildStep.readAsString(assetId1))
            .thenAnswer((_) => Future.value(content));
        when(buildStep.canRead(assetId2)).thenAnswer((_) => Future.value(true));
        when(buildStep.readAsString(assetId2))
            .thenAnswer((_) => Future.value(content));

        final result = await generate(textAssetDir, generator, buildStep);

        expect(result, equals(r"""
enum MyAssets {
  level100$txt, level900$txt
}
const _myAssets$asset = {
  MyAssets.level100$txt: TextAsset(AssetData(r'packageName|assets/level100.txt', r'''''')),
  MyAssets.level900$txt: TextAsset(AssetData(r'packageName|assets/level900.txt', r''''''))
};"""));
      });
    });
  });
}

AssetId resolveAssetId(String uri) => AssetId.resolve(Uri.parse(uri));

void mockFindAssets(MockBuildStep buildStep, String assetUri, String content) {
  final assetId = resolveAssetId(assetUri);
  when(buildStep.findAssets(any)).thenAnswer((realInvocation) {
    final glob = realInvocation.positionalArguments[0];
    if (glob is Glob && glob.pattern == 'assets/*.*') {
      return Stream.value(assetId);
    }
    return const Stream.empty();
  });
  when(buildStep.inputId).thenReturn(assetId);
  when(buildStep.canRead(assetId)).thenAnswer((_) => Future.value(true));
  when(buildStep.readAsString(assetId))
      .thenAnswer((_) => Future.value(content));
}

Future<String> generate(
    String source, AssetGenerator generator, BuildStep buildStep) async {
  final libraryElement = await resolveSource<LibraryElement?>(
      source, (resolver) => resolver.findLibraryByName(''));

  return await generator.generate(LibraryReader(libraryElement!), buildStep);
}

// ignore: avoid_implementing_value_types
class AssetIdMock extends Mock implements AssetId {}

T trackStageShim<T>(String? label, T Function()? action,
    {bool? isExternal = false}) {
  throw Exception('not supported');
}

const textAsset = r'''
import 'package:asset_data/asset_data.dart';

@Asset('asset:packageName/assets/textAsset.txt')
const textAsset = TextAsset(_textAsset$asset);
''';

const binaryAsset = r'''
import 'package:asset_data/asset_data.dart';

@Asset('asset:packageName/assets/binaryAsset.jpg')
const binaryAsset = BinaryAsset(_binaryAsset$asset);
''';

const jsonAsset = r'''
import 'package:asset_data/asset_data.dart';

@Asset('asset:packageName/assets/jsonAsset.json')
const jsonAsset = JsonAsset(_jsonAsset$asset);
''';

const textAssetDir = r'''
import 'package:asset_data/asset_data.dart';

@Asset('asset:packageName/assets/*.*')
const myAssets = DirAsset<TextAsset, MyAssets>(_dirAsset$asset);
''';

const textAssetDirWithoutWildcards = r'''
import 'package:asset_data/asset_data.dart';

@Asset('asset:packageName/assets')
const myAssets = DirAsset<TextAsset, MyAssets>(_dirAsset$asset);
''';
