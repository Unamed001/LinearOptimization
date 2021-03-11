//
//  TypeExtensions.swift
//  LinearOptimization
//
//  Created by MK_Dev on 10.03.21.
//

import Foundation

/// A type with values that support divsion (semi-exact).
public protocol DivisionArithmetic {
    static func / (lhs: Self, rhs: Self) -> Self
    static func /= (lhs: inout Self, rhs: Self) -> Void
}

extension Double: DivisionArithmetic {}
extension Float: DivisionArithmetic {}
extension Int: DivisionArithmetic {}

/// A type with values that support format string converstion.
protocol CustomFormatStringConvertible {
    func format(using formatString: String) -> String
}

extension CustomFormatStringConvertible where Self:CVarArg {
    func format(using formatString: String) -> String {
        return String(format: formatString, self)
    }
}

extension Double: CustomFormatStringConvertible {}
extension Float: CustomFormatStringConvertible {}
extension Int: CustomFormatStringConvertible {}

typealias FloatLike = BinaryFloatingPoint & CustomFormatStringConvertible
