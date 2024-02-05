/*
 InfinitePagingView.swift
 InfinitePaging

 Created by Takuto Nakamura on 2023/10/22.
*/

import SwiftUI

public protocol Pageable: Equatable & Identifiable {}

public struct InfinitePagingView<T: Pageable, Content: View>: View {
    @Binding var index: Int
    @Binding var objects: [T]
    let numberOfContents: Int
    let pageAlignment: PageAlignment
    let scrollAnimationConfig: ScrollAnimationConfig
    let pagingHandler: (PageDirection) -> Void
    let content: (T) -> Content

    public init(
        index: Binding<Int>,
        objects: Binding<[T]>,
        numberOfContents: Int,
        pageAlignment: PageAlignment,
        scrollAnimationConfig: ScrollAnimationConfig,
        pagingHandler: @escaping (PageDirection) -> Void,
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        _index = index
        _objects = objects
        self.numberOfContents = numberOfContents
        self.pageAlignment = pageAlignment
        self.scrollAnimationConfig = scrollAnimationConfig
        self.pagingHandler = pagingHandler
        self.content = content
    }

    public var body: some View {
        GeometryReader { proxy in
            Group {
                switch pageAlignment {
                case .horizontal:
                    horizontalView(size: proxy.size)
                case .vertical:
                    verticalView(size: proxy.size)
                }
            }
            .modifier(
                InfinitePagingViewModifier(
                    index: $index,
                    objects: $objects,
                    pageSize: Binding<CGFloat>(
                        get: { pageAlignment.scalar(proxy.size) },
                        set: { _ in }
                    ), 
                    scrollAnimationConfig: Binding<ScrollAnimationConfig>(
                        get: { scrollAnimationConfig },
                        set: { _ in }
                    ),
                    numberOfContents: numberOfContents,
                    pageAlignment: pageAlignment,
                    pagingHandler: pagingHandler
                )
            )
        }
        .clipped()
    }

    func horizontalView(size: CGSize) -> some View {
        return HStack(alignment: .center, spacing: 0) {
            ForEach(objects) { object in
                content(object)
                    .frame(width: size.width, height: size.height)
            }
        }
    }

    func verticalView(size: CGSize) -> some View {
        return VStack(alignment: .center, spacing: 0) {
            ForEach(objects) { object in
                content(object)
                    .frame(width: size.width, height: size.height)
            }
        }
    }
}
