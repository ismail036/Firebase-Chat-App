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
    
    
    public func insertUser(with user: ChatAppUser) {
        database.child(user.safeEmail).setValue([
            "first_name" : user.firstName,
            "last_name"  : user.lastName,
            "email" : user.emailAddress
            
        ])
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
}
