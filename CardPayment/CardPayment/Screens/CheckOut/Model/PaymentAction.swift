//
//  PaymentAction.swift
//  CardPayment
//
//  Created by Kaipeng Wu on 27/11/19.
//  Copyright © 2019 Kaipeng Wu. All rights reserved.
//

import Foundation
import ObjectMapper

class PaymentAction: Mappable {
    var url: String?
    var action_type: String?
    
    init (){
        
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        url <- map["url"]
        action_type <- map["action_type"]
    }
}

