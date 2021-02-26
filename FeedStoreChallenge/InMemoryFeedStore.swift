//
//  File.swift
//  FeedStoreChallenge
//
//  Created by Nadheer on 25/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class InMemoryFeedStore: FeedStore {
	public init() {}
	
	private struct InMemoryFeedCache {
		let feed: [LocalFeedImage]
		let timestamp: Date
	}
	
	private var cache: InMemoryFeedCache?
	private let queue = DispatchQueue(label: "\(InMemoryFeedStore.self)Queue", qos: .userInitiated)
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		queue.async(flags: .barrier) {
			guard self.cache != nil else { return completion(nil) }
			self.cache = nil
			completion(nil)
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		queue.async(flags: .barrier) {
			
			self.cache = InMemoryFeedCache(feed: feed, timestamp: timestamp)
			completion(nil)
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		queue.async {
			
			guard let cache = self.cache else {
				return completion(.empty)
			}
			
			completion(.found(feed: cache.feed, timestamp: cache.timestamp))
		}
	}
}

