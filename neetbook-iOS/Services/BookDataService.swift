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
}

final class BookDataService {
    static let shared = BookDataService()
    
    let baseURL = URL(string: "https://www.googleapis.com/books/v1/volumes")!
    
    func searchBooks(query: String) async throws -> [Book] {
        let queryItems = [URLQueryItem(name: "q", value: query)]
        var urlComponents = URLComponents(url: self.baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw APIError.invalidData
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            if let items = json?["items"] as? [[String: Any]] {
                var books: [Book] = []

                // Use TaskGroup for concurrent image downloads
                try await withThrowingTaskGroup(of: Book?.self) { group in
                    for item in items {
                        group.addTask {
                            guard let volumeInfo = item["volumeInfo"] as? [String: Any],
                                  let bookId = item["id"] as? String,
                                  let imageLinks = volumeInfo["imageLinks"] as? [String: Any],
                                  let title = volumeInfo["title"] as? String,
                                  let authors = volumeInfo["authors"] as? [String],
                                  let smallThumbnail = imageLinks["smallThumbnail"] as? String,
                                  let description = volumeInfo["description"] as? String,
                                  let pageCount = volumeInfo["pageCount"] as? Int,
                                  let categories = volumeInfo["categories"] as? [String] else {
                                return nil
                            }

                            let author = authors.joined(separator: ", ")
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
                                pageCount: pageCount,
                                categories: categories,
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

                return books
            } else {
                throw APIError.invalidData
            }
        } catch {
            throw APIError.networkError(error)
        }
    }

    
    func fetchBookInfo(bookId: String) async throws -> Book? {
        guard let url = URL(string: "\(self.baseURL)/\(bookId)?key=AIzaSyAqHfZuOvUdHrkjsXxdSdj_c0ZiGZ5GONo") else {
            throw APIError.invalidData
        }
        
        do {
           let (data, _) = try await URLSession.shared.data(from: url)
           let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let volumeInfo = json?["volumeInfo"] as? [String: Any],
                  let bookId = json?["id"] as? String,
                  let imageLinks = volumeInfo["imageLinks"] as? [String: Any],
                  let title = volumeInfo["title"] as? String,
                  let authors = volumeInfo["authors"] as? [String],
                  let smallThumbnail = imageLinks["smallThumbnail"] as? String,
                  let description = volumeInfo["description"] as? String,
                  let pageCount = volumeInfo["pageCount"] as? Int,
                  let categories = volumeInfo["categories"] as? [String] else {
                return nil
            }
            
            let author = authors.joined(separator: ", ")
            
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
                 pageCount: pageCount,
                 categories: categories,
                 coverPhoto: image
            )
        } catch {
           throw APIError.networkError(error)
        }
    }
    
    func fetchBookList(bookIds: [String]) async throws {
        var books: [Book] = []
        for bookId in bookIds {
            guard let url = URL(string: "\(self.baseURL)/\(bookId)") else {
                throw APIError.invalidData
            }
            
            do {
               let (data, _) = try await URLSession.shared.data(from: url)
               let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

                guard let volumeInfo = json?["volumeInfo"] as? [String: Any],
                      let bookId = json?["id"] as? String,
                      let imageLinks = volumeInfo["imageLinks"] as? [String: Any],
                      let title = volumeInfo["title"] as? String,
                      let authors = volumeInfo["authors"] as? [String],
                      let smallThumbnail = imageLinks["smallThumbnail"] as? String,
                      let description = volumeInfo["description"] as? String,
                      let pageCount = volumeInfo["pageCount"] as? Int,
                      let categories = volumeInfo["categories"] as? [String] else {
                    throw APIError.invalidData
                }

                let author = authors.joined(separator: ", ")
                let book = Book(
                     bookId: bookId,
                     title: title,
                     author: author,
                     coverURL: smallThumbnail,
                     description: description,
                     pageCount: pageCount,
                     categories: categories
                )
                
                books.append(book)
            } catch {
               throw APIError.networkError(error)
            }
        }
    }
}
