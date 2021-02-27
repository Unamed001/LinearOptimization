//
//  Matrix.swift
//  LinearOptimization
//
//  Created by MK_Dev on 16.02.21.
//

///
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
/// print(Matrix.det(mt)) // Prints "-13"
/// ```
///
public struct Matrix<Element> {
    
    /// The type of the elements contained in the matrix.
    public typealias Element = Element
    
    /// The core representation of the data.
    internal var data: [[Element]]
    
    /// The number of rows in the given matrix.
    public var rows: Int
    
    /// The number of colums in the given matrix.
    public var cols: Int
    
    /// Indicates if a matrix is a vector (on colum matrix).
    @inlinable
    public var isVec: Bool { return self.cols == 1 }
}

// MARK: - Initalisers

public extension Matrix {
    
    ///
    /// Constructs a new matrix using a the raw data.
    ///
    /// - parameter data: A two-dimensional array of raw values.
    ///
    init(_ data: [[Element]] = []) {
        self.rows = data.count
        self.cols = data.first?.count ?? 0
        self.data = data
    }
    
    ///
    /// Construct a new matrix using a single fill value.
    ///
    /// - parameter rows:
    /// The number of rows in the matrix to be constructed.
    /// - parameter cols:
    /// The number of colums in the matrix to be constructed.
    /// - parameter value:
    /// The fill value to be used to prefill the matrix.
    ///
    init(_ rows: Int, _ cols: Int, value: Element) {
        assert(rows >= 0 && cols >= 0, "Invalid Dimensions")
        self.rows = rows
        self.cols = cols
        self.data = [[Element]](repeating: [Element](repeating: value, count: cols), count: rows)
    }
    
    ///
    /// Constructs a quadratic matrix using the provided fill value.
    ///
    /// - parameter dimension:
    /// The size of the matrix, resulting in a NxN matrix.
    /// - parameter value:
    /// The fill value to be used.
    ///
    init(_ dimension: Int, value: Element) {
        self.init(dimension, dimension, value: value)
    }
    
    ///
    /// Constructs a new vector (single-colum matrix)
    /// using the provided values.
    ///
    /// - parameter vectorData:
    /// An array containing the raw values for the vector.
    ///
    init(_ vectorData: [Element]) {
        self.rows = vectorData.count
        self.cols = 1
        self.data = [[Element]](repeating: [Element](), count: vectorData.count)
        for i in 0..<vectorData.count {
            self.data[i].append(vectorData[i])
        }
    }
    
    ///
    /// Constructs a new vector (single-colum matrix)
    /// using the provided values.
    ///
    /// - parameter vectorData:
    /// An array containing the raw values for the vector.
    ///
    init(_ vectorData: Element...) {
        self.init(vectorData)
    }
    
    typealias ArrayLiteralElement = Element
    init(arrayLiteral elements: Self.ArrayLiteralElement...) {
        self.init(elements)
    }
    
    ///
    /// Constructs a new diagonal matrix (values on main diagonal)
    /// using the provided values.
    ///
    /// - parameter diagonalValues: An array containing the raw values.
    /// - parameter fillValue: The value to be used in non-diagonal fields.
    ///
    init(diagonal diagonalValues: [Element], fill fillValue: Element) {
        self.rows = diagonalValues.count
        self.cols = diagonalValues.count
        self.data = [[Element]](repeating: [Element](repeating: fillValue, count: diagonalValues.count), count: diagonalValues.count)
        for i in 0..<diagonalValues.count {
            self.data[i][i] = diagonalValues[i]
        }
    }
}

public extension Matrix where Element: AdditiveArithmetic {
    
    ///
    /// Construct a new matrix using a zero as fill value.
    ///
    /// - parameter rows:
    /// The number of rows in the matrix to be constructed.
    /// - parameter cols:
    /// The number of colums in the matrix to be constructed.
    ///
    init(_ rows: Int, _ cols: Int) {
        self.init(rows, cols, value: .zero)
    }
    
    ///
    /// Constructs a quadratic matrix using zero as fill value.
    ///
    /// - parameter dimension:
    /// The size of the matrix, resulting in a NxN matrix.
    ///
    init(_ dimension: Int, value: Element) {
        self.init(dimension, dimension, value: .zero)
    }
    
    ///
    /// Constructs a new diagonal matrix (values on main diagonal)
    /// using the provided values.
    ///
    /// - parameter diagonalValues: An array containing the raw values.
    /// - parameter fillValue: The value to be used in non-diagonal fields.
    ///
    init(diagonal diagonalValues: [Element]) {
        self.init(diagonal: diagonalValues, fill: .zero)
    }
}



// MARK: - Derived Protocols
extension Matrix: Hashable where Element: Hashable {}
extension Matrix: Encodable where Element: Encodable {}
extension Matrix: Decodable where Element: Decodable {}

extension Matrix {
    ///
    /// Returns a boolean value indicating whether the matrix
    /// contains an element that satisfies the given predicate.
    ///
    /// - parameter predicate:
    /// A closure that takes an element of the sequence as its argument
    /// and returns a Boolean value that indicates
    /// whether the passed element represents a match.
    ///
    /// - returns:
    /// true if the sequence contains an element that satisfies predicate;
    /// otherwise, false.
    ///
    /// You can use the predicate to check for an element of a type that
    /// does not conform the `Equable` protocol.
    /// ```
    /// enum Slice {
    ///     case first
    ///     case pfix(length: Int)
    /// }
    ///
    /// let matrix = Matrix<Slice>([
    ///     [ .first, .first, .pfix(4) ],
    ///     [ .pfix(1), .first, .first ]
    /// ])
    ///
    /// matrix.contains(where: { (tpl) -> Bool in
    ///     if .pfix(let l) = tpl {
    ///         return l > 3
    ///     }
    ///     return false
    /// })
    /// // Returns true
    /// ```
    /// Complexity: O(n*m)
    ///
    public func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        for row in 0..<self.rows {
            for col in 0..<self.cols {
                if try predicate(self[row, col]) {
                    return true
                }
            }
        }
        return false
    }
}

extension Matrix: Equatable where Element: Equatable {
    ///
    /// Returns a Boolean value indicating whether the sequence contains the
    /// given element.
    ///
    /// - parameter element: The element to find in the sequence.
    ///
    /// - returns:
    /// true if the element was found in the sequence; otherwise, false.
    ///
    /// You can use this method on any type that conforms to the `Equable`
    /// protocol.
    ///
    /// Complexity: O(n*m)
    ///
    public func contains(_ element: Element) -> Bool {
        for row in 0..<self.rows {
            for col in 0..<self.cols {
                if self[row, col] == element {
                    return true
                }
            }
        }
        return false
    }
}

public extension Matrix where Element: Comparable {
    ///
    /// Returns a Boolean indicating whether all element of the first vector
    /// are less than all element of the second vector(row-wise).
    ///
    /// - parameter lhs: A vector to  compared.
    /// - parameter rhs: Another vector to compare.
    ///
    /// - returns: Boolean indicating if the predicate is satisfied.
    ///
    /// Note that this operator does not defined the `Comparable` Protocol
    /// since the row-wise comparison is not a total or partial order.
    /// This operator is neither symmertic nor reflexiv, but tranisitv.
    ///
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
    
    ///
    /// Returns a Boolean indicating whether all element of the first vector
    /// are less or equal than all element of the second vector(row-wise).
    ///
    /// - parameter lhs: A vector to  compared.
    /// - parameter rhs: Another vector to compare.
    ///
    /// - returns: Boolean indicating if the predicate is satisfied.
    ///
    /// Note that this operator does not defined the `Comparable` Protocol
    /// since the row-wise comparison is not a total or partial order.
    /// This operator is reflexiv and transitiv, but not symmertic
    ///
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
    
    ///
    /// Returns a Boolean indicating whether all element of the first vector
    /// are greater than all element of the second vector(row-wise).
    ///
    /// - parameter lhs: A vector to  compared.
    /// - parameter rhs: Another vector to compare.
    ///
    /// - returns: Boolean indicating if the predicate is satisfied.
    ///
    /// Note that this operator does not defined the `Comparable` Protocol
    /// since the row-wise comparison is not a total or partial order.
    /// This operator is neither symmertic nor reflexiv, but tranisitv.
    ///
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
    
    ///
    /// Returns a Boolean indicating whether all element of the first vector
    /// are greater or equal than all element of the second vector(row-wise).
    ///
    /// - parameter lhs: A vector to  compared.
    /// - parameter rhs: Another vector to compare.
    ///
    /// - returns: Boolean indicating if the predicate is satisfied.
    ///
    /// Note that this operator does not defined the `Comparable` Protocol
    /// since the row-wise comparison is not a total or partial order.
    /// This operator is reflexiv and transitiv, but not symmertic
    ///
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
public extension Matrix {
    ///
    /// Returns / Sets the element at the given index.
    ///
    /// - parameter row: The row index of the referenced element.
    /// - parameter col: The colum index of the referenced element.
    ///
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
    
    ///
    /// Returns / Sets a certain row referenced by the given index.
    ///
    /// - parameter row: The row index of the referenced row.
    ///
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

public extension Matrix where Element: AdditiveArithmetic {
    
    @inlinable
    subscript(_ rows: OpenRange<Int>, _ cols: OpenRange<Int>) -> Matrix {
        set {
            self[rows.clamed(to: 0..<self.rows), cols.clamed(to: 0..<self.cols)] = newValue
        }
        get {
            return self[rows.clamed(to: 0..<self.rows), cols.clamed(to: 0..<self.cols)]
        }
    }
    
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
            assert(rows.lowerBound >= 0, "Range(Row) out of bounds")
            assert(cols.lowerBound >= 0, "Range(Col) out of bounds")
            
            assert(rows.lowerBound + newValue.rows <= self.rows, "Range(Rows) exceeds matrix dimensions")
            assert(cols.lowerBound + newValue.cols <= self.cols, "Range(Cols) exceeds matrix dimensions")
            
            for row in 0..<newValue.rows {
                for col in 0..<newValue.cols {
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
    public var description: String {
        return ([ "Matrix<\(self.rows)x\(self.cols)>" ]
            + self.data.map { $0.map { $0.description }.joined(separator: ", ") })
        .joined(separator: "\n")
    }
}

extension Matrix: CustomDebugStringConvertible where Element: CustomDebugStringConvertible {
    public var debugDescription: String {
        return ([ "Matrix<\(Element.self): \(self.rows)x\(self.cols)>" ]
            + self.data.map { $0.map { $0.debugDescription }.joined(separator: ", ") })
        .joined(separator: "\n")
    }
}

// MARK: - Operations

public extension Matrix {
    ///
    /// Returns the tranposed matrix (mirrored at main diagonal)
    /// of the given input matrix.
    ///
    /// - parameter operand:
    /// The matrix to be transposed. Can be of `Element` type.
    ///
    /// - returns:
    /// A new matrix containing the transposed values.
    ///
    /// Not that this implementation of transpose relies on mutable Arrays
    /// due to missing "zero"-values. This can be ineffective at times.
    ///
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

public extension Matrix where Element: AdditiveArithmetic {
    ///
    /// Adds up the given vectors (row-wise) according to the
    /// addition operator defined in the `Element` type.
    ///
    /// - parameter lhs: A vector to be added.
    /// - parameter rhs: Another vector to be added.
    ///
    /// - returns:
    /// A new vector containing the (row-wise) added values
    /// of the input parameters.
    ///
    /// This operation can only be performed on Vectors (single-col matrices)
    /// otherwise the function will fail an assertion.
    ///
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

public extension Matrix where Element: Numeric {
    
    ///
    /// Returns numeric value characterising the type of a quadratic matrix.
    ///
    /// - parameter matrix: The matrix to be characterised.
    ///
    /// - returns:
    /// A numeric value of type `Element` describing the type of the matrix.
    ///
    /// The determinant describe certain Characteristics of the given matrix
    /// (e.g. orthogonal matrices have det(M) = ±1).
    /// This variant used the Lapace-Expansion algorithm
    /// to calculate the determinant.
    ///
    /// - TODO: Implement using Gauß-Jordan reduction & diagonal rule.
    ///
    static func det(_ matrix: Matrix) -> Element {
        assert(matrix.rows == matrix.cols)
        if matrix.rows == 2 {
            return matrix[0, 0] * matrix[1, 1] - matrix[1, 0] * matrix[0, 1]
        }
        
        let n = matrix.rows - 1
        
        var sb = Matrix(n,n)
        var sum: Element = .zero
        for i in 0...n {
            if i != 0 {
                sb[0..<n, 0..<i] = matrix[1...n, 0..<i]
            }
            if i != n {
                sb[0..<n, i..<n] = matrix[1...n, (i + 1)...n]
            }
            
            if i % 2 == 0 {
                sum += matrix[0, i] * det(sb)
            } else {
                sum -= matrix[0, i] * det(sb)
            }
        }
        return sum
    }
    
    ///
    /// Multiplicates all elements of the matrix given in the right operand
    /// with the left operand using the multiplication defined in the
    /// `Element` type.
    ///
    /// - parameter lhs: The skalar value to be applied onto the matrix.
    /// - parameter rhs: The matrix to be changed using the left operand.
    ///
    /// - returns: A new matrix consisting of the calculated values.
    ///
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
public func * <Element: Numeric>
    (_ lhs: Element, _ rhs: Matrix<Element>) -> Matrix<Element> {
    return Matrix<Element>.skalar(lhs, rhs)
}

infix operator +: AdditionPrecedence
public func + <Element: AdditiveArithmetic>
    (_ lhs: Matrix<Element>, _ rhs: Matrix<Element>) -> Matrix<Element> {
    return Matrix<Element>.add(lhs, rhs)
}

prefix operator %
public prefix func % <Element: AdditiveArithmetic>
    (_ operand: Matrix<Element>) -> Matrix<Element> {
    return Matrix<Element>.transpose(operand)
}
