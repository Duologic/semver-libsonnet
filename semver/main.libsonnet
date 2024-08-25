local validator = import './validator.libsonnet';
local d = import 'github.com/jsonnet-libs/docsonnet/doc-util/main.libsonnet';

{
  '#':
    d.package.new(
      'semver',
      'github.com/Duologic/semver-libsonnet/semver',
      |||
        Jsonnet library to parse and validate Semantic Versioning.

        Implemented according spec Semantic Versioning 2.0.0

        Using BNF: https://semver.org/#backusnaur-form-grammar-for-valid-semver-versions
      |||,
      'main.libsonnet',
      'main'
    )
    + {
      usageTemplate:
        |||
          ## Usage

          Example:

          ```
          %(jsonnet)s
          ```

          Output:

          ```json
          %(output)s
          ```
        ||| % {
          jsonnet:
            std.strReplace(
              importstr '../example.libsonnet',
              './main.libsonnet',
              '%(url)s/%(filename)s',
            ),
          output:
            std.manifestJson(import './example.libsonnet'),
        },
    },

  '#parse': d.func.new(
    "`parse` will parse and validate a Semantic Version from a string and returning an object. It'll throw and assertion if the string is not valid.",
    [d.argument.new('semver', d.T.string)],
  ),
  parse(semver)::
    local parsed = self._parse(semver);
    assert validator.isMajor(parsed.major) : 'MAJOR is not a numeric identifier: "%s"' % parsed.major;
    assert validator.isMinor(parsed.minor) : 'MINOR is not a numeric identifier: "%s"' % parsed.minor;
    assert validator.isPatch(parsed.patch) : 'PATCH is not a numeric identifier: "%s"' % parsed.patch;
    assert !std.objectHas(parsed, 'pre-release') || validator.isPreRelease(parsed['pre-release']) : 'PRE-RELEASE is not valid: "%s"' % parsed['pre-release'];
    assert !std.objectHas(parsed, 'build') || validator.isBuild(parsed.build) : 'BUILD is not valid: "%s"' % parsed.build;
    parsed,

  '#validate': d.func.new(
    '`validate` will parse and validate a Semantic Version from a string and return a boolean.',
    [d.argument.new('semver', d.T.string)],
  ),
  validate(semver)::
    local parsed = self._parse(semver);
    std.all([
      validator.isNumericIdentifier(parsed.major),
      validator.isNumericIdentifier(parsed.minor),
      validator.isNumericIdentifier(parsed.patch),
      !std.objectHas(parsed, 'pre-release') || validator.isDotSeperatedPreReleaseIdentifier(parsed['pre-release']),
      !std.objectHas(parsed, 'build') || validator.isDotSeperatedBuildIdentifier(parsed.build),
    ]),

  // undocumented private function, use parse() or validate() instead
  // `_parse` will attempt to parse a Semantic Version without validation, returning the parsed result as an object.
  _parse(str)::
    local _parts = std.splitLimit(str, '.', 2);
    local parts =
      if std.length(_parts) == 1
      then _parts + ['', '']
      else if std.length(_parts) == 2
      then _parts + ['']
      else _parts;

    local buildSplit = std.splitLimit(parts[2], '+', 1);
    local hasBuild = std.length(buildSplit) == 2;

    local remainder =
      if hasBuild
      then parts[2][:std.length(parts[2]) - (std.length(buildSplit[1]) + 1)]
      else parts[2];

    local preReleaseSplit = std.splitLimit(remainder, '-', 1);
    local hasPreRelease = std.length(preReleaseSplit) == 2;

    local major = parts[0];
    local minor = parts[1];

    local patch =
      if hasPreRelease
      then preReleaseSplit[0]
      else buildSplit[0];

    local preRelease = preReleaseSplit[1];
    local build = buildSplit[1];

    {
      major: major,
      minor: minor,
      patch: patch,
      [if hasPreRelease then 'pre-release']: preRelease,
      [if hasBuild then 'build']: build,
    },
}
