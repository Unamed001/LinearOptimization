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
        
        XCTAssert(m[1] == [ .v3, .v3, .v1 ], "Invalid result at subscript(_:Int)")
        
        // Setter Test
        
        var u = m
        
        u[0, 0] = .v2
        XCTAssert(u[0,0] == .v2, "Invalid result at setter(_:Int, _:Int)")
        XCTAssert(u.contains(.v2) == true, "Invalid result at mutated contains(_:T)")
        
        u[1] = [ .v2, .v2, .v2 ]
        XCTAssert(u[1] == [ .v2, .v2, .v2 ], "Invalid result at setter(_:Int)")
        XCTAssert(u.contains(.v3) == false, "Invalid result at mutated negative contains(_:T)")
        
        // Vector Test
        
        let v = Mat([ .v1, .v2, .v3 ])
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
        
        let v1 = Mat([ 1, 2, 3 ])
        let v2 = Mat([ 1, 0, 0 ])
        
        XCTAssert((v1 >= v2) == true, "Invalid result at componentwise >=(_:_:)")
        XCTAssert((v1 > v2) == false, "Invalid result at componentwise >(_:_:)")
        XCTAssert((v2 <= v1) == true, "Invalid result at componentwise <=(_:_:)")
        XCTAssert((v2 < v1) == false, "Invalid result at componentwise <(_:_:)")
    }
}
