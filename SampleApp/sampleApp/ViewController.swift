//
//  ViewController.swift
//  sampleApp
//
//  Created by Giancarlo Pacheco on 7/27/20.
//  Copyright © 2020 Giancarlo Pacheco. All rights reserved.
//

import UIKit
import CashUI

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        CoreSessionManager.shared.start()
        CoreSessionManager.shared.delegate = self
    }
    
    @IBAction func showMenu(_ sender: Any) {
        let navigationController = UINavigationController()
        let menuController = MenuViewController()
        navigationController.addChild(menuController)
        self.present(navigationController, animated: true) {}
    }
}

extension ViewController : CoreSessionManagerDelegate {
    func sendCoin(amount: String, address: String, completion: @escaping (() -> Void)) {
        print("Send \(amount) for Address : \(address)")
    }
}
