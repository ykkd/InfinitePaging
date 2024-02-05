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
    @Binding var isAllowAnimation: Bool
    let numberOfContents: Int
    let pageAlignment: PageAlignment
    let pageLength: CGFloat
    let scrollAnimationConfig: ScrollAnimationConfig
    let pagingHandler: (PageDirection) -> Void
    let content: (T) -> Content

    public init(
        index: Binding<Int>,
        objects: Binding<[T]>,
        isAllowAnimation: Binding<Bool>,
        numberOfContents: Int,
        pageAlignment: PageAlignment,
        pageLength: CGFloat,
        scrollAnimationConfig: ScrollAnimationConfig,
        pagingHandler: @escaping (PageDirection) -> Void,
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        _index = index
        _objects = objects
        _isAllowAnimation = isAllowAnimation
        self.numberOfContents = numberOfContents
        self.pageAlignment = pageAlignment
        self.pageLength = pageLength
        self.scrollAnimationConfig = scrollAnimationConfig
        self.pagingHandler = pagingHandler
        self.content = content
    }

    public var body: some View {
        GeometryReader { proxy in
            let size: CGSize = switch pageAlignment {
            case .horizontal:
                CGSize(width: pageLength, height: proxy.size.height)
            case .vertical:
                CGSize(width: proxy.size.width, height: pageLength)
            }
            Group {
                switch pageAlignment {
                case .horizontal:
                    horizontalView(size: size)
                case .vertical:
                    verticalView(size: size)
                }
            }
            .modifier(
                InfinitePagingViewModifier(
                    index: $index,
                    objects: $objects,
                    isAllowAnimation: $isAllowAnimation,
                    pageSize: Binding<CGFloat>(
                        get: { pageAlignment.scalar(size) },
                        set: { _ in }
                    ),
                    scrollAnimationConfig: Binding<ScrollAnimationConfig>(
                        get: { scrollAnimationConfig },
                        set: { _ in }
                    ),
                    parentSize: proxy.size,
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
