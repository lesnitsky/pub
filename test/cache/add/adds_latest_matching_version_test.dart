// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:scheduled_test/scheduled_test.dart';

import '../../descriptor.dart' as d;
import '../../test_pub.dart';

main() {
  integration(
      'adds the latest version of the package matching the '
      'version constraint', () {
    servePackages((builder) {
      builder.serve("foo", "1.2.2");
      builder.serve("foo", "1.2.3");
      builder.serve("foo", "2.0.0-dev");
      builder.serve("foo", "2.0.0");
    });

    schedulePub(
        args: ["cache", "add", "foo", "-v", ">=1.0.0 <2.0.0"],
        output: 'Downloading foo 1.2.3...',
        silent: allOf([
          contains("X-Pub-OS: ${Platform.operatingSystem}"),
          contains("X-Pub-Command: cache add"),
          contains("X-Pub-Session-ID:"),
          isNot(contains("X-Pub-Environment")),
          isNot(contains("X-Pub-Reason")),
        ]));

    d.cacheDir({"foo": "1.2.3"}).validate();
    d.hostedCache([
      d.nothing("foo-1.2.2"),
      d.nothing("foo-2.0.0-dev"),
      d.nothing("foo-2.0.0")
    ]).validate();
  });
}
