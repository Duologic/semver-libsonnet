{
  isMajor(str):
    self.isNumericIdentifier(str),

  isMinor(str):
    self.isNumericIdentifier(str),

  isPatch(str):
    self.isNumericIdentifier(str),

  isPreRelease(str):
    self.isDotSeperatedPreReleaseIdentifier(str),

  isDotSeperatedPreReleaseIdentifier(str):
    self.isPreReleaseIdentifier(str)
    || std.all(std.map(
      self.isPreReleaseIdentifier,
      std.split(str, '.')
    )),

  isBuild(str):
    self.isDotSeperatedBuildIdentifier(str),

  isDotSeperatedBuildIdentifier(str):
    self.isBuildIdentifier(str)
    || std.all(std.map(
      self.isBuildIdentifier,
      std.split(str, '.')
    )),

  isPreReleaseIdentifier(str):
    self.isAlphanumericIdentifier(str)
    || self.isNumericIdentifier(str),

  isBuildIdentifier(str):
    self.isAlphanumericIdentifier(str)
    || self.isDigits(str),

  isAlphanumericIdentifier(str):
    std.length(str) > 0
    && self.isIdentifierCharacters(str)
    && std.any(std.map(
      self.isNonDigit,
      std.stringChars(str)
    )),

  isNumericIdentifier(str):
    std.length(str) > 0
    && (
      self.isZero(str)
      || self.isPositiveDigit(str)
      || (self.isPositiveDigit(str[0]) && self.isDigits(str[1:]))
    ),

  isIdentifierCharacters(str):
    std.length(str) > 0
    && std.all(std.map(
      self.isIdentifierCharacter,
      std.stringChars(str)
    )),

  isIdentifierCharacter(c):
    self.isDigit(c)
    || self.isNonDigit(c),

  isNonDigit(c):
    self.isLetter(c)
    || c == '-',

  isDigits(str):
    std.length(str) > 0
    && std.all(std.map(
      self.isDigit,
      std.stringChars(str)
    )),

  isDigit(c):
    self.isZero(c)
    || self.isPositiveDigit(c),

  local cp(c) = std.codepoint(c),

  isZero(c):
    std.length(c) == 1
    && cp(c) == 48,  // 0

  isPositiveDigit(c):
    std.length(c) == 1
    && (cp(c) >= 49 && cp(c) <= 57),  // [1-9]

  isLetter(c):
    std.length(c) == 1
    && (
      (cp(c) >= 97 && cp(c) < 123)  // [a-z]
      || (cp(c) >= 65 && cp(c) < 91)  // [A-Z]
    ),
}
