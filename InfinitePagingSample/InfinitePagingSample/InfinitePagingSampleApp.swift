/*
 InfinitePagingSampleApp.swift
 InfinitePagingSample

 Created by Takuto Nakamura on 2023/10/22.
*/

import SwiftUI

@main
struct InfinitePagingSampleApp: App {
    var body: some Scene {
        WindowGroup {
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
    }
}
