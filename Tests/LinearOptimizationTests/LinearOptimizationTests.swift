import XCTest
@testable import LinearOptimization

final class LinearOptimizationTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        self.lop1()
        self.lop2()
        self.lop3()
    }
    
    func lop3() {
        let lop = LOP<Double>(
            c: .init([ 8, 8, -9, 0, 0 ]),
            A: .init([
                [ 1, 1, 1, 0, 0 ],
            ]),
            b: .init([ 1 ]),
            Aeq: .init([
                [ 2, 4, 1, -1, 0 ],
                [ 1, -1, -1, 0, -1 ]
            ]),
            beq: .init([ 8, 2 ])
        )
        
        guard case .Error(_) = linprog(lop, .init(verbose: false)) else {
            XCTFail()
            return
        }
    }
    
    func lop2() {
        let lop = LOP<Double>(
            c: .init([ 1, -3, 2, 0, 0 ]),
            A: .init([
                [ 1, 0, -1, 0, 0 ]
            ]),
            b: .init([ 4 ]),
            Aeq: .init([
                [ 1, -1, 0, -1, 0 ],
                [ 0, 1, -2, 0, -1 ]
            ]),
            beq: .init([ 1, 1 ])
        )
        
        guard case .Ok(let r) = linprog(lop, .init(verbose: false)) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(r.x[0...2, 0...0], Matrix<Double>([ 6, 5, 2 ]))
        XCTAssertEqual(r.fval, -5.0)
    }

    func lop1() {
        
        let lop = LOP<Double>(
            c: .init([ 4, -2, -5, 0 ]),
            A: .init([
                [ -5, 2, 9, 0 ],
                [ -2, 1, 4, 0 ]
            ]),
            b: .init([ 2, 1 ]),
            Aeq: .init([
                [ -13, 7, 27, -1 ]
            ]),
            beq: .init([ 3 ])
        )
        
        guard case .Ok(let r) = linprog(lop, .init(verbose: false)) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(r.x[0...2, 0...0], Matrix<Double>([ 0, 1, 0]))
        XCTAssertEqual(r.fval, -2.0)
    }
    
    static var allTests = [
        ("testExample", testExample),
    ]
}
