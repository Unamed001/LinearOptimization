//
//  LinearOptimization.swift
//  LinearOptimization
//
//  Created by MK_Dev on 7.03.21.
//

import Swift

/// A object to describe a linar optimization problem in normal form.
///
/// Describes a linear optimization problem of type
/// `$$\text{min } c^Tx + \lambda \text{ with } Ax \leq b \text{ and } A_{eq}x = b_{eq} \text{ and } x \geq 0_n$$`
///
public struct LinearOptimizationProblem<F: FloatLike> {
    
    /// Options to control the linprog execution.
    public struct Options {
        /// Indicates if the solver should print results onto stdout.
        public var verbose: Bool = true
        
        /// Limits the maximum number of iterations per phase of Simplex.
        public var maxIterations: Int = 8
        
        /// Creates the default config for the LOP Solver.
        public init() {}
        
        /// Creates a config with variable verbosity settings for the LOP Solver.
        public init(verbose: Bool) {
            self.verbose = verbose
        }
    }
    
    /// A result of a linprog execution.
    public enum Result {
        /// A valid minima for the given LOP.
        case Ok((x: Matrix<F>, fval: F))
        /// An error occured with solving the LOP (or no solution found).
        case Error(String)
    }
    
    /// The vector `$c \in \mathbb{R}^n$` that describes the target function.
    public var c: Matrix<F>
    /// The constant offset `$\lambda$` of the target function.
    public var l: F
    
    /// The matrix `$A \in \mathbb{R}^{m,n} $`that describes the variable
    /// part of the <= Equations.
    public var A: Matrix<F>
    /// The vector `$b \in \mathbb{R}^m$`that describes the constant
    /// part of the <= Equation.
    public var b: Matrix<F>
    
    /// The matrix `$A_{eq} \in \mathbb{R}^{p,n}$`that describes the variable part of the = Equations.
    public var Aeq: Matrix<F>
    /// The vector `$b_{eq} \in \mathbb{R}^p$` that describes the constant port of the = Equation.
    public var beq: Matrix<F>
    
    /// Construct a new LOP in NF without offset.
    public init(
        c: Matrix<F>,
        A: Matrix<F>,
        b: Matrix<F>,
        Aeq: Matrix<F> = Matrix<F>(),
        beq: Matrix<F> = Matrix<F>()
    ) {
        self.init(
            c: c,
            l: 0,
            A: A,
            b: b,
            Aeq: Aeq,
            beq: beq
        )
    }
    
    /// Construct a new LOP in NF with offset.
    public init(
        c: Matrix<F>,
        l: F,
        A: Matrix<F>,
        b: Matrix<F>,
        Aeq: Matrix<F> = Matrix<F>(),
        beq: Matrix<F> = Matrix<F>()
    ) {
        self.c = c
        self.l = l
        self.A = A
        self.b = b
        self.Aeq = Aeq
        self.beq = beq
    }
}

/// A object to describe a linar optimization problem in normal form.
///
/// Describes a linear optimization problem of type
/// `$$\text{min } c^Tx + \lambda \text{ with } Ax \leq b \text{ and } A_{eq}x = b_{eq} \text{ and } x \geq 0_n$$`
///
public typealias LOP = LinearOptimizationProblem

///
/// Solves the given LOP using the given options.
///
/// - parameter p: The LOP to be solved.
/// - parameter opts: The run configuration of the Solver.
/// - returns: Either a valid point or an error.
///
public func linprog<F: FloatLike>(
    _ p: LOP<F>,
    _ opts: LOP<F>.Options = LOP<F>.Options()
) -> LOP<F>.Result {
    // Check LOP consistency
    assert(p.c.isVec)
    assert(p.A.rows == p.b.rows)
    assert(p.A.cols == p.c.rows || p.A.rows == 0)
    assert(p.Aeq.rows == p.beq.rows)
    assert(p.Aeq.cols == p.c.rows || p.Aeq.rows == 0)
    
    let n = p.c.rows
    let numberOfVars = n + p.A.rows + p.Aeq.rows
    let numberOfEq = p.A.rows + p.Aeq.rows
    
    var mat = Matrix<F>(numberOfEq + 2, n + 1)
    
    // Fill Axy=b matrix
    if p.A.rows != 0 {
        mat[0..., n...] = p.b
        mat[0..., 0...] = p.A
    }
    
    // Fill Aeqx=beq matrix
    if p.Aeq.rows != 0 {
        mat[p.b.rows..., n...] = p.beq
        mat[p.A.rows..., 0...] = p.Aeq
    }
    
    
    // Fill c matrix of (P)
    mat[(numberOfEq + 1)..., 0...] = -1*p.c′
    // Fille c matrix of (H)
    var ch = Matrix<F>(n + 1, 1)
    for o in p.A.rows..<numberOfEq {
        ch = ch + (mat[o...o, 0..<mat.cols]′)
    }
    
    // Fill bottom rows of orignal ch matrix of help problem
    mat[numberOfEq..., 0...] = ch′
    
    // Mar which vars are base indices or not
    var baseVars = Array(1...n)
    var nonBaseVars = Array((n + 1)...numberOfVars)
    
    /// Loggin method
    func log(
        _ iteration: Int,
        _ matrix: Matrix<F>,
        _ phase1: Bool,
        _ pvRow: Int = -1,
        _ pvCol: Int = -1
    ) {
        guard opts.verbose else { return }
        let tb = TableView(cols:
                            [
                                [
                                    .raw(" \(phase1 ? "@" : "ß")\(iteration) | "), .fill("-") ]
                                    + nonBaseVars.map { .raw(" x\($0) | ") }
                                    + (phase1 ? [ .raw(" (H) | "), .raw(" (P) | ") ] : [ .raw(" (P) | ") ])
                            ] +
                            (baseVars + [ -1 ]).enumerated().map {
                                if $1 == -1 {
                                    var col: [TableView.Primitiv] = [ .rawRight("|"), .fill("-") ]
                                    for r in 0..<matrix.rows {
                                        col.append(.rawRight("| \(matrix[r, $0].format(using: "%.4f"))"))
                                    }
                                    return col
                                }
                                var col: [TableView.Primitiv] = [ .raw("x\($1) "), .fill("-") ]
                                for r in 0..<matrix.rows {
                                    let fstr = (r == pvRow && $0 == pvCol) ? "[%.4f]" : "%.4f"
                                    col.append(.raw("\(matrix[r, $0].format(using: fstr)) "))
                                }
                                return col
                            }
        )
        
        print(tb.description)
        
    }
    
    // Phase 1
    func getPivotPhase1() -> (Int,Int)? {
        var colSelect: F = .infinity
        var pvCol: Int?
        
        for i in 0..<n {
            guard mat[numberOfEq ,i] > 0 else { continue }
            if mat[numberOfEq ,i]  < colSelect {
                colSelect = mat[numberOfEq ,i]
                pvCol = i
            }
        }
        
        guard pvCol != nil else { return nil }
        
        var rowSelect: F = .infinity
        var pvRow: Int?
        
        for j in  0..<numberOfEq {
            guard mat[j, pvCol!] != 0 else { continue }
            let rValue = mat[j, n] / mat[j, pvCol!]
            guard rValue >= 0 else { continue }
            if rValue < rowSelect {
                rowSelect = rValue
                pvRow = j
            }
        }
        
        guard pvRow != nil else { return nil }
        return (pvRow!, pvCol!)
    }
    
    // Phase 1 Iteration
    var p1HashList = [Int]()
    var p1Itr = 0
    while let (pvRow, pvCol) = getPivotPhase1() {
        guard p1Itr < opts.maxIterations else {
            return .Error("Exceeded phase 1 max iterations")
        }
        p1Itr += 1
        
        guard !p1HashList.contains(mat.customHashValue) else {
            return .Error("Phase 1 Cycle found")
        }
        p1HashList.append(mat.customHashValue)
        
        log(p1Itr, mat, true, pvRow, pvCol)
        
        let pv = mat[pvRow, pvCol]
        
        let temp = baseVars[pvCol]
        baseVars[pvCol] = nonBaseVars[pvRow]
        nonBaseVars[pvRow] = temp
        
        let old = mat
        
        for row in 0..<mat.rows {
            for col in 0..<mat.cols {
                switch (row == pvRow, col == pvCol) {
                case (true, true):
                    mat[row, col] = 1 / pv
                    break
                case (true, false):
                    mat[row, col] =  old[row, col] / pv
                    break
                case (false, true):
                    mat[row, col] =  -1 * old[row, col] / pv
                    break
                case (false, false):
                    mat[row, col] = old[row, col] - (old[pvRow, col] * old[row, pvCol]) / pv
                    break
                }
            }
        }
    }
    log(p1Itr, mat, true)
    
    guard mat[numberOfEq, n] == 0 else {
        return .Error("Problem (H) is unbound")
    }
    
    let helpVar = numberOfVars - p.Aeq.rows + 1
    guard nonBaseVars.reduce(0, { max($0, $1) }) < helpVar else {
        return .Error("Problem (H) is unbound")
    }
    
    // Phae 1
    
    var mx = Matrix<F>(numberOfEq + 1, n + 1 - p.Aeq.rows)
    
    var colIdx = 0
    for col in 0..<mat.cols {
        guard col == mat.cols - 1 || baseVars[col] < (numberOfVars - p.Aeq.rows) else { continue }
        
        mx[0..., colIdx...] = mat[0..<numberOfEq, col...col]
        mx[numberOfEq, colIdx] = mat[numberOfEq + 1, col]
        
        colIdx += 1
    }
    
    baseVars = baseVars.filter({ $0 < numberOfVars - p.Aeq.rows })
    
    func getPivotPhase2() -> (Int, Int)? {
        var colSelect: F = .infinity
        var pvCol: Int?
        
        for i in 0..<(mx.cols - 1) {
            guard mx[numberOfEq ,i] > 0 else { continue }
            if mx[numberOfEq ,i]  < colSelect {
                colSelect = mx[numberOfEq ,i]
                pvCol = i
            }
        }
        
        guard pvCol != nil else { return nil }
        
        var rowSelect: F = .infinity
        var pvRow: Int?
        
        for j in  0..<numberOfEq {
            guard mx[j, pvCol!] != 0 else { continue }
            let rValue = mx[j, mx.cols - 1] / mx[j, pvCol!]
            guard rValue >= 0 else { continue }
            if rValue < rowSelect {
                rowSelect = rValue
                pvRow = j
            }
        }
        
        guard pvRow != nil else { return nil }
        return (pvRow!, pvCol!)
    }
    
    // Phase 2 Iteration
    var p2HashList = [Int]()
    var p2Itr = 0
    while let (pvRow, pvCol) = getPivotPhase2() {
        
        guard p2Itr < opts.maxIterations else {
            return .Error("Exceeded phase 2 max iterations")
        }
        p2Itr += 1
        
        guard !p2HashList.contains(mx.customHashValue) else {
            return .Error("Phase 2 Cycle found")
        }
        p2HashList.append(mx.customHashValue)
        
        log(p2Itr, mx, false, pvRow, pvCol)
        
        let pv = mx[pvRow, pvCol]
        
        let temp = baseVars[pvCol]
        baseVars[pvCol] = nonBaseVars[pvRow]
        nonBaseVars[pvRow] = temp
        
        let old = mx
        
        for row in 0..<mx.rows {
            for col in 0..<mx.cols {
                switch (row == pvRow, col == pvCol) {
                case (true, true):
                    mx[row, col] = 1 / pv
                    break
                case (true, false):
                    mx[row, col] =  old[row, col] / pv
                    break
                case (false, true):
                    mx[row, col] =  -1 * old[row, col] / pv
                    break
                case (false, false):
                    mx[row, col] = old[row, col] - (old[pvRow, col] * old[row, pvCol]) / pv
                    break
                }
            }
        }
    }
    log(p2Itr, mx, false)
    
    var solution = Matrix<F>(n, 1)
    for i in 0..<nonBaseVars.count {
        let k = nonBaseVars[i]
        guard k <= p.c.rows else { continue }
        solution[k - 1, 0] = mx[i, mx.cols - 1]
    }
    
    return .Ok((solution, mx[mx.rows - 1, mx.cols - 1] + p.l))
}
