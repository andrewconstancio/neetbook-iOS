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
    private let isbnAuth: String =  "51178_5cfc6b159101f2948a1d51ae96d35242"
    
    func fetchBookInfo(bookId: String) async throws -> Book? {
        
        guard let url = URL(string: "\(isbnBaseURL)/book/\(bookId)") else {
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
        let subjects = bookJSON["subjects"] as? [String] ?? []
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
    
    func searchBooks(searchText: String) async throws -> [Book] {
        let search = searchText.replacingOccurrences(of: " ", with: "%20")
        guard let url = URL(string: "\(isbnBaseURL)/books/\(search)?page=1&pageSize=100&column=title") else {
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
        let endpoint = "https://api.nytimes.com/svc/books/v3/lists.json"
//        let endpoint = "https://api.nytimes.com/svc/books/v3/lists/current/hardcover-fiction.json"
        guard var urlComponents = URLComponents(string: endpoint) else {
          throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        urlComponents.queryItems = [
          URLQueryItem(name: "api-key", value: "YnfINN7ZG1aH7zkqEooljdQiBXOivgiY"),
          URLQueryItem(name: "list", value: listName)
        ]
        guard let url = urlComponents.url else {
          throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let results = json?["results"] as? [[String: Any]] else {
          throw NSError(domain: "Invalid Data", code: 0, userInfo: nil)
        }
        
        var isbnArray: [String] = []
        
        for result in results {
            let isbns = result["isbns"] as? [[String: Any]]
            let details = result["book_details"] as? [[String: Any]]

            
            if let details = details {
                for detail in details {
                    let title = detail["title"] as? String
                    let primary_isbn13 = detail["primary_isbn13"] as? String
                    if let isbn =  primary_isbn13 {
                        isbnArray.append(isbn)
                    }
                }
            }
        }
        
        return isbnArray
    }
}
