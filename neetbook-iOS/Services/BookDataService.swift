//
//  BookDataService.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/4/23.
//

import SwiftUI
enum APIError: Error {
    case networkError(Error)
    case invalidData
    case invalidURL
}



final class BookDataService {
    static let shared = BookDataService()

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
        
        let image: UIImage?
        if let coverURL = URL(string: smallThumbnail) {
            let (coverData, response) = try await URLSession.shared.data(from: coverURL, delegate: nil)
            image = Helpers.shared.convertDataToUIImage(data: coverData, response: response)
        } else {
            image = UIImage(systemName: "book.closed.circle.fill")
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
            publisher: publisher,
            coverPhoto: image
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

                        let image: UIImage?
                        if let coverURL = URL(string: smallThumbnail) {
                            let (coverData, response) = try await URLSession.shared.data(from: coverURL, delegate: nil)
                            image = Helpers.shared.convertDataToUIImage(data: coverData, response: response)
                        } else {
                            image = UIImage(systemName: "book.closed.circle.fill")
                        }
                        
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
                            publisher: publisher,
                            coverPhoto: image
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
