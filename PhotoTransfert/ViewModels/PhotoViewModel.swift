//
//  PhotoViewModel.swift
//  PhotoTransfert
//
//  Created by Luigi Aiello on 28/10/22.
//

import Foundation

struct PhotoViewModel {
    
    // MARK: - Stored Properties
    
    private let photo: Photo
    
    // MARK: - Init
    
    init(photo: Photo) {
        self.photo = photo
    }
}

// MARK: - Computed Variables

extension PhotoViewModel {
    
    var id: String {
        photo.id
    }
    
    var productUrl: String {
        photo.productUrl ?? ""
    }
    
    var baseUrl: String {
        photo.baseUrl ?? ""
    }
    
    var type: String {
        String(photo.mimeType?.split(separator: "/").last ?? "")
    }
    
    var imageUrl: URL? {
        URL(string: baseUrl)
    }
}
