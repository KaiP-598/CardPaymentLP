//
//  NetworkService.swift
//  CardPayment
//
//  Created by Kaipeng Wu on 26/11/19.
//  Copyright © 2019 Kaipeng Wu. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import ObjectMapper

enum NetworkError: Error {
    case failure
    case success
}

protocol NetworkServicing {
   func createPayment(paymentParameters: [String: Any], completionHandler: @escaping (Payment?, NetworkError) -> ())
    
    func getPayment(paymentId: String, completionHandler: @escaping (Payment?, NetworkError) -> ())
    func getPaymentAuthorised() -> Payment
    func getPaymentRequireAction() -> Payment
    func getPaymentError() -> Payment
}

class NetworkService: NetworkServicing{

    
    /// Create payment from the endpoint
    ///
    /// - parameter paymentParameters: dictionary containing initial payment data.
    /// - parameter completionHandler: handler containing payment data and network result.
    func createPayment(paymentParameters: [String: Any], completionHandler: @escaping (Payment?, NetworkError) -> ()) {
        let finalEnpoint = "/payments"
        
        Alamofire.request(finalEnpoint, method: HTTPMethod.post, parameters: paymentParameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            
            let result: [String: Any] = ["id" : "123",
                          "currency": "USD",
                          "amount": 10.00,
                          "status": "REQUIRES_PAYMENT_METHOD"
            ]
            
            let payment = Payment.init(JSON: result)
            
            completionHandler(payment, .success)
        }
    }
    
    
    //Randomly mock API response from get payment
    func getPayment(paymentId: String, completionHandler: @escaping (Payment?, NetworkError) -> ()) {
        let number = Int.random(in: 0 ... 2)
        switch number {
        case 0:
            let payment = getPaymentAuthorised()
            completionHandler(payment, .success)
        case 1:
            let payment = getPaymentRequireAction()
            completionHandler(payment, .success)
        case 2:
            let payment = getPaymentError()
            completionHandler(payment, .success)
        default:
            completionHandler(Payment(), .failure)
        }
    }
    
    func getPaymentAuthorised() -> Payment {
        let result: [String: Any] = ["id" : "123",
                                     "currency": "USD",
                                     "amount": 10.00,
                                     "status": "AUTHORISED",
                                     "last_update": 1574125296778
        ]
        
        let payment = Payment.init(JSON: result)
        
        return payment ?? Payment()
    }
    
    func getPaymentRequireAction() -> Payment {
        let next_action_data = ["url": "https://www.google.com/",
                                "action_type": "CHALLENGE"]
        
    //    let paymentAction = PaymentAction.init(JSON: next_action_data)
        
        let result: [String: Any] = ["id" : "123",
                                     "currency": "USD",
                                     "amount": 10.00,
                                     "status": "REQUIRES_ACTION",
                                     "last_update": 1574125296778,
                                     "next_action": next_action_data
        ]
        
        let payment = Payment.init(JSON: result)
        
        return payment ?? Payment()
    }
    
    func getPaymentError() -> Payment {
        let result: [String: Any] = ["id" : "123",
                                     "currency": "USD",
                                     "amount": 10.00,
                                     "status": "REQUIRES_ACTION",
                                     "error": "INTERNAL_SERVER_ERROR",
                                     "last_update": 1574125296778
        ]
        
        let payment = Payment.init(JSON: result)
        
        return payment ?? Payment()
    }
    
}


