// 
//  ScrollAnimationConfig.swift
//  
//
//  Created by ykkd on 2024/02/01.
//

import Foundation

public enum ScrollAnimationConfig {
    case inactive
    case active(TimeInterval)
}

extension ScrollAnimationConfig {
    
    var isActive: Bool {
        return switch self {
        case .active:
            true
        case .inactive:
            false
        }
    }
    
    var threshold: TimeInterval {
        return switch self {
        case let .active(timeInterval):
            timeInterval
        case .inactive:
                .zero
        }
    }
}
