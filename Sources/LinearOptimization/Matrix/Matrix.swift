//
//  Matrix.swift
//  LinearOptimization
//
//  Created by MK_Dev on 16.02.21.
//

import Swift

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
    internal var data: [Element]
    
    /// The number of rows in the given matrix.
    public var rows: Int
    
    /// The number of colums in the given matrix.
    public var cols: Int
    
    /// The number of element in the matrix
    @inlinable
    public var count: Int { return self.cols * self.rows }
    
    /// Indicates if a matrix is a vector (single-colum matrix).
    @inlinable
    public var isVec: Bool { return self.cols == 1 }
    
    /// Indicates if a matrix is a vector (single-colum matrix).
    @inlinable
    public var isColVec: Bool { return self.rows == 1 }
    
    /// Indicates if a matrix is a square matrix.
    @inlinable
    public var isSquare: Bool { return self.cols == self.rows }
}

// MARK: - Initalizers

extension Matrix: ExpressibleByArrayLiteral {
    
    ///
    /// Constructs a new matrix using a the raw data.
    ///
    /// - parameter data: A two-dimensional array of raw values.
    ///
    public init(_ data: [[Element]] = []) {
        self.rows = data.count
        self.cols = data.first?.count ?? 0
        self.data = data.reduce([], { $0 + $1 })
    }
    
    ///
    /// Constructs a new matrix using the raw values,
    /// formatted by the given rows & cols.
    ///
    /// - parameter data: The raw array pointer.
    /// - parameter rows: The number of rows in the matrix.
    /// - parameter cols: The number of colums in the matrix.
    ///
    public init(_ data: [Element], _ rows: Int, _ cols: Int) {
        assert(data.count == rows * cols, "Invalid number of raw values")
        self.rows = rows
        self.cols = cols
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
    public init(_ rows: Int, _ cols: Int, value: Element) {
        assert(rows >= 0 && cols >= 0, "Invalid Dimensions")
        self.rows = rows
        self.cols = cols
        self.data = [Element](repeating: value, count: cols * rows)
    }
    
    ///
    /// Constructs a quadratic matrix using the provided fill value.
    ///
    /// - parameter dimension:
    /// The size of the matrix, resulting in a NxN matrix.
    /// - parameter value:
    /// The fill value to be used.
    ///
    public init(_ dimension: Int, value: Element) {
        self.init(dimension, dimension, value: value)
    }
    
    ///
    /// Constructs a new vector (single-colum matrix)
    /// using the provided values.
    ///
    /// - parameter vectorData:
    /// An array containing the raw values for the vector.
    ///
    public init(vector vectorData: [Element]) {
        self.rows = vectorData.count
        self.cols = 1
        self.data = vectorData
    }
    
    ///
    /// Constructs a new vector (single-colum matrix)
    /// using the provided values.
    ///
    /// - parameter vectorData:
    /// An array containing the raw values for the vector.
    ///
    public init(vector vectorData: Element...) {
        self.init(vector: vectorData)
    }
    
    public typealias ArrayLiteralElement = Element
    public init(arrayLiteral elements: Self.ArrayLiteralElement...) {
        self.init(vector: elements)
    }
    
    ///
    /// Constructs a new diagonal matrix (values on main diagonal)
    /// using the provided values.
    ///
    /// - parameter diagonalValues: An array containing the raw values.
    /// - parameter fillValue: The value to be used in non-diagonal fields.
    ///
    public init(diagonal diagonalValues: [Element], fill fillValue: Element) {
        self.rows = diagonalValues.count
        self.cols = diagonalValues.count
        self.data = [Element](repeating: fillValue, count: self.cols * self.rows)
        for i in 0..<diagonalValues.count {
            self[i, i] = diagonalValues[i]
        }
    }
}

extension Matrix where Element: AdditiveArithmetic {
    
    ///
    /// Construct a new matrix using a zero as fill value.
    ///
    /// - parameter rows:
    /// The number of rows in the matrix to be constructed.
    /// - parameter cols:
    /// The number of colums in the matrix to be constructed.
    ///
    public init(_ rows: Int, _ cols: Int) {
        self.init(rows, cols, value: .zero)
    }
    
    ///
    /// Constructs a quadratic matrix using zero as fill value.
    ///
    /// - parameter dimension:
    /// The size of the matrix, resulting in a NxN matrix.
    ///
    public init(_ dimension: Int) {
        self.init(dimension, dimension, value: .zero)
    }
    
    ///
    /// Constructs a new diagonal matrix (values on main diagonal)
    /// using the provided values.
    ///
    /// - parameter diagonalValues: An array containing the raw values.
    /// - parameter fillValue: The value to be used in non-diagonal fields.
    ///
    public init(diagonal diagonalValues: [Element]) {
        self.init(diagonal: diagonalValues, fill: .zero)
    }
}

// MARK: - Derived Protocols
extension Matrix: Equatable where Element: Equatable {}
extension Matrix: Encodable where Element: Encodable {}
extension Matrix: Decodable where Element: Decodable {}

extension Matrix: Hashable where Element: Hashable {
    public var customHashValue: Int {
        var hasher = Hasher()
        hasher.combine(self)
        return hasher.finalize()
    }
}

extension Matrix: Sequence {
    
    public typealias Iterator = MatrixIterator
    
    ///
    /// A Iterator iterating over a given matrix left-to-right &
    /// top-to-bottom.
    ///
    public struct MatrixIterator: Sequence, IteratorProtocol {
        /// The current raw index (=row*cols + col) of the iterator.
        var index: Int = 0
        
        /// The referenced matrix.
        var matrix: Matrix
        
        public mutating func next() -> Element? {
            guard self.index < self.matrix.data.count else {
                return nil
            }
            defer { self.index += 1 }
            return self.matrix.data[self.index]
        }
    }
    
    public __consuming func makeIterator() -> Matrix<Element>.Iterator {
        return MatrixIterator(matrix: self)
    }
}

extension Matrix where Element: Comparable {
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
    public static func < (lhs: Matrix<Element>, rhs: Matrix<Element>) -> Bool {
        precondition(lhs.isVec && rhs.isVec, "Compare operator can only be applied on vectors")
        return lhs.data < rhs.data
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
    public static func <= (lhs: Matrix<Element>, rhs: Matrix<Element>) -> Bool {
        precondition(lhs.isVec && rhs.isVec, "Compare operator can only be applied on vectors")
        return lhs.data <= rhs.data
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
    public static func > (lhs: Matrix<Element>, rhs: Matrix<Element>) -> Bool {
        precondition(lhs.isVec && rhs.isVec, "Compare operator can only be applied on vectors")
        return lhs.data > rhs.data
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
    public static func >= (lhs: Matrix<Element>, rhs: Matrix<Element>) -> Bool {
        precondition(lhs.isVec && rhs.isVec, "Compare operator can only be applied on vectors")
        return lhs.data >= rhs.data
    }
}

// MARK: - Subscripts
extension Matrix {
    ///
    /// Refrences a element at the given index pair.
    ///
    /// - parameter row: The row index of the referenced element.
    /// - parameter col: The colum index of the referenced element.
    ///
    public subscript(_ row: Int, _ col: Int) -> Element {
        set {
            assert(row >= 0 && row < self.rows, "Index(Row) out of bounds")
            assert(col >= 0 && col < self.cols, "Index(Col) out of bounds")
            self.data[row * self.cols + col] = newValue
        }
        get {
            assert(row >= 0 && row < self.rows, "Index(Row) out of bounds")
            assert(col >= 0 && col < self.cols, "Index(Col) out of bounds")
            return self.data[row * self.cols + col]
        }
    }
    
    @inlinable
    public subscript
        <L: ClosableRangeExpression, R: ClosableRangeExpression>
        (_ rows: L, _ cols: R) -> Matrix
        where L.Bound == Int, R.Bound == Int
    {
        set {
            let rows = rows.clamped(to: 0..<self.rows)
            let cols = cols.clamped(to: 0..<self.cols)
            
            assert(rows.lowerBound + newValue.rows <= self.rows, "Range(Row) exceeds matrix dimensions")
            assert(cols.lowerBound + newValue.cols <= self.cols, "Range(Row) exceeds matrix dimensions")
            
            for row in 0..<newValue.rows {
                for col in 0..<newValue.cols {
                    self[rows.lowerBound + row, cols.lowerBound + col] = newValue[row, col]
                }
            }
        }
        get {
            let rows = rows.clamped(to: 0..<self.rows)
            let cols = cols.clamped(to: 0..<self.cols)
            
            let fRows = rows.upperBound - rows.lowerBound + 1
            let fCols = cols.upperBound - cols.lowerBound + 1
            
            var data = [Element]()
            data.reserveCapacity(fRows * fCols)
            
            for row in 0...(rows.upperBound - rows.lowerBound) {
                for col in 0...(cols.upperBound - cols.lowerBound) {
                    data.append(self[rows.lowerBound + row, cols.lowerBound + col])
                }
            }
            
            return Matrix(data, fRows, fCols)
        }
    }
}

// MARK: - Describtables

extension Matrix: CustomStringConvertible where Element: CustomStringConvertible {
    public var description: String {
        var str = "Matrix<\(self.rows)x\(self.cols)>"
        for row in 0..<self.rows {
            str += "\n"
            for col in 0..<self.cols {
                str += "\(self[row, col])"
                if col != self.cols - 1 {
                    str += ", "
                }
            }
        }
        return str
    }
}

extension Matrix: CustomDebugStringConvertible where Element: CustomDebugStringConvertible {
    public var debugDescription: String {
        var str = "Matrix<\(Element.self): \(self.rows)x\(self.cols)>"
        for row in 0..<self.rows {
            str += "\n"
            for col in 0..<self.cols {
                str += "\(self[row, col])"
                if col != self.cols - 1 {
                    str += ", "
                }
            }
        }
        return str
    }
}
