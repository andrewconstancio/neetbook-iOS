//
//  CacheImplemation.swift
//  neetbook-iOS
//
//  Created by Andrew Constancio on 4/20/24.
//

import Foundation

fileprivate protocol NSCacheType: Cache {
    var cache: NSCache<NSString, CacheEntry<V>> { get }
    var keyTracking: KeysTracker<V> { get }
}

actor InMemoryCache<V>: NSCacheType {
    fileprivate let cache: NSCache<NSString, CacheEntry<V>> = .init()
    fileprivate let keyTracking: KeysTracker<V> = .init()
    
    var expirationInternal: TimeInterval
    
    init(experationInternal: TimeInterval) {
        self.expirationInternal = experationInternal
    }
}

actor DiskCache<V: Codable>: NSCacheType {
    fileprivate let cache: NSCache<NSString, CacheEntry<V>> = .init()
    fileprivate let keyTracking: KeysTracker<V> = .init()
    
    let filename: String
    var expirationInternal: TimeInterval
    
    init(filename: String, experationInternal: TimeInterval) {
        self.filename = filename
        self.expirationInternal = experationInternal
    }
    
    private var saveLocationURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(filename).cache")
    }
    
    func saveToDisk() throws {
        let entries = keyTracking.keys.compactMap(entry)
        let data = try JSONEncoder().encode(entries)
        try data.write(to: saveLocationURL)
    }
    
    func loadFromDisk() throws {
        let data = try Data(contentsOf: saveLocationURL)
        let entries = try JSONDecoder().decode([CacheEntry<V>].self, from: data)
        entries.forEach { insert($0) }
    }
}

extension NSCacheType {
    func removeValue(forKey key: String) {
        keyTracking.keys.removeAll()
        cache.removeObject(forKey: key as NSString)
    }
    
    func removeAllValues() {
        cache.removeAllObjects()
    }
    
    func setValue(_ value: V?, forKey key: String) {
        if let value = value {
            let expiredTimestamp = Date().addingTimeInterval(expirationInternal)
            let cacheEntry = CacheEntry(key: key, value: value, expiredTimestamp: expiredTimestamp)
            insert(cacheEntry)
        } else {
            removeValue(forKey: key)
        }
    }
    
    func value(forKey key: String) -> V? {
        entry(forKey: key)?.value
    }
    
    func entry(forKey key: String) -> CacheEntry<V>? {
        guard let entry = cache.object(forKey: key as NSString) else {
            return nil
        }
        
        guard !entry.isCacheExpired(after: Date()) else {
            removeValue(forKey: key)
            return nil
        }
        
        return entry
    }
    
    func insert(_ entry: CacheEntry<V>) {
        keyTracking.keys.insert(entry.key)
        cache.setObject(entry, forKey: entry.key as NSString)
    }
}
