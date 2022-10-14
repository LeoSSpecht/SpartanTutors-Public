//
//  ArraysExtension.swift
//  SpartanTutors
//
//  Created by Leo on 8/16/22.
//

import Foundation

extension Array where Element == DataPoint {
    func sum_sessions() -> Int {
        var temp = 0
        self.forEach({temp += Int($0.y)})
        return temp
    }
}
