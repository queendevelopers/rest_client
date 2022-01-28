// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../rendering/mock_canvas.dart';
import '../widgets/semantics_tester.dart';

void main() {
  setUp(() {
    debugResetSemanticsIdCounter();
  });

  testWidgets(
      'Checkbox size is configurable by ThemeData.materialTapTargetSize',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Theme(
        data: ThemeData(materialTapTargetSize: MaterialTapTargetSize.padded),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            child: Center(
              child: Checkbox(
                value: true,
                onChanged: (bool? newValue) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(Checkbox)), const Size(48.0, 48.0));

    await tester.pumpWidget(
      Theme(
        data:
            ThemeData(materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            child: Center(
              child: Checkbox(
                value: true,
                onChanged: (bool? newValue) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(Checkbox)), const Size(40.0, 40.0));
  });

  testWidgets('CheckBox semantics', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(Material(
      child: Checkbox(
        value: false,
        onChanged: (bool? b) {},
      ),
    ));

    expect(
        tester.getSemantics(find.byType(Focus)),
        matchesSemantics(
          hasCheckedState: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
        ));

    await tester.pumpWidget(Material(
      child: Checkbox(
        value: true,
        onChanged: (bool? b) {},
      ),
    ));

    expect(
        tester.getSemantics(find.byType(Focus)),
        matchesSemantics(
          hasCheckedState: true,
          hasEnabledState: true,
          isChecked: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
        ));

    await tester.pumpWidget(const Material(
      child: Checkbox(
        value: false,
        onChanged: null,
      ),
    ));

    expect(
        tester.getSemantics(find.byType(Checkbox)),
        matchesSemantics(
          hasCheckedState: true,
          hasEnabledState: true,
          // isFocusable is delayed by 1 frame.
          isFocusable: true,
        ));

    await tester.pump();
    // isFocusable should be false now after the 1 frame delay.
    expect(
        tester.getSemantics(find.byType(Checkbox)),
        matchesSemantics(
          hasCheckedState: true,
          hasEnabledState: true,
        ));

    await tester.pumpWidget(const Material(
      child: Checkbox(
        value: true,
        onChanged: null,
      ),
    ));

    expect(
        tester.getSemantics(find.byType(Checkbox)),
        matchesSemantics(
          hasCheckedState: true,
          hasEnabledState: true,
          isChecked: true,
        ));
    handle.dispose();
  });

  testWidgets('Can wrap CheckBox with Semantics', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(Material(
      child: Semantics(
        label: 'foo',
        textDirection: TextDirection.ltr,
        child: Checkbox(
          value: false,
          onChanged: (bool? b) {},
        ),
      ),
    ));

    expect(
        tester.getSemantics(find.byType(Focus).last),
        matchesSemantics(
          label: 'foo',
          textDirection: TextDirection.ltr,
          hasCheckedState: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
        ));
    handle.dispose();
  });

  testWidgets('CheckBox tristate: true', (WidgetTester tester) async {
    bool? checkBoxValue;

    await tester.pumpWidget(
      Material(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Checkbox(
              tristate: true,
              value: checkBoxValue,
              onChanged: (bool? value) {
                setState(() {
                  checkBoxValue = value;
                });
              },
            );
          },
        ),
      ),
    );

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, null);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(checkBoxValue, false);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(checkBoxValue, true);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(checkBoxValue, null);

    checkBoxValue = true;
    await tester.pumpAndSettle();
    expect(checkBoxValue, true);

    checkBoxValue = null;
    await tester.pumpAndSettle();
    expect(checkBoxValue, null);
  });

  testWidgets('has semantics for tristate', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);
    await tester.pumpWidget(
      Material(
        child: Checkbox(
          tristate: true,
          value: null,
          onChanged: (bool? newValue) {},
        ),
      ),
    );

    expect(
        semantics.nodesWith(
          flags: <SemanticsFlag>[
            SemanticsFlag.hasCheckedState,
            SemanticsFlag.hasEnabledState,
            SemanticsFlag.isEnabled,
            SemanticsFlag.isFocusable,
          ],
          actions: <SemanticsAction>[SemanticsAction.tap],
        ),
        hasLength(1));

    await tester.pumpWidget(
      Material(
        child: Checkbox(
          tristate: true,
          value: true,
          onChanged: (bool? newValue) {},
        ),
      ),
    );

    expect(
        semantics.nodesWith(
          flags: <SemanticsFlag>[
            SemanticsFlag.hasCheckedState,
            SemanticsFlag.hasEnabledState,
            SemanticsFlag.isEnabled,
            SemanticsFlag.isChecked,
            SemanticsFlag.isFocusable,
          ],
          actions: <SemanticsAction>[SemanticsAction.tap],
        ),
        hasLength(1));

    await tester.pumpWidget(
      Material(
        child: Checkbox(
          tristate: true,
          value: false,
          onChanged: (bool? newValue) {},
        ),
      ),
    );

    expect(
        semantics.nodesWith(
          flags: <SemanticsFlag>[
            SemanticsFlag.hasCheckedState,
            SemanticsFlag.hasEnabledState,
            SemanticsFlag.isEnabled,
            SemanticsFlag.isFocusable,
          ],
          actions: <SemanticsAction>[SemanticsAction.tap],
        ),
        hasLength(1));

    semantics.dispose();
  });

  testWidgets('has semantic events', (WidgetTester tester) async {
    dynamic semanticEvent;
    bool? checkboxValue = false;
    tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
        SystemChannels.accessibility, (dynamic message) async {
      semanticEvent = message;
    });
    final SemanticsTester semanticsTester = SemanticsTester(tester);

    await tester.pumpWidget(
      Material(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Checkbox(
              value: checkboxValue,
              onChanged: (bool? value) {
                setState(() {
                  checkboxValue = value;
                });
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(Checkbox));
    final RenderObject object = tester.firstRenderObject(find.byType(Checkbox));

    expect(checkboxValue, true);
    expect(semanticEvent, <String, dynamic>{
      'type': 'tap',
      'nodeId': object.debugSemantics!.id,
      'data': <String, dynamic>{},
    });
    expect(
        object.debugSemantics!
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        true);

    tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
        SystemChannels.accessibility, null);
    semanticsTester.dispose();
  });

  testWidgets('CheckBox tristate rendering, programmatic transitions',
      (WidgetTester tester) async {
    Widget buildFrame(bool? checkboxValue) {
      return Material(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Checkbox(
              tristate: true,
              value: checkboxValue,
              onChanged: (bool? value) {},
            );
          },
        ),
      );
    }

    RenderBox getCheckboxRenderer() {
      return tester.renderObject<RenderBox>(find.byType(Checkbox));
    }

    await tester.pumpWidget(buildFrame(false));
    await tester.pumpAndSettle();
    expect(getCheckboxRenderer(),
        isNot(paints..path())); // checkmark is rendered as a path
    expect(getCheckboxRenderer(),
        isNot(paints..line())); // null is rendered as a line (a "dash")
    expect(getCheckboxRenderer(), paints..drrect()); // empty checkbox

    await tester.pumpWidget(buildFrame(true));
    await tester.pumpAndSettle();
    expect(getCheckboxRenderer(),
        paints..path()); // checkmark is rendered as a path

    await tester.pumpWidget(buildFrame(false));
    await tester.pumpAndSettle();
    expect(getCheckboxRenderer(),
        isNot(paints..path())); // checkmark is rendered as a path
    expect(getCheckboxRenderer(),
        isNot(paints..line())); // null is rendered as a line (a "dash")
    expect(getCheckboxRenderer(), paints..drrect()); // empty checkbox

    await tester.pumpWidget(buildFrame(null));
    await tester.pumpAndSettle();
    expect(getCheckboxRenderer(),
        paints..line()); // null is rendered as a line (a "dash")

    await tester.pumpWidget(buildFrame(true));
    await tester.pumpAndSettle();
    expect(getCheckboxRenderer(),
        paints..path()); // checkmark is rendered as a path

    await tester.pumpWidget(buildFrame(null));
    await tester.pumpAndSettle();
    expect(getCheckboxRenderer(),
        paints..line()); // null is rendered as a line (a "dash")
  });

  testWidgets('CheckBox color rendering', (WidgetTester tester) async {
    const Color borderColor = Color(0xff1e88e5);
    Color checkColor = const Color(0xffFFFFFF);
    Color activeColor;

    Widget buildFrame(
        {Color? activeColor, Color? checkColor, ThemeData? themeData}) {
      return Material(
        child: Theme(
          data: themeData ?? ThemeData(),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Checkbox(
                value: true,
                activeColor: activeColor,
                checkColor: checkColor,
                onChanged: (bool? value) {},
              );
            },
          ),
        ),
      );
    }

    RenderBox getCheckboxRenderer() {
      return tester.renderObject<RenderBox>(find.byType(Checkbox));
    }

    await tester.pumpWidget(buildFrame(checkColor: checkColor));
    await tester.pumpAndSettle();
    expect(
        getCheckboxRenderer(),
        paints
          ..path(color: borderColor)
          ..path(
              color:
                  checkColor)); // paints's color is 0xFFFFFFFF (default color)

    checkColor = const Color(0xFF000000);

    await tester.pumpWidget(buildFrame(checkColor: checkColor));
    await tester.pumpAndSettle();
    expect(
        getCheckboxRenderer(),
        paints
          ..path(color: borderColor)
          ..path(color: checkColor)); // paints's color is 0xFF000000 (params)

    activeColor = const Color(0xFF00FF00);

    await tester.pumpWidget(
        buildFrame(themeData: ThemeData(toggleableActiveColor: activeColor)));
    await tester.pumpAndSettle();
    expect(
        getCheckboxRenderer(),
        paints
          ..path(color: activeColor)); // paints's color is 0xFF00FF00 (theme)

    activeColor = const Color(0xFF000000);

    await tester.pumpWidget(buildFrame(activeColor: activeColor));
    await tester.pumpAndSettle();
    expect(
        getCheckboxRenderer(),
        paints
          ..path(color: activeColor)); // paints's color is 0xFF000000 (params)
  });

  testWidgets('Checkbox is focusable and has correct focus color',
      (WidgetTester tester) async {
    final FocusNode focusNode = FocusNode(debugLabel: 'Checkbox');
    tester.binding.focusManager.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    bool? value = true;
    Widget buildApp({bool enabled = true}) {
      return MaterialApp(
        home: Material(
          child: Center(
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Checkbox(
                value: value,
                onChanged: enabled
                    ? (bool? newValue) {
                        setState(() {
                          value = newValue;
                        });
                      }
                    : null,
                focusColor: Colors.orange[500],
                autofocus: true,
                focusNode: focusNode,
              );
            }),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp());

    await tester.pumpAndSettle();
    expect(focusNode.hasPrimaryFocus, isTrue);
    expect(
      Material.of(tester.element(find.byType(Checkbox))),
      paints
        ..circle(color: Colors.orange[500])
        ..path(color: const Color(0xff1e88e5))
        ..path(color: Colors.white),
    );

    // Check the false value.
    value = false;
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    expect(focusNode.hasPrimaryFocus, isTrue);
    expect(
      Material.of(tester.element(find.byType(Checkbox))),
      paints
        ..circle(color: Colors.orange[500])
        ..drrect(
          color: const Color(0x8a000000),
          outer: RRect.fromLTRBR(
              15.0, 15.0, 33.0, 33.0, const Radius.circular(1.0)),
          inner: RRect.fromLTRBR(
              17.0, 17.0, 31.0, 31.0, const Radius.circular(-1.0)),
        ),
    );

    // Check what happens when disabled.
    value = false;
    await tester.pumpWidget(buildApp(enabled: false));
    await tester.pumpAndSettle();
    expect(focusNode.hasPrimaryFocus, isFalse);
    expect(
      Material.of(tester.element(find.byType(Checkbox))),
      paints
        ..drrect(
          color: const Color(0x61000000),
          outer: RRect.fromLTRBR(
              15.0, 15.0, 33.0, 33.0, const Radius.circular(1.0)),
          inner: RRect.fromLTRBR(
              17.0, 17.0, 31.0, 31.0, const Radius.circular(-1.0)),
        ),
    );
  });

  testWidgets('Checkbox with splash radius set', (WidgetTester tester) async {
    tester.binding.focusManager.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    const double splashRadius = 30;
    Widget buildApp() {
      return MaterialApp(
        home: Material(
          child: Center(
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Checkbox(
                value: false,
                onChanged: (bool? newValue) {},
                focusColor: Colors.orange[500],
                autofocus: true,
                splashRadius: splashRadius,
              );
            }),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    expect(
      Material.of(tester.element(find.byType(Checkbox))),
      paints..circle(color: Colors.orange[500], radius: splashRadius),
    );
  });

  testWidgets('Checkbox can be hovered and has correct hover color',
      (WidgetTester tester) async {
    tester.binding.focusManager.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    bool? value = true;
    Widget buildApp({bool enabled = true}) {
      return MaterialApp(
        home: Material(
          child: Center(
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Checkbox(
                value: value,
                onChanged: enabled
                    ? (bool? newValue) {
                        setState(() {
                          value = newValue;
                        });
                      }
                    : null,
                hoverColor: Colors.orange[500],
              );
            }),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    expect(
      Material.of(tester.element(find.byType(Checkbox))),
      paints
        ..path(color: const Color(0xff1e88e5))
        ..path(
            color: const Color(0xffffffff),
            style: PaintingStyle.stroke,
            strokeWidth: 2.0),
    );

    // Start hovering
    final TestGesture gesture =
        await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(find.byType(Checkbox)));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    expect(
      Material.of(tester.element(find.byType(Checkbox))),
      paints
        ..path(color: const Color(0xff1e88e5))
        ..path(
            color: const Color(0xffffffff),
            style: PaintingStyle.stroke,
            strokeWidth: 2.0),
    );

    // Check what happens when disabled.
    await tester.pumpWidget(buildApp(enabled: false));
    await tester.pumpAndSettle();
    expect(
      Material.of(tester.element(find.byType(Checkbox))),
      paints
        ..path(color: const Color(0x61000000))
        ..path(
            color: const Color(0xffffffff),
            style: PaintingStyle.stroke,
            strokeWidth: 2.0),
    );
  });

  testWidgets('Checkbox can be toggled by keyboard shortcuts',
      (WidgetTester tester) async {
    tester.binding.focusManager.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    bool? value = true;
    Widget buildApp({bool enabled = true}) {
      return MaterialApp(
        home: Material(
          child: Center(
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Checkbox(
                value: value,
                onChanged: enabled
                    ? (bool? newValue) {
                        setState(() {
                          value = newValue;
                        });
                      }
                    : null,
                focusColor: Colors.orange[500],
                autofocus: true,
              );
            }),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    // On web, switches don't respond to the enter key.
    expect(value, kIsWeb ? isTrue : isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(value, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(value, isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(value, isTrue);
  });

  testWidgets('Checkbox responds to density changes.',
      (WidgetTester tester) async {
    const Key key = Key('test');
    Future<void> buildTest(VisualDensity visualDensity) async {
      return tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Center(
              child: Checkbox(
                visualDensity: visualDensity,
                key: key,
                onChanged: (bool? value) {},
                value: true,
              ),
            ),
          ),
        ),
      );
    }

    await buildTest(VisualDensity.standard);
    final RenderBox box = tester.renderObject(find.byKey(key));
    await tester.pumpAndSettle();
    expect(box.size, equals(const Size(48, 48)));

    await buildTest(const VisualDensity(horizontal: 3.0, vertical: 3.0));
    await tester.pumpAndSettle();
    expect(box.size, equals(const Size(60, 60)));

    await buildTest(const VisualDensity(horizontal: -3.0, vertical: -3.0));
    await tester.pumpAndSettle();
    expect(box.size, equals(const Size(36, 36)));

    await buildTest(const VisualDensity(horizontal: 3.0, vertical: -3.0));
    await tester.pumpAndSettle();
    expect(box.size, equals(const Size(60, 36)));
  });

  testWidgets('Checkbox stops hover animation when removed from the tree.',
      (WidgetTester tester) async {
    const Key checkboxKey = Key('checkbox');
    bool? checkboxVal = true;

    await tester.pumpWidget(
      Theme(
        data: ThemeData(materialTapTargetSize: MaterialTapTargetSize.padded),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            child: Center(
              child: StatefulBuilder(
                builder: (_, StateSetter setState) => Checkbox(
                  key: checkboxKey,
                  value: checkboxVal,
                  onChanged: (bool? newValue) => setState(() {
                    checkboxVal = newValue;
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(checkboxKey), findsOneWidget);
    final Offset checkboxCenter = tester.getCenter(find.byKey(checkboxKey));
    final TestGesture testGesture =
        await tester.createGesture(kind: PointerDeviceKind.mouse);
    await testGesture.moveTo(checkboxCenter);

    await tester.pump(); // start animation
    await tester.pump(const Duration(
        milliseconds:
            25)); // hover animation duration is 50 ms. It is half-way.

    await tester.pumpWidget(
      Theme(
        data: ThemeData(materialTapTargetSize: MaterialTapTargetSize.padded),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            child: Center(
              child: Container(),
            ),
          ),
        ),
      ),
    );

    // Hover animation should not trigger an exception when the checkbox is removed
    // before the hover animation should complete.
    expect(tester.takeException(), isNull);

    await testGesture.removePointer();
  });

  testWidgets('Checkbox changes mouse cursor when hovered',
      (WidgetTester tester) async {
    // Test Checkbox() constructor
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: Material(
              child: MouseRegion(
                cursor: SystemMouseCursors.forbidden,
                child: Checkbox(
                  mouseCursor: SystemMouseCursors.text,
                  value: true,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final TestGesture gesture =
        await tester.createGesture(kind: PointerDeviceKind.mouse, pointer: 1);
    await gesture.addPointer(location: tester.getCenter(find.byType(Checkbox)));
    addTearDown(gesture.removePointer);

    await tester.pump();

    expect(RendererBinding.instance!.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.text);

    // Test default cursor
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: Material(
              child: MouseRegion(
                cursor: SystemMouseCursors.forbidden,
                child: Checkbox(
                  value: true,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(RendererBinding.instance!.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.click);

    // Test default cursor when disabled
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: Material(
              child: MouseRegion(
                cursor: SystemMouseCursors.forbidden,
                child: Checkbox(
                  value: true,
                  onChanged: null,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(RendererBinding.instance!.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.basic);

    // Test cursor when tristate
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: Material(
              child: MouseRegion(
                cursor: SystemMouseCursors.forbidden,
                child: Checkbox(
                  value: null,
                  tristate: true,
                  onChanged: null,
                  mouseCursor: _SelectedGrabMouseCursor(),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(RendererBinding.instance!.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.grab);

    await tester.pumpAndSettle();
  });

  testWidgets('Checkbox fill color resolves in enabled/disabled states',
      (WidgetTester tester) async {
    const Color activeEnabledFillColor = Color(0xFF000001);
    const Color activeDisabledFillColor = Color(0xFF000002);

    Color getFillColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return activeDisabledFillColor;
      }
      return activeEnabledFillColor;
    }

    final MaterialStateProperty<Color> fillColor =
        MaterialStateColor.resolveWith(getFillColor);

    Widget buildFrame({required bool enabled}) {
      return Material(
        child: Theme(
          data: ThemeData(),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Checkbox(
                value: true,
                fillColor: fillColor,
                onChanged: enabled ? (bool? value) {} : null,
              );
            },
          ),
        ),
      );
    }

    RenderBox getCheckboxRenderer() {
      return tester.renderObject<RenderBox>(find.byType(Checkbox));
    }

    await tester.pumpWidget(buildFrame(enabled: true));
    await tester.pumpAndSettle();
    expect(getCheckboxRenderer(), paints..path(color: activeEnabledFillColor));

    await tester.pumpWidget(buildFrame(enabled: false));
    await tester.pumpAndSettle();
    expect(getCheckboxRenderer(), paints..path(color: activeDisabledFillColor));
  });

  testWidgets('Checkbox fill color resolves in hovered/focused states',
      (WidgetTester tester) async {
    final FocusNode focusNode = FocusNode(debugLabel: 'checkbox');
    tester.binding.focusManager.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    const Color hoveredFillColor = Color(0xFF000001);
    const Color focusedFillColor = Color(0xFF000002);

    Color getFillColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.hovered)) {
        return hoveredFillColor;
      }
      if (states.contains(MaterialState.focused)) {
        return focusedFillColor;
      }
      return Colors.transparent;
    }

    final MaterialStateProperty<Color> fillColor =
        MaterialStateColor.resolveWith(getFillColor);

    Widget buildFrame() {
      return Material(
        child: Theme(
          data: ThemeData(),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Checkbox(
                focusNode: focusNode,
                autofocus: true,
                value: true,
                fillColor: fillColor,
                onChanged: (bool? value) {},
              );
            },
          ),
        ),
      );
    }

    RenderBox getCheckboxRenderer() {
      return tester.renderObject<RenderBox>(find.byType(Checkbox));
    }

    await tester.pumpWidget(buildFrame());
    await tester.pumpAndSettle();
    expect(focusNode.hasPrimaryFocus, isTrue);
    expect(getCheckboxRenderer(), paints..path(color: focusedFillColor));

    // Start hovering
    final TestGesture gesture =
        await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer();
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(find.byType(Checkbox)));
    await tester.pumpAndSettle();

    expect(getCheckboxRenderer(), paints..path(color: hoveredFillColor));
  });

  testWidgets('Checkbox respects shape and side', (WidgetTester tester) async {
    final RoundedRectangleBorder roundedRectangleBorder =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(5));

    const BorderSide side = BorderSide(
      width: 4,
      color: Color(0xfff44336),
    );

    Widget buildApp() {
      return MaterialApp(
        home: Material(
          child: Center(
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Checkbox(
                value: false,
                onChanged: (bool? newValue) {},
                shape: roundedRectangleBorder,
                side: side,
              );
            }),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).shape,
        roundedRectangleBorder);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).side, side);
    expect(
      Material.of(tester.element(find.byType(Checkbox))),
      paints
        ..drrect(
          color: const Color(0xfff44336),
          outer:
              RRect.fromLTRBR(15.0, 15.0, 33.0, 33.0, const Radius.circular(5)),
          inner:
              RRect.fromLTRBR(19.0, 19.0, 29.0, 29.0, const Radius.circular(1)),
        ),
    );
  });

  testWidgets(
      'Checkbox overlay color resolves in active/pressed/focused/hovered states',
      (WidgetTester tester) async {
    final FocusNode focusNode = FocusNode(debugLabel: 'Checkbox');
    tester.binding.focusManager.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;

    const Color fillColor = Color(0xFF000000);
    const Color activePressedOverlayColor = Color(0xFF000001);
    const Color inactivePressedOverlayColor = Color(0xFF000002);
    const Color hoverOverlayColor = Color(0xFF000003);
    const Color focusOverlayColor = Color(0xFF000004);
    const Color hoverColor = Color(0xFF000005);
    const Color focusColor = Color(0xFF000006);

    Color? getOverlayColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) {
        if (states.contains(MaterialState.selected)) {
          return activePressedOverlayColor;
        }
        return inactivePressedOverlayColor;
      }
      if (states.contains(MaterialState.hovered)) {
        return hoverOverlayColor;
      }
      if (states.contains(MaterialState.focused)) {
        return focusOverlayColor;
      }
      return null;
    }

    const double splashRadius = 24.0;

    Widget buildCheckbox(
        {bool active = false, bool focused = false, bool useOverlay = true}) {
      return MaterialApp(
        home: Scaffold(
          body: Checkbox(
            focusNode: focusNode,
            autofocus: focused,
            value: active,
            onChanged: (_) {},
            fillColor: MaterialStateProperty.all(fillColor),
            overlayColor: useOverlay
                ? MaterialStateProperty.resolveWith(getOverlayColor)
                : null,
            hoverColor: hoverColor,
            focusColor: focusColor,
            splashRadius: splashRadius,
          ),
        ),
      );
    }

    await tester.pumpWidget(buildCheckbox(active: false, useOverlay: false));
    await tester.startGesture(tester.getCenter(find.byType(Checkbox)));
    await tester.pumpAndSettle();

    expect(
      Material.of(tester.element(find.byType(Checkbox))),
      paints
        ..circle(
          color: fillColor.withAlpha(kRadialReactionAlpha),
          radius: splashRadius,
        ),
      reason:
          'Default inactive pressed Checkbox should have overlay color from fillColor',
    );

    await tester.pumpWidget(buildCheckbox(active: true, useOverlay: false));
    await tester.startGesture(tester.getCenter(find.byType(Checkbox)));
    await tester.pumpAndSettle();

    expect(
      Material.of(tester.element(find.byType(Checkbox))),
      paints
        ..circle(
          color: fillColor.withAlpha(kRadialReactionAlpha),
          radius: splashRadius,
        ),
      reason:
          'Default active pressed Checkbox should have overlay color from fillColor',
    );

    await tester.pumpWidget(buildCheckbox(active: false));
    await tester.startGesture(tester.getCenter(find.byType(Checkbox)));
    await tester.pumpAndSettle();

    expect(
      Material.of(tester.element(find.byType(Checkbox))),
      paints
        ..circle(
          color: inactivePressedOverlayColor,
          radius: splashRadius,
        ),
      reason:
          'Inactive pressed Checkbox should have overlay color: $inactivePressedOverlayColor',
    );

    await tester.pumpWidget(buildCheckbox(active: true));
    await tester.startGesture(tester.getCenter(find.byType(Checkbox)));
    await tester.pumpAndSettle();

    expect(
      Material.of(tester.element(find.byType(Checkbox))),
      paints
        ..circle(
          color: activePressedOverlayColor,
          radius: splashRadius,
        ),
      reason:
          'Active pressed Checkbox should have overlay color: $activePressedOverlayColor',
    );

    await tester.pumpWidget(buildCheckbox(focused: true));
    await tester.pumpAndSettle();

    expect(focusNode.hasPrimaryFocus, isTrue);
    expect(
      Material.of(tester.element(find.byType(Checkbox))),
      paints
        ..circle(
          color: focusOverlayColor,
          radius: splashRadius,
        ),
      reason:
          'Focused Checkbox should use overlay color $focusOverlayColor over $focusColor',
    );

    // Start hovering
    final TestGesture gesture =
        await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer();
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(find.byType(Checkbox)));
    await tester.pumpAndSettle();

    expect(
      Material.of(tester.element(find.byType(Checkbox))),
      paints
        ..circle(
          color: hoverOverlayColor,
          radius: splashRadius,
        ),
      reason:
          'Hovered Checkbox should use overlay color $hoverOverlayColor over $hoverColor',
    );
  });

  testWidgets(
      'Tristate Checkbox overlay color resolves in pressed active/inactive states',
      (WidgetTester tester) async {
    const Color activePressedOverlayColor = Color(0xFF000001);
    const Color inactivePressedOverlayColor = Color(0xFF000002);

    Color? getOverlayColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) {
        if (states.contains(MaterialState.selected)) {
          return activePressedOverlayColor;
        }
        return inactivePressedOverlayColor;
      }
    }

    const double splashRadius = 24.0;
    TestGesture gesture;
    bool? _value = false;

    Widget buildTristateCheckbox() {
      return MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Checkbox(
                value: _value,
                tristate: true,
                onChanged: (bool? value) {
                  setState(() {
                    _value = value;
                  });
                },
                overlayColor:
                    MaterialStateProperty.resolveWith(getOverlayColor),
                splashRadius: splashRadius,
              );
            },
          ),
        ),
      );
    }

    // The checkbox is inactive.
    await tester.pumpWidget(buildTristateCheckbox());
    gesture = await tester.press(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(_value, false);
    expect(
      Material.of(tester.element(find.byType(Checkbox))),
      paints
        ..circle(
          color: inactivePressedOverlayColor,
          radius: splashRadius,
        ),
      reason:
          'Inactive pressed Checkbox should have overlay color: $inactivePressedOverlayColor',
    );

    // The checkbox is active.
    await gesture.up();
    gesture = await tester.press(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(_value, true);
    expect(
      Material.of(tester.element(find.byType(Checkbox))),
      paints
        ..circle(
          color: activePressedOverlayColor,
          radius: splashRadius,
        ),
      reason:
          'Active pressed Checkbox should have overlay color: $activePressedOverlayColor',
    );

    // The checkbox is active in tri-state.
    await gesture.up();
    gesture = await tester.press(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(_value, null);
    expect(
      Material.of(tester.element(find.byType(Checkbox))),
      paints
        ..circle(
          color: activePressedOverlayColor,
          radius: splashRadius,
        ),
      reason:
          'Active (tristate) pressed Checkbox should have overlay color: $activePressedOverlayColor',
    );

    // The checkbox is inactive again.
    await gesture.up();
    gesture = await tester.press(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(_value, false);
    expect(
      Material.of(tester.element(find.byType(Checkbox))),
      paints
        ..circle(
          color: inactivePressedOverlayColor,
          radius: splashRadius,
        ),
      reason:
          'Inactive pressed Checkbox should have overlay color: $inactivePressedOverlayColor',
    );

    await gesture.up();
  });

  testWidgets('Do not crash when widget disappears while pointer is down',
      (WidgetTester tester) async {
    Widget buildCheckbox(bool show) {
      return MaterialApp(
        home: Material(
          child: Center(
            child:
                show ? Checkbox(value: true, onChanged: (_) {}) : Container(),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildCheckbox(true));
    final Offset center = tester.getCenter(find.byType(Checkbox));
    // Put a pointer down on the screen.
    final TestGesture gesture = await tester.startGesture(center);
    await tester.pump();
    // While the pointer is down, the widget disappears.
    await tester.pumpWidget(buildCheckbox(false));
    expect(find.byType(Checkbox), findsNothing);
    // Release pointer after widget disappeared.
    await gesture.up();
  });

  testWidgets('Checkbox BorderSide side only applies when unselected',
      (WidgetTester tester) async {
    const Color borderColor = Color(0xfff44336);
    const Color activeColor = Color(0xff123456);
    const BorderSide side = BorderSide(
      width: 4,
      color: borderColor,
    );

    Widget buildApp({bool? value, bool enabled = true}) {
      return MaterialApp(
        home: Material(
          child: Center(
            child: Checkbox(
              value: value,
              tristate: value == null,
              activeColor: activeColor,
              onChanged: enabled ? (bool? newValue) {} : null,
              side: side,
            ),
          ),
        ),
      );
    }

    RenderBox getCheckboxRenderer() {
      return tester.renderObject<RenderBox>(find.byType(Checkbox));
    }

    void expectBorder() {
      expect(
        getCheckboxRenderer(),
        paints
          ..drrect(
            color: borderColor,
            outer: RRect.fromLTRBR(15, 15, 33, 33, const Radius.circular(1)),
            inner: RRect.fromLTRBR(19, 19, 29, 29, const Radius.circular(-3)),
          ),
      );
    }

    // Checkbox is unselected, so the specified BorderSide appears.

    await tester.pumpWidget(buildApp(value: false));
    await tester.pumpAndSettle();
    expectBorder();

    await tester.pumpWidget(buildApp(value: false, enabled: false));
    await tester.pumpAndSettle();
    expectBorder();

    // Checkbox is selected/interdeterminate, so the specified BorderSide
    // does not appear.

    await tester.pumpWidget(buildApp(value: true));
    await tester.pumpAndSettle();
    expect(getCheckboxRenderer(), isNot(paints..drrect())); // no border
    expect(getCheckboxRenderer(),
        paints..path(color: activeColor)); // checkbox fill

    await tester.pumpWidget(buildApp(value: null));
    await tester.pumpAndSettle();
    expect(getCheckboxRenderer(), isNot(paints..drrect())); // no border
    expect(getCheckboxRenderer(),
        paints..path(color: activeColor)); // checkbox fill
  });

  testWidgets('Checkbox MaterialStateBorderSide applies unconditionally',
      (WidgetTester tester) async {
    const Color borderColor = Color(0xfff44336);
    const BorderSide side = BorderSide(
      width: 4,
      color: borderColor,
    );

    Widget buildApp({bool? value, bool enabled = true}) {
      return MaterialApp(
        home: Material(
          child: Center(
            child: Checkbox(
              value: value,
              tristate: value == null,
              onChanged: enabled ? (bool? newValue) {} : null,
              side: MaterialStateBorderSide.resolveWith(
                  (Set<MaterialState> states) => side),
            ),
          ),
        ),
      );
    }

    void expectBorder() {
      expect(
        tester.renderObject<RenderBox>(find.byType(Checkbox)),
        paints
          ..drrect(
            color: borderColor,
            outer: RRect.fromLTRBR(15, 15, 33, 33, const Radius.circular(1)),
            inner: RRect.fromLTRBR(19, 19, 29, 29, const Radius.circular(-3)),
          ),
      );
    }

    await tester.pumpWidget(buildApp(value: false));
    await tester.pumpAndSettle();
    expectBorder();

    await tester.pumpWidget(buildApp(value: false, enabled: false));
    await tester.pumpAndSettle();
    expectBorder();

    await tester.pumpWidget(buildApp(value: true));
    await tester.pumpAndSettle();
    expectBorder();

    await tester.pumpWidget(buildApp(value: null));
    await tester.pumpAndSettle();
    expectBorder();
  });
}

class _SelectedGrabMouseCursor extends MaterialStateMouseCursor {
  const _SelectedGrabMouseCursor();

  @override
  MouseCursor resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return SystemMouseCursors.grab;
    }
    return SystemMouseCursors.basic;
  }

  @override
  String get debugDescription => '_SelectedGrabMouseCursor()';
}
