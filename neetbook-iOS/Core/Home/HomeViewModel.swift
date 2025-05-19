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
    @Published var sectionOneBookResults: [Book] = []
    @Published var sectionTwoBookResults: [Book] = []
    @Published var sectionThreeBookResults: [Book] = []
    @Published var sectionFourBookResults: [Book] = []
    @Published var searchUsersResults: [UserSearchResult] = []
    @Published var searchText: String = ""
    @Published var loadingBooks: Bool = false
    @Published var loadingUsers: Bool = false
    @Published var isSearching: Bool = false
    @Published var searchType: String = "books"
    
    @Published var isLoadingBooksSectionOne: Bool = false
    @Published var isLoadingBooksSectionTwo: Bool = false
    @Published var isLoadingBooksSectionThree: Bool = false
    @Published var isLoadingBooksSectionFour: Bool = false
    
    private var recentlySearchedUserText: String = ""
    private var recentlySearchedBookText: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    let sectionOneListName = "mass-market-monthly"
    let sectionTwoListName = "paperback-nonfiction"
    let sectionThreeListName = "advice-how-to-and-miscellaneous"
    let sectionFourListName = "graphic-books-and-manga"
    
    let sectionOneFriendlyName = "Best Sellers"
    let sectionTwoFriendlyName = "Nonfiction"
    let sectionThreeFriendlyName = "Advice and Misc."
    let sectionFourFriendlyName = "Graphic Books and Manga"
    
    init() {
        addSubscribers()
        Task {
            isLoadingBooksSectionOne = true
            try await BookDataService.shared.cache.loadFromDisk()
            sectionOneBookResults = try await getNYTBooks(for: sectionOneListName, limit: 3)
            isLoadingBooksSectionOne = false
        }
        
        Task {
            isLoadingBooksSectionTwo = true
            sectionTwoBookResults = try await getNYTBooks(for: sectionTwoListName, limit: 3)
            isLoadingBooksSectionTwo = false
        }
        
        Task {
            isLoadingBooksSectionThree = true
            sectionThreeBookResults = try await getNYTBooks(for: sectionThreeListName, limit: 3)
            isLoadingBooksSectionThree = false
        }
        
        Task {
            isLoadingBooksSectionFour = true
            sectionFourBookResults = try await getNYTBooks(for: sectionFourListName, limit: 3)
            isLoadingBooksSectionFour = false
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
    
//    func getUserBooks() async throws {
//        do {
//            let userId = try AuthenticationManager.shared.getAuthenticatedUserUserId()
//        } catch {
//            throw error
//        }
//    }
    
    func getNYTBooks(for listName: String, limit: Int = 0) async throws -> [Book] {
        do {
            var isbns = try await BookDataService.shared.fetchPopularBooksISBNs(for: listName)
            
            if limit > 0 && limit < isbns.count {
                isbns = Array(isbns[0..<limit])
            }
            
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
            return books
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}
