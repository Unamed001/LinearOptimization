//
//  Matrix+Random.swift
//  LinearOptimization
//
//  Created by MK_Dev on 07.03.21.
//

import Swift

extension Matrix {
    ///
    /// Creates a new matrix filled with random values from
    /// the collection.
    ///
    /// - parameter collection: The collection of possible elements.
    /// - parameter rows: The number of rows to be generated.
    /// - parameter cols: The number of colums to be generated.
    ///
    init(randomFrom collection: [Element], _ rows: Int, _ cols: Int) {
        self.data = [Element]()
        self.data.reserveCapacity(rows*cols)
        self.rows = rows
        self.cols = cols
        for _ in 0..<rows*cols {
            self.data.append(collection.randomElement()!)
        }
    }
}

/// A type that can be created using a range limited randomizer.
protocol RandomInitializable: Comparable {
    /// A function that creates an instance limited by a closed range.
    @inlinable static func random(in range: ClosedRange<Self>) -> Self
    
    /// A function that creates an instance limited by a closed range
    /// using a given generator.
    @inlinable static func random<T>(in range: ClosedRange<Self>, using generator: inout T) -> Self
        where T: RandomNumberGenerator
    
    /// A function that creates an instance limited by a open range.
    @inlinable static func random(in range: Range<Self>) -> Self
    
    /// A function that creates an instance limited by a open range
    /// using a given generator.
    @inlinable static func random<T>(in range: Range<Self>, using generator: inout T) -> Self
        where T: RandomNumberGenerator
}

extension Int: RandomInitializable {}
extension UInt: RandomInitializable {}
extension Float: RandomInitializable {}
extension Double: RandomInitializable {}

extension Matrix where Element: RandomInitializable {
    
    ///
    /// Creates a new square matrix filled with random values
    /// from the given limits
    ///
    /// - parameter limits: The range of values that cells can be from
    /// - parameter dimensionLimits: The limits of the random dimension to be generated.
    ///
    init(randomSquare limits: ClosedRange<Element>, _ dimensionLimits: ClosedRange<Int>) {
        let dim = Int.random(in: dimensionLimits)
        self.init(random: limits, dim, dim)
    }
    
    ///
    /// Creates a new matrix filled with random values
    /// from the given limits
    ///
    /// - parameter limits: The range of values that cells can be from
    /// - parameter rows: The number of rows to be generated.
    /// - parameter cols: The number of colums to be generated.
    ///
    init(random limits: ClosedRange<Element>, _ rows: Int, _ cols: Int) {
        self.data = [Element]()
        self.data.reserveCapacity(rows*cols)
        self.rows = rows
        self.cols = cols
        
        for _ in 0..<rows*cols {
            self.data.append(Element.random(in: limits))
        }
    }
    
    ///
    /// Creates a new square matrix filled with random values
    /// from the given limits
    ///
    /// - parameter limits: The range of values that cells can be from
    /// - parameter dimensionLimits: The limits of the random dimension to be generated.
    ///
    init(randomSquare limits: Range<Element>, _ dimensionLimits: ClosedRange<Int>) {
        let dim = Int.random(in: dimensionLimits)
        self.init(random: limits, dim, dim)
    }
    
    ///
    /// Creates a new matrix filled with random values
    /// from the given limits
    ///
    /// - parameter limits: The range of values that cells can be from
    /// - parameter rows: The number of rows to be generated.
    /// - parameter cols: The number of colums to be generated.
    ///
    init(random limits: Range<Element>, _ rows: Int, _ cols: Int) {
        self.data = [Element]()
        self.data.reserveCapacity(rows*cols)
        self.rows = rows
        self.cols = cols
        
        for _ in 0..<rows*cols {
            self.data.append(Element.random(in: limits))
        }
    }
}
