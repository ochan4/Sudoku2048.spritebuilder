//
//  Tile.swift
//  Sudoku2048
//
//  Created by Oi I Chan on 11/17/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Tile: CCNode {
    weak var valueLabel: CCLabelTTF!
    weak var backgroundNode: CCNodeColor!
    var mergedThisRound = false

    
    
    var value: Int = 0 {
        //observer: updates the text of the label with the current value of the tile.
        didSet {
            valueLabel.string = "\(value)"
        }
    }

}