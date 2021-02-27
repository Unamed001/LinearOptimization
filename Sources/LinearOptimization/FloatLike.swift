//
//  File.swift
//  
//
//  Created by MK_Dev on 16.02.21.
//

import Foundation

protocol FloatLike: CustomStringConvertible, BinaryFloatingPoint {
    func format(using formatString: String) -> String
}

extension Double: FloatLike {
    func format(using formatString: String) -> String {
        return String(format: formatString, self)
    }
}

extension Float: FloatLike {
    func format(using formatString: String) -> String {
        return String(format: formatString, self)
    }
}

