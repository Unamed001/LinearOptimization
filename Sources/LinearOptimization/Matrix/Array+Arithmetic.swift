//
//  Array+Arithmetic.swift
//  LinearOptimization
//
//  Created by MK_Dev on 03.03.21.
//

import Swift

extension Array where Element: Comparable {
    ///
    /// Returns a Boolean indicating whether all element of the first array
    /// are less than all element of the second array(row-wise).
    ///
    /// - parameter lhs: A array to  compared.
    /// - parameter rhs: Another array to compare.
    ///
    /// - returns: Boolean indicating if the predicate is satisfied.
    ///
    /// Note that this operator does not defined the `Comparable` Protocol
    /// since the element-wise comparison is not a total or partial order.
    /// This operator is neither symmertic nor reflexiv, but tranisitv.
    ///
    public static func < (_ lhs: Array<Element>, _ rhs: Array<Element>) -> Bool {
        precondition(lhs.count == rhs.count, "Compare operator required arrays of same size")
        for idx in 0..<lhs.count {
            if lhs[idx] >= rhs[idx] {
                return false
            }
        }
        return true
    }
    
    ///
    /// Returns a Boolean indicating whether all element of the first array
    /// are less or equal than all element of the second array(row-wise).
    ///
    /// - parameter lhs: A array to  compared.
    /// - parameter rhs: Another array to compare.
    ///
    /// - returns: Boolean indicating if the predicate is satisfied.
    ///
    /// Note that this operator does not defined the `Comparable` Protocol
    /// since the element-wise comparison is not a total or partial order.
    /// This operator is reflexiv and transitiv, but not symmertic
    ///
    public static func <= (_ lhs: Array<Element>, _ rhs: Array<Element>) -> Bool {
        precondition(lhs.count == rhs.count, "Compare operator required arrays of same size")
        for idx in 0..<lhs.count {
            if lhs[idx] > rhs[idx] {
                return false
            }
        }
        return true
    }
    
    ///
    /// Returns a Boolean indicating whether all element of the first array
    /// are greater than all element of the second array(row-wise).
    ///
    /// - parameter lhs: A array to  compared.
    /// - parameter rhs: Another array to compare.
    ///
    /// - returns: Boolean indicating if the predicate is satisfied.
    ///
    /// Note that this operator does not defined the `Comparable` Protocol
    /// since the element-wise comparison is not a total or partial order.
    /// This operator is neither symmertic nor reflexiv, but tranisitv.
    ///
    public static func > (_ lhs: Array<Element>, _ rhs: Array<Element>) -> Bool {
        precondition(lhs.count == rhs.count, "Compare operator required arrays of same size")
        for idx in 0..<lhs.count {
            if lhs[idx] <= rhs[idx] {
                return false
            }
        }
        return true
    }
    
    ///
    /// Returns a Boolean indicating whether all element of the first array
    /// are greater or equal than all element of the second array(row-wise).
    ///
    /// - parameter lhs: A array to  compared.
    /// - parameter rhs: Another array to compare.
    ///
    /// - returns: Boolean indicating if the predicate is satisfied.
    ///
    /// Note that this operator does not defined the `Comparable` Protocol
    /// since the element-wise comparison is not a total or partial order.
    /// This operator is reflexiv and transitiv, but not symmertic
    ///
    public static func >= (_ lhs: Array<Element>, _ rhs: Array<Element>) -> Bool {
        precondition(lhs.count == rhs.count, "Compare operator required arrays of same size")
        for idx in 0..<lhs.count {
            if lhs[idx] < rhs[idx] {
                return false
            }
        }
        return true
    }
}


