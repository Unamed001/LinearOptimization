import XCTest
@testable import LinearOptimization

final class GaussianTests: XCTestCase {
    
    lazy var testDataF: [Matrix<Float>] = { () -> [Matrix<Float>] in
        var data = [Matrix<Float>]()
        for i in 1...1000 {
            data.append(.init(random: -1000...1000, i % 30 + 1, i % 30 + 1))
        }
        return data
    }()
    
    lazy var testDataD: [Matrix<Double>] = { () -> [Matrix<Double>] in
        var data = [Matrix<Double>]()
        for i in 1...1000 {
            data.append(.init(random: -1000...1000, i % 30 + 1, i % 30 + 1))
        }
        return data
    }()
    
    func test_iReduce() {
        measure {
            for i in 0..<self.testDataF.count {
                Gaussian.ireduce(&self.testDataF[i])
            }
            
            for i in 0..<self.testDataD.count {
                Gaussian.ireduce(&self.testDataD[i])
            }
        }
    }
    
}
