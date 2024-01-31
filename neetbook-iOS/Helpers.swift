//
//  Helpers.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 8/18/23.
//

import SwiftUI

let darkBlack = Color(red: 17/255, green: 18/255, blue: 19/255)
let darkGray = Color(red: 41/255, green: 42/255, blue: 48/255)
let darkBlue = Color(red: 96/255, green: 174/255, blue: 201/255)
let darkPink = Color(red: 244/255, green: 132/255, blue: 177/255)
let darkViolet = Color(red: 214/255, green: 189/255, blue: 251/255)
let darkGreen = Color(red: 137/255, green: 192/255, blue: 180/255)

let clearWhite = Color(red: 17/255, green: 18/255, blue: 19/255)
let clearGray = Color(red: 181/255, green: 182/255, blue: 183/255)
let clearBlue = Color(red: 116/255, green: 166/255, blue: 240/255)

final class Helpers {
    
    static let shared = Helpers()
    
    func generateRandomFourDigitNumberString() -> String {
        var result = ""
            repeat {
                // Create a string with a random number 0...9999
                result = String(format:"%04d", arc4random_uniform(10000) )
            } while Set<Character>(result).count < 4
        return result
    }
    
    func getDownloadAndResponseDataFromURL(someURL: String) async throws -> (Data, URLResponse) {
        guard let url = URL(string: someURL) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            return (data, response)
        } catch {
            throw APIError.invalidData
        }
    }
    
    func convertDataToUIImage(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let image = UIImage(data: data),
            let reponse = response as? HTTPURLResponse,
            reponse.statusCode >= 200 && reponse.statusCode < 300 else {
                return nil
            }
        
        return image
    }
}
