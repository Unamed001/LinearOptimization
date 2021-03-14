//
//  Gauß.swift
//  LinearOptimization
//
//  Created by MK_Dev on 19.02.21.
//

import Accelerate

/// A collection of gaussian operations.
enum Gaussian {

    // MARK: - Transpose
    
    ///
    /// Caluclates the transposed matrix of a single-precision matrix (out of place).
    ///
    /// - parameter matrix: The matrix to be transposed.
    /// - returns: The transposed matrix.
    ///
    public static func transpose(_ matrix: Matrix<Float>) -> Matrix<Float> {
        var raw = [Float](repeating: .nan, count: matrix.count)
        vDSP_mtrans(matrix.data, 1, &raw, 1, vDSP_Length(matrix.rows), vDSP_Length(matrix.cols))
        return Matrix(raw, matrix.rows, matrix.cols)
    }
    
    ///
    /// Caluclates the transposed matrix of a single-precision matrix (in place).
    ///
    /// - parameter matrix: The matrix to be transposed.
    /// - returns: The transposed matrix.
    ///
    public static func transpose(_ matrix: inout Matrix<Float>) {
        vDSP_mtrans(matrix.data, 1, &matrix.data, 1, vDSP_Length(matrix.rows), vDSP_Length(matrix.cols))
    }
    
    ///
    /// Caluclates the transposed matrix of a double-precision matrix (out of place).
    ///
    /// - parameter matrix: The matrix to be transposed.
    /// - returns: The transposed matrix.
    ///
    public static func transpose(_ matrix: Matrix<Double>) -> Matrix<Double> {
        var raw = [Double](repeating: .nan, count: matrix.count)
        vDSP_mtransD(matrix.data, 1, &raw, 1, vDSP_Length(matrix.rows), vDSP_Length(matrix.cols))
        return Matrix(raw, matrix.rows, matrix.cols)
    }
    
    ///
    /// Caluclates the transposed matrix of a double-precision matrix (in place).
    ///
    /// - parameter matrix: The matrix to be transposed.
    /// - returns: The transposed matrix.
    ///
    public static func transpose(_ matrix: inout Matrix<Double>) {
        vDSP_mtransD(matrix.data, 1, &matrix.data, 1, vDSP_Length(matrix.rows), vDSP_Length(matrix.cols))
    }
    
    
    // MARK: - Determinant
    
    ///
    /// Calculates the determinant of a single-precision matrix.
    ///
    /// - parameter matrix: The matrix to be used.
    /// - returns: The determinant.
    ///
    public static func det(_ matrix: Matrix<Float>) -> Float {
        assert(matrix.isSquare, "det(A) requires A to be a square matrix")
        var matrix = matrix
        let swaps = Gaussian.reduce(&matrix)
        var d: Float = (swaps % 2 == 0) ? 1 : -1
        for idx in 0..<matrix.rows {
            d *= matrix[idx, idx]
        }
        return d
    }
    
    ///
    /// Calculates the determinant of a double-precision matrix.
    ///
    /// - parameter matrix: The matrix to be used.
    /// - returns: The determinant.
    ///
    public static func det(_ matrix: Matrix<Double>) -> Double {
        assert(matrix.isSquare, "det(A) requires A to be a square matrix")
        var matrix = matrix
        let swaps = Gaussian.reduce(&matrix)
        var d: Double = (swaps % 2 == 0) ? 1 : -1
        for idx in 0..<matrix.rows {
            d *= matrix[idx, idx]
        }
        return d
    }
    
    // MARK: - Explicite trinangular reduction
    
    ///
    /// Reduces a given single-precision matrix into explicit lower
    /// triangular form (out of place).
    ///
    /// - parameter: The single-precision matrix to be reduced.
    /// - parameter cols: The maximum number of rows to be used as pivot.
    /// - returns: The new triangular matrix.
    ///
    /// - Space Complexity: O(m) - where m is the number of colums.
    /// - Time Complexity: O(n^2) - where n is the number of rows.
    ///
    public static func reduce(_ matrix: Matrix<Float>, _ cols: Int? = nil) -> Matrix<Float> {
        var matrix = matrix
        Gaussian.reduce(&matrix, cols)
        return matrix
    }
    
    ///
    /// Reduces a given single-precision matrix into explicit lower
    /// triangular form (in place).
    ///
    /// - parameter: The single-precision matrix to be reduced.
    /// - parameter cols: The maximum number of rows to be used as pivot.
    /// - returns: The number of line swaps performed.
    ///
    /// - Space Complexity: O(m) - where m is the number of colums.
    /// - Time Complexity: O(n^2) - where n is the number of rows.
    ///
    @discardableResult
    public static func reduce(_ matrix: inout Matrix<Float>, _ cols: Int? = nil) -> Int {
        // Reduce matrix into implicte form
        Gaussian.ireduce(&matrix, cols)
        
        // The number of line swaps (real ones) needed normalize.
        var swaps = 0
        // The current row to be fixed
        var sRow = 0
        
        // Fix based on pivot element top to bottom
        for col in 0..<(cols ?? matrix.cols) {
            // Find a valid pivot, else try next colum assuming free colum
            guard sRow < matrix.rows else { break }
            guard let row = (sRow..<matrix.rows).first(where: { matrix[$0, col] != 0 }) else { continue }
            
            // Fix new line, swap if nessesary
            defer { sRow += 1 }
            guard sRow != row else { continue }
          
            swaps += 1
            
            matrix.data.withUnsafeMutableBufferPointer { (ptr) in
                vDSP_vswap(
                    ptr.baseAddress! + (sRow*matrix.cols), 1,
                    ptr.baseAddress! + (row*matrix.cols), 1,
                    vDSP_Length(matrix.cols)
                )
            }
        }
        
        return swaps
    }
    
    ///
    /// Reduces a given double-precision matrix into explicit lower
    /// triangular form (out of place).
    ///
    /// - parameter: The double-precision matrix to be reduced.
    /// - parameter cols: The maximum number of rows to be used as pivot.
    /// - returns: The new triangular matrix.
    ///
    /// - Space Complexity: O(m) - where m is the number of colums.
    /// - Time Complexity: O(n^2) - where n is the number of rows.
    ///
    public static func reduce(_ matrix: Matrix<Double>, _ cols: Int? = nil) -> Matrix<Double> {
        var matrix = matrix
        Gaussian.reduce(&matrix, cols)
        return matrix
    }
    
    ///
    /// Reduces a given double-precision matrix into explicit lower
    /// triangular form (in place).
    ///
    /// - parameter: The double-precision matrix to be reduced.
    /// - parameter cols: The maximum number of rows to be used as pivot.
    /// - returns: The number of line swaps performed.
    ///
    /// - Space Complexity: O(m) - where m is the number of colums.
    /// - Time Complexity: O(n^2) - where n is the number of rows.
    ///
    @discardableResult
    public static func reduce(_ matrix: inout Matrix<Double>, _ cols: Int? = nil) -> Int {
        // Reduce matrix into implicte form
        Gaussian.ireduce(&matrix, cols)
        
        // The number of line swaps (real ones) needed normalize.
        var swaps = 0
        // The current row to be fixed
        var sRow = 0
        
        // Fix based on pivot element top to bottom
        for col in 0..<(cols ?? matrix.cols) {
            // Find a valid pivot, else try next colum assuming free colum
            guard sRow < matrix.rows else { break }
            guard let row = (sRow..<matrix.rows).first(where: { matrix[$0, col] != 0 }) else { continue }
            
            // Fix new line, swap if nessesary
            defer { sRow += 1 }
            guard sRow != row else { continue }
          
            swaps += 1
            
            matrix.data.withUnsafeMutableBufferPointer { (ptr) in
                vDSP_vswapD(
                    ptr.baseAddress! + (sRow*matrix.cols), 1,
                    ptr.baseAddress! + (row*matrix.cols), 1,
                    vDSP_Length(matrix.cols)
                )
            }
        }
        
        return swaps
    }
    
    // MARK: - Implicite triangular reduction
    
    
    ///
    /// Reduces a given single-precision matrix into lower implicit
    /// triangle form (out of place).
    ///
    /// - parameter matrix: The single-precision matrix to be reduced.
    /// - parameter cols: The maximum number of rows to be used as pivot.
    /// - returns: The new triangular matrix.
    ///
    /// - Space Complexity: O(m) - where m is the number of colums.
    /// - Time Complexity: O(n^2) - where n is the number of rows.
    ///
    public static func ireduce(_ matrix: Matrix<Float>, _ cols: Int? = nil) -> Matrix<Float> {
        var matrix = matrix
        Gaussian.ireduce(&matrix, cols)
        return matrix
    }
    
    ///
    /// Reduces a given single-precision matrix into lower implicit
    /// triangle form (in place).
    ///
    /// - parameter matrix: The single-precision matrix to be reduced.
    /// - parameter cols: The maximum number of rows to be used as pivot.
    ///
    /// - Space Complexity: O(m) - where m is the number of colums.
    /// - Time Complexity: O(n^2) - where n is the number of rows.
    ///
    public static func ireduce(_ matrix: inout Matrix<Float>, _ cols: Int? = nil) {
        // Allready 'fixed' rows
        var done = [Int]()
        // Buffer for using vDSP vector operations
        var tempBuffer = [Float](repeating: .nan, count: matrix.cols)
        
        // Try to make a 'straircase-step' for each row, ignore if not possible
        for col in 0..<(cols ?? matrix.cols) {
            // Ensure there is a not fixed row
            guard done.count != matrix.rows else { break }
            
            // Extract not fixed row with non-zero pivot element
            guard let row = (0..<matrix.rows).first(where: { !done.contains($0) && matrix[$0, col] != 0 })
                else { continue }
            done.append(row)
            
            // Propergate pivot and normalize other rows
            for trow in 0..<matrix.rows {
                // only *other* rows
                guard trow != row else { continue }
                
                // try reducing pseudo pivot using a factor != 0
                var factor = matrix[trow, col] / matrix[row, col]
                guard factor != 0 else { continue }
                
                // Calculate targetRow -= factor * pivotRow
                matrix.data.withUnsafeMutableBufferPointer { (ptr) in
                    vDSP_vsmul(
                        ptr.baseAddress! + (row * matrix.cols),
                        1,
                        &factor,
                        &tempBuffer,
                        1,
                        vDSP_Length(matrix.cols)
                    )
                    vDSP_vsub(
                        ptr.baseAddress! + (trow * matrix.cols),
                        1,
                        tempBuffer,
                        1,
                        ptr.baseAddress! + (trow * matrix.cols),
                        1,
                        vDSP_Length(matrix.cols)
                    )
                }
            }
        }
    }
    
    ///
    /// Reduces a given double-precision matrix into lower implicit
    /// triangle form (out of place).
    ///
    /// - parameter matrix: The double-precision matrix to be reduced.
    /// - parameter cols: The maximum number of rows to be used as pivot.
    /// - returns: The new triangular matrix.
    ///
    /// - Space Complexity: O(m) - where m is the number of colums.
    /// - Time Complexity: O(n^2) - where n is the number of rows.
    ///
    public static func ireduce(_ matrix: Matrix<Double>, _ cols: Int? = nil) -> Matrix<Double> {
        var matrix = matrix
        Gaussian.ireduce(&matrix, cols)
        return matrix
    }
    
    ///
    /// Reduces a given double-precision matrix into lower implicit
    /// triangle form (in place).
    ///
    /// - parameter matrix: The double-precision matrix to be reduced.
    /// - parameter cols: The maximum number of rows to be used as pivot.
    ///
    /// - Space Complexity: O(m) - where m is the number of colums.
    /// - Time Complexity: O(n^2) - where n is the number of rows.
    ///
    public static func ireduce(_ matrix: inout Matrix<Double>, _ cols: Int? = nil) {
        // Allready 'fixed' rows
        var done = [Int]()
        // Buffer for using vDSP vector operations
        var tempBuffer = [Double](repeating: .nan, count: matrix.cols)
        
        // Try to make a 'straircase-step' for each row, ignore if not possible
        for col in 0..<(cols ?? matrix.cols) {
            // Ensure there is a not fixed row
            guard done.count != matrix.rows else { break }
            
            // Extract not fixed row with non-zero pivot element
            guard let row = (0..<matrix.rows).first(where: { !done.contains($0) && matrix[$0, col] != 0 })
                else { continue }
            done.append(row)
            
            // Propergate pivot and normalize other rows
            for trow in 0..<matrix.rows {
                // only *other* rows
                guard trow != row else { continue }
                
                // try reducing pseudo pivot using a factor != 0
                var factor = matrix[trow, col] / matrix[row, col]
                guard factor != 0 else { continue }
                
                // Calculate targetRow -= factor * pivotRow
                matrix.data.withUnsafeMutableBufferPointer { (ptr) in
                    vDSP_vsmulD(
                        ptr.baseAddress! + (row * matrix.cols),
                        1,
                        &factor,
                        &tempBuffer,
                        1,
                        vDSP_Length(matrix.cols)
                    )
                    vDSP_vsubD(
                        ptr.baseAddress! + (trow * matrix.cols),
                        1,
                        tempBuffer,
                        1,
                        ptr.baseAddress! + (trow * matrix.cols),
                        1,
                        vDSP_Length(matrix.cols)
                    )
                }
            }
        }
    }
}
