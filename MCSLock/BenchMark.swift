//
//  BenchMark.swift
//  MCSLock
//
//  Created by Ebubechukwu Dimobi on 20.12.2021.
//

import Foundation

protocol BenchMarkable {
    func startTimer()
    func increaseRelapsedTime()
}

protocol Loggable {
    func logTime(currentCount: Int)
    func createCSV(name: String)
}


class BenchMark {
    private var startTime: CFAbsoluteTime
    private var database:[Dictionary<String, AnyObject>] = Array()
    
    var elapsedTime: Double = .zero
    
    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
}

extension BenchMark: Loggable {
    func logTime(currentCount: Int) {
        var dct = Dictionary<String, AnyObject>()
        dct.updateValue(currentCount as AnyObject, forKey: "Count")
        dct.updateValue(self.elapsedTime as AnyObject, forKey: "Time")
        database.append(dct)
    }
    
    func createCSV(name: String) {
        var csvString = "\("Critical Section Count per Thread"),\("Time (ms)")\n\n"
        for dct in database {
            csvString = csvString.appending("\(String(describing: dct["Count"]!)) ,\(String(describing: dct["Time"]!))\n")
        }
        
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .downloadsDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("\(name).csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("error creating file")
        }
        
    }
}

extension BenchMark: BenchMarkable {
    func increaseRelapsedTime() {
        elapsedTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        print(elapsedTime)
    }
    
    func startTimer() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
}
