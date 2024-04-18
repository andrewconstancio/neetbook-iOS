//
//  PreviewProvider-Ext.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 2/18/24.
//

import Foundation
import SwiftUI

extension PreviewProvider {
    
    static var dev: DeveloperPreview {
        return DeveloperPreview.instance
    }
    
}

class DeveloperPreview {
    static let instance = DeveloperPreview()
    private init() {}
    
    let user = DBUser(userId: "7moM6z8207WPwZPaG5MHgUSETLj1",
                      hashcode: "2503",
                      username: "swag",
                      displayname: "Andrew",
                      email: "andrewconstancio7@gmail.com",
                      photoUrl: "https://firebasestorage.googleapis.com:443/v0/b/neetbook-71cb0.appspot.com/o/profile_images%2FHZdLedirQBeyTeSkImpVAfsfp1e2?alt=media&token=87c62246-0270-48b5-a2b8-c32ee048887c",
                      publicAccount: true,
                      dateOfBirth: Date(),
                      dateCreated: Date(),
                      selectedGenres: [],
                      profilePhoto: UIImage(named: "onepiece"))
    
    let book = Book(id: UUID(),
                    bookId: "1101157879",
                    title: "Dune Messiah",
                    author: "Herbert, Frank",
                    coverURL: "https://images.isbndb.com/covers/99/35/9780340839935.jpg",
                    description: "Book Two in the Magnificent Dune Chronicles—the Bestselling Science Fiction Adventure of All Time Dune Messiah continues the story of Paul Atreides, better known—and feared—as the man christened Muad’Dib. As Emperor of the known universe, he possesses more power than a single man was ever meant to wield. Worshipped as a religious icon by the fanatical Fremen, Paul faces the enmity of the political houses he displaced when he assumed the throne—and a conspiracy conducted within his own sphere of influence. And even as House Atreides begins to crumble around him from the machinations of his enemies, the true threat to Paul comes to his lover, Chani, and the unborn heir to his family’s dynasty...",
                    pages: 416,
                    publishedYear: "2008-02-05",
                    language: "en",
                    publisher: "YOOO",
                    coverPhoto: UIImage(named: "dunemi"))
    
    let postComment = PostComment(documentId: "zZrI19bILlAbfkvH4pI8",
                                  userId: "9iNv2tf5tqQMFvdwhLPLzDo2OZf1",
                                  displayName: "Andrew",
                                  profilePicture: UIImage(named: "onepiece")!,
                                  comment: "This is a comment",
                                  dateCreated: Date())
}
