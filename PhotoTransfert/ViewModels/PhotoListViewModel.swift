//
//  PhotoListViewModel.swift
//  PhotoTransfert
//
//  Created by Luigi Aiello on 28/10/22.
//

import SwiftUI
import Combine

class PhotoListViewModel: ObservableObject {
    
    // MARK: - Stored Properties
    
    private var cancellable = Set<AnyCancellable>()
    private let photoLoader = PhotoLoader()
    private var pageToken: String?
    
    // MARK: - Wrapped Properties
    
    /// The `Birthday` of the current user.
    /// - note: Changes to this property will be published to observers.
    @Published private(set) var photos: [PhotoViewModel] = []
    //@Published private(set) var photos: [Data] = []
    
    // MARK: - Methods
    
    /// Fetches the birthday of the current user.
    func fetchPhotos() {
        photoLoader.photoPublisher(pageToken: pageToken) { [weak self] publisher in
            guard let self else {
                return
            }
            
            publisher
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error retrieving photos: \(error)")
                    }
                } receiveValue: { response in
                    /*for photo in photos {
                        self.fetchPhoto(photo)
                    }
                     */
                    self.photos.append(contentsOf: response.photos.map(PhotoViewModel.init))
                    self.pageToken = response.nextPageToken
                }
                .store(in: &self.cancellable)
        }
    }
    
    /*
    
    func fetchPhoto(_ photo: Photo) {
        guard
            let urlString = photo.productUrl,
            let url = URL(string: urlString)
        else {
            return
        }
        
        photoLoader.downloadPhoto(url: url) { publisher in
            publisher
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error retrieving photos: \(error)")
                    }
                } receiveValue: { data in
                    self.photos.append(data)
                }
                .store(in: &self.cancellable)
        }
    }
     */
}
