//
//  SearchViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/4/23.
//

import SwiftUI
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchBookResults: [Book] = []
    @Published var searchText: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    func addSubscribers() {
        $searchText
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { value in
                if value.count > 3 {
                    Task {
                        try await self.searchTextAction(searchText: value)
                    }
                } else if value.count == 0 {
                    self.searchBookResults = []
                }
            }
            .store(in: &cancellables)
    }
    
    func searchTextAction(searchText: String) async throws {
        searchBookResults = try await BookDataService.shared.searchBooks(query: searchText)
    }
}
