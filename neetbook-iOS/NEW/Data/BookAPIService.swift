import Foundation

final class BookAPIService {
    static var shared = BookAPIService()
    
    private let isbnBaseURL: String =  "https://api.premium.isbndb.com"
    private let isbnBaseURLDev: String =  "https://api2.isbndb.com"
    private let isbnAuth: String =  "51178_5cfc6b159101f2948a1d51ae96d35242"
    private let isbnAuthDev: String =  "53048_0b15a9753633ec3f107cadfe8eef37ae"
    
    let cache = DiskCache<Book>(filename: "xca_book", experationInternal: 60 * 60 * 24)
    
    func fetchBookInfo(bookId: String) async throws -> Book? {
        
        if let book = await cache.value(forKey: bookId) {
            return book
        }

        guard let url = URL(string: "\(isbnBaseURLDev)/book/\(bookId)") else {
            throw APIError.invalidData
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Content-Type", forHTTPHeaderField: "application/json")
        urlRequest.setValue(isbnAuth, forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let bookJSON = json?["book"] as? [String : Any] else {
            return nil
        }
        
        var publishedYear = "N/A"
        let title = bookJSON["title"] as? String ?? ""
        let authors = bookJSON["authors"] as? [String] ?? []
        let smallThumbnail = bookJSON["image"] as? String ?? ""
        let pages = bookJSON["pages"] as? Int ?? 0
        let description = bookJSON["synopsis"] as? String ?? ""
//        let subjects = bookJSON["subjects"] as? [String] ?? []
        let author = authors.first ?? ""
        let publishedDate = bookJSON["date_published"] as? String
        let language = bookJSON["language"] as? String ?? ""
        let publisher = bookJSON["publisher"] as? String ?? ""
        
        if let publishedDate = publishedDate {
            publishedYear = String(publishedDate.prefix(4))
        }
        
        let book = Book(
            bookId: bookId,
            title: title,
            author: author,
            coverURL: smallThumbnail,
            description: description,
            pages: pages,
            publishedYear: publishedYear,
            language: language,
            publisher: publisher
        )
        
        //save to cache
        await cache.setValue(book, forKey: bookId)
        try await cache.saveToDisk()


        return book
    }
    
    func searchBooks(searchText: String) async throws -> [Book] {
        let search = searchText.replacingOccurrences(of: " ", with: "%20")
        
        guard let url = URL(string: "\(isbnBaseURLDev)/books/\(search)?page=1&pageSize=50&column=title") else {
            throw APIError.invalidData
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Content-Type", forHTTPHeaderField: "application/json")
        urlRequest.setValue(isbnAuth, forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        var books: [Book] = []
        if let items = json?["books"] as? [[String: Any]] {
            // Use TaskGroup for concurrent image downloads
            try await withThrowingTaskGroup(of: Book?.self) { group in
                for item in items {
                    group.addTask {
                        guard let bookId = item["isbn13"] as? String,
                              let title = item["title"] as? String,
                              let authors = item["authors"] as? [String],
                              let smallThumbnail = item["image"] as? String,
                              let publishedDate = item["date_published"] as? String else {
                            return nil
                        }

                        let description = item["synopsis"] as? String ?? ""
                        let pages = item["pages"] as? Int ?? 0
                        let author = authors.first ?? ""
                        let publishedYear = String(publishedDate.prefix(4))
                        let language = item["language"] as? String ?? ""
                        let publisher = item["publisher"] as? String ?? ""
                        
                        if let book = await self.cache.value(forKey: bookId) {
                            return book
                        }

                        return Book(
                            bookId: bookId,
                            title: title,
                            author: author,
                            coverURL: smallThumbnail,
                            description: description,
                            pages: pages,
                            publishedYear: publishedYear,
                            language: language,
                            publisher: publisher
                        )
                    }
                }

                // Collect the results of image download tasks
                for try await book in group {
                    if let book = book {
                        books.append(book)
                    }
                }
            }
        }

        return books
    }
    
    func fetchPopularBooksISBNs(for listName: String) async throws -> [String] {
        
        let endpoint = "https://api.nytimes.com/svc/books/v3/lists/current/\(listName).json?api-key=YnfINN7ZG1aH7zkqEooljdQiBXOivgiY"
        
        guard let url = URL(string: endpoint) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Invalid Response", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: nil)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let results = json["results"] as? [String: Any],
           let books = results["books"] as? [[String: Any]] else {
            throw NSError(domain: "Invalid Data", code: 0, userInfo: nil)
        }

        let isbnArray: [String] = books.compactMap { $0["primary_isbn13"] as? String }

        return isbnArray
    }
}

//// MARK: - Book API Service
//final class BookAPIService {
//    
//    // MARK: - Static Var
//    static var shared = BookAPIService()
//    
//    // MARK: - Properties
//    private let isbnBaseURL = "https://api2.isbndb.com"
//    private let isbnAuth = "53048_0b15a9753633ec3f107cadfe8eef37ae"
//    private let nyTimesAPIKey = "YnfINN7ZG1aH7zkqEooljdQiBXOivgiY"
//    
//    private let cache = DiskCache<Book>(
//        filename: "xca_book",
//        experationInternal: 60 * 60 * 24
//    )
//    
//    private let session: URLSession
//    
//    // MARK: - Initialization
//    init(session: URLSession = .shared) {
//        self.session = session
//    }
//    
//    // MARK: - NY Times API
//    func fetchPopularBooksISBNs(for listName: String) async throws -> [String] {
//        let endpoint = "https://api.nytimes.com/svc/books/v3/lists/current/\(listName).json"
//        
//        guard var components = URLComponents(string: endpoint) else {
//            throw BookAPIError.invalidURL
//        }
//        
//        components.queryItems = [
//            URLQueryItem(name: "api-key", value: nyTimesAPIKey)
//        ]
//        
//        guard let url = components.url else {
//            throw BookAPIError.invalidURL
//        }
//        
//        let (data, response) = try await session.data(from: url)
//        
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw BookAPIError.invalidResponse(statusCode: -1)
//        }
//        
//        guard httpResponse.statusCode == 200 else {
//            throw BookAPIError.invalidResponse(statusCode: httpResponse.statusCode)
//        }
//        
//        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
//        
//        guard let results = json?["results"] as? [String: Any],
//              let books = results["books"] as? [[String: Any]] else {
//            throw BookAPIError.invalidData
//        }
//        
//        return books.compactMap { $0["primary_isbn13"] as? String }
//    }
//    
//    // MARK: - ISBN DB API
//    func fetchBookInfo(bookId: String) async throws -> Book? {
//        // Check cache first
//        if let cachedBook = await cache.value(forKey: bookId) {
//            return cachedBook
//        }
//        
//        guard let url = URL(string: "\(isbnBaseURL)/book/\(bookId)") else {
//            throw BookAPIError.invalidURL
//        }
//        
//        let request = createISBNRequest(url: url)
//        let (data, _) = try await session.data(for: request)
//        
//        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
//        
//        print(json)
//        
//        guard let bookJSON = json?["book"] as? [String: Any] else {
//            throw BookAPIError.noBookFound
//        }
//        
//        let book = parseBook(from: bookJSON, bookId: bookId)
//        
//        // Cache the result
//        await cache.setValue(book, forKey: bookId)
//        try await cache.saveToDisk()
//        
//        return book
//    }
//    
//    func searchBooks(searchText: String) async throws -> [Book] {
//        let encodedSearch = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText
//        
//        guard let url = URL(string: "\(isbnBaseURL)/books/\(encodedSearch)?page=1&pageSize=50&column=title") else {
//            throw BookAPIError.invalidURL
//        }
//        
//        let request = createISBNRequest(url: url)
//        let (data, _) = try await session.data(for: request)
//        
//        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
//        
//        guard let items = json?["books"] as? [[String: Any]] else {
//            return []
//        }
//        
//        return await withTaskGroup(of: Book?.self) { group in
//            for item in items {
//                group.addTask { [weak self] in
//                    await self?.parseBookFromSearch(item)
//                }
//            }
//            
//            var books: [Book] = []
//            for await book in group {
//                if let book = book {
//                    books.append(book)
//                }
//            }
//            return books
//        }
//    }
//    
//    // MARK: - Private Helpers
//    private func createISBNRequest(url: URL) -> URLRequest {
//        var request = URLRequest(url: url)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue(isbnAuth, forHTTPHeaderField: "Authorization")
//        return request
//    }
//    
//    private func parseBook(from json: [String: Any], bookId: String) -> Book {
//        let title = json["title"] as? String ?? ""
//        let authors = json["authors"] as? [String] ?? []
//        let author = authors.first ?? ""
//        let coverURL = json["image"] as? String ?? ""
//        let description = json["synopsis"] as? String ?? ""
//        let pages = json["pages"] as? Int ?? 0
//        let language = json["language"] as? String ?? ""
//        let publisher = json["publisher"] as? String ?? ""
//        
//        let publishedYear: String
//        if let publishedDate = json["date_published"] as? String {
//            publishedYear = String(publishedDate.prefix(4))
//        } else {
//            publishedYear = "N/A"
//        }
//        
//        return Book(
//            bookId: bookId,
//            title: title,
//            author: author,
//            coverURL: coverURL,
//            description: description,
//            pages: pages,
//            publishedYear: publishedYear,
//            language: language,
//            publisher: publisher
//        )
//    }
//    
//    private func parseBookFromSearch(_ item: [String: Any]) async -> Book? {
//        guard let bookId = item["isbn13"] as? String,
//              let title = item["title"] as? String,
//              let authors = item["authors"] as? [String],
//              let coverURL = item["image"] as? String,
//              let publishedDate = item["date_published"] as? String else {
//            return nil
//        }
//        
//        // Check cache first
//        if let cachedBook = await cache.value(forKey: bookId) {
//            return cachedBook
//        }
//        
//        let author = authors.first ?? ""
//        let description = item["synopsis"] as? String ?? ""
//        let pages = item["pages"] as? Int ?? 0
//        let publishedYear = String(publishedDate.prefix(4))
//        let language = item["language"] as? String ?? ""
//        let publisher = item["publisher"] as? String ?? ""
//        
//        return Book(
//            bookId: bookId,
//            title: title,
//            author: author,
//            coverURL: coverURL,
//            description: description,
//            pages: pages,
//            publishedYear: publishedYear,
//            language: language,
//            publisher: publisher
//        )
//    }
//}


