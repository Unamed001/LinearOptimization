//
//  File.swift
//  
//
//  Created by MK_Dev on 16.02.21.
//

import Foundation

/// An ordered tow-dimensional collection.
///
/// A matrix is a two-dimensional collection of elements supporting
/// any type avaiable.
///
/// ```
/// let matrix = Matrix<String>([
///     [ "Hi", "This", "Is" ],
///     [ "A", "Matrix", "That" ],
///     [ "Contains", "Strings", "!" ]
/// ])
/// print(matrix[0, 0]) // Prints "Hi"
/// ```
///
/// Dependent on the Element type additional functionality is
/// added to the struct, including typical operations on number
/// based matrices.
///
/// ```
/// let mt = Matrix<Int>([
///     [ 1, 3 ],
///     [ 3, -4]
/// ])
/// print(mt.determinant) // Prints "-13"
/// ```
struct Matrix<Element> {
    
    /// The type of the elements contained in the matrix.
    typealias Element = Element
    
    /// The core representation of the data.
    private var data: [[Element]]
    
    /// The number of rows in the given matrix.
    public var rows: Int
    
    /// The number of colums in the given matrix.
    public var cols: Int
    
    /// Indicates if a matrix is a vector (on colum matrix).
    @inlinable
    public var isVec: Bool { return self.cols == 1 }
}

// MARK: - Initalisers

extension Matrix {
    
    /// Constructs a new matrix using a the raw data.
    /// - parameter data: A two-dimensional array of raw values.
    init(_ data: [[Element]] = []) {
        self.rows = data.count
        self.cols = data.first?.count ?? 0
        self.data = data
    }
    
    // Construct a new matrix using a single fill value.
    /// - parameter rows: The number of rows in the matrix to be constructed.
    /// - parameter cols: The number of colums in the matrix to be constructed.
    /// - parameter value: The fill value to be used to prefill the matrix.
    init(_ rows: Int, _ cols: Int, value: Element) {
        assert(rows >= 0 && cols >= 0, "Invalid Dimensions")
        self.rows = rows
        self.cols = cols
        self.data = [[Element]](repeating: [Element](repeating: value, count: cols), count: rows)
    }
    
    /// Constructs a quadratic matrix using the provided fill value.
    /// - parameter dimension: The size of the matrix, resulting in a NxN matrix.
    /// - parameter value: The fill value to be used.
    init(_ dimension: Int, value: Element) {
        self.init(dimension, dimension, value: value)
    }
    
    /// Constructs a new vector (single-colum matrix) using the provided values.
    /// - parameter vectorData: An array containing the raw values for the vector.
    init(_ vectorData: [Element]) {
        self.rows = vectorData.count
        self.cols = 1
        self.data = [[Element]](repeating: [Element](), count: vectorData.count)
        for i in 0..<vectorData.count {
            self.data[i].append(vectorData[i])
        }
    }
    
    /// Constructs a new vector (single-colum matrix) using the provided values.
    /// - parameter vectorData: An array containing the raw values for the vector.
    init(_ vectorData: Element...) {
        self.init(vectorData)
    }
    
    /// The Raw type to intialise a vector(single-colum matrix) using a array literal.
    typealias ArrayLiteralElement = Element
    init(arrayLiteral elements: Self.ArrayLiteralElement...) {
        self.init(elements)
    }
    
    /// Constructs a new diagonal matrix (values on main diagonal) using the provided values.
    /// - parameter diagonalValues: An array containing the raw values.
    /// - parameter fillValue: The value to be used in non-diagonal fields.
    init(diagonal diagonalValues: [Element], fill fillValue: Element) {
        self.rows = diagonalValues.count
        self.cols = diagonalValues.count
        self.data = [[Element]](repeating: [Element](repeating: fillValue, count: diagonalValues.count), count: diagonalValues.count)
        for i in 0..<diagonalValues.count {
            self.data[i][i] = diagonalValues[i]
        }
    }
}

extension Matrix where Element: AdditiveArithmetic {
    
    /// Construct a new matrix using a zero as fill value.
    /// - parameter rows: The number of rows in the matrix to be constructed.
    /// - parameter cols: The number of colums in the matrix to be constructed.
    init(_ rows: Int, _ cols: Int) {
        self.init(rows, cols, value: .zero)
    }
    
    /// Constructs a quadratic matrix using zero as fill value.
    /// - parameter dimension: The size of the matrix, resulting in a NxN matrix.
    init(_ dimension: Int, value: Element) {
        self.init(dimension, dimension, value: .zero)
    }
    
    /// Constructs a new diagonal matrix (values on main diagonal) using the provided values.
    /// - parameter diagonalValues: An array containing the raw values.
    /// - parameter fillValue: The value to be used in non-diagonal fields.
    init(diagonal diagonalValues: [Element]) {
        self.init(diagonal: diagonalValues, fill: .zero)
    }
}



// MARK: - Derived Protocols
extension Matrix: Equatable where Element: Equatable {}
extension Matrix: Hashable where Element: Hashable {}
extension Matrix: Encodable where Element: Encodable {}
extension Matrix: Decodable where Element: Decodable {}

extension Matrix where Element: Comparable {
    static func < (lhs: Matrix<Element>, rhs: Matrix<Element>) -> Bool {
        assert(lhs.isVec && rhs.isVec, "Compare operator can only be applied on vectors")
        assert(lhs.rows == rhs.rows, "Compare operator required vectors of same size")
        for idx in 0..<lhs.rows {
            if lhs[idx, 0] >= rhs[idx, 0] {
                return false
            }
        }
        return true
    }
    
    static func <= (lhs: Matrix<Element>, rhs: Matrix<Element>) -> Bool {
        assert(lhs.isVec && rhs.isVec, "Compare operator can only be applied on vectors")
        assert(lhs.rows == rhs.rows, "Compare operator required vectors of same size")
        for idx in 0..<lhs.rows {
            if lhs[idx, 0] > rhs[idx, 0] {
                return false
            }
        }
        return true
    }
    
    static func > (lhs: Matrix<Element>, rhs: Matrix<Element>) -> Bool {
        assert(lhs.isVec && rhs.isVec, "Compare operator can only be applied on vectors")
        assert(lhs.rows == rhs.rows, "Compare operator required vectors of same size")
        for idx in 0..<lhs.rows {
            if lhs[idx, 0] <= rhs[idx, 0] {
                return false
            }
        }
        return true
    }
    
    static func >= (lhs: Matrix<Element>, rhs: Matrix<Element>) -> Bool {
        assert(lhs.isVec && rhs.isVec, "Compare operator can only be applied on vectors")
        assert(lhs.rows == rhs.rows, "Compare operator required vectors of same size")
        for idx in 0..<lhs.rows {
            if lhs[idx, 0] < rhs[idx, 0] {
                return false
            }
        }
        return true
    }
}

// MARK: - Subscripts
extension Matrix {
    @inlinable
    subscript(_ row: Int, _ col: Int) -> Element {
        set {
            assert(row >= 0 && row < self.rows, "Index(Row) out of bounds")
            assert(col >= 0 && col < self.cols, "Index(Col) out of bounds")
            self.data[row][col] = newValue
        }
        get {
            assert(row >= 0 && row < self.rows, "Index(Row) out of bounds")
            assert(col >= 0 && col < self.cols, "Index(Col) out of bounds")
            return self.data[row][col]
        }
    }
    
    @inlinable
    subscript(_ row: Int) -> [Element] {
        set {
            assert(row >= 0 && row < self.rows, "Index(Row) out of bounds")
            self.data[row] = newValue
        }
        get {
            assert(row >= 0 && row < self.rows, "Index(Row) out of bounds")
            return self.data[row]
        }
    }
}

extension Matrix where Element: AdditiveArithmetic {
    
    @inlinable
    subscript(_ rows: Range<Int>, _ cols: Range<Int>) -> Matrix {
        set {
            self[ClosedRange(rows), ClosedRange(cols)] = newValue
        }
        get {
            return self[ClosedRange(rows), ClosedRange(cols)]
        }
    }
    
    @inlinable
    subscript(_ rows: Range<Int>, _ cols: ClosedRange<Int>) -> Matrix {
        set {
            self[ClosedRange(rows), cols] = newValue
        }
        get {
            return self[ClosedRange(rows), cols]
        }
    }
    
    @inlinable
    subscript(_ rows: ClosedRange<Int>, _ cols: Range<Int>) -> Matrix {
        set {
            self[rows, ClosedRange(cols)] = newValue
        }
        get {
           return self[rows, ClosedRange(cols)]
        }
    }
    
    @inlinable
    subscript(_ rows: ClosedRange<Int>, _ cols: ClosedRange<Int>) -> Matrix {
        set {
            assert(rows.lowerBound >= 0 && rows.upperBound < self.rows, "Range(Row) out of bounds")
            assert(cols.lowerBound >= 0 && cols.upperBound < self.cols, "Range(Col) out of bounds")
            
            assert(rows.upperBound - rows.lowerBound + 1 == newValue.rows)
            assert(cols.upperBound - cols.lowerBound + 1 == newValue.cols)
            
            for row in 0...(rows.upperBound - rows.lowerBound) {
                for col in 0...(cols.upperBound - cols.lowerBound) {
                    self[rows.lowerBound + row, cols.lowerBound + col] = newValue[row, col]
                }
            }
        }
        get {
            
            assert(rows.lowerBound >= 0 && rows.upperBound < self.rows, "Range(Row) out of bounds")
            assert(cols.lowerBound >= 0 && cols.upperBound < self.cols, "Range(Col) out of bounds")
            
            var mat = Matrix<Element>(
                rows.upperBound - rows.lowerBound + 1,
                cols.upperBound - cols.lowerBound + 1
            )
            
            for row in 0...(rows.upperBound - rows.lowerBound) {
                for col in 0...(cols.upperBound - cols.lowerBound) {
                    mat[row, col] = self[rows.lowerBound + row, cols.lowerBound + col]
                }
            }
            
            return mat
        }
    }
}

// MARK: - Describtables

extension Matrix: CustomStringConvertible where Element: CustomStringConvertible {
    var description: String {
        return ([ "Matrix<\(self.rows)x\(self.cols)>" ]
            + self.data.map { $0.map { $0.description }.joined(separator: ", ") })
        .joined(separator: "\n")
    }
}

extension Matrix: CustomDebugStringConvertible where Element: CustomDebugStringConvertible {
    var debugDescription: String {
        return ([ "Matrix<\(Element.self): \(self.rows)x\(self.cols)>" ]
            + self.data.map { $0.map { $0.debugDescription }.joined(separator: ", ") })
        .joined(separator: "\n")
    }
}

// MARK: - Operations

extension Matrix {
    static func transpose(_ operand: Matrix) -> Matrix {
        var data = [[Element]]()
        for col in 0..<operand.cols {
            data.append([])
            for row in 0..<operand.rows {
                data[col].append(operand[row,col])
            }
        }
        return Matrix(data)
    }
}

extension Matrix where Element: AdditiveArithmetic {
    static func add(_ lhs: Matrix, _ rhs: Matrix) -> Matrix {
        assert(lhs.isVec && rhs.isVec, "Cannot use addition on matrices")
        assert(lhs.rows == rhs.rows)
        
        var ret = lhs
        for i in 0..<rhs.rows {
            ret[i, 0] += rhs[i, 0]
        }
        return ret
    }
}

extension Matrix where Element: Numeric {
    
    /// A numeric value characterising the type of a matrix.
    ///
    /// Is implemented using the Laplace expansion.
    /// - TODO:
    /// Implement using Gauß-Jordan reduction & diagonal rule.
    var determinant: Element {
        assert(self.rows == self.cols)
        if self.rows == 2 {
            return self[0, 0] * self[1, 1] - self[1, 0] * self[0, 1]
        }
        
        let n = self.rows - 1
        
        var sb = Matrix(n,n)
        var sum: Element = .zero
        for i in 0...n {
            if i != 0 {
                sb[0..<n, 0..<i] = self[1...n, 0..<i]
            }
            if i != n {
                sb[0..<n, i..<n] = self[1...n, (i + 1)...n]
            }
            
            if i % 2 == 0 {
                sum += self[0, i] * sb.determinant
            } else {
                sum -= self[0, i] * sb.determinant
            }
        }
        return sum
    }
    
    static func skalar(_ lhs: Element, _ rhs: Matrix) -> Matrix {
        var mat = rhs
        for row in 0..<mat.rows {
            for col in 0..<mat.cols {
                mat[row, col] *= lhs
            }
        }
        return mat
    }
}

infix operator *: MultiplicationPrecedence
func * <Element: Numeric>
    (_ lhs: Element, _ rhs: Matrix<Element>) -> Matrix<Element> {
    return Matrix<Element>.skalar(lhs, rhs)
}

infix operator +: AdditionPrecedence
func + <Element: AdditiveArithmetic>
    (_ lhs: Matrix<Element>, _ rhs: Matrix<Element>) -> Matrix<Element> {
    return Matrix<Element>.add(lhs, rhs)
}

prefix operator %
prefix func % <Element: AdditiveArithmetic>
    (_ operand: Matrix<Element>) -> Matrix<Element> {
    return Matrix<Element>.transpose(operand)
}
