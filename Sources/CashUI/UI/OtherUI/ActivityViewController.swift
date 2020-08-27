// 
//  ActivityViewController.swift
//
//  Created by Giancarlo Pacheco on 5/22/20.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import CashCore

let kReusableIdentifier = "kTableViewCellReuseIdentifier"

public class ActivityViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    var transactions: [CoreTransaction] {
        get {
            let trans = CoreTransactionManager.getTransactions()
            return trans.reversed()
        }
    }
    @IBOutlet open var tableView: UITableView!
    @IBOutlet open var navigationBar: UIView!
    @IBOutlet weak var refreshButton: LoadingButton!

    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNavigationBar();
        
        NotificationCenter.default.addObserver(self, selector: #selector(transactionDidUpdate), name: .CoreTransactionDidChange, object: nil)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO table view needs refreshing after any presentation controller dismisses
        CoreTransactionManager.pollImmediately()
        tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupNavigationBar() {
        navigationBar.layer.cornerRadius = 8
        navigationBar.clipsToBounds = true
        navigationBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func refresh(_ sender: Any) {
        CoreTransactionManager.pollImmediately()
    }

    
    // MARK: Helpers
    private func setup() {
        self.view.backgroundColor = Theme.tertiaryBackground
        let cellNib = UINib(nibName: "ActivityTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: kReusableIdentifier)
        tableView.backgroundColor = Theme.tertiaryBackground
        tableView.estimatedRowHeight = 199
        tableView.rowHeight = UITableView.automaticDimension
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refreshHandler), for: .valueChanged)
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var frame = self.tableView.frame
        frame.size = CGSize(width: frame.width, height: (self.view.superview?.frame.height)! - self.tableView.frame.origin.y)
        self.tableView.frame = frame
    }
    
    @IBAction func refreshHandler(_ sender: Any) {
        self.refreshButton.showLoading()
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: { [weak self] in
            if #available(iOS 10.0, *) {
                self?.refresh(sender)
                self?.refreshButton.hideLoading()
                self?.tableView.refreshControl?.endRefreshing()
            }
            self?.tableView.reloadData()

        })
    }
    
    @objc func transactionDidUpdate(_ notification: Notification) {
        self.tableView.reloadData()
    }
}

extension ActivityViewController: UITableViewDataSource, UITableViewDelegate {

    public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.transactions.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: kReusableIdentifier, for: indexPath) as! ActivityTableViewCell
        cell.transaction = self.transactions[indexPath.row]
        return cell
    }

    public func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ActivityTableViewCell.heightForTableViewCell()
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction = transactions[indexPath.row]

        let bundle = Bundle.init(for: WithdrawalStatusViewController.self)
        let withdrawalStatusVC = WithdrawalStatusViewController.init(nibName: "WithdrawalStatusView", bundle: bundle)
        withdrawalStatusVC.transaction = transaction
        self.present(withdrawalStatusVC, animated: true, completion: nil)
    }
}
