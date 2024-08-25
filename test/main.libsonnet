local parser = import '../semver/main.libsonnet';
local test = import 'github.com/jsonnet-libs/testonnet/main.libsonnet';

test.new(std.thisFile)
+ std.foldl(
  function(testcases, validcase)
    testcases
    + test.case.new(
      name='Validate: "%s"' % validcase.value,
      test=test.expect.eq(
        actual=parser.validate(validcase.value),
        expected=true
      )
    )
    + test.case.new(
      name='Parsed: "%s"' % validcase.value,
      test=test.expect.eqDiff(
        actual=parser._parse(validcase.value),
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
        actual=parser.validate(value),
        expected=false
      )
    ),
  (import 'invalid.json'),
  {},
)
