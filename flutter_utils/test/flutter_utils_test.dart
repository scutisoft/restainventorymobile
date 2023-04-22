import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/flutter_utils_platform_interface.dart';
import 'package:flutter_utils/flutter_utils_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';



void main() {
  final FlutterUtilsPlatform initialPlatform = FlutterUtilsPlatform.instance;

  test('$MethodChannelFlutterUtils is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterUtils>());
  });

}
