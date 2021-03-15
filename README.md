# LinearOptimization

A package providing a interface for linear algebra, including linear optimization.
This package provides a matrix struct, some gaussian operations and the simplex algorithm to solve LOPs.

## Installation

### Using Git
```bash
git clone https://github.com/Unamed001/LinearOptimization && cd LinearOptimization
swift build
```

```swift
// Package.swift
...
dependencies: [
  ...
  .package(path: "path/to/local/copy")
]
...
```

### Using Swift Packages

```swift
// Package.swift
...
dependencies: [
  ...
  .package(url: "https://github.com/Unamed001/LinearOptimization", from: Version(1,0,0))
]
...
```
## Usage

The LOPs to be solved should be in semi-NF:
`$$\text{min } c^Tx + \lambda \text{ with } Ax \leq b \text{ and } A_{eq}x = b_{eq} \text{ and } x \geq 0_n$$`

This can be defined using the matrix & LOP structs.
```swift 
let lop = LOP<Double>(
    c: [ 8, 8, -9, 0, 0 ],
    A: .init([
        [ 1, 1, 1, 0, 0 ],
    ]),
    b: [ 1 ],
    Aeq: .init([
        [ 2, 4, 1, -1, 0 ],
        [ 1, -1, -1, 0, -1 ]
    ]),
    beq: [ 8, 2 ]
)

let result = linprog(p)
```
## License


LinearOptimization is available under the MIT license.

Copyright 2020 Petrichor(https://github.com/Unamed001)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
