/*
 InfinitePagingViewModifier.swift
 InfinitePaging

 Created by Takuto Nakamura on 2023/10/22.
*/

import Combine
import SwiftUI

struct InfinitePagingViewModifier<T: Pageable>: ViewModifier {
    @Binding var index: Int
    @Binding var objects: [T]
    
    @Binding var pageSize: CGFloat
    @State var pagingOffset: CGFloat
    @State var draggingOffset: CGFloat
    
    @Binding var scrollAnimationConfig: ScrollAnimationConfig
    
    @State var timeCount: TimeInterval
    @State var timer: TimePublisher = Timer.publish (every: 1, on: .current, in:
            .common).autoconnect()
    @State var isTimerActive = true
    
    let numberOfContents: Int
    let pageAlignment: PageAlignment
    let pagingHandler: (PageDirection) -> Void

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                draggingOffset = pageAlignment.scalar(value.translation)
                cancelTimer()
            }
            .onEnded { value in
                let oldIndex = Int(floor(0.5 - (pagingOffset / pageSize)))
                pagingOffset += pageAlignment.scalar(value.translation)
                draggingOffset = 0
                let newIndex = Int(max(0, min(2, floor(0.5 - (pagingOffset / pageSize)))))
                if #available(iOS 17.0, *) {
                    withAnimation(.linear(duration: 0.1)) {
                        pagingOffset = -pageSize * CGFloat(newIndex)
                    } completion: {
                        if newIndex == oldIndex { return }
                        if newIndex == 0 {
                            updateIndex(for: .backward)
                        }
                        if newIndex == 2 {
                            updateIndex(for: .forward)
                        }
                    }
                } else {
                    withAnimation(.linear(duration: 0.1)) {
                        pagingOffset = -pageSize * CGFloat(newIndex)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if newIndex == oldIndex { return }
                        if newIndex == 0 {
                            updateIndex(for: .backward)
                            index -= 1
                        }
                        if newIndex == 2 {
                            updateIndex(for: .forward)
                        }
                    }
                }
                startTimer(scrollAnimationConfig.isActive)
            }
    }

    init(
        index: Binding<Int>,
        objects: Binding<[T]>,
        pageSize: Binding<CGFloat>,
        scrollAnimationConfig: Binding<ScrollAnimationConfig>,
        numberOfContents: Int,
        pageAlignment: PageAlignment,
        pagingHandler: @escaping (PageDirection) -> Void
    ) {
        _index = index
        _objects = objects
        _pageSize = pageSize
        _scrollAnimationConfig = scrollAnimationConfig
        _pagingOffset = State(initialValue: -pageSize.wrappedValue)
        _draggingOffset = State(initialValue: 0)
        _timeCount = State(initialValue: 0)
        self.numberOfContents = numberOfContents
        self.pageAlignment = pageAlignment
        self.pagingHandler = pagingHandler
    }

    func body(content: Content) -> some View {
        content
            .offset(pageAlignment.offset(pagingOffset + draggingOffset))
            .simultaneousGesture(dragGesture)
            .onChange(of: objects) { _ in
                pagingOffset = -pageSize
            }
            .onChange(of: pageSize) { _ in
                pagingOffset = -pageSize
            }
            .onChange(of: index) { [index] newValue in
                guard index != newValue else {
                    return
                }
                
                print("index: from \(index) to \(newValue)")
                let diff: Int = (newValue - index)
                let isMaxDiff = abs(diff) == (numberOfContents - 1)
                
                if isMaxDiff {
                    let direction: PageDirection = diff >= .zero ? .backward : .forward
                    executePaging(direction)
                } else {
                    let direction: PageDirection = diff >= .zero ? .forward : .backward
                    for i in 1...abs(diff) {
                        executePaging(direction)
                    }
                }
            }
            .onReceive(timer) { _ in
                guard scrollAnimationConfig.isActive else {
                    cancelTimer()
                    return
                }
                timeCount += 1
                
                guard timeCount >= scrollAnimationConfig.threshold else {
                    return
                }
                updateIndex(for: .forward)
                timeCount = 0
            }
            .onAppear {
                startTimer(scrollAnimationConfig.isActive)
            }
            .onDisappear {
                cancelTimer()
            }
            .onReceiveAppLifeCycle { isActive in
                if isActive {
                    startTimer(scrollAnimationConfig.isActive)
                } else {
                    cancelTimer()
                }
            }
    }
}

// MARK: - Paging
extension InfinitePagingViewModifier {
    
    @MainActor
    private func executePaging(_ direction: PageDirection) {
        print("executePaging")
        let targetIndex: CGFloat = switch direction {
        case .backward:
                0
        case .forward:
                2
        }
        if #available(iOS 17.0, *) {
            withAnimation(.linear(duration: 0.1)) {
                pagingOffset = -pageSize * CGFloat(targetIndex)
            } completion: {
                pagingHandler(direction)
            }
        } else {
            withAnimation(.linear(duration: 0.1)) {
                pagingOffset = -pageSize * CGFloat(targetIndex)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                pagingHandler(direction)
            }
        }
    }
}

// MARK: - Timer
extension InfinitePagingViewModifier {
    
    private func startTimer(_ isScrollAnimationActive: Bool) {
        guard isScrollAnimationActive,
              !isTimerActive else {
            return
        }
        // TODO: remove
        print("start timer")
        isTimerActive = true
        timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    }
    
    private func cancelTimer() {
        guard isTimerActive else {
            return
        }
        // TODO: remove
        print("cancel timer")
        timeCount = 0
        timer.upstream.connect().cancel()
        isTimerActive = false
    }
}

// MARK: - Index
extension InfinitePagingViewModifier {
    
    private func updateIndex(for direction: PageDirection) {
        switch direction {
        case .backward:
            if (index - 1) >= 0 {
                index -= 1
            } else {
                index = (numberOfContents - 1)
            }
        case .forward:
            if (index + 1) <= (numberOfContents - 1) {
                index += 1
            } else {
                index = .zero
            }
        }
        print(index, numberOfContents)
    }
}
