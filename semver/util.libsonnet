local semver = import './main.libsonnet';
local validate = import './validator.libsonnet';

{
  sortSemVer(arr):
    local preReleaseTags =
      self.sortPreReleaseTags(
        std.filterMap(
          function(x) 'pre-release' in x,
          function(x) x['pre-release'],
          arr,
        )
      );

    std.reverse(
      std.foldl(
        std.sort,
        [
          function(x)
            if 'pre-release' in x
            then std.find(x['pre-release'], preReleaseTags)[0]
            else std.length(preReleaseTags),
          function(x) x.patch,
          function(x) x.minor,
          function(x) x.major,
        ],
        arr,
      )
    ),

  sortPreReleaseTags(input):
    // Precedence:
    // 1. Identifiers consisting of only digits are compared numerically.
    // 2. Identifiers with letters or hyphens are compared lexically in ASCII sort order.
    // 3. Numeric identifiers always have lower precedence than non-numeric identifiers.
    // 4. A larger set of pre-release fields has a higher precedence than a smaller set, if all of the preceding identifiers are equal.

    local splitinput =
      std.map(
        function(str)
          std.split(str, '.'),
        input
      );

    // this'll build a verbose tree with all possible tags
    local buildtree =
      std.foldl(
        function(acc, tag)
          acc + std.foldl(
            function(acc, key)
              { [key]+: acc },
            std.reverse(tag),
            {}
          ),
        splitinput,
        {},
      );

    // compare numeric and non-numeric seperately
    // then merge, higher index == higher precedence
    local sortKeys(keys) =
      local digits = std.filter(validate.isDigits, keys);
      local words = std.filter(function(x) !validate.isDigits(x), keys);
      std.sort(digits, std.parseInt)
      + std.sort(words);

    // recursively apply sortKeys to the keys of the tree, then return keys as an array
    local sortTree(tree) =
      std.foldl(
        function(acc, key)
          acc
          + [key]
          // larger set after key, higher index == higher precedence
          + std.map(
            function(k)
              key + '.' + k,
            sortTree(tree[key])
          ),
        sortKeys(std.objectFields(tree)),
        [],
      );

    // this'll be a verbose sorted array of all possible release tag sets
    local sorted = sortTree(buildtree);

    // only return tags that were part of the input
    std.filter(
      function(x)
        std.member(input, x),
      sorted
    ),
}
