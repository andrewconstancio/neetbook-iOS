//
//  HomeNewViewModel.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 3/31/24.
//

import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var searchBookResults: [Book] = []
    @Published var popularBookResults: [Book] = []
    @Published var popularTwoBookResults: [Book] = []
    @Published var searchUsersResults: [UserSearchResult] = []
    @Published var searchText: String = ""
    @Published var loadingBooks: Bool = false
    @Published var loadingUsers: Bool = false
    @Published var isSearching: Bool = false
    @Published var searchType: String = "books"
    
    private var recentlySearchedUserText: String = ""
    private var recentlySearchedBookText: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
        Task {
            isLoading = true
            try? await getPopularBooks()
            isLoading = false
        }
    }
    
    func addSubscribers() {
        $searchText
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                if value.count < 3 {
                    self?.clearSearchVars()
                }
            }
            .store(in: &cancellables)
    }
    
    private func clearSearchVars() {
        isSearching = false
        searchBookResults = []
        loadingBooks = false
        recentlySearchedBookText = ""
    }
    
    func searchAction() async throws {
        if searchType == "books" {
            try? await searchBooksTextAction()
        } else if searchType == "users" {
            try? await searchUsersTextAction()
        }
    }
    
    func searchBooksTextAction() async throws {
        do {
            isSearching = true
            loadingBooks = true
            searchBookResults = try await BookDataService.shared.searchBooks(searchText: searchText)
            recentlySearchedBookText = searchText
            loadingBooks = false
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func searchUsersTextAction() async throws {
        isSearching = true
        loadingUsers = true
        let currentUserId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        searchUsersResults = try await UserInteractions.shared.searchForUser(searchText: searchText, currentUserId: currentUserId)
        recentlySearchedUserText = searchText
        loadingUsers = false
    }
    
    func getUserBooks() async throws {
        do {
            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
        } catch {
            throw error
        }
    }
    
    func getPopularBooks() async throws {
        do {
            let isbns = try await BookDataService.shared.fetchPopularBooksISBNs(for: "mass-market-paperback")
            var books: [Book] = []
            try await withThrowingTaskGroup(of: Book?.self) { group in
                for isbn in isbns {
                    group.addTask {
                        let book = try await BookDataService.shared.fetchBookInfo(bookId: isbn)
                        return book
                    }
                }
                
                for try await book in group {
                    if let book = book {
                        books.append(book)
                    }
                }
            }
            popularBookResults = books
        } catch {
            throw error
        }
    }
}
