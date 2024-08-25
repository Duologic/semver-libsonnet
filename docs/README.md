# semver

Jsonnet library to parse and validate Semantic Versioning.

Implemented according spec Semantic Versioning 2.0.0
Using BNF: https://semver.org/#backusnaur-form-grammar-for-valid-semver-versions

## Install

```
jb install github.com/Duologic/semver-libsonnet/semver@main
```

## Usage

```jsonnet
local semver = import "github.com/Duologic/semver-libsonnet/semver/main.libsonnet"
```


## Index

* [`fn parse(str)`](#fn-parse)
* [`fn validate(str)`](#fn-validate)

## Fields

### fn parse

```jsonnet
parse(str)
```

PARAMETERS:

* **str** (`string`)

`parse` will parse and validate a Semantic Version from a string and returning an object. It'll throw and assertion if the string is not valid.
### fn validate

```jsonnet
validate(str)
```

PARAMETERS:

* **str** (`string`)

`validate` will parse and validate a Semantic Version from a string and return a boolean.