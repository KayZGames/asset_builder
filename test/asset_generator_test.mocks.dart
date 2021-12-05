// Mocks generated by Mockito 5.0.16 from annotations
// in asset_builder/test/asset_generator_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i7;
import 'dart:convert' as _i9;

import 'package:analyzer/dart/element/element.dart' as _i3;
import 'package:build/src/analyzer/resolver.dart' as _i4;
import 'package:build/src/asset/id.dart' as _i2;
import 'package:build/src/builder/build_step.dart' as _i6;
import 'package:build/src/resource/resource.dart' as _i8;
import 'package:crypto/crypto.dart' as _i5;
import 'package:glob/glob.dart' as _i11;
import 'package:mockito/mockito.dart' as _i1;

import 'asset_generator_test.dart' as _i10;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeAssetId_0 extends _i1.Fake implements _i2.AssetId {}

class _FakeLibraryElement_1 extends _i1.Fake implements _i3.LibraryElement {}

class _FakeResolver_2 extends _i1.Fake implements _i4.Resolver {}

class _FakeDigest_3 extends _i1.Fake implements _i5.Digest {}

/// A class which mocks [BuildStep].
///
/// See the documentation for Mockito's code generation for more information.
class MockBuildStep extends _i1.Mock implements _i6.BuildStep {
  MockBuildStep() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.AssetId get inputId => (super.noSuchMethod(Invocation.getter(#inputId),
      returnValue: _FakeAssetId_0()) as _i2.AssetId);
  @override
  _i7.Future<_i3.LibraryElement> get inputLibrary =>
      (super.noSuchMethod(Invocation.getter(#inputLibrary),
              returnValue:
                  Future<_i3.LibraryElement>.value(_FakeLibraryElement_1()))
          as _i7.Future<_i3.LibraryElement>);
  @override
  _i4.Resolver get resolver => (super.noSuchMethod(Invocation.getter(#resolver),
      returnValue: _FakeResolver_2()) as _i4.Resolver);
  @override
  Iterable<_i2.AssetId> get allowedOutputs =>
      (super.noSuchMethod(Invocation.getter(#allowedOutputs),
          returnValue: <_i2.AssetId>[]) as Iterable<_i2.AssetId>);
  @override
  _i7.Future<T> fetchResource<T>(_i8.Resource<T>? resource) =>
      (super.noSuchMethod(Invocation.method(#fetchResource, [resource]),
          returnValue: Future<T>.value(null)) as _i7.Future<T>);
  @override
  _i7.Future<void> writeAsBytes(
          _i2.AssetId? id, _i7.FutureOr<List<int>>? bytes) =>
      (super.noSuchMethod(Invocation.method(#writeAsBytes, [id, bytes]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  _i7.Future<void> writeAsString(
          _i2.AssetId? id, _i7.FutureOr<String>? contents,
          {_i9.Encoding? encoding = const _i9.Utf8Codec()}) =>
      (super.noSuchMethod(
          Invocation.method(
              #writeAsString, [id, contents], {#encoding: encoding}),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i7.Future<void>);
  @override
  T trackStage<T>(String? label, T Function()? action,
          {bool? isExternal = false}) =>
      (super.noSuchMethod(
          Invocation.method(
              #trackStage, [label, action], {#isExternal: isExternal}),
          returnValue: _i10.trackStageShim<T>(label, action,
              isExternal: isExternal)) as T);
  @override
  void reportUnusedAssets(Iterable<_i2.AssetId>? ids) =>
      super.noSuchMethod(Invocation.method(#reportUnusedAssets, [ids]),
          returnValueForMissingStub: null);
  @override
  String toString() => super.toString();
  @override
  _i7.Future<List<int>> readAsBytes(_i2.AssetId? id) => (super.noSuchMethod(
      Invocation.method(#readAsBytes, [id]),
      returnValue: Future<List<int>>.value(<int>[])) as _i7.Future<List<int>>);
  @override
  _i7.Future<String> readAsString(_i2.AssetId? id,
          {_i9.Encoding? encoding = const _i9.Utf8Codec()}) =>
      (super.noSuchMethod(
          Invocation.method(#readAsString, [id], {#encoding: encoding}),
          returnValue: Future<String>.value('')) as _i7.Future<String>);
  @override
  _i7.Future<bool> canRead(_i2.AssetId? id) =>
      (super.noSuchMethod(Invocation.method(#canRead, [id]),
          returnValue: Future<bool>.value(false)) as _i7.Future<bool>);
  @override
  _i7.Stream<_i2.AssetId> findAssets(_i11.Glob? glob) =>
      (super.noSuchMethod(Invocation.method(#findAssets, [glob]),
          returnValue: Stream<_i2.AssetId>.empty()) as _i7.Stream<_i2.AssetId>);
  @override
  _i7.Future<_i5.Digest> digest(_i2.AssetId? id) =>
      (super.noSuchMethod(Invocation.method(#digest, [id]),
              returnValue: Future<_i5.Digest>.value(_FakeDigest_3()))
          as _i7.Future<_i5.Digest>);
}