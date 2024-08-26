local semver = import '../semver/main.libsonnet';
local util = import '../semver/util.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';

local toString(obj) =
  std.join('.', [
    obj.major,
    obj.minor,
    obj.patch,
  ])
  + (if 'pre-release' in obj
     then '-' + obj['pre-release']
     else '')
  + (if 'build' in obj
     then '+' + obj.build
     else '');

test.new(std.thisFile)
+ std.foldl(
  function(testcases, validcase)
    testcases
    + test.case.new(
      name='Validate: "%s"' % validcase.value,
      test=test.expect.eq(
        actual=semver.validate(validcase.value),
        expected=true
      )
    )
    + test.case.new(
      name='Parsed: "%s"' % validcase.value,
      test=test.expect.eqDiff(
        actual=semver._parse(validcase.value),
        expected=validcase.parsed
      )
    ),
  (import 'valid.json'),
  {},
)
+ std.foldl(
  function(testcases, value)
    testcases
    + test.case.new(
      name='Validate: "%s"' % value,
      test=test.expect.eq(
        actual=semver.validate(value),
        expected=false
      )
    ),
  (import 'invalid.json'),
  {},
)
+ (
  local input =
    std.map(
      semver._parse,
      [
        // deliberate random order
        '2.1.0',
        '1.0.0',
        '2.1.1',
        '2.0.0',
      ]
    );

  local expectedOrder = [
    '2.1.1',
    '2.1.0',
    '2.0.0',
    '1.0.0',
  ];
  test.case.new(
    name='Sort simple versions',
    test=test.expect.eq(
      actual=
      std.map(
        toString,
        util.sortSemVer(input),
      ),
      expected=expectedOrder,
    )
  )
)
+ (
  local input =
    std.map(
      semver._parse,
      [
        // deliberate random order
        '1.0.0-alpha.1',
        '1.0.0-rc.1',
        '1.0.0',
        '1.0.0-alpha.beta.2.a',
        '1.0.0-beta.11',
        '1.0.0-alpha.beta',
        '1.0.0-alpha',
        '1.0.0-beta.2',
        '1.0.0-beta.11.bb',
        '1.0.0-beta',
      ]
    );

  local expectedOrder = [
    '1.0.0',
    '1.0.0-rc.1',
    '1.0.0-beta.11.bb',
    '1.0.0-beta.11',
    '1.0.0-beta.2',
    '1.0.0-beta',
    '1.0.0-alpha.beta.2.a',
    '1.0.0-alpha.beta',
    '1.0.0-alpha.1',
    '1.0.0-alpha',
  ];
  test.case.new(
    name='Sort versions with pre-release tags',
    test=test.expect.eq(
      actual=
      std.map(
        toString,
        util.sortSemVer(input),
      ),
      expected=expectedOrder,
    )
  )
)
