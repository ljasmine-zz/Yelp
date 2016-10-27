//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    var businesses: [Business]!
    var searchBar: UISearchBar!
    var categories: [String]!

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

        // Add SearchBar to the NavigationBar
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar

        doSearch(term: "")
    }

    fileprivate func doSearch(term: String) {
        Business.searchWithTerm(term: term, completion: { (businesses: [Business]?, error: Error?) -> Void in

            self.businesses = businesses
            self.tableView.reloadData()

            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }

            }
        )
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

        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController

        filtersViewController.delegate = self
     }

    func filtersViewController(_ filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        self.categories = filters["categories"] as? [String]
        Business.searchWithTerm(term: "Restaurants", sort: nil, categories: categories, deals: nil, completion: {(businesses, error) -> Void in
        self.businesses = businesses
        self.tableView.reloadData()})
    }

    func updateSearchResults(for searchController: UISearchController){
        if let searchText = searchController.searchBar.text {
            if let categories = self.categories {
                Business.searchWithTerm(term: searchText, sort: nil, categories: categories, deals: nil, completion: {(businesses, error) -> Void in
                    self.businesses = businesses
                    self.tableView.reloadData()})

            } else {
                Business.searchWithTerm(term: searchText, completion: {(businesses, error) -> Void in
                    self.businesses = businesses
                    self.tableView.reloadData()})
            }
        }
    }
}

// SearchBar methods
extension BusinessesViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        if let searchTerm = searchBar.text {
            doSearch(term: searchTerm)
        } else {
            doSearch(term: "")
        }
    }
}

