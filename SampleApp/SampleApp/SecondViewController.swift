//
//  SecondViewController.swift
//  SampleApp
//
//  Created by Giancarlo Pacheco on 10/2/20.
//  Copyright © 2020 Giancarlo Pacheco. All rights reserved.
//

import UIKit
import CashUI

class SecondViewController: UITableViewController, NavigationControllerProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = Theme.color(.primaryBackground)
        tableView.separatorColor = UIColor(white: 1, alpha: 0.5)
        colorNavigationController(self.navigationController!)
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier", for: indexPath)
        cell.backgroundColor = .clear
        
        // set the text from the data model
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = indexPath.row == 0 ? "All Support Pages" : "Transaction Failed Topic"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            guard let vc = SupportManager.shared.supportCategories() else { return }
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            SupportManager.shared.presentSupportTopic(for: "TRANSACTION_FAILED", from: self.navigationController!)
        }
    }
}

