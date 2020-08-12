// 
//  MenuViewController.swift
//  breadwallet
//
//  Created by Gardner von Holt on 5/29/20.
//  Copyright © 2020 Breadwinner AG. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import CashCore

public class MenuViewController: UIViewController {

    @IBOutlet weak var labelMainTitle: UILabel!
    @IBOutlet weak var containerView: UIView!

    private var activityViewController: ActivityViewController?
    var cellHeights: [CGFloat] = []
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        let bundle = Bundle.init(for: MenuViewController.self)
        let bundle = Bundle.module
        super.init(nibName: "MenuView", bundle: bundle)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ATM Cash Redemption"
        view.backgroundColor = Theme.primaryBackground

        setupActivityView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        activityViewController?.tableView.reloadData()
    }
    
    func setupActivityView() {
//        let bundle = Bundle.init(for: ActivityViewController.self)
        let bundle = Bundle.module
        activityViewController = ActivityViewController(nibName: "ActivityView", bundle: bundle)
        containerView.addSubview(activityViewController!.view)
    }

    @IBAction func showMap(_ sender: Any) {
//        let bundle = Bundle.init(for: AtmLocationsViewController.self)
        let bundle = Bundle.module
        let vc = AtmLocationsViewController(nibName: "AtmLocationsView", bundle: bundle)
        navigationController?.pushViewController(vc, animated: true)
    }

}
