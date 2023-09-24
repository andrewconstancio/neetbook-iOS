//
//  UserNameSetupViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 8/20/23.
//

import SwiftUI
import Combine

final class UserNameSetupViewModel: ObservableObject {
    private var disposeBag = Set<AnyCancellable>()

    @Published var text: String = ""

    init() {
        self.debounceTextChanges()
    }

    private func debounceTextChanges() {
        $text
            // 2 second debounce
            .debounce(for: 2, scheduler: RunLoop.main)

            // Called after 2 seconds when text stops updating (stoped typing)
            .sink {
                print("new text value: \($0)")
            }
            .store(in: &disposeBag)
    }
}
