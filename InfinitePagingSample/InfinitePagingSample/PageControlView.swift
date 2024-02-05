// 
//  PageControlView.swift
//  InfinitePagingSample
//
//  Created by ykkd on 2024/02/05.
//

import UIKit
import SwiftUI

public struct PageControlView: UIViewRepresentable {
    var numberOfPages: Int

    var currentPage: Binding<Int>

    let selectedColor: UIColor
    let borderColor: UIColor

    public init(
        numberOfPages: Int,
        currentPage: Binding<Int>,
        selectedColor: UIColor,
        borderColor: UIColor
    ) {
        self.numberOfPages = numberOfPages
        self.currentPage = currentPage
        self.selectedColor = selectedColor
        self.borderColor = borderColor
    }

    public func makeUIView(context: Context) -> UIPageControl {
        let control = AlwaysVisiblePageControl()
        control.numberOfPages = numberOfPages
        control.currentPageIndicatorTintColor = selectedColor
        control.pageIndicatorTintColor = borderColor

        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged
        )
        return control
    }

    public func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage.wrappedValue
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject {
        var control: PageControlView

        init(_ control: PageControlView) {
            self.control = control
        }

        @objc
        func updateCurrentPage(sender: UIPageControl) {
            control.currentPage.wrappedValue = sender.currentPage
        }
    }
}
