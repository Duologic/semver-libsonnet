// Implemented according spec Semantic Versioning 2.0.0
// Using BNF: https://semver.org/#backusnaur-form-grammar-for-valid-semver-versions

{
  local validator = self.validator,
  validator: {
    isDotSeperatedPreReleaseIdentifier(str):
      self.isPreReleaseIdentifier(str)
      || std.all(std.map(self.isPreReleaseIdentifier, std.split(str, '.'))),

    isDotSeperatedBuildIdentifier(str):
      self.isBuildIdentifier(str)
      || std.all(std.map(self.isBuildIdentifier, std.split(str, '.'))),

    isPreReleaseIdentifier(str):
      self.isAlphanumericIdentifier(str)
      || self.isNumericIdentifier(str),

    isBuildIdentifier(str):
      self.isAlphanumericIdentifier(str)
      || self.isDigits(str),

    isAlphanumericIdentifier(str):
      std.length(str) > 0
      && (
        self.isNonDigit(str)
        || (self.isNonDigit(str[0]) && self.isIdentifierCharacters(str[1:]))
        || (self.isIdentifierCharacters(str) && self.isNonDigit(str[std.length(str) - 1]))
        // spec also has this but can't wrap my head around it
        //| <identifier characters> <non-digit> <identifier characters>
      ),

    isNumericIdentifier(str):
      std.length(str) > 0
      && (
        self.isZero(str)
        || self.isPositiveDigit(str)
        || (self.isPositiveDigit(str[0]) && self.isDigits(str[1:]))
      ),

    isIdentifierCharacters(str):
      std.length(str) > 0
      && std.all(
        std.map(
          self.isIdentifierCharacter,
          std.stringChars(str)
        )
      ),

    isIdentifierCharacter(c):
      self.isDigit(c)
      || self.isNonDigit(c),

    isNonDigit(c): self.isLetter(c) || c == '-',

    isDigits(str):
      std.length(str) > 0
      && std.all(
        std.map(
          self.isDigit,
          std.stringChars(str)
        )
      ),

    isDigit(c): (self.isZero(c) || self.isPositiveDigit(c)),

    local cp(c) = std.codepoint(c),

    isZero(c): std.length(c) == 1 && cp(c) == 48,

    isPositiveDigit(c):
      std.length(c) == 1
      && (cp(c) >= 49 && cp(c) <= 57),  // [1-9]

    isLetter(c):
      std.length(c) == 1
      && (
        (cp(c) >= 97 && cp(c) < 123)  // [a-z]
        || (cp(c) >= 65 && cp(c) < 91)  // [A-Z]
      ),
  },

  parse(str, doAssertion=true):
    local _parts = std.splitLimit(str, '.', 2);
    local parts =
      if std.length(_parts) == 1
      then _parts + ['', '']
      else if std.length(_parts) == 2
      then _parts + ['']
      else _parts;

    assert std.trace(str, true);
    local preReleaseSplit = std.splitLimit(parts[2], '-', 1);

    local hasPreRelease = std.length(preReleaseSplit) == 2;

    local buildSplit =
      if hasPreRelease
      then std.splitLimit(preReleaseSplit[1], '+', 1)
      else std.splitLimit(parts[2], '+', 1);

    local hasBuild = std.length(buildSplit) == 2;

    local major = parts[0];
    local minor = parts[1];

    local patch =
      if hasPreRelease
      then preReleaseSplit[0]
      else buildSplit[0];

    local preRelease =
      if hasBuild
      then buildSplit[0]
      else preReleaseSplit[1];

    local build =
      if hasBuild
      then std.trace(std.toString(buildSplit), buildSplit[1])
      else error '???';

    local parsed = {
      major: major,
      minor: minor,
      patch: patch,
      [if hasPreRelease then 'pre-release']: preRelease,
      [if hasBuild then 'build']: build,
    };

    assert if doAssertion then self.doAssertion(parsed) else true;

    parsed,

  doAssertion(parsed):
    assert validator.isNumericIdentifier(parsed.major) : 'MAJOR is not a numeric identifier: "%s"' % parsed.major;
    assert validator.isNumericIdentifier(parsed.minor) : 'MINOR is not a numeric identifier: "%s"' % parsed.minor;
    assert validator.isNumericIdentifier(parsed.patch) : 'PATCH is not a numeric identifier: "%s"' % parsed.patch;
    assert !std.objectHas(parsed, 'pre-release') || validator.isDotSeperatedPreReleaseIdentifier(parsed['pre-release']) : 'PRE-RELEASE is not valid: "%s"' % parsed['pre-release'];
    assert !std.objectHas(parsed, 'build') || validator.isDotSeperatedBuildIdentifier(parsed.build) : 'BUILD is not valid: "%s"' % parsed.build;
    true,

  validate(str):
    local parsed = self.parse(str, false);
    std.all([
      validator.isNumericIdentifier(parsed.major),
      validator.isNumericIdentifier(parsed.minor),
      validator.isNumericIdentifier(parsed.patch),
      !std.objectHas(parsed, 'pre-release') || validator.isDotSeperatedPreReleaseIdentifier(parsed['pre-release']),
      !std.objectHas(parsed, 'build') || validator.isDotSeperatedBuildIdentifier(parsed.build),
    ]),
}
