// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show exit, stderr, stdout, File, ProcessResult;

import 'package:args/args.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:platform/platform.dart';
import 'package:process/process.dart';

import 'configuration.dart';
import 'snippets.dart';

const String _kSerialOption = 'serial';
const String _kElementOption = 'element';
const String _kHelpOption = 'help';
const String _kInputOption = 'input';
const String _kLibraryOption = 'library';
const String _kOutputOption = 'output';
const String _kPackageOption = 'package';
const String _kTemplateOption = 'template';
const String _kTypeOption = 'type';
const String _kShowDartPad = 'dartpad';

class GitStatusFailed implements Exception {
  GitStatusFailed(this.gitResult);

  final ProcessResult gitResult;

  @override
  String toString() =>
      'git status exited with a non-zero exit code: ${gitResult.exitCode}:\n${gitResult.stderr}\n${gitResult.stdout}';
}

/// Get the name of the channel these docs are from.
///
/// First check env variable LUCI_BRANCH, then refer to the currently
/// checked out git branch.
String getChannelName({
  @visibleForTesting Platform platform = const LocalPlatform(),
  @visibleForTesting
      ProcessManager processManager = const LocalProcessManager(),
}) {
  final String? envReleaseChannel = platform.environment['LUCI_BRANCH']?.trim();
  if (<String>['master', 'stable'].contains(envReleaseChannel)) {
    return envReleaseChannel!;
  }
  final RegExp gitBranchRegexp = RegExp(r'^## (?<branch>.*)');
  final ProcessResult gitResult = processManager.runSync(
      <String>['git', 'status', '-b', '--porcelain'],
      environment: <String, String>{'GIT_TRACE': '2', 'GIT_TRACE_SETUP': '2'},
      includeParentEnvironment: true);
  if (gitResult.exitCode != 0) {
    throw GitStatusFailed(gitResult);
  }
  final RegExpMatch? gitBranchMatch = gitBranchRegexp
      .firstMatch((gitResult.stdout as String).trim().split('\n').first);
  return gitBranchMatch == null
      ? '<unknown>'
      : gitBranchMatch.namedGroup('branch')!.split('...').first;
}

// This is a hack to workaround the fact that git status inexplicably fails
// (random non-zero error code) about 2% of the time.
String getChannelNameWithRetries() {
  int retryCount = 0;
  while (retryCount < 2) {
    try {
      return getChannelName();
    } on GitStatusFailed catch (e) {
      retryCount += 1;
      stderr.write(
          'git status failed, retrying ($retryCount)\nError report:\n$e');
    }
  }
  return getChannelName();
}

/// Generates snippet dartdoc output for a given input, and creates any sample
/// applications needed by the snippet.
void main(List<String> argList) {
  const Platform platform = LocalPlatform();
  final Map<String, String> environment = platform.environment;
  final ArgParser parser = ArgParser();
  final List<String> snippetTypes = SnippetType.values
      .map<String>((SnippetType type) => getEnumName(type))
      .toList();
  parser.addOption(
    _kTypeOption,
    defaultsTo: getEnumName(SnippetType.sample),
    allowed: snippetTypes,
    allowedHelp: <String, String>{
      getEnumName(SnippetType.sample):
          'Produce a code sample application complete with embedding the sample in an '
              'application template.',
      getEnumName(SnippetType.snippet):
          'Produce a nicely formatted piece of sample code. Does not embed the '
              'sample into an application template.',
    },
    help: 'The type of snippet to produce.',
  );
  parser.addOption(
    _kTemplateOption,
    defaultsTo: null,
    help: 'The name of the template to inject the code into.',
  );
  parser.addOption(
    _kOutputOption,
    defaultsTo: null,
    help: 'The output path for the generated sample application. Overrides '
        'the naming generated by the --package/--library/--element arguments. '
        'Metadata will be written alongside in a .json file. '
        'The basename of this argument is used as the ID',
  );
  parser.addOption(
    _kInputOption,
    defaultsTo: environment['INPUT'],
    help: 'The input file containing the sample code to inject.',
  );
  parser.addOption(
    _kPackageOption,
    defaultsTo: environment['PACKAGE_NAME'],
    help: 'The name of the package that this sample belongs to.',
  );
  parser.addOption(
    _kLibraryOption,
    defaultsTo: environment['LIBRARY_NAME'],
    help: 'The name of the library that this sample belongs to.',
  );
  parser.addOption(
    _kElementOption,
    defaultsTo: environment['ELEMENT_NAME'],
    help: 'The name of the element that this sample belongs to.',
  );
  parser.addOption(
    _kSerialOption,
    defaultsTo: environment['INVOCATION_INDEX'],
    help: 'A unique serial number for this snippet tool invocation.',
  );
  parser.addFlag(
    _kHelpOption,
    defaultsTo: false,
    negatable: false,
    help: 'Prints help documentation for this command',
  );
  parser.addFlag(
    _kShowDartPad,
    defaultsTo: false,
    negatable: false,
    help: "Indicates whether DartPad should be included in the sample's "
        'final HTML output. This flag only applies when the type parameter is '
        '"sample".',
  );

  final ArgResults args = parser.parse(argList);

  if (args[_kHelpOption] as bool) {
    stderr.writeln(parser.usage);
    exit(0);
  }

  final SnippetType snippetType = SnippetType.values.firstWhere(
      (SnippetType type) => getEnumName(type) == args[_kTypeOption]);

  if (args[_kShowDartPad] == true && snippetType != SnippetType.sample) {
    errorExit(
        '${args[_kTypeOption]} was selected, but the --dartpad flag is only valid '
        'for application sample code.');
  }

  if (args[_kInputOption] == null) {
    stderr.writeln(parser.usage);
    errorExit(
        'The --$_kInputOption option must be specified, either on the command '
        'line, or in the INPUT environment variable.');
  }

  final File input = File(args['input'] as String);
  if (!input.existsSync()) {
    errorExit('The input file ${input.path} does not exist.');
  }

  String? template;
  if (snippetType == SnippetType.sample) {
    final String templateArg = args[_kTemplateOption] as String;
    if (templateArg == null || templateArg.isEmpty) {
      stderr.writeln(parser.usage);
      errorExit(
          'The --$_kTemplateOption option must be specified on the command '
          'line for application samples.');
    }
    template = templateArg.replaceAll(RegExp(r'.tmpl$'), '');
  }

  final String packageName = args[_kPackageOption] as String? ?? '';
  final String libraryName = args[_kLibraryOption] as String? ?? '';
  final String elementName = args[_kElementOption] as String? ?? '';
  final String serial = args[_kSerialOption] as String? ?? '';
  final List<String> id = <String>[];
  if (args[_kOutputOption] != null) {
    id.add(path.basename(
        path.basenameWithoutExtension(args[_kOutputOption] as String)));
  } else {
    if (packageName.isNotEmpty && packageName != 'flutter') {
      id.add(packageName);
    }
    if (libraryName.isNotEmpty) {
      id.add(libraryName);
    }
    if (elementName.isNotEmpty) {
      id.add(elementName);
    }
    if (serial.isNotEmpty) {
      id.add(serial);
    }
    if (id.isEmpty) {
      errorExit('Unable to determine ID. At least one of --$_kPackageOption, '
          '--$_kLibraryOption, --$_kElementOption, -$_kSerialOption, or the environment variables '
          'PACKAGE_NAME, LIBRARY_NAME, ELEMENT_NAME, or INVOCATION_INDEX must be non-empty.');
    }
  }

  final SnippetGenerator generator = SnippetGenerator();
  stdout.write(generator.generate(
    input,
    snippetType,
    showDartPad: args[_kShowDartPad] as bool,
    template: template,
    output: args[_kOutputOption] != null
        ? File(args[_kOutputOption] as String)
        : null,
    metadata: <String, Object?>{
      'sourcePath': environment['SOURCE_PATH'],
      'sourceLine': environment['SOURCE_LINE'] != null
          ? int.tryParse(environment['SOURCE_LINE']!)
          : null,
      'id': id.join('.'),
      'channel': getChannelNameWithRetries(),
      'serial': serial,
      'package': packageName,
      'library': libraryName,
      'element': elementName,
    },
  ));

  exit(0);
}
