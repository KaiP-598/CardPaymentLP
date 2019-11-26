//
//  Payment.swift
//  CardPayment
//
//  Created by Kaipeng Wu on 27/11/19.
//  Copyright © 2019 Kaipeng Wu. All rights reserved.
//

import Foundation
import ObjectMapper

class Payment: Mappable {
    var id: String?
    var amount: Double?
    var card_number: String?
    var currency: String?
    var status: String?
    var last_update: Int?
    var next_action: PaymentAction?
    var error: String?
    
    init (){
        
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        amount <- map["amount"]
        card_number <- map["card_number"]
        currency <- map["currency"]
        status <- map["status"]
        last_update <- map["last_update"]
        next_action <- map["next_action"]
        error <- map["error"]

    }
}

