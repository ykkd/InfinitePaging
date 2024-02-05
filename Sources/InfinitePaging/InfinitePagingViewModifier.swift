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
                guard index != newValue,
                      !isManualPagingNeededWhenIndexUpdated else {
                    return
                }
                
                // TODO: remove
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
                guard scrollAnimationConfig.isActive,
                      isPagingAnimationNeeded else {
                    cancelTimer()
                    return
                }
                timeCount += 1
                
                guard timeCount >= scrollAnimationConfig.threshold else {
                    return
                }
                updateIndex(for: .forward, type: .autoScroll)
                timeCount = 0
            }
            .onAppear {
                startTimerIfNeeded(scrollAnimationConfig.isActive)
            }
            .onDisappear {
                cancelTimer()
            }
            .onReceiveAppLifeCycle { isActive in
                if isActive {
                    startTimerIfNeeded(scrollAnimationConfig.isActive)
                } else {
                    cancelTimer()
                }
            }
    }
}

// MARK: - Private variables
extension InfinitePagingViewModifier {
    
    private var maxIndex: Int {
        numberOfContents - 1
    }
    
    private var minIndex: Int {
        .zero
    }
    
    private var numberOfContentsThresholdForPagingAnimation: Int {
        1
    }
    
    private var numberOfContentsThresholdForManualPaging: Int {
        3
    }
    
    private var isManualPagingNeededWhenIndexUpdated: Bool {
        numberOfContents < numberOfContentsThresholdForManualPaging
    }
    
    private var isPagingAnimationNeeded: Bool {
        numberOfContents > numberOfContentsThresholdForPagingAnimation
    }
}

// MARK: - Gesture
extension InfinitePagingViewModifier {
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                draggingOffset = pageAlignment.scalar(value.translation)
                cancelTimer()
            }
            .onEnded { @MainActor value in
                let oldPosition = PagePosition(Int(floor(0.5 - (pagingOffset / pageSize))))
                pagingOffset += pageAlignment.scalar(value.translation)
                draggingOffset = 0
                let newPosition = PagePosition(Int(max(0, min(2, floor(0.5 - (pagingOffset / pageSize))))))
                executePagingAnimationIfNeeded(newPosition: newPosition, oldPosition: oldPosition)
                startTimerIfNeeded(scrollAnimationConfig.isActive)
            }
    }
    
    @MainActor
    private func executePagingAnimationIfNeeded(newPosition: PagePosition, oldPosition: PagePosition) {
        if #available(iOS 17.0, *) {
            withAnimation(.linear(duration: 0.1)) {
                pagingOffset = -pageSize * CGFloat(newPosition.rawValue)
            } completion: {
                if newPosition == oldPosition {
                    return
                }
                if newPosition == .first {
                    updateIndex(for: .backward, type: .gesture)
                }
                if newPosition == .third {
                    updateIndex(for: .forward, type: .gesture)
                }
            }
        } else {
            withAnimation(.linear(duration: 0.1)) {
                pagingOffset = -pageSize * CGFloat(newPosition.rawValue)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if newPosition == oldPosition {
                    return
                }
                if newPosition == .first {
                    updateIndex(for: .backward, type: .gesture)
                }
                if newPosition == .third {
                    updateIndex(for: .forward, type: .gesture)
                }
            }
        }
    }
}

// MARK: - Paging
extension InfinitePagingViewModifier {
    
    @MainActor
    private func executePaging(_ direction: PageDirection) {
        // TODO: remove
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
    
    private func startTimerIfNeeded(_ isScrollAnimationActive: Bool) {
        guard isScrollAnimationActive,
              isPagingAnimationNeeded,
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
    
    @MainActor 
    private func updateIndex(for direction: PageDirection, type: PageUpdateType) {
        switch direction {
        case .backward:
            let backwardIndex = index - 1
            if backwardIndex >= minIndex {
                index = backwardIndex
            } else {
                index = maxIndex
            }
        case .forward:
            let forwardIndex = index + 1
            if forwardIndex <= maxIndex {
                index = forwardIndex
            } else {
                index = minIndex
            }
        }
        
        manuallyExecutePagingIfNeeded(for: direction, type: type)
        
        // TODO: remove
        print(index, numberOfContents)
    }
    
    @MainActor
    private func manuallyExecutePagingIfNeeded(for direction: PageDirection, type: PageUpdateType) {
        guard isManualPagingNeededWhenIndexUpdated else {
            return
        }
        if type.isAutoUpdate {
            executePaging(.forward)
        } else {
            executePaging(direction)
        }
    }
}
