// 
//  AlwaysVisiblePageControl.swift
//  InfinitePagingSample
//
//  Created by ykkd on 2024/02/05.
//

import UIKit
import SFSafeSymbols

open class AlwaysVisiblePageControl: UIPageControl {

    open override var currentPage: Int {
        didSet {
            updateBorderColor()
        }
    }
    
    override open var numberOfPages: Int {
        didSet {
            // 1ページだけの場合でもドットを表示するようにする
            isHidden = false
        }
    }
    
    private func updateBorderColor() {
        let configuration = UIImage.SymbolConfiguration(pointSize: 8.0, weight: .bold)
        let circleFill = UIImage(systemSymbol: SFSymbol.circleFill, withConfiguration: configuration)
        let circle = UIImage(systemSymbol: SFSymbol.circle, withConfiguration: configuration)
        for index in 0..<numberOfPages {
            if index == currentPage {
                setIndicatorImage(circleFill, forPage: index)
            } else {
                setIndicatorImage(circle, forPage: index)
            }
        }
    }
}
