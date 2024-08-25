local parser = import '../semver/main.libsonnet';

// WARN: This file is used to generate valid.json, do not use this as source of truth for test cases themselves.

local valid = [
  '0.0.4',
  '1.2.3',
  '10.20.30',
  '1.1.2-prerelease+meta',
  '1.1.2+meta',
  '1.1.2+meta-valid',
  '1.0.0-alpha',
  '1.0.0-beta',
  '1.0.0-alpha.beta',
  '1.0.0-alpha.beta.1',
  '1.0.0-alpha.1',
  '1.0.0-alpha0.valid',
  '1.0.0-alpha.0valid',
  '1.0.0-alpha-a.b-c-somethinglong+build.1-aef.1-its-okay',
  '1.0.0-rc.1+build.1',
  '2.0.0-rc.1+build.123',
  '1.2.3-beta',
  '10.2.3-DEV-SNAPSHOT',
  '1.2.3-SNAPSHOT-123',
  '1.0.0',
  '2.0.0',
  '1.1.7',
  '2.0.0+build.1848',
  '2.0.1-alpha.1227',
  '1.0.0-alpha+beta',
  '1.2.3----RC-SNAPSHOT.12.9.1--.12+788',
  '1.2.3----R-S.12.9.1--.12+meta',
  '1.2.3----RC-SNAPSHOT.12.9.1--.12',
  '1.0.0+0.build.1-rc.10000aaa-kk-0.1',
  '99999999999999999999999.999999999999999999.99999999999999999',
  '1.0.0-0A.is.legal',
];

std.map(
  function(v) {
    value: v,
    parsed: parser._parse(v),
  },
  valid,
)
