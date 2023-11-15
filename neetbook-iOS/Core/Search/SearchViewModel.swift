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
    @Published var searchUsersResults: [UserSearchResult] = []
    @Published var searchText: String = ""
    @Published var searchType: String = "books"
    @Published var loadingBooks: Bool = false
    @Published var loadingUsers: Bool = false
    private var recentlySearchedBookText: String = ""
    private var recentlySearchedUserText: String = ""
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
                        if self.searchType == "books" && self.recentlySearchedBookText != value {
                            self.loadingBooks = true
                            try await self.searchBooksTextAction(searchText: value)
                        } else if self.recentlySearchedUserText != value {
                            self.loadingUsers = true
                            try await self.searchUsersTextAction(searchText: value)
                        }
                    }
                } else if value.count == 0 {
                    self.searchBookResults = []
                    self.searchUsersResults = []
                    self.loadingBooks = false
                    self.loadingUsers = false
                } else {
                    self.loadingBooks = false
                    self.loadingUsers = false
                }
            }
            .store(in: &cancellables)
    }
    
    func searchBooksTextAction(searchText: String) async throws {
        searchBookResults = try await BookDataService.shared.searchBooks(query: searchText)
        recentlySearchedBookText = searchText
        loadingBooks = false
    }
    
    func searchUsersTextAction(searchText: String) async throws {
        searchUsersResults = try await UserConnectivity.shared.searchForUser(searchText: searchText)
        recentlySearchedUserText = searchText
        loadingUsers = false
    }
}
