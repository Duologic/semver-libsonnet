local parser = import './main.libsonnet';
std.map(
  parser.parse,
  [
    '1.2.3',
    '0.2.3',
    '1.20.3',
    '1.1.1-alpha',
    '1.1.1-alpha+5443',
    '1.1.1+5443',
    '1.1.1+5443alpha',
    '1.1.1+alpha5443',
    '1.1.1-alpha5443',
    // expect failures:
    //'01.2.3',
    //'1.2.03',
    //'1.2.3.4',
    //'1.2',
    //'1.1.1+5443-alpha',
    //'1.1.1-alpha54%43',
  ]
)
