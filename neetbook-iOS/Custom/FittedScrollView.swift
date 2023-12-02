//
//  FittedScrollView.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 11/30/23.
//

import SwiftUI

// MARK: - ScrollView

/// A scrollable view that sizes its content to fit the available space, scrolling if necessary.
public struct FittedScrollView<Content: View>: View {
    // MARK: Properties

    /// The scrollable view.
    private let content: Content

    // MARK: Initialization

    /// Initializes a `FittedScrollView`.
    ///
    /// - Parameter content: The view builder that creates the scrollable view.
    public init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }

    // MARK: View

    public var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                content
                    .frame(minWidth: geometry.size.width,
                           minHeight: geometry.size.height)
            }
        }
    }
}
