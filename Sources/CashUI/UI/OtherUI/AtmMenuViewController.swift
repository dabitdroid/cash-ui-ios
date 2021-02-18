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

public class AtmMenuViewController: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet weak var labelMainTitle: UILabel!
    @IBOutlet weak var containerView: UIView!

    private var activityViewController: ActivityViewController?
    var cellHeights: [CGFloat] = []
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let bundle = Bundle.init(for: AtmMenuViewController.self)
        super.init(nibName: "MenuView", bundle: bundle)
     }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
        let bundle = Bundle.init(for: ActivityViewController.self)
        activityViewController = ActivityViewController(nibName: "ActivityView", bundle: bundle)
        activityViewController?.shouldShowCloseButton = false
        containerView.addSubview(activityViewController!.view)
    }

    @IBAction func showMap(_ sender: Any) {
        let bundle = Bundle.init(for: AtmLocationsViewController.self)
        let vc = AtmLocationsViewController(nibName: "AtmLocationsView", bundle: bundle)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
