//
//  CheckOutViewModel.swift
//  CardPayment
//
//  Created by Kaipeng Wu on 27/11/19.
//  Copyright © 2019 Kaipeng Wu. All rights reserved.
//

import Foundation
import RxSwift

enum SubmissionResult {
    case invalidInput
    case submissionSuccess
    case submissionFail
}

protocol CheckOutViewModeling {
    var card: PublishSubject<String> {get}
    var checkOutDidTap: PublishSubject<Void> {get}
    var checkOutResult: PublishSubject<SubmissionResult> {get}
    var showInvalidInput: PublishSubject<Void> {get}
    var proceedGetPayment: PublishSubject<String> {get}
    
    var showCheckOutSuccess: PublishSubject<Void> {get}
    var showCheckOutError: PublishSubject<Void> {get}
    var showChallengeUrl: PublishSubject<String> {get}
}

class CheckOutViewModel: CheckOutViewModeling{
    
    let card: PublishSubject<String> = PublishSubject<String>()
    let checkOutDidTap: PublishSubject<Void> = PublishSubject<Void>()
    let checkOutResult: PublishSubject<SubmissionResult> = PublishSubject<SubmissionResult>()
    let showInvalidInput: PublishSubject<Void> = PublishSubject<Void>()
    let proceedGetPayment: PublishSubject<String> = PublishSubject<String>()
    
    let showCheckOutSuccess: PublishSubject<Void> = PublishSubject<Void>()
    let showCheckOutError: PublishSubject<Void> = PublishSubject<Void>()
    let showChallengeUrl: PublishSubject<String> = PublishSubject<String>()
    
    let networkService: NetworkServicing
    
    private let disposeBag = DisposeBag()
    
    init(networkService: NetworkServicing){
        self.networkService = networkService
        
        checkOutDidTap
            .throttle(2, scheduler: MainScheduler.instance)
            .withLatestFrom(card)
            .flatMapLatest({ [weak self]  card -> Observable<(Payment, SubmissionResult)> in
                let cardNumber = card
                let nonNumericCharacters = NSCharacterSet.decimalDigits.inverted
                
                //validate card number input
                if cardNumber == "" {
                    return Observable.just((Payment(), SubmissionResult.invalidInput))
                } else if cardNumber.rangeOfCharacter(from: nonNumericCharacters) == nil {
                    let param: [String: Any] = ["currency": "USD",
                                                "amount": 10.00,
                                                "card_number": card
                    ]
                    return self?.createPayment(paymentParameters: param) ?? Observable.just((Payment(), SubmissionResult.invalidInput))
                } else {
                    return Observable.just((Payment(), SubmissionResult.invalidInput))
                }
                
            })
            .subscribe(onNext: { [weak self] (result) in
                let submissionResult = result.1
                if submissionResult == .invalidInput{
                    self?.showInvalidInput.onNext(())
                } else if submissionResult == .submissionSuccess{
                    self?.proceedGetPayment.onNext(result.0.id ?? "")
                }
            })
            .disposed(by: disposeBag)
        
        
        //process get payment
        proceedGetPayment
            .flatMapLatest({ [weak self]  id -> Observable<(Payment, SubmissionResult)> in
                return self?.getPayment(paymentId: id) ?? Observable.just((Payment(), SubmissionResult.submissionFail))
                
            })
            .subscribe(onNext: { [weak self] (result) in
                let finalResult = result.1
                if finalResult == .submissionSuccess{
                    let payment = result.0
                    let status = payment.status ?? ""
                    if status == "AUTHORISED"{
                        self?.showCheckOutSuccess.onNext(())
                    } else if status == "REQUIRES_ACTION"{
                        if let _ = payment.error{
                            self?.showCheckOutError.onNext(())
                        } else if let nextAction = payment.next_action{
                            if let type = nextAction.action_type, type == "CHALLENGE"{
                                if let url = nextAction.url{
                                    self?.showChallengeUrl.onNext(url)
                                }
                            }
                        }
             
                    }
                }
                
            })
            .disposed(by: disposeBag)
    }

    //create payment with mock data
    func createPayment(paymentParameters: [String: Any]) -> Observable<(Payment, SubmissionResult)>{
        //Create an observable of country array here
        return Observable.create { [weak self] observer in
            self?.networkService.createPayment(paymentParameters: paymentParameters, completionHandler: { (payment, result) in
                switch result{
                case .failure:
                    debugPrint("There is an error when getting data")
                    observer.onNext((Payment(), SubmissionResult.submissionFail))
                case .success:
                    observer.onNext((payment ?? Payment(), SubmissionResult.submissionSuccess))
                }
            })
            
            return Disposables.create {
            }
        }
    }
    
    func getPayment(paymentId: String) -> Observable<(Payment, SubmissionResult)>{
        return Observable.create { [weak self] observer in
            self?.networkService.getPayment(paymentId: paymentId, completionHandler: { (payment, result) in
                switch result{
                case .failure:
                    debugPrint("There is an error when getting data")
                    observer.onNext((Payment(), SubmissionResult.submissionFail))
                case .success:
                    observer.onNext((payment ?? Payment(), SubmissionResult.submissionSuccess))
                }
            })
            
            return Disposables.create {
            }
        }
    }
    
    
}


