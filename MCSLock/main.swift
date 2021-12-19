//
//  main.swift
//  MCSLock
//
//  Created by Ebubechukwu Dimobi on 19.12.2021.
//

import Foundation

let SD = 100 // SD: shared data srray size
let CS = 100 // CS: critical section executed per thread
let TH = 5  // TH: number of threads

class Main {
    let lock: NSLocking
    var sharedData: [Double]
    
    
    /// Initializies Main Swift
    /// - Parameters:
    ///   - lock: the lock to be used
    ///   - sharedData: the shared data to be used in critical section
    init(
        lock: NSLocking,
        sharedData: [Double]
    ) {
        self.lock = lock
        self.sharedData = sharedData
    }
    
    // Critical section updated shared data
    // with a random value. If all values
    // dont match then it was not executed
    // atomically!
    func criticalSection() {
        let number = Double(Int.random(in: 0...1000))
        for counter in 0..<SD {
            if counter % SD/4 == 0 { Thread.sleep(forTimeInterval: 1.0) }
            let value = number + number
            sharedData.append(value)
        }
    }
    
    // Checks to see if all values match. If not,
    // then critical section was not executed
    // atomically.
    func wasCriticalSectionAtomic() -> Bool {
        let number = sharedData[0]
        for counter in 0..<SD {
            if sharedData[counter] != number { return false }
        }
        return true
    }
    
    // Unsafe thread executes CS N times, without
    // holding a lock. This can cause CS to be
    // executed non-atomically which can be detected.
    //
    // Safe thread executes CS N times, while
    // holding a lock. This allows CS to always be
    // executed atomically which can be verified.
    func createThread(threadNumber: Int, shouldUseLock: Bool) -> Thread {
        let threadNumber = threadNumber
        let thread = Thread {
            if shouldUseLock {
                self.lock.lock()
            }
            print("locked", threadNumber)
            self.criticalSection()
            if shouldUseLock {
                self.lock.unlock()
            }
            print("Thread N\(threadNumber) done")
        }
        thread.start()
        return thread
    }
    
    // Tests to see if threads execute critical
    // section atomically.
    func testThreads(usingLock: Bool) {
        let testType = usingLock ? "safe" : "unsafe"
        print("Starting \(TH) \(testType) threads ....")
        var threads: [Thread] = []
        threads.reserveCapacity(TH)
        
        for counter in 0..<TH {
            threads.append(createThread(threadNumber: counter, shouldUseLock: usingLock))
        }
    }
}


// main function to start
func startup() {
    var sharedData: [Double] = []
    sharedData.reserveCapacity(SD)
    let main = Main(lock: MCSLock(), sharedData: sharedData)
    main.testThreads(usingLock: true)
}

startup()

RunLoop.main.run()
