import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/asset_generator.dart';

Builder assetBuilder(_) =>
    SharedPartBuilder([AssetGenerator()], 'asset_builder');
