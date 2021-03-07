//
//  Matrix+Operations.swift
//  LinearOptimization
//
//  Created by MK_Dev on 28.02.21.
//

import Swift

extension Matrix {
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
    public static func transpose(_ matrix: Matrix) -> Matrix {
        var raw = [Element]()
        raw.reserveCapacity(matrix.count)
        
        
        for col in 0..<matrix.cols {
            for row in 0..<matrix.rows {
                raw.append(matrix[row, col])
            }
        }
        return Matrix(raw, matrix.cols, matrix.rows)
    }
    
    /// The transposed matrix calculated from itself.
    @inlinable
    var transposed: Matrix {
        return Matrix.transpose(self)
    }
}

extension Matrix where Element: AdditiveArithmetic {
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
    public static func add(_ lhs: Matrix, _ rhs: Matrix) -> Matrix {
        assert(lhs.isVec && rhs.isVec || lhs.isColVec == rhs.isColVec, "Cannot use addition on matrices")
        assert(lhs.rows == rhs.rows && lhs.cols == rhs.cols)
        
        var ret = lhs
        for i in 0..<rhs.rows {
            ret[i, 0] += rhs[i, 0]
        }
        return ret
    }
    
    ///
    /// Returns the trace of the given matrix (often referred as tr(A))
    /// assuming the matrix is a square matrix.
    ///
    /// - parameter matrix: The given matrix.
    /// - returns: The trace of the matrix.
    ///
    public static func trace(_ matrix: Matrix) -> Element {
        assert(matrix.isSquare, "Trace operation tr(A) can only be conducted on square matrices")
        var sum = Element.zero
        for i in 0..<matrix.rows {
            sum += matrix[i, i]
        }
        return sum
    }
    
    /// The trace of the matrix.
    @inlinable
    public var trace: Element {
        return Matrix.trace(self)
    }
}

extension Matrix where Element: Numeric  {
    
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
    public static func det(_ matrix: Matrix) -> Element {
        assert(matrix.isSquare, "Invalid matrix at det(M) call. Expected square matrix.")
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
    
    /// A numeric value characterising the type of a quadratic matrix.
    @inlinable
    public var determinant: Element {
        return Matrix.det(self)
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
    public static func skalar(_ lhs: Element, _ rhs: Matrix) -> Matrix {
        var mat = rhs
        for row in 0..<mat.rows {
            for col in 0..<mat.cols {
                mat[row, col] *= lhs
            }
        }
        return mat
    }
}

extension Matrix where Element: FloatingPoint {
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
    public static func fdet(_ matrix: Matrix) -> Element {
        assert(matrix.isSquare, "Invalid matrix at det(M) call. Expected square matrix.")
        let diag = Gauß._diagonalize(matrix)
        var sum = Element(1)
        for i in 0..<diag.rows {
            sum *= diag[i, i]
        }
        return sum
    }
    
    /// A numeric value characterising the type of a quadratic matrix.
    @inlinable
    var fdeterminant: Element {
        return Matrix.fdet(self)
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
