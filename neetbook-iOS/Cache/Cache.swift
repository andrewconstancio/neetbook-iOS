//
//  Cache.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/20/24.
//

import Foundation

protocol Cache: Actor {
    associatedtype V
    var expirationInternal: TimeInterval { get }
    
    func removeValue(forKey key: String)
    func removeAllValues()
    func setValue(_ value: V?, forKey key: String)
    func value(forKey key: String) -> V?
    
}
