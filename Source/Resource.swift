//
//  Resource.swift
//  MusicFeeder
//
//  Created by Hiroki Kumamoto on 2017/05/17.
//  Copyright © 2017 kumabook. All rights reserved.
//

import Foundation
import SwiftyJSON
import FeedlyKit

public struct Resource: ResponseObjectSerializable {
    public enum ResourceType: String {
        case stream         = "stream"
        case trackStream    = "track_stream"
        case albumStream    = "album_stream"
        case playlistStream = "playlist_stream"
        case entry          = "entry"
        case track          = "track"
        case album          = "album"
        case playlist       = "playlist"
        case custom         = "custom"
        case mix            = "mix"
        case trackMix       = "track_mix"
        case albumMix       = "album_mix"
        case playlistMix    = "playlist_mix"
    }
    public enum ItemType: String {
        case journal   = "journal"
        case topic     = "topic"
        case keyword   = "keyword"
        case tag       = "tag"
        case category  = "category"
        case entry     = "entry"
        case track     = "track"
        case album     = "album"
        case playlist  = "playlist"
        case globalTag = "global_tag"
    }
    public var resourceId:   String
    public var resourceType: ResourceType
    public var engagement:   Int
    public var itemType:     ItemType?
    public var item:         ResourceItem?
    public var options:      [String:Any]?
    public init(resourceId: String, resourceType: ResourceType, engagement: Int, itemType: ItemType? = nil, item: ResourceItem? = nil, options: [String:Any]? = nil) {
        self.resourceId   = resourceId
        self.resourceType = resourceType
        self.engagement   = engagement
        self.itemType     = itemType
        self.item         = item
        self.options      = options
    }
    public init?(response: HTTPURLResponse, representation: Any) {
        let json = JSON(representation)
        self.init(json: json)
    }
    public init(json: JSON) {
        resourceId   = json["resource_id"].stringValue
        resourceType = ResourceType(rawValue : json["resource_type"].stringValue) ?? .custom
        engagement   = json["engagement"].intValue
        itemType     = ItemType(rawValue: json["item_type"].stringValue)
        item         = ResourceItem(resourceType: resourceType, itemType: itemType, item: json["item"], options: json["options"])
        options      = json["options"].dictionaryObject
    }
}

public enum ResourceItem {
    case stream(FeedlyKit.Stream, MixPeriod)
    case trackStream(FeedlyKit.Stream, MixPeriod)
    case albumStream(FeedlyKit.Stream, MixPeriod)
    case playlistStream(FeedlyKit.Stream, MixPeriod)
    case mix(FeedlyKit.Stream, MixPeriod, MixType)
    case trackMix(FeedlyKit.Stream, MixPeriod, MixType)
    case albumMix(FeedlyKit.Stream, MixPeriod, MixType)
    case playlistMix(FeedlyKit.Stream, MixPeriod, MixType)
    case entry(Entry)
    case track(Track)
    case album(Album)
    case playlist(ServicePlaylist)
    public init?(resourceType: Resource.ResourceType, itemType: Resource.ItemType?, item: JSON, options: JSON) {
        if item.type == .null { return nil }
        guard let itemType = itemType else { return nil }
        switch resourceType {
        case .stream:
            guard let stream = ResourceItem.buildStream(itemType:itemType, json: item) else { return nil }
            self = .stream(stream, ResourceItem.buildMixPeriod(json: options))
        case .trackStream:
            guard let stream = ResourceItem.buildStream(itemType:itemType, json: item) else { return nil }
            self = .trackStream(stream, ResourceItem.buildMixPeriod(json: options))
        case .albumStream:
            guard let stream = ResourceItem.buildStream(itemType:itemType, json: item) else { return nil }
            self = .albumStream(stream, ResourceItem.buildMixPeriod(json: options))
        case .playlistStream:
            guard let stream = ResourceItem.buildStream(itemType:itemType, json: item) else { return nil }
            self = .playlistStream(stream, ResourceItem.buildMixPeriod(json: options))
        case .mix:
            guard let stream = ResourceItem.buildStream(itemType:itemType, json: item) else { return nil }
            self = .mix(stream,
                        ResourceItem.buildMixPeriod(json: options),
                        ResourceItem.buildMixType(json: options))
        case .trackMix:
            guard let stream = ResourceItem.buildStream(itemType:itemType, json: item) else { return nil }
            self = .trackMix(stream,
                             ResourceItem.buildMixPeriod(json: options),
                             ResourceItem.buildMixType(json: options))
        case .albumMix:
            guard let stream = ResourceItem.buildStream(itemType:itemType, json: item) else { return nil }
            self = .albumMix(stream,
                             ResourceItem.buildMixPeriod(json: options),
                             ResourceItem.buildMixType(json: options))
        case .playlistMix:
            guard let stream = ResourceItem.buildStream(itemType:itemType, json: item) else { return nil }
            self = .playlistMix(stream,
                                ResourceItem.buildMixPeriod(json: options),
                                ResourceItem.buildMixType(json: options))
        case .entry:
            self = .entry(Entry(json: item))
        case .track:
            self = .track(Track(json: item))
        case .album:
            self = .album(Album(json: item))
        case .playlist:
            self = .playlist(ServicePlaylist(json: item))
        case .custom:
            return nil
        }
    }
    public var stream: FeedlyKit.Stream? {
        switch self {
        case .stream(let stream, _):         return stream
        case .trackStream(let stream, _):    return stream
        case .albumStream(let stream, _):    return stream
        case .playlistStream(let stream, _): return stream
        case .mix(let stream, _, _):         return stream
        case .trackMix(let stream, _, _):    return stream
        case .albumMix(let stream, _, _):    return stream
        case .playlistMix(let stream, _, _): return stream
        default:                             return nil
        }
    }
    public static func buildStream(itemType: Resource.ItemType, json: JSON) -> FeedlyKit.Stream? {
        switch itemType {
        case .journal:
            return Journal(json: json)
        case .topic:
            return Topic(json: json)
        case .keyword:
            return Tag(json: json)
        case .tag:
            return Tag(json: json)
        case .category:
            return FeedlyKit.Category(json: json)
        case .globalTag:
            return Tag(json: json)
        default:
            return nil
        }
    }
    public static func buildMixPeriod(json: JSON) -> MixPeriod {
        return MixPeriod(rawValue: json["period"].stringValue) ?? .default
    }
    public static func buildMixType(json: JSON) -> MixType {
        return MixType(rawValue: json["type"].stringValue) ?? .hot
    }
}
