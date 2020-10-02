//
//  SecondViewController.swift
//  SampleApp
//
//  Created by Giancarlo Pacheco on 10/2/20.
//  Copyright © 2020 Giancarlo Pacheco. All rights reserved.
//

import UIKit
import CashUI

class SecondViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier", for: indexPath)
        
        // set the text from the data model
        cell.textLabel?.text = "support"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "SupportListStoryboard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SupportListViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

