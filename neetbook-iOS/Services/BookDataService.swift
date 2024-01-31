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
    
    let baseURL = URL(string: "https://www.googleapis.com/books/v1/volumes")!
    private let isbnBaseURL: String =  "https://api2.isbndb.com"
    private let isbnAuth: String =  "51178_5cfc6b159101f2948a1d51ae96d35242"
//    private let openLibraryBaseURL: String = "https://openlibrary.org/"
//    private let openLibraryCoversBaseURL: String = "https://covers.openlibrary.org/"
//    private let openLibraryFetchAuthorBaseURL: String = "https://openlibrary.org/search/authors.json"
    
    func fetchBookInfo(bookId: String) async throws -> Book? {
        guard let url = URL(string: "\(isbnBaseURL)/book/\(bookId)") else {
            throw APIError.invalidData
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Content-Type", forHTTPHeaderField: "application/json")
        urlRequest.setValue(isbnAuth, forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        guard let bookJSON = json?["book"] as? [String : Any],
              let title = bookJSON["title"] as? String,
              let authors = bookJSON["authors"] as? [String],
              let smallThumbnail = bookJSON["image"] as? String,
              let publishedDate = bookJSON["date_published"] as? String else {
            return nil
        }

        let description = bookJSON["synopsis"] as? String ?? ""
        let author = authors.first ?? ""
        let publishedYear = String(publishedDate.prefix(4))

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
            publishedYear: publishedYear,
            coverPhoto: image
        )
    }
    
    func searchBooks(searchText: String) async throws -> [Book] {
        let search = searchText.replacingOccurrences(of: " ", with: "%20")
        guard let url = URL(string: "\(isbnBaseURL)/books/\(search)?page=1&pageSize=200&column=title") else {
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
                        guard let bookId = item["isbn10"] as? String,
                              let title = item["title"] as? String,
                              let authors = item["authors"] as? [String],
                              let smallThumbnail = item["image"] as? String,
                              let publishedDate = item["date_published"] as? String else {
                            return nil
                        }

                        let description = item["synopsis"] as? String ?? ""
                        let author = authors.first ?? ""
                        let publishedYear = String(publishedDate.prefix(4))

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
                            publishedYear: publishedYear,
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
    
    
//    func fetchBookInfo(bookId: String) async throws -> Book? {
//        guard let fetchBookURL = URL(string: "\(self.openLibraryBaseURL)/works/\(bookId).json") else {
//            print("1")
//            return nil
//        }
//
//        let (bookData, _) = try await URLSession.shared.data(from: fetchBookURL)
//        let bookJSON = try JSONSerialization.jsonObject(with: bookData) as? [String: Any]
//
//
//        guard let title = bookJSON?["title"] as? String else {
//            print("no title")
//            return nil
//        }
//
//        guard let authors = bookJSON?["authors"] as? [[String: Any]] else {
//            print("no authors")
//            return nil
//        }
//
//        let description = bookJSON?["description"] as? String ?? ""
//
//        guard let coversIdArray = bookJSON?["covers"] as? [Int] else {
//            print("no coversIdArray")
//            return nil
//        }
//
//        guard let authorObject = authors[0]["author"] as? [String : Any] else {
//            print("no authorObject")
//            return nil
//        }
//
//        guard let authorPath = authorObject["key"] as? String else {
//            print("no authorPath")
//            return nil
//        }
//
//
//        guard let fetchAuthorURL = URL(string: "\(self.openLibraryFetchAuthorBaseURL)\(authorPath).json") else {
//            print("3")
//            return nil
//        }
//        let (authorData, _) = try await URLSession.shared.data(from: fetchAuthorURL)
//        let authorJSON = try JSONSerialization.jsonObject(with: authorData) as? [String: Any]
//
//        guard let authorName = authorJSON?["name"] as? String else {
//            print("4")
//            return nil
//        }
//        let coverid = coversIdArray[0]
//        let coverURL = "\(openLibraryCoversBaseURL)/b/id/\(coverid)-M.jpg"
//
//        let coverImage: UIImage?
//        if let coverURL = URL(string: coverURL) {
//            let (coverData, response) = try await URLSession.shared.data(from: coverURL, delegate: nil)
//            coverImage = Helpers.shared.convertDataToUIImage(data: coverData, response: response)
//        } else {
//            coverImage = UIImage(systemName: "book.closed.circle.fill")
//        }
//
//        return Book(
//            bookId: bookId,
//            title: title,
//            author: authorName,
//            coverURL: coverURL,
//            description: description,
//            coverPhoto: coverImage
//        )
//    }
//
//    func searchBooks(query: String) async throws -> [Book] {
//        let searchText = query.replacingOccurrences(of: " ", with: "+")
//        let queryItems = [URLQueryItem(name: "q", value: searchText)]
//
//        guard let oURL = URL(string: self.openLibraryBaseURL) else {
//            throw APIError.invalidData
//        }
//
//        var urlComponents = URLComponents(url: oURL, resolvingAgainstBaseURL: true)!
//        urlComponents.queryItems = queryItems
//
//        guard let url = urlComponents.url else {
//            throw APIError.invalidData
//        }
//
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
//
//
//            if let items = json?["docs"] as? [[String: Any]] {
//                var books: [Book] = []
//                try await withThrowingTaskGroup(of: Book?.self) { group in
//                    for item in items {
//                        group.addTask {
//                            guard let bookIdFull = item["key"] as? String else {
//                                return nil
//                            }
//                            let bookId = bookIdFull.replacingOccurrences(of: "/works/", with: "")
//                            return try await self.fetchBookInfo(bookId: bookId)
//                        }
//                    }
//                    // Collect the results of image download tasks
//                    for try await book in group {
//                        if let book = book {
//                            books.append(book)
//                        }
//                    }
//                }
//                return books
//            } else {
//                throw APIError.invalidData
//            }
//        }
//    }
    
//    func searchBooks(searchText: String) async throws -> [Book] {
////        let queryItems = [URLQueryItem(name: "title", value: searchText)]
////        var urlComponents = URLComponents(url: self.baseURL, resolvingAgainstBaseURL: true)!
////        urlComponents.queryItems = queryItems
////
////        guard let url = urlComponents.url else {
////            throw APIError.invalidData
////        }
//
//        print(searchText)
//
//        guard let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=\(searchText)?key=AIzaSyAqHfZuOvUdHrkjsXxdSdj_c0ZiGZ5GONo") else {
//            throw APIError.invalidURL
//        }
//
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
//
//            if let items = json?["items"] as? [[String: Any]] {
//                var books: [Book] = []
//
//                // Use TaskGroup for concurrent image downloads
//                try await withThrowingTaskGroup(of: Book?.self) { group in
//                    for item in items {
//                        group.addTask {
//                            guard let volumeInfo = item["volumeInfo"] as? [String: Any],
//                                  let bookId = item["id"] as? String,
//                                  let imageLinks = volumeInfo["imageLinks"] as? [String: Any],
//                                  let title = volumeInfo["title"] as? String,
//                                  let authors = volumeInfo["authors"] as? [String],
//                                  let smallThumbnail = imageLinks["smallThumbnail"] as? String,
//                                  let description = volumeInfo["description"] as? String else {
//                                return nil
//                            }
//
//                            let author = authors.joined(separator: ", ")
//                            let image: UIImage?
//                            if let coverURL = URL(string: smallThumbnail) {
//                                let (coverData, response) = try await URLSession.shared.data(from: coverURL, delegate: nil)
//                                image = Helpers.shared.convertDataToUIImage(data: coverData, response: response)
//                            } else {
//                                image = UIImage(systemName: "book.closed.circle.fill")
//                            }
//
//                            return Book(
//                                bookId: bookId,
//                                title: title,
//                                author: author,
//                                coverURL: smallThumbnail,
//                                description: description,
//                                coverPhoto: image
//                            )
//                        }
//                    }
//
//                    // Collect the results of image download tasks
//                    for try await book in group {
//                        if let book = book {
//                            books.append(book)
//                        }
//                    }
//                }
//
//                return books
//            } else {
//                throw APIError.invalidData
//            }
//        } catch {
//            throw APIError.networkError(error)
//        }
//    }
//
//    func fetchBookInfo(bookId: String) async throws -> Book? {
//        guard let url = URL(string: "\(self.baseURL)/\(bookId)?key=AIzaSyAqHfZuOvUdHrkjsXxdSdj_c0ZiGZ5GONo") else {
//            throw APIError.invalidData
//        }
//
//        do {
//           let (data, _) = try await URLSession.shared.data(from: url)
//           let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
//
//            guard let volumeInfo = json?["volumeInfo"] as? [String: Any],
//                  let bookId = json?["id"] as? String,
//                  let imageLinks = volumeInfo["imageLinks"] as? [String: Any],
//                  let title = volumeInfo["title"] as? String,
//                  let authors = volumeInfo["authors"] as? [String],
//                  let smallThumbnail = imageLinks["smallThumbnail"] as? String,
//                  let description = volumeInfo["description"] as? String else {
//                return nil
//            }
//
//            let author = authors.joined(separator: ", ")
//
//            let image: UIImage?
//            if let coverURL = URL(string: smallThumbnail) {
//                let (coverData, response) = try await URLSession.shared.data(from: coverURL, delegate: nil)
//                image = Helpers.shared.convertDataToUIImage(data: coverData, response: response)
//            } else {
//                image = UIImage(systemName: "book.closed.circle.fill")
//            }
//
//            return Book(
//                 bookId: bookId,
//                 title: title,
//                 author: author,
//                 coverURL: smallThumbnail,
//                 description: description,
////                 pageCount: pageCount,
////                 categories: categories,
//                 coverPhoto: image
//            )
//        } catch {
//           throw APIError.networkError(error)
//        }
//    }
}
