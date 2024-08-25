# semver

Jsonnet library to parse and validate Semantic Versioning.

Implemented according spec Semantic Versioning 2.0.0

Using BNF: https://semver.org/#backusnaur-form-grammar-for-valid-semver-versions

## Install

```
jb install github.com/Duologic/semver-libsonnet/semver@main
```
## Usage

Example:

```jsonnet
local semver = import 'github.com/Duologic/semver-libsonnet/semver/main.libsonnet';

semver.parse('2.0.0-rc.1+build.123')

```

Output:

```json
{
    "build": "build.123",
    "major": "2",
    "minor": "0",
    "patch": "0",
    "pre-release": "rc.1"
}
```


## Index

* [`fn parse(semver)`](#fn-parse)
* [`fn validate(semver)`](#fn-validate)

## Fields

### fn parse

```jsonnet
parse(semver)
```

PARAMETERS:

* **semver** (`string`)

`parse` will parse and validate a Semantic Version from a string and returning an object. It'll throw an assertion if the string is not valid.
### fn validate

```jsonnet
validate(semver)
```

PARAMETERS:

* **semver** (`string`)

`validate` will parse and validate a Semantic Version from a string and return a boolean.