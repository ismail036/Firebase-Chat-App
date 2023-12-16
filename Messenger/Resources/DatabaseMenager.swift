//
//  DatabaseMenager.swift
//  Messenger
//
//  Created by İsmail Parlak on 12.12.2023.
//

import Foundation
import FirebaseDatabase

final class DatabaseMenager{
    static let shared = DatabaseMenager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress:String) -> String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
       }
    }





extension DatabaseMenager{
    public func userExists(with email:String,comletion:@escaping((Bool) -> Void)){
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: {
            snashot in guard snashot.value as? String != nil else{
                comletion(false)
                return
            }
            
            comletion(true)
        })
    }
    
                
    public func insertUser(with user: ChatAppUser, comletion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name" : user.firstName,
            "last_name"  : user.lastName,
        ], withCompletionBlock: { error, _ in
            guard error == nil else{
                print("failed write to database")
                comletion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var userCollection = snapshot.value as? [[String:String]] {
                    let newElement = [
                        "name" : user.firstName + " " + user.lastName,
                        "email" : user.safeEmail
                    ]
                    userCollection.append(newElement)
                    
                    self.database.child("users").setValue(userCollection, withCompletionBlock: {error, _ in
                        guard error == nil else{
                            comletion(false)
                            return
                        }
                        comletion(true)
                    })
                }
                else{
                    let newColection: [[String: String]] = [[
                        "name" : user.firstName + " " + user.lastName,
                        "email" : user.safeEmail
                    ]]
                    
                    self.database.child("users").setValue(newColection, withCompletionBlock: {error, _ in
                        guard error == nil else{
                            return
                        }
                        comletion(true)
                    })
                }
            })
        })
    }
    
    
    public func getAllUsers(completion:@escaping(Result<[[String:String]] , Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value as? [[String:String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    public enum DatabaseError: Error{
        case failedToFetch
    }
    
}

struct ChatAppUser{
    let firstName:String
    let lastName:String
    let emailAddress:String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String{
        return "\(safeEmail)_profile_picture.png"
    }
}
