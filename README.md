# QQ 0.1.1

[![Build Status](http://img.shields.io/travis/MrBeardy/OTBExercise.svg)][travis]
[![Code Climate](http://img.shields.io/codeclimate/github/MrBeardy/OTBExercise.svg)][codeclimate]
[![Coverage Status](http://img.shields.io/coveralls/MrBeardy/OTBExercise.svg)][coveralls]
[![License](https://img.shields.io/badge/license-MIT-blue.svg)][license]

[travis]: https://travis-ci.org/MrBeardy/OTBExercise
[codeclimate]: https://codeclimate.com/github/MrBeardy/OTBExercise
[coveralls]: https://coveralls.io/r/MrBeardy/OTBExercise
[license]: LICENSE

QQ is a small library that takes a formatted string (or multi-dimensional 
array) as input and stores it as Jobs with optional dependencies.

This job list can then be sorted using 
[TSort](http://ruby-doc.org/stdlib/libdoc/tsort/rdoc/TSort.html) to ensure
proper dependency ordering and Cyclic dependency safety.

# Usage
```ruby
require 'qq'

qq = QQ.new %|
  a =>
  b => c
  c => f
  d => a
  e => b
  f =>
|

p qq.job_list.tsort_ids
# => ['a', 'f', 'c', 'b', 'd', 'e']

p qq.run
# => 'afcbde'

QQ.new([
  ['a', 'b'],
  ['b', 'c'],
  ['c'],
]).run
# =>'cba'

```

### Jobs
```ruby
qq = QQ.new [
  QQ::Job.new('a', ['b']) { 'world' },
  QQ::Job.new('b') { 'Hello ' },
]

p qq.run
# => 'Hello world'
```

### Command Line

```bash
$ bin/qq 'a=>b;b=>c;c=>'
cba
```

# Testing

To test, use the `rspec` command in the root directory. 
You can also limit testing against the OTB exercise specification by
using `rspec --tag otb`.

# Roadmap

- Take over the world

# License

The MIT License (MIT)

Copyright (c) 2015 Michael Hibbs

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
