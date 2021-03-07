//
//  File.swift
//  
//
//  Created by MK_Dev on 28.02.21.
//

import Swift

/// A range type that is transformable to a `ClosedRange`.
public protocol ClosableRangeExpression: RangeExpression
where Bound: Strideable, Bound.Stride: SignedInteger {
    ///
    /// Returns a copy of this range clamped to the given limiting range.
    ///
    /// - parameter limits: The range to clamp the bounds of this range.
    ///
    /// - returns: A new range clamped to the bounds of limits.
    ///
    @inlinable
    func clamped(to limits: ClosedRange<Bound>) -> ClosedRange<Bound>
}

extension ClosableRangeExpression {
    ///
    /// Returns a copy of this range clamped to the given limiting range.
    ///
    /// - parameter limits: The range to clamp the bounds of this range.
    ///
    /// - returns: A new range clamped to the bounds of limits.
    ///
    @inlinable
    func clamped(to limits: Range<Bound>) -> ClosedRange<Bound> {
        return self.clamped(to: ClosedRange(limits))
    }
}

extension Range: ClosableRangeExpression where Bound: Strideable, Bound.Stride: SignedInteger {
    public func clamped(to limits: ClosedRange<Bound>) -> ClosedRange<Bound> {
        return Swift.max(self.lowerBound, limits.lowerBound)...Swift.min(self.upperBound.advanced(by: -1), limits.upperBound)
    }
}

extension ClosedRange: ClosableRangeExpression where Bound: Strideable, Bound.Stride: SignedInteger {
    public func clamped(to limits: ClosedRange<Bound>) -> ClosedRange<Bound> {
        return Swift.max(self.lowerBound, limits.lowerBound)...Swift.min(self.upperBound, limits.upperBound)
    }
}

extension PartialRangeFrom: ClosableRangeExpression where Bound: Strideable, Bound.Stride: SignedInteger {
    public func clamped(to limits: ClosedRange<Bound>) -> ClosedRange<Bound> {
        return Swift.max(limits.lowerBound, self.lowerBound)...limits.upperBound
    }
}

extension PartialRangeUpTo: ClosableRangeExpression where Bound: Strideable, Bound.Stride: SignedInteger {
    public func clamped(to limits: ClosedRange<Bound>) -> ClosedRange<Bound> {
        return limits.lowerBound...Swift.min(limits.upperBound, self.upperBound.advanced(by: -1))
    }
}

extension PartialRangeThrough: ClosableRangeExpression where Bound: Strideable, Bound.Stride: SignedInteger {
    public func clamped(to limits: ClosedRange<Bound>) -> ClosedRange<Bound> {
        return limits.lowerBound...Swift.min(limits.upperBound, self.upperBound)
    }
}

extension Int: RangeExpression {
    
    public typealias Bound = Int
    
    public func relative<C>(to collection: C) -> Range<Int> where C : Collection, Int.Bound == C.Index {
        return 0..<collection.count
    }
    
    public func contains(_ element: Int) -> Bool {
        return element == self
    }
}

extension Int: ClosableRangeExpression {
    public func clamped(to limits: ClosedRange<Int.Bound>) -> ClosedRange<Int.Bound> {
        assert(limits.contains(self), "Index must be contained int the limits")
        return self...self
    }
}
