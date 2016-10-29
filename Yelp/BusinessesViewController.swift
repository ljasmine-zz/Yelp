//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MBProgressHUD
import MapKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,FiltersViewControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    var businesses: [Business]!
    var searchBar: UISearchBar!
    var categories: [String]?
    var searchText: String! = ""
    var filters: Preferences = Preferences()
    var selectedSegment: Int = 0

    var distanceMap : [Int: Float] = [0: 25, 1: 0.3, 2: 1, 3: 3, 4: 10]

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
        navigationController?.navigationBar.tintColor = UIColor.white

        // decide which type of view to show, list or grid
        if selectedSegment == 0 {
            self.tableView.isHidden = false
            self.mapView.isHidden = true

            let mapViewButton = UIBarButtonItem(image: UIImage(named: "pin"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(switchViews))
            self.navigationItem.rightBarButtonItem = mapViewButton
        } else {
            self.tableView.isHidden = true
            self.mapView.isHidden = false

            let listViewButton = UIBarButtonItem(image: UIImage(named: "list"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(switchViews))
            self.navigationItem.rightBarButtonItem = listViewButton

            addAnnotationsToMap()
        }


        doSearch(isShowProgress: true)
    }

    private dynamic func switchViews() {
        if selectedSegment == 0 {

            self.tableView.isHidden = true
            self.mapView.isHidden = false

            let listViewButton = UIBarButtonItem(image: UIImage(named: "list"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(switchViews))
            self.navigationItem.rightBarButtonItem = listViewButton

            selectedSegment = 1
            addAnnotationsToMap()

        } else {

            self.tableView.isHidden = false
            self.mapView.isHidden = true

            let mapViewButton = UIBarButtonItem(image: UIImage(named: "pin"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(switchViews))
            self.navigationItem.rightBarButtonItem = mapViewButton
            
            selectedSegment = 0
        }
    }

    private func addAnnotationsToMap() {
        mapView.addAnnotations(businesses)
        mapView.showAnnotations(businesses, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.contentInset.top = topLayoutGuide.length
        tableView.contentInset.bottom = bottomLayoutGuide.length
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

        if let array = self.businesses {
            self.mapView.removeAnnotations(array)
        }

        Business.searchWithTerm(term: self.searchText, sort: sortValue, categories: self.categories, deals: isOfferingDeal, distance: distance, completion: { (businesses: [Business]?, error: Error?) -> Void in

            self.businesses = businesses
            self.tableView.reloadData()
            self.addAnnotationsToMap()

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

