//
//  KeysTracker.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/20/24.
//

import Foundation

final class KeysTracker<V>: NSObject, NSCacheDelegate {
    var keys = Set<String>()
    
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        guard let entry = obj as? CacheEntry<V> else {
            return
        }
        keys.remove(entry.key)
    }
}
