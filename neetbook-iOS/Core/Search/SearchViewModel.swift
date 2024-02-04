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
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                if value.count > 3 {
                        if self?.searchType == "books" && self?.recentlySearchedBookText != value {
                            Task {
                                try await self?.searchBooksTextAction(searchText: value)
                            }
                        } else if self?.recentlySearchedUserText != value {
                            Task {
                                try await self?.searchUsersTextAction(searchText: value)
                            }
                        }
                } else {
                    self?.clearSearchVars()
                }
            }
            .store(in: &cancellables)
    }
    
    private func clearSearchVars() {
        self.searchBookResults = []
        self.searchUsersResults = []
        self.loadingBooks = false
        self.loadingUsers = false
        self.recentlySearchedBookText = ""
        self.recentlySearchedUserText = ""
    }
    
    func searchBooksTextAction(searchText: String) async throws {
        do {
            self.loadingBooks = true
            searchBookResults = try await BookDataService.shared.searchBooks(searchText: searchText)
            recentlySearchedBookText = searchText
            loadingBooks = false
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func searchUsersTextAction(searchText: String) async throws {
        self.loadingUsers = true
        let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        searchUsersResults = try await UserInteractions.shared.searchForUser(searchText: searchText.lowercased(), currentUserId: currentUserId)
        recentlySearchedUserText = searchText
        loadingUsers = false
    }
}
