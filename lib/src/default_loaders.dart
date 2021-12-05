import 'dart:convert';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

typedef Loader = Future<String> Function(
    BuildStep step, AssetId asset, ConstantReader options);

Future<String> loadText(
        BuildStep buildStep, AssetId asset, ConstantReader options) =>
    buildStep.readAsString(asset);

Future<String> loadBinary(
    BuildStep buildStep, AssetId asset, ConstantReader options) async {
  final bytes = List<int>.from(await buildStep.readAsBytes(asset));
  return base64Encode(bytes);
}

final defaultLoaders = <String, Loader>{
  'TextAsset': loadText,
  'BinaryAsset': loadBinary,
};
