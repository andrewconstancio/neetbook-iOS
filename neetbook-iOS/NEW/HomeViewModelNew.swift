import SwiftUI
import Combine

class HomeViewModelNew: ObservableObject {
    @Published var searchText = ""
    @Published var searchType: SearchType = .booksAndAuthors
    @Published var searchingState: SearchingState = .notSearching

    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                if value.count > 3 {
                    self?.searchingState = .startedSearch
                    
                    Task {
                        try await self?.searchAction()
                    }
                } else {
                    self?.searchingState = .notSearching
                }
            }
            .store(in: &cancellables)
    }
    
    func searchAction() async throws {
        do {
            searchingState = .loading
            
            switch searchType {
            case .booksAndAuthors:
                let foundBooks = try await BookAPIService.shared.searchBooks(searchText: searchText)
                searchingState = .searchedBooks(foundBooks)
            case .users:
                let foundUsers = try await UserInteractions.shared.searchUsers(searchText: searchText)
                searchingState = .searchedUser(foundUsers)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func getNYTBooks(for listName: String, limit: Int = 0) async -> [Book] {
        do {
            var isbns = try await BookAPIService.shared.fetchPopularBooksISBNs(for: listName)
            
            if limit > 0 && limit < isbns.count {
                isbns = Array(isbns[0..<limit])
            }
            
            var books: [Book] = []
            try await withThrowingTaskGroup(of: Book?.self) { group in
                for isbn in isbns {
                    group.addTask {
                        let book = try await BookAPIService.shared.fetchBookInfo(bookId: isbn)
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
            return []
        }
    }
}

