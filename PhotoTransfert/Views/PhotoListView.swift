//
//  ContentView.swift
//  PhotoTransfert
//
//  Created by Luigi Aiello on 28/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct PhotoListView: View {
    
    // MARK: - Stored Properties
    
    let columns = [GridItem(.adaptive(minimum: 80))]
    
    // MARK: - Wrapped Properties
    
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject var photoViewModel = PhotoListViewModel()
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            HStack {
                Text("Number of photos: \(photoViewModel.photos.count)")
                    .font(.callout)
                
                Spacer()
            } //: HSTACK
            .padding(.horizontal, 16)
            
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(photoViewModel.photos, id: \.id) { photoVM in
                        WebImage(url: photoVM.imageUrl)
                            .onSuccess { image, data, cacheType in
                                // Success
                                // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                            }
                            .onFailure { error in
                                print("ERROR: \(String(describing: error))")
                            }
                            .resizable()
                            .placeholder(Image(systemName: "photo"))
                            .placeholder {
                                Rectangle().foregroundColor(.gray)
                            }
                            .indicator(.activity)
                            .transition(.fade(duration: 0.5))
                            .scaledToFit()
                            .frame(width: 80, height: 80, alignment: .center)
                    } //: LOOP
                } //: LAZYVSTACK
            } //: SCROLLVIEW
        } //: VSTACK
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    self.authViewModel.signOut()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // TODO - Add transfert action
                } label: {
                    Image(systemName: "arrow.up.circle")
                }
            }
        } //: TOOLBAR
        .onAppear {
            if !self.authViewModel.hasPhotoReadScope {
                self.authViewModel.addPhotoReadScope {
                    self.photoViewModel.fetchPhotos()
                }
            } else {
                self.photoViewModel.fetchPhotos()
            }
        }
    }
}

// MARK: - Preview

struct PhotoListView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoListView()
            .environmentObject(AuthenticationViewModel())
    }
}
