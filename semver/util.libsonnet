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
    local splitinput =
      std.map(
        function(str)
          std.split(str, '.'),
        input
      );

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

    local sortKeys(keys) =
      local digits = std.filter(validate.isDigits, keys);
      local words = std.filter(function(x) !validate.isDigits(x), keys);
      std.sort(digits, std.parseInt)
      + std.sort(words);

    local sortTree(tree) =
      std.foldl(
        function(acc, key)
          acc
          + [key]
          + [
            key + '.' + k
            for k in sortTree(tree[key])
          ],
        sortKeys(std.objectFields(tree)),
        [],
      );

    local sorted = sortTree(buildtree);

    // only return tags that were in the input
    std.filter(
      function(x)
        std.member(input, x),
      sorted
    ),
}
