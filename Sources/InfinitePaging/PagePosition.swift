// 
//  PagePosition.swift
//  
//
//  Created by ykkd on 2024/02/05.
//

import Foundation

enum PagePosition: Int {
    case first = 0
    case center = 1
    case third = 2
    
    init(_ value: Int) {
        switch value {
        case Int.min...0:
            self = .first
        case 1:
            self = .center
        case 2...Int.max:
            self = .third
        default:
            fatalError("unexpected value")
        }
    }
}
