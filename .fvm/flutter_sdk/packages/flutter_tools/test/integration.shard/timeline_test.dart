// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.8

import 'dart:async';

import 'package:file/file.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

import '../src/common.dart';
import 'test_data/basic_project.dart';
import 'test_driver.dart';
import 'test_utils.dart';

void main() {
  Directory tempDir;
  FlutterRunTestDriver flutter;
  VmService vmService;

  setUp(() async {
    tempDir = createResolvedTempDirectorySync('vmservice_integration_test.');

    final BasicProjectWithTimelineTraces project =
        BasicProjectWithTimelineTraces();
    await project.setUpIn(tempDir);

    flutter = FlutterRunTestDriver(tempDir);
    await flutter.run(withDebugger: true);
    final int port = flutter.vmServicePort;
    vmService = await vmServiceConnectUri('ws://localhost:$port/ws');
  });

  tearDown(() async {
    await flutter?.stop();
    tryToDelete(tempDir);
  });

  // Regression test for https://github.com/flutter/flutter/issues/79498
  testWithoutContext(
      'Can connect to the timeline without getting ANR from the application',
      () async {
    final Timer timer = Timer(const Duration(minutes: 5), () {
      print(
          'Warning: test isolate is still active after 5 minutes. This is likely an '
          'app-not-responding error and not a flake. See https://github.com/flutter/flutter/issues/79498 '
          'for the bug this test is attempting to exercise.');
    });

    // Subscribe to all available streams.
    await Future.wait(<Future<void>>[
      vmService.streamListen(EventStreams.kVM),
      vmService.streamListen(EventStreams.kIsolate),
      vmService.streamListen(EventStreams.kDebug),
      vmService.streamListen(EventStreams.kGC),
      vmService.streamListen(EventStreams.kExtension),
      vmService.streamListen(EventStreams.kTimeline),
      vmService.streamListen(EventStreams.kLogging),
      vmService.streamListen(EventStreams.kService),
      vmService.streamListen(EventStreams.kHeapSnapshot),
      vmService.streamListen(EventStreams.kStdout),
      vmService.streamListen(EventStreams.kStderr),
    ]);

    // Verify that the app can be interacted with by querying the brightness
    // for 30 seconds. Once this time has elapsed, wait for any pending requests and
    // exit. If the app stops responding, the requests made will hang.
    bool interactionCompleted = false;
    Timer(const Duration(seconds: 30), () {
      interactionCompleted = true;
    });
    final Isolate isolate =
        await waitForExtension(vmService, 'ext.flutter.brightnessOverride');
    while (!interactionCompleted) {
      final Response response = await vmService.callServiceExtension(
        'ext.flutter.brightnessOverride',
        isolateId: isolate.id,
      );
      expect(response.json['value'], 'Brightness.light');
    }
    timer.cancel();
  });
}