
import Foundation
import UIKit
import CashCore

public class SupportListViewController: UITableViewController, NavigationControllerProtocol {
    
    public var client: ServerEndpoints?
    private var selectedIndexPath: IndexPath?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Support"
        view.backgroundColor = Theme.primaryBackground
        colorNavigationController(navigationController!)
        
        tableView.backgroundColor = Theme.primaryBackground
        tableView.separatorColor = UIColor(white: 1, alpha: 0.5)
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        guard let categories = client?.support?.categories else { return 1 }
        return categories.count
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let categories = client?.support?.categories else { return nil }
        return categories[section].title
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let support = client?.support else { return 0 }
        let categories = support.categories
        let categoryId = categories[section].id
        return support.topics(for: categoryId).count
    }
    
    public override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = Theme.secondaryBackground
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .white
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "topicCellReuseIdentifier", for: indexPath)
        
        guard let support = client?.support else { return cell }
        let categories = support.categories
        let categoryId = categories[indexPath.section].id
        let topics = support.topics(for: categoryId)
        
        // set the text from the data model
        cell.backgroundColor = Theme.primaryBackground
        cell.textLabel?.textColor = UIColor(white: 1, alpha: 0.65)
        cell.textLabel?.text = topics[indexPath.row].title
        
        return cell
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "topicDetailSegue" {
            guard let support = client?.support, let indexPath = self.tableView.indexPathForSelectedRow else {
                print()
                return
            }
            let categories = support.categories
            let categoryId = categories[indexPath.section].id
            let topics = support.topics(for: categoryId)
            let topic = topics[indexPath.row]
            
            let detailController = segue.destination as! TopicDetailViewController
            detailController.topic = topic
        }
    }
    
    @IBAction func presentPrivacyPolicy() {
        Utilities.presentPrivacyPolicy(controller: self)
    }
}
