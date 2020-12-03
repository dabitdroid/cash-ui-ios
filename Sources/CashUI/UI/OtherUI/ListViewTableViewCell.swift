
import UIKit
import CashCore

public class ListViewTableViewCell: UITableViewCell {
    
    @IBOutlet open var atmDescriptionLabel: UILabel!
    @IBOutlet open var streetLabel: UILabel!
    @IBOutlet open var stateLabel: UILabel!
    @IBOutlet open var redemptionImageView: UIImageView!
    @IBOutlet open var purchaseImageView: UIImageView!
    @IBOutlet open var favoriteButton: UIButton!
    @IBOutlet open var directionsButton: UIButton!
    
    private var _atm: AtmMachine?
    public var atm: AtmMachine? {
        get {
            return _atm
        }
        set {
            _atm = newValue
            displayData()
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.atmDescriptionLabel.text = ""
        self.redemptionImageView.isHidden = true
        self.purchaseImageView.isHidden = true
        self.stateLabel.text = ""
        self.streetLabel.text = ""
    }
    
    public var presentationController: UIViewController?
    
    func displayData() {
        guard let atm = atm else { return }
        self.atmDescriptionLabel.text = atm.addressDesc
        self.redemptionImageView.isHidden = !atm.redemption!.boolValue
        self.purchaseImageView.isHidden = !atm.purchase!.boolValue
//        if atm.redemption!.boolValue {
            self.backgroundColor = .white
//        } else {
//            self.backgroundColor = Theme.color(.noRedemptionCell)
//        }
        let addressDescription = AtmHelper.cityStateZip(for: atm)
        self.stateLabel.text = addressDescription
        guard let street = atm.street else { return }
        self.streetLabel.text = street
    }
    
    @IBAction func favoriteAtm(_ sender: Any) {
        // TODO: to be implemented
//        atm.isFavorite = !atm.isFavorite
//        favoriteButton.isSelected = atm.isFavorite
    }
    
    @IBAction func showMapDirections(_ sender: Any) {
        guard let atm = atm, let controller = presentationController else { return }
        MapHelper.openMapActionSheet(for: atm, presentation: controller)
    }
}
