//
//  MutableCollection+Extension.swift
//  Virtual Tourist
//
//  Created by ivan lares on 3/4/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import Foundation

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
   
        guard count > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: count, to: 1, by: -1)) {
            let indexDistance: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: indexDistance)
            swapAt(firstUnshuffled, i)
        }
    }
}
