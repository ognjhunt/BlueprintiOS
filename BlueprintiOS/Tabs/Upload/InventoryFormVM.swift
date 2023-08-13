//
//  InventoryFormVM.swift
//  XCAInventoryTracker
//
//  Created by Alfian Losari on 30/07/23.
//

import FirebaseFirestore
import FirebaseStorage
import Foundation
import SwiftUI
import UIKit
import QuickLookThumbnailing

class InventoryFormViewModel: ObservableObject {
    
    let db = Firestore.firestore()
    let formType: FormType
    
    let id: String
    @Published var name = ""
    @Published var description = ""
    @Published var price = 0.0
    @Published var creatorId = ""
    @Published var category = ""
    @Published var tags = ""
    @Published var privacy = ""
    @Published var scale = 1.0
    @Published var size = 10.0
    
    @Published var usdzURL: URL?
    @Published var thumbnailURL: URL?
    
    @Published var thumbnailImage: UIImage?

    
    @Published var loadingState = LoadingType.none
    @Published var error: String?
    
    @Published var uploadProgress: UploadProgress?
    @Published var showUSDZSource = false
    @Published var selectedUSDZSource: USDZSourceType?
    
    let byteCountFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.countStyle = .file
        return f
    }()
    
    var navigationTitle: String {
        switch formType {
        case .add:
            return "Add Item"
        case .edit:
            return "Edit Item"
        }
    }
    
    init(formType: FormType = .add) {
        self.formType = formType
        switch formType {
        case .add:
            id = UUID().uuidString
        case .edit(let item):
            id = item.id
            name = item.name
            description = item.description
            price = item.price
            creatorId = item.creatorId
            category = item.category
            privacy = item.privacy
            tags = item.tags
            scale = item.scale
            size = item.size
            
            if let usdzURL = item.usdzURL {
                self.usdzURL = usdzURL
            }
            if let thumbnailURL = item.thumbnailURL {
                self.thumbnailURL = thumbnailURL
            }
        }
    }
    
    func save() throws {
        loadingState = .savingItem
        
        defer { loadingState = .none }
        
        var item: InventoryItem
        switch formType {
        case .add:
            item = .init(id: id, name: name, creatorId: creatorId, description: description, price: price, category: category, privacy: privacy, tags: tags, scale: scale, size: size)
        case .edit(let inventoryItem):
            item = inventoryItem
            item.name = name
            item.description = description
            item.price = price
            item.creatorId = creatorId
            item.category = category
            item.privacy = privacy
            item.tags = tags
            item.scale = scale
            item.size = size
        }
        item.usdzLink = usdzURL?.absoluteString
        item.thumbnailLink = thumbnailURL?.absoluteString
        
        do {
            try db.document("items/\(item.id)")
                .setData(from: item)
//            try db.document("models/\(item.id)")
//                .setData(from: item)
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    @MainActor
    func deleteUSDZ() async {
        
        let storageRef = Storage.storage().reference()
        let usdzRef = storageRef.child("\(id).usdz")
        let thumbnailRef = storageRef.child("\(id).jpg")
        
        loadingState = .deleting(.usdzWithThumbnail)
        defer { loadingState = .none }
        
        do {
            try await usdzRef.delete()
            try? await thumbnailRef.delete()
            self.usdzURL = nil
            self.thumbnailURL = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    @MainActor
    func deleteItem() async throws {
        loadingState = .deleting(.item)
        do {
            try await db.document("items/\(id)").delete()
            try? await Storage.storage().reference().child("\(id).usdz").delete()
            try? await Storage.storage().reference().child("\(id).jpg").delete()
        } catch {
            loadingState = .none
            throw error
        }
    }
    
    @MainActor
    func uploadUSDZ(fileURL: URL) async {
        let gotAccess = fileURL.startAccessingSecurityScopedResource()
        guard gotAccess, let data = try? Data(contentsOf: fileURL) else { return }
        fileURL.stopAccessingSecurityScopedResource()
        
        uploadProgress = .init(fractionCompleted: 0, totalUnitCount: 0, completedUnitCount: 0)
        loadingState = .uploading(.usdz)
        
        defer { loadingState = .none }
        do {
            /// Upload USDZ to Firebase Storage
            let storageRef = Storage.storage().reference()
            let usdzRef = storageRef.child("\(id).usdz")
            
            _ = try await usdzRef.putDataAsync(data, metadata: .init(dictionary: ["contentType": "model/vnd.usd+zip"])) { [weak self] progress in
                guard let self, let progress else { return }
                self.uploadProgress = .init(fractionCompleted: progress.fractionCompleted, totalUnitCount: progress.totalUnitCount, completedUnitCount: progress.completedUnitCount)
            }
            let downloadURL = try await usdzRef.downloadURL()
            
            /// Generate Thumbnail
            let cacheDirURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let fileCacheURL = cacheDirURL.appending(path: "temp_\(id).usdz")
            try? data.write(to: fileCacheURL)
            
            let thumbnailRequest = QLThumbnailGenerator.Request(fileAt: fileCacheURL, size: .init(width: 300, height: 300), scale: UIScreen.main.scale, representationTypes: .all)
            
            if let thumbnail = try? await QLThumbnailGenerator.shared.generateBestRepresentation(for: thumbnailRequest),
               let jpgData = thumbnail.uiImage.jpegData(compressionQuality: 0.5) {
                loadingState = .uploading(.thumbnail)
                let thumbnailRef = storageRef.child("\(id).jpg")
                _ = try? await thumbnailRef.putDataAsync(jpgData, metadata: .init(dictionary: ["contentType": "image/jpeg"]), onProgress: { [weak self] progress in
                    guard let self, let progress else { return }
                    self.uploadProgress = .init(fractionCompleted: progress.fractionCompleted, totalUnitCount: progress.totalUnitCount, completedUnitCount: progress.completedUnitCount)
                })
                
                if let thumbnailURL = try? await thumbnailRef.downloadURL() {
                    self.thumbnailURL = thumbnailURL
                }
            }
            
            self.usdzURL = downloadURL
        } catch {
            self.error = error.localizedDescription
        }
    }
    
}

enum FormType: Identifiable {
    
    case add
    case edit(InventoryItem)
    
    var id: String {
        switch self {
        case .add:
            return "add"
        case .edit(let inventoryItem):
            return "edit-\(inventoryItem.id)"
        }
    }
    
}

enum LoadingType: Equatable {
    
    case none
    case savingItem
    case uploading(UploadType)
    case deleting(DeleteType)
    
}

enum USDZSourceType {
    case fileImporter, objectCapture
}

enum UploadType: Equatable {
    case usdz, thumbnail
}

enum DeleteType {
    case usdzWithThumbnail, item
}

struct UploadProgress {
    var fractionCompleted: Double
    var totalUnitCount: Int64
    var completedUnitCount: Int64
}

