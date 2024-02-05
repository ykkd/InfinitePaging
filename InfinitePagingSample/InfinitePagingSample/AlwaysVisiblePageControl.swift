// 
//  AlwaysVisiblePageControl.swift
//  InfinitePagingSample
//
//  Created by ykkd on 2024/02/05.
//

import UIKit
import SFSafeSymbols

open class AlwaysVisiblePageControl: UIPageControl {
    
    var onTouchesBegan: (() -> Void)?
    var onTouchesCancelled: (() -> Void)?
    var onTouchesEnded: (() -> Void)?
    
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
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        onTouchesBegan?()
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        onTouchesCancelled?()
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        onTouchesEnded?()
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
