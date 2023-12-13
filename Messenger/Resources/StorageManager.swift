//
//  StorageManager.swift
//  Messenger
//
//  Created by İsmail Parlak on 13.12.2023.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    
    public typealias UploadPictureComletion = (Result<String,Error>) -> Void
    
    public func uploadProfilePicture(with data: Data,
                                     fileName: String,
                                     completion: @escaping UploadPictureComletion){
        storage.child("images/\(fileName)").putData(data,metadata: nil,completion: {
            metadata , error in
            guard error == nil else{
                print("failed to upload data to firabase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            let reference = self.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else{
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.filedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("dowload url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
}
    
    public enum StorageErrors: Error{
        case failedToUpload
        case filedToGetDownloadUrl
    }
    
    
    
    
    
    
}
