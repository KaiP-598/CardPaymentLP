//
//  ViewController.swift
//  CardPayment
//
//  Created by Kaipeng Wu on 26/11/19.
//  Copyright © 2019 Kaipeng Wu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

class CheckOutViewController: UIViewController {
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var webView: UIWebView!
    
    
    var viewModel: CheckOutViewModeling?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupBinding()
    }
    
    func setupView(){
        super.title = "Check Out"
    }
    
    func setupBinding(){
        viewModel = CheckOutViewModel.init(networkService: NetworkService())
        
        guard let viewModel = self.viewModel else {
            return
        }
        
        //bind input field to card in viewModel
        inputTextField.rx.text.orEmpty
            .bind(to: viewModel.card)
            .disposed(by: disposeBag)
        
        //action when button is tapped
        checkOutButton.rx.tap
            .subscribe(onNext: { (_) in
                viewModel.checkOutDidTap.onNext(())
            })
            .disposed(by: disposeBag)
        
        viewModel.showInvalidInput
            .subscribe(onNext: { [weak self] (_) in
                let alert = UIAlertController(title: "", message: "Invalid input for card number, please try again!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.showCheckOutSuccess
            .subscribe(onNext: { [weak self] (_) in
                let alert = UIAlertController(title: "", message: "Checked out successfully!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.showCheckOutError
            .subscribe(onNext: { [weak self] (_) in
                let alert = UIAlertController(title: "", message: "Checked out failed due to server error!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        //load challenge url inside a Web View
        viewModel.showChallengeUrl
            .subscribe(onNext: { [weak self] (url) in
                let alert = UIAlertController(title: "", message: "Loading challenge, please wait to continue!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                
                if let url = URL (string: url){
                   let request = URLRequest(url: url)
                    self?.webView.loadRequest(request)
                }
            })
            .disposed(by: disposeBag)

    }

}

