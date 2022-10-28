//
//  Birtd.swift
//  PhotoTransfert
//
//  Created by Luigi Aiello on 28/10/22.
//

import Foundation

struct Photo: Identifiable, Decodable {
    
    // MARK: - Stored Properties
    
    var id: String
    var productUrl: String?
    var baseUrl: String?
    var mimeType: String?
    var mediaMetadata: MediaMetaData
    var filename: String?
}

struct MediaMetaData: Decodable {
    
    // MARK: - Stored Properties
    
    var creationTime: String
    var width: String
    var height: String
    var video: VideoData?
    var photo: PhotoMetaData?
}

struct VideoData: Decodable {
    
    // MARK: - Stored Properties
    
    var fps: Double?
    var status: String?
}

struct PhotoMetaData: Decodable {
    
    // MARK: - Stored Properties
    
    var cameraMake: String?
    var cameraModel: String?
    var focalLength: Double?
    var apertureFNumber: Double?
    var isoEquivalent: Double?
    var exposureTime: String?
}

/// A model type representing the response from the request for the current user's birthday.
struct PhotoResponse: Decodable {
    
    // MARK: - Stored Properties
    
    /// The requested user's birthdays.
    let photos: [Photo]
    let nextPageToken: String?
    
    // MARK: - Init
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.photos = try container.decode([Photo].self, forKey: .mediaItems)
        self.nextPageToken = try container.decodeIfPresent(String.self, forKey: .nextPageToken)
    }
}

extension PhotoResponse {
    enum CodingKeys: String, CodingKey {
        case mediaItems
        case nextPageToken
    }
}
