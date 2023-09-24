//
//  BookDataService.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 9/4/23.
//

import Foundation
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
               let books = items.compactMap { item -> Book? in
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
                   return Book(
                        bookId: bookId,
                        title: title,
                        author: author,
                        coverURL: smallThumbnail,
                        description: description,
                        pageCount: pageCount,
                        categories: categories
                   )
               }
               return books
           } else {
               throw APIError.invalidData
           }
        } catch {
           throw APIError.networkError(error)
        }
    }
    
    func fetchBookInfo(bookId: String) async throws -> Book {
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
            return Book(
                 bookId: bookId,
                 title: title,
                 author: author,
                 coverURL: smallThumbnail,
                 description: description,
                 pageCount: pageCount,
                 categories: categories
            )
        } catch {
           throw APIError.networkError(error)
        }
    }
}
