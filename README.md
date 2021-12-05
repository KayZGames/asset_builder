Embed assets into Dart code using `asset_data` and `asset_builder`. Created because `aspen` is no longer maintained.

```dart
@Asset('asset:package/assets/shader/')
const shaders = DirAsset<TextAsset, Shaders>(_shaders$asset);
@Asset('asset:package/assets/img/assets.json')
const assetJson = JsonAsset(_assetJson$asset);
@Asset('asset:package/assets/img/assets.png')
const assetPng = BinaryAsset(_assetPng$asset);
@Asset('asset:package/CHANGELOG.md')
const changelogMd = TextAsset(_changelogMd$asset);
```
