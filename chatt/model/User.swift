//
//  User.swift
//  chatt
//
//  Created by Mohamed Korany Ali on 7/15/19.
//  Copyright © 2019 ashraf. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var name: String?
    var email: String?
    var profileImageUrl: String?
    
    init(dictionary: [AnyHashable: Any]) {
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }

}
