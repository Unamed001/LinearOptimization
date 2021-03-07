import XCTest
@testable import LinearOptimization

final class MatrixTests: XCTestCase {
    
    func test_primitivMatrix() {
        
        enum TestType {
            case v1
            case v2
            case v3
        }
        
        typealias Mat = Matrix<TestType>
        
        let m = Mat([
            [ .v1, .v1, .v1 ],
            [ .v3, .v3, .v1 ]
        ])
        
        // Getter Tests
        
        XCTAssert(m.rows == 2, "Invalid row size at init(_: [[T]])")
        XCTAssert(m.cols == 3, "Invalid col size at init(_: [[T]])")
        
        XCTAssert(m.isVec == false, "isVec check failed at primitve matrix")
        XCTAssert(m.contains(.v1) == true, "Invalid result at contains(_:T)")
        XCTAssert(m.contains(.v2) == false, "Invalid result at negative contains(_:T)")
        
        XCTAssert(m[1, 1] == .v3, "Invalid result at subscript(_:Int, _:Int)")
        XCTAssert(m[0, 1] == .v1, "Invalid result at subscript(_:Int, _:Int)")
        
        // Setter Test
        
        var u = m
        
        u[0, 0] = .v2
        XCTAssert(u[0,0] == .v2, "Invalid result at setter(_:Int, _:Int)")
        XCTAssert(u.contains(.v2) == true, "Invalid result at mutated contains(_:T)")
  
        // Vector Test
        
        let v = Mat(vector: [ .v1, .v2, .v3 ])
        XCTAssert(v.isVec == true, "isVec check failed at primitve vector")
        XCTAssert(v.rows == 3, "Invalid row size at init(_:[T])")
        
        XCTAssert(v.contains(.v2), "Invalid result at contains(_:T)")
        
        // ColVec Test
        
        let tv = Mat([[ .v1, .v2, .v3 ]])
        XCTAssert(tv.isVec == false, "isVec check failed at primitve vector")
        XCTAssert(tv.cols == 3, "Invalid row size at init(_:[T])")
        
        XCTAssert(tv.contains(.v2), "Invalid result at contains(_:T)")
        
        XCTAssert(Mat.transpose(tv).isVec == true, "isVec check failed at transpose(_:ColVec)")
        XCTAssert(Mat.transpose(tv) == v, "isVec check failed at transpose(_:ColVec)")
    }
    
    func test_derivedProtocols() {
        
        typealias Mat = Matrix<Int>
        
        let m = Mat([
            [ 1, 2, 3 ],
            [ 2, 3, 4 ],
            [ 3, 4, 5 ],
        ])
        
        XCTAssert(m.rows == 3, "Invalid row size at init(_: [[T]])")
        XCTAssert(m.cols == 3, "Invalid col size at init(_: [[T]])")
        
        XCTAssert(m.isVec == false, "isVec check failed at primitve matrix")
        XCTAssert(m.contains(3) == true, "Invalid result at contains(_:T)")
        XCTAssert(m.contains(6) == false, "Invalid result at negative contains(_:T)")
        
        do {
            let data = try JSONEncoder().encode(m)
            let d = try JSONDecoder().decode(Mat.self, from: data)
            
            XCTAssert(d == m, "Failed to preserve integrety at encoding/decoding Matrix<Codable>")
        } catch {
            XCTFail("Failed at encoding/decoding Matrix<Codable>")
        }
        
        let v1 = Mat(vector: [ 1, 2, 3 ])
        let v2 = Mat(vector: [ 1, 0, 0 ])
        
        XCTAssert((v1 >= v2) == true, "Invalid result at componentwise >=(_:_:)")
        XCTAssert((v1 > v2) == false, "Invalid result at componentwise >(_:_:)")
        XCTAssert((v2 <= v1) == true, "Invalid result at componentwise <=(_:_:)")
        XCTAssert((v2 < v1) == false, "Invalid result at componentwise <(_:_:)")
    }
    
    func test_iterator() {
        let m = Matrix<Int>([
            [ 1, 2, 3 ],
            [ 4, 5, 6 ]
        ])
        
        XCTAssert(m.isVec == false, "isVec check failed on iteratable matrix")
        XCTAssert(m.rows == 2, "Inherited rows invalid on iteratable matrix")
        XCTAssert(m.cols == 3, "Inherited cols invalid on iteratabke matrix")
        
        var i = 1
        for element in m {
            XCTAssert(element == i, "Iterator order invalid")
            i += 1
        }
    }
    
    func test_subscripts() {
        
        let matrix = Matrix([
            1, 2, 3, 4,
            2, 3, 4, 5,
            3, 4, 5, 6,
            4, 5, 6, 7,
        ], 4, 4)
        
        
        XCTAssert(matrix[3, 3] == 7, "Invalid result at subscript(_:Int,_:Int)")
        XCTAssert(matrix[1, 3] == 5, "Invalid result at subscript(_:Int,_:Int)")
        XCTAssert(matrix[3, 1] == 5, "Invalid result at subscript(_:Int,_:Int)")
        
        XCTAssert(matrix[2...3, 1...2] == Matrix([ 4, 5, 5, 6 ], 2, 2),
                  "Invalid result at subscript(_:ClosedRange<Int>,_:ClosedRange<Int>)")
        XCTAssert(matrix[2..<3, 1...2] == Matrix([ 4, 5 ], 1, 2),
                  "Invalid result at subscript(_:Range<Int>,_:ClosedRange<Int>)")
        
        XCTAssert(matrix[2..., 1...2] == Matrix([ 4, 5, 5, 6 ], 2, 2),
                  "Invalid result at subscript(_:ParitalRangeFrom<Int>,_:ClosedRange<Int>)")
        XCTAssert(matrix[2..., 1...] == Matrix([ 4, 5, 6, 5, 6, 7 ], 2, 3),
                  "Invalid result at subscript(_:ParitalRangeFrom<Int>,_:ParitalRangeFrom<Int>)")
        
        XCTAssert(matrix[...2, ...2] == Matrix([ 1, 2, 3, 2, 3, 4, 3, 4, 5 ], 3, 3),
                  "Invalid result at subscript(_:PartialRangeThrough<Int>,_:PartialRangeThrough<Int>)")
        XCTAssert(matrix[..<2, ..<2] == Matrix([ 1, 2, 2, 3 ], 2, 2),
                  "Invalid result at subscript(_:PartialRangeUpTo<Int>,_:PartialRangeUpTo<Int>)")
        
        XCTAssert(matrix[..<2, 1...] == Matrix([ 2, 3, 4, 3, 4, 5 ], 2, 3),
                  "Invalid result at subscript(_:PartialRangeUpTo<Int>,_:ParitalRangeFrom<Int>)")
        XCTAssert(matrix[...1, 1...] == Matrix([ 2, 3, 4, 3, 4, 5 ], 2, 3),
                  "Invalid result at subscript(_:PartialRangeThrough<Int>,_:ParitalRangeFrom<Int>)")
    }
    
    func test_description() {
        let matrix = Matrix<Int>([
            1, 2, 3, 4,
            2, 3, 4, 5,
            3, 4, 5, 6,
            4, 5, 6, 7,
        ], 4, 4)
        
        XCTAssert(matrix.description == "Matrix<4x4>\n1, 2, 3, 4\n2, 3, 4, 5\n3, 4, 5, 6\n4, 5, 6, 7", "Invalid result at :description")
    }
    
    func test_determinant() {
        for _ in 1...100 {
            
            let n = Int.random(in: 2...5)
            var array = [Double]()
            
            for _ in 0..<n*n {
                array.append(.random(in: -25...50))
            }
            
            let mat = Matrix(array, n, n)
//            print(Gauß.det(mat), Matrix.det(mat))
            XCTAssert(Gauß.det(mat) - Matrix.det(mat) < 0.1)
        }
    }
}
