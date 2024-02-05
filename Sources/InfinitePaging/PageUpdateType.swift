// 
//  PageUpdateType.swift
//  
//
//  Created by ykkd on 2024/02/05.
//

import Foundation

enum PageUpdateType {
    case gesture
    case autoScroll
}

extension PageUpdateType {
    
    var isAutoUpdate: Bool {
        return self == .autoScroll
    }
}
