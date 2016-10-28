//
//  FiltersViewController.swift
//  Yelp
//
//  Created by jasmine_lee on 10/26/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(_ filtersViewController: FiltersViewController, didUpdateFilters filters: [String: AnyObject])
}

enum FilterSectionIdentifier : String {
    case Deal = "Deal"
    case Distance = "Distance"
    case Sort = "Sort By"
    case Category = "Categories"
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!

    weak var delegate: FiltersViewControllerDelegate?

    let tableStructure: [FilterSectionIdentifier] = [.Deal, .Distance, .Sort, .Category]

    var dealSwitchState : Bool = false
    var sortedBySelection : YelpSortMode = YelpSortMode.bestMatched
    var distanceSelection: Int = 0
    var categorySwitchStates = [Int:Bool]()

    var distanceMap : [Int: String] = [0: "Auto", 1: "0.3 mile", 2: "1 mile", 3: "5 miles", 4: "10 miles"]
    var sortedByMap : [Int: String] = [0: "Best Matched", 1: "Distance", 2: "Highest Rated"]

    var isSectionExpanded : [Int: Bool] = [0: false, 1: false, 2: false, 3: false]

    // should be set by the class that instantiates this view controller
    var currentFilters: Preferences! {

        // update the filters field for local use
        didSet {

            dealSwitchState = currentFilters.deal
            sortedBySelection = currentFilters.sort
            distanceSelection = currentFilters.distance
            categorySwitchStates = currentFilters.categorySwitchStates

            tableView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70

        currentFilters = currentFilters ?? Preferences()

        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableStructure.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableStructure[section].rawValue
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch tableStructure[section] {
        case .Deal:
            return 1
        case .Distance:
            return 5
        case .Sort:
            return 3
        case .Category:
            return yelpCategories().count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch tableStructure[indexPath.section] {
        case .Deal:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            cell.delegate = self
            cell.switchLabel.text = "Offering a Deal"
            cell.onSwitch.isOn = dealSwitchState
            return cell
        case .Distance:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RadioCell", for: indexPath) as! RadioCell
            cell.radioLabel.text = distanceMap[indexPath.row]
            if indexPath.row == distanceSelection {
                cell.radioImageView.image = UIImage(named: "check")
                cell.radioImageView.image = cell.radioImageView.image?.withRenderingMode(.alwaysTemplate)
                cell.radioImageView.tintColor = UIColor(hue: 0.5861, saturation: 1, brightness: 1, alpha: 1.0)
            } else {
                cell.radioImageView.image = UIImage(named: "circle")
                cell.radioImageView.image = cell.radioImageView.image?.withRenderingMode(.alwaysTemplate)
                cell.radioImageView.tintColor = UIColor.lightGray
            }
            return cell
        case .Sort:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RadioCell", for: indexPath) as! RadioCell
            cell.radioLabel.text = sortedByMap[indexPath.row]
            if indexPath.row == sortedBySelection.rawValue {
                cell.radioImageView.image = UIImage(named: "check")
                cell.radioImageView.image = cell.radioImageView.image?.withRenderingMode(.alwaysTemplate)
                cell.radioImageView.tintColor = UIColor(hue: 0.5861, saturation: 1, brightness: 1, alpha: 1.0)
            } else {
                cell.radioImageView.image = UIImage(named: "circle")
                cell.radioImageView.image = cell.radioImageView.image?.withRenderingMode(.alwaysTemplate)
                cell.radioImageView.tintColor = UIColor.lightGray
            }
            return cell
        case .Category:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            let categories = yelpCategories()
            cell.delegate = self
            cell.switchLabel.text = categories[indexPath.row]["name"]
            cell.onSwitch.isOn = categorySwitchStates[indexPath.row] ?? false

            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let section = tableStructure[indexPath.section]

        switch section {
        case .Sort:
            sortedBySelection = YelpSortMode(rawValue: indexPath.row)!
        case .Distance:
            distanceSelection = indexPath.row
        case .Category: break
        case .Deal: break
        }

        tableView.reloadSections(NSIndexSet(index: indexPath.section) as IndexSet, with: UITableViewRowAnimation.fade)
    }


    // disable cell highlighting for deal and category sections
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let section = tableStructure[indexPath.section]

        if section == .Deal || section == .Category {
           return false
        }
        return true
    }

    @IBAction func onCancelButton(_ sender: AnyObject) {

        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSearchButton(_ sender: AnyObject) {

        dismiss(animated: true, completion: nil)

        var filters = [String: AnyObject]()
        let categories = yelpCategories()
        var selectedCategories = [String] ()

        for (row, isSelected) in categorySwitchStates {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }

        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject
        }

        filters["deal"] = dealSwitchState as AnyObject
        filters["sort"] = sortedBySelection as AnyObject
        filters["distance"] = distanceSelection as AnyObject
        filters["categorySwitchStates"] = categorySwitchStates as AnyObject

        delegate?.filtersViewController!(self, didUpdateFilters: filters as [String : AnyObject])
    }

    func preferencesFromTableData() -> Preferences {
        let ret = Preferences()
        ret.deal = dealSwitchState
        ret.distance = distanceSelection
        ret.sort = sortedBySelection
        ret.categorySwitchStates = categorySwitchStates
        return ret
    }

    func switchCell(_ switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!
        let section = tableStructure[indexPath.section]

        if section == .Deal {
            dealSwitchState = value
        } else if section == .Category {
            categorySwitchStates[indexPath.row] = value
        }
    }


    // MARK: Private
    private func yelpCategories() -> [[String:String]] {
        return [["name": "Afghan", "code": "afghani"],
                ["name": "African", "code": "african"],
                ["name": "American, New", "code": "newamerican"],
                ["name": "American, Traditional", "code": "tradamerican"],
                ["name": "Arabian", "code": "arabian"],
                ["name": "Argentine", "code": "argentine"],
                ["name": "Armenian", "code": "armenian"],
                ["name": "Asian Fusion", "code": "asianfusion"],
                ["name": "Asturian", "code": "asturian"],
                ["name": "Australian", "code": "australian"],
                ["name": "Austrian", "code": "austrian"],
                ["name": "Baguettes", "code": "baguettes"],
                ["name": "Bangladeshi", "code": "bangladeshi"],
                ["name": "Barbeque", "code": "bbq"],
                ["name": "Basque", "code": "basque"],
                ["name": "Bavarian", "code": "bavarian"],
                ["name": "Beer Garden", "code": "beergarden"],
                ["name": "Beer Hall", "code": "beerhall"],
                ["name": "Beisl", "code": "beisl"],
                ["name": "Belgian", "code": "belgian"],
                ["name": "Bistros", "code": "bistros"],
                ["name": "Black Sea", "code": "blacksea"],
                ["name": "Brasseries", "code": "brasseries"],
                ["name": "Brazilian", "code": "brazilian"],
                ["name": "Breakfast & Brunch", "code": "breakfast_brunch"],
                ["name": "British", "code": "british"],
                ["name": "Buffets", "code": "buffets"],
                ["name": "Bulgarian", "code": "bulgarian"],
                ["name": "Burgers", "code": "burgers"],
                ["name": "Burmese", "code": "burmese"],
                ["name": "Cafes", "code": "cafes"],
                ["name": "Cafeteria", "code": "cafeteria"],
                ["name": "Cajun/Creole", "code": "cajun"],
                ["name": "Cambodian", "code": "cambodian"],
                ["name": "Canadian", "code": "New)"],
                ["name": "Canteen", "code": "canteen"],
                ["name": "Caribbean", "code": "caribbean"],
                ["name": "Catalan", "code": "catalan"],
                ["name": "Chech", "code": "chech"],
                ["name": "Cheesesteaks", "code": "cheesesteaks"],
                ["name": "Chicken Shop", "code": "chickenshop"],
                ["name": "Chicken Wings", "code": "chicken_wings"],
                ["name": "Chilean", "code": "chilean"],
                ["name": "Chinese", "code": "chinese"],
                ["name": "Comfort Food", "code": "comfortfood"],
                ["name": "Corsican", "code": "corsican"],
                ["name": "Creperies", "code": "creperies"],
                ["name": "Cuban", "code": "cuban"],
                ["name": "Curry Sausage", "code": "currysausage"],
                ["name": "Cypriot", "code": "cypriot"],
                ["name": "Czech", "code": "czech"],
                ["name": "Czech/Slovakian", "code": "czechslovakian"],
                ["name": "Danish", "code": "danish"],
                ["name": "Delis", "code": "delis"],
                ["name": "Diners", "code": "diners"],
                ["name": "Dumplings", "code": "dumplings"],
                ["name": "Eastern European", "code": "eastern_european"],
                ["name": "Ethiopian", "code": "ethiopian"],
                ["name": "Fast Food", "code": "hotdogs"],
                ["name": "Filipino", "code": "filipino"],
                ["name": "Fish & Chips", "code": "fishnchips"],
                ["name": "Fondue", "code": "fondue"],
                ["name": "Food Court", "code": "food_court"],
                ["name": "Food Stands", "code": "foodstands"],
                ["name": "French", "code": "french"],
                ["name": "French Southwest", "code": "sud_ouest"],
                ["name": "Galician", "code": "galician"],
                ["name": "Gastropubs", "code": "gastropubs"],
                ["name": "Georgian", "code": "georgian"],
                ["name": "German", "code": "german"],
                ["name": "Giblets", "code": "giblets"],
                ["name": "Gluten-Free", "code": "gluten_free"],
                ["name": "Greek", "code": "greek"],
                ["name": "Halal", "code": "halal"],
                ["name": "Hawaiian", "code": "hawaiian"],
                ["name": "Heuriger", "code": "heuriger"],
                ["name": "Himalayan/Nepalese", "code": "himalayan"],
                ["name": "Hong Kong Style Cafe", "code": "hkcafe"],
                ["name": "Hot Dogs", "code": "hotdog"],
                ["name": "Hot Pot", "code": "hotpot"],
                ["name": "Hungarian", "code": "hungarian"],
                ["name": "Iberian", "code": "iberian"],
                ["name": "Indian", "code": "indpak"],
                ["name": "Indonesian", "code": "indonesian"],
                ["name": "International", "code": "international"],
                ["name": "Irish", "code": "irish"],
                ["name": "Island Pub", "code": "island_pub"],
                ["name": "Israeli", "code": "israeli"],
                ["name": "Italian", "code": "italian"],
                ["name": "Japanese", "code": "japanese"],
                ["name": "Jewish", "code": "jewish"],
                ["name": "Kebab", "code": "kebab"],
                ["name": "Korean", "code": "korean"],
                ["name": "Kosher", "code": "kosher"],
                ["name": "Kurdish", "code": "kurdish"],
                ["name": "Laos", "code": "laos"],
                ["name": "Laotian", "code": "laotian"],
                ["name": "Latin American", "code": "latin"],
                ["name": "Live/Raw Food", "code": "raw_food"],
                ["name": "Lyonnais", "code": "lyonnais"],
                ["name": "Malaysian", "code": "malaysian"],
                ["name": "Meatballs", "code": "meatballs"],
                ["name": "Mediterranean", "code": "mediterranean"],
                ["name": "Mexican", "code": "mexican"],
                ["name": "Middle Eastern", "code": "mideastern"],
                ["name": "Milk Bars", "code": "milkbars"],
                ["name": "Modern Australian", "code": "modern_australian"],
                ["name": "Modern European", "code": "modern_european"],
                ["name": "Mongolian", "code": "mongolian"],
                ["name": "Moroccan", "code": "moroccan"],
                ["name": "New Zealand", "code": "newzealand"],
                ["name": "Night Food", "code": "nightfood"],
                ["name": "Norcinerie", "code": "norcinerie"],
                ["name": "Open Sandwiches", "code": "opensandwiches"],
                ["name": "Oriental", "code": "oriental"],
                ["name": "Pakistani", "code": "pakistani"],
                ["name": "Parent Cafes", "code": "eltern_cafes"],
                ["name": "Parma", "code": "parma"],
                ["name": "Persian/Iranian", "code": "persian"],
                ["name": "Peruvian", "code": "peruvian"],
                ["name": "Pita", "code": "pita"],
                ["name": "Pizza", "code": "pizza"],
                ["name": "Polish", "code": "polish"],
                ["name": "Portuguese", "code": "portuguese"],
                ["name": "Potatoes", "code": "potatoes"],
                ["name": "Poutineries", "code": "poutineries"],
                ["name": "Pub Food", "code": "pubfood"],
                ["name": "Rice", "code": "riceshop"],
                ["name": "Romanian", "code": "romanian"],
                ["name": "Rotisserie Chicken", "code": "rotisserie_chicken"],
                ["name": "Rumanian", "code": "rumanian"],
                ["name": "Russian", "code": "russian"],
                ["name": "Salad", "code": "salad"],
                ["name": "Sandwiches", "code": "sandwiches"],
                ["name": "Scandinavian", "code": "scandinavian"],
                ["name": "Scottish", "code": "scottish"],
                ["name": "Seafood", "code": "seafood"],
                ["name": "Serbo Croatian", "code": "serbocroatian"],
                ["name": "Signature Cuisine", "code": "signature_cuisine"],
                ["name": "Singaporean", "code": "singaporean"],
                ["name": "Slovakian", "code": "slovakian"],
                ["name": "Soul Food", "code": "soulfood"],
                ["name": "Soup", "code": "soup"],
                ["name": "Southern", "code": "southern"],
                ["name": "Spanish", "code": "spanish"],
                ["name": "Steakhouses", "code": "steak"],
                ["name": "Sushi Bars", "code": "sushi"],
                ["name": "Swabian", "code": "swabian"],
                ["name": "Swedish", "code": "swedish"],
                ["name": "Swiss Food", "code": "swissfood"],
                ["name": "Tabernas", "code": "tabernas"],
                ["name": "Taiwanese", "code": "taiwanese"],
                ["name": "Tapas Bars", "code": "tapas"],
                ["name": "Tapas/Small Plates", "code": "tapasmallplates"],
                ["name": "Tex-Mex", "code": "tex-mex"],
                ["name": "Thai", "code": "thai"],
                ["name": "Traditional Norwegian", "code": "norwegian"],
                ["name": "Traditional Swedish", "code": "traditional_swedish"],
                ["name": "Trattorie", "code": "trattorie"],
                ["name": "Turkish", "code": "turkish"],
                ["name": "Ukrainian", "code": "ukrainian"],
                ["name": "Uzbek", "code": "uzbek"],
                ["name": "Vegan", "code": "vegan"],
                ["name": "Vegetarian", "code": "vegetarian"],
                ["name": "Venison", "code": "venison"],
                ["name": "Vietnamese", "code": "vietnamese"],
                ["name": "Wok", "code": "wok"],
                ["name": "Wraps", "code": "wraps"],
                ["name": "Yugoslav", "code": "yugoslav"]]

    }
}
