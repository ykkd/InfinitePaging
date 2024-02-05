/*
 ContentView.swift
 InfinitePagingSample

 Created by Takuto Nakamura on 2023/10/22.
*/

import SwiftUI
import InfinitePaging

struct ContentView: View {
    // Prepare three elements to display at first.
    @State var pages: [Page]
    @State private var displayedPages: [Page]
    
    @State var pageAlignment: PageAlignment = .horizontal
    @State var currentIndex: Int = 0
    
    @State var isAllowAutoScrollAnimation: Bool = true

    static func generateDisplayedPages(_ pages: [Page]) -> [Page] {
        guard 3 >= pages.count else {
            return pages
        }
        
        var pageCount = pages.count
        var generatedPages: [Page] = pages
        var loopCount = 0
        
        while 3 > pageCount {
            let generatedPage = Page.init(id: .init(), number: generatedPages[loopCount].number)
            generatedPages.append(generatedPage)
            loopCount += 1
            pageCount += 1
        }
        print(generatedPages.count)
        return generatedPages
    }
    
    init(pages: [Page], pageAlignment: PageAlignment, currentIndex: Int) {
        self.pages = pages
        self.displayedPages = Self.generateDisplayedPages(pages)
        self.pageAlignment = pageAlignment
        self.currentIndex = currentIndex
    }
    
    var body: some View {
        VStack {
            InfinitePagingView(
                index: $currentIndex,
                objects: $displayedPages, 
                isAllowAnimation: $isAllowAutoScrollAnimation,
                numberOfContents: pages.count,
                pageAlignment: pageAlignment,
                pageLength: UIScreen.main.bounds.width * 0.8,
                scrollAnimationConfig: .active(2.0),
                pagingHandler: { pageDirection in
                    paging(pageDirection)
                },
                content: { page in
                    pageView(page)
                }
            )
            PageControlView(
                numberOfPages: pages.count,
                currentPage: $currentIndex,
                selectedColor: .black,
                borderColor: .black,
                onTouchesBegan: {
                    isAllowAutoScrollAnimation = false
                },
                onTouchesCancelled: {
                    isAllowAutoScrollAnimation = true
                },
                onTouchesEnded: {
                    isAllowAutoScrollAnimation = true
                }
            )
                .frame(height: 24)
                .padding(.vertical, 10)
            Picker("Alignment", selection: $pageAlignment) {
                ForEach(PageAlignment.allCases) { alignment in
                    Text(verbatim: alignment.label)
                        .tag(alignment)
                }
            }
        }
    }

    // Define the View that makes up one page.
    private func pageView(_ page: Page) -> some View {
        return Text(String(page.number))
            .font(.largeTitle)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .padding()
    }

    // Shifts the array element by one when a paging request comes.
    private func paging(_ pageDirection: PageDirection) {
        switch pageDirection {
        case .backward:
            if let number = displayedPages.first?.number,
               let content = (pages.filter({ $0.number == (number - 1) }).first ?? pages.last) {
                displayedPages.insert(Page(id: .init(), number: content.number), at: 0)
                displayedPages.removeLast()
            }
        case .forward:
            if let number = displayedPages.last?.number,
               let content = (pages.filter({ $0.number == (number + 1) }).first ?? pages.first) {
                displayedPages.append(Page(id: .init(), number: content.number))
                displayedPages.removeFirst()
            }
        }
    }
}

extension PageAlignment: Identifiable {
    public var id: String { rawValue }
    var label: String { rawValue.localizedCapitalized }
}

#Preview {
    ContentView(
        pages: [
            Page(number: 0),
            Page(number: 1),
            Page(number: 2),
            Page(number: 3),
            Page(number: 4),
            Page(number: 5),
            Page(number: 6),
            Page(number: 7),
            Page(number: 8),
            Page(number: 9),
        ], 
        pageAlignment: .horizontal,
        currentIndex: 0
    )
}
