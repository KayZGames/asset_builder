import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:asset_data/asset_data.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

import 'default_loaders.dart';

class AssetGenerator extends GeneratorForAnnotation<Asset> {
  AssetGenerator();

  void error(Element element, String error) {
    log.severe(spanForElement(element).message(error));
  }

  String getAssetTypeName(VariableElement variableElement) {
    final type = variableElement.computeConstantValue()?.type;
    if (type is! InterfaceType) {
      error(variableElement,
          '@Asset(...) ${variableElement.displayName} has an invalid type');
      return '';
    }

    InterfaceType? current = type;
    while (current != null && current.superclass != null) {
      final displayName = current.element.displayName;
      if (displayName == 'TextAsset' || displayName == 'BinaryAsset') {
        return displayName;
      }
      current = current.superclass;
    }

    error(variableElement,
        '''Asset type ${type.getDisplayString(withNullability: false)} is no FileAsset''');
    return '';
  }

  @override
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element is! VariableElement) {
      error(element, '@Asset(...) may only be used on variables');
      return '';
    }

    final value = element.computeConstantValue();
    if (value == null) {
      error(element,
          '@Asset(...) ${element.displayName} must have a constant value');
      return '';
    }

    final assetPathReader = _getAssetPathReader(annotation);
    final assetPath = Uri.parse(assetPathReader.stringValue);

    if (element.type.element?.name == 'DirAsset') {
      final assetDirId = AssetId.resolve(assetPath, from: buildStep.inputId);
      if (buildStep.inputId.package != assetDirId.package) {
        error(element,
            '''DirAsset only works for the current package (current: ${buildStep.inputId.package}, requested: ${assetDirId.package})''');
        return '';
      }
      var assetDirPath = assetDirId.path;
      final firstIndexOfWildcard = assetDirPath.indexOf('*');
      if (firstIndexOfWildcard == -1) {
        assetDirPath = '$assetDirPath/*.*';
      }

      final assetType =
          (element.type as InterfaceType).typeArguments[0] as InterfaceType;
      final assetTypeName = assetType.element.displayName;

      final enumName =
          '${element.name[0].toUpperCase()}${element.name.substring(1)}';
      final enumValues = <String, AssetData>{};
      final enumValueSanitzerRegExp = RegExp('[^a-zA-Z0-9]');

      final assetIds = (await buildStep.findAssets(Glob(assetDirPath)).toList())
        ..sort();
      for (final assetId in assetIds) {
        var enumValue = p
            .basenameWithoutExtension(assetId.path)
            .replaceAll(enumValueSanitzerRegExp, '');
        final extension = p.extension(assetId.path);
        if (extension.isNotEmpty) {
          enumValue =
              '''$enumValue\$${extension.replaceAll(enumValueSanitzerRegExp, '')}''';
        }
        enumValues[enumValue] = await _loadAssetData(
            assetTypeName, buildStep, assetId, element, value);
      }

      return Future.value('''
enum $enumName {
  ${enumValues.keys.join(', ')}
}
const _${element.name}\$asset = {
  ${enumValues.entries.map((entry) => "$enumName.${entry.key}: ${assetType.element.name}(AssetData(r'${entry.value.id}', r'''${entry.value.content}'''))").join(',\n  ')}
};
''');
    } else {
      final assetId = AssetId.resolve(assetPath, from: buildStep.inputId);
      final assetTypeName = getAssetTypeName(element);
      final assetData = await _loadAssetData(
          assetTypeName, buildStep, assetId, element, value);

      return Future.value(
          """const _${element.name}\$asset = AssetData(r'${assetData.id}', r'''${assetData.content}''');""");
    }
  }

  Future<AssetData> _loadAssetData(String assetTypeName, BuildStep buildStep,
      AssetId assetId, Element element, DartObject value) async {
    final assetIdString = assetId.toString();
    if (assetTypeName.isEmpty) {
      return AssetData(assetIdString, '');
    }

    if (!await buildStep.canRead(assetId)) {
      error(element, 'Asset $assetId cannot be found');
      return AssetData(assetIdString, '');
    }

    final loader = defaultLoaders[assetTypeName];
    if (loader != null) {
      final content = await loader(buildStep, assetId, ConstantReader(value));
      return AssetData(assetIdString, content);
    }
    error(element, 'Loader for $assetTypeName does not exist');
    return AssetData(assetIdString, '');
  }

  ConstantReader _getAssetPathReader(ConstantReader annotation) =>
      annotation.read('path');
}
