//
//  Preferences.swift
//  Yelp
//
//  Created by jasmine_lee on 10/26/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import Foundation

class Preferences {
    var deal = false
    var distance = 0
    var sort = YelpSortMode.bestMatched
    var categorySwitchStates = [Int:Bool]()
}

