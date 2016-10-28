//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MBProgressHUD

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,FiltersViewControllerDelegate {
    
    var businesses: [Business]!
    var searchBar: UISearchBar!
    var categories: [String]?
    var searchText: String! = ""
    var filters: Preferences = Preferences()

    var distanceMap : [Int: Float] = [0: 25, 1: 0.3, 2: 1, 3: 3, 4: 10]

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120

        // replace navigation bar with search bar and search controller
        // Initialize the UISearchBar
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Restaurants"
        searchBar.tintColor = UIColor.white

        // Add SearchBar to the NavigationBar
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar

        doSearch(isShowProgress: true)
    }

    fileprivate func doSearch(isShowProgress: Bool) {

        if isShowProgress {
            // Display HUD right before the request is made
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }

        let isOfferingDeal = self.filters.deal
        let sortValue = self.filters.sort
        let distanceIndex = self.filters.distance
        let distance = distanceMap[distanceIndex]! * 1609.344

        Business.searchWithTerm(term: self.searchText, sort: sortValue, categories: self.categories, deals: isOfferingDeal, distance: distance, completion: { (businesses: [Business]?, error: Error?) -> Void in

            self.businesses = businesses
            self.tableView.reloadData()

            // Hide HUD once the network request comes back (must be done on main UI thread)
            MBProgressHUD.hide(for: self.view, animated: true)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        return cell
    }

     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showFiltersSegue" {
            let navigationController = segue.destination as! UINavigationController
            let filtersViewController = navigationController.topViewController as! FiltersViewController

            filtersViewController.delegate = self
            filtersViewController.currentFilters = filters
        }
     }


    // Listening to changes propagating back from the Filters page
    func filtersViewController(_ filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {

        // updated the categories
        self.filters = filtersViewController.preferencesFromTableData()
        self.categories = filters["categories"] as? [String]

        doSearch(isShowProgress: true)

        // update other filters
    }
}

// SearchBar methods
extension BusinessesViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.placeholder = "e.g. tacos, delivery"
        return true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchText = ""
        searchBar.text = ""
        doSearch(isShowProgress: false)
        searchBar.placeholder = "Restaurants"
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.searchText = searchBar.text!
        doSearch(isShowProgress: true)
    }
}

