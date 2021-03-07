//
//  File.swift
//  
//
//  Created by MK_Dev on 16.02.21.
//

import Foundation

struct TableView: CustomStringConvertible {
    
    enum Primitiv {
        case raw(String)
        case rawRight(String)
        
        case fill(String.Element)
        
        var count: Int {
            switch self {
            case .raw(let str), .rawRight(let str):
                return str.count
            case .fill(_):
                return 0
            }
        }
        
        func padded(_ n: Int) -> String {
            switch self {
            case .raw(let str):
                return str.paddedLeft(n)
            case .rawRight(let str):
                return str.paddedRight(n)
            case .fill(let char):
                return String(repeating: char, count: n)
            }
        }
    }
    
    var cols: [[Primitiv]]
    var maxChar: [Int] {
        return cols.map { $0.reduce(0, { max($0, $1.count )}) }
    }
    
    var description: String {
        var str = ""
        let mx = maxChar
        for row in 0..<cols[0].count {
            for col in 0..<cols.count {
                str += cols[col][row].padded(mx[col])
            }
            str += "\n"
        }
        str.removeLast()
        return str
    }
}

extension String {
    func paddedLeft(_ n: Int, _ padding: Element = " ") -> String {
        return String(repeating: padding, count: n - self.count) + self
    }
    func paddedRight(_ n: Int, _ padding: Element = " ") -> String {
        return self + String(repeating: padding, count: n - self.count)
    }
}
