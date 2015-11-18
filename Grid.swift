//
//  Grid.swift
//  Sudoku2048
//
//  Created by Oi I Chan on 11/17/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Grid: CCNodeColor {
    let gridSize = 4
    
    var columnWidth: CGFloat = 0
    var columnHeight: CGFloat = 0
    var tileMarginVertical: CGFloat = 0
    var tileMarginHorizontal: CGFloat = 0

    //two dimensional array that will store the tile for each index of the grid
    var gridArray = [[Tile?]]()
    //represent an empty cell in the gridArray
    var noTile: Tile? = nil
    
    let startTiles = 2
    
    let winTile = 2048
    
    var score: Int = 0 {
        didSet {
            var mainScene = parent as! MainScene
            mainScene.scoreLabel.string = "\(score)"
        }
    }
    
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func didLoadFromCCB() {
        //1.
        setupBackground()
        
        //2.
        //initial array with all empty tiles
        for i in 0..<gridSize {
            var column = [Tile?]()
            for j in 0..<gridSize {
                column.append(noTile)
            }
            gridArray.append(column)
        }
        
        //3.
        spawnStartTiles()
        
        //4.
        setupGestures()
        
        
    }
    
    //Renders 16 empty cells to our grid
    func setupBackground() {
        //load a Tile.ccb to read the height and width of a single tile
        let tile = CCBReader.load("Tile") as! Tile
        columnWidth = tile.contentSize.width
        columnHeight = tile.contentSize.height
        
        //subtract the width of all tiles we need to render from the width of the grid to calculate the available width
        tileMarginHorizontal = (contentSize.width - (CGFloat(gridSize) * columnWidth)) / CGFloat(gridSize + 1)
        tileMarginVertical = (contentSize.height - (CGFloat(gridSize) * columnHeight)) / CGFloat(gridSize + 1)
        
        var x = tileMarginHorizontal
        var y = tileMarginVertical
        
        //run through a two dimensional loop to create all tiles *doubleFORloop
        //Swift allows the use of an underscore instead of a variable name in cases where the index in the loop isn't used *new
        for _ in 0..<gridSize {
            x = tileMarginHorizontal
            for _ in 0..<gridSize {
                let backgroundTile = CCNodeColor.nodeWithColor(CCColor.grayColor())
                backgroundTile.contentSize = CGSize(width: columnWidth, height: columnHeight)
                backgroundTile.position = CGPoint(x: x, y: y)
                addChild(backgroundTile)
                x += columnWidth + tileMarginHorizontal
            }
            y += columnHeight + tileMarginVertical
        }
    }//end of setup
    
    //Determining the position for a new tile INTERNALLY!
    func positionForColumn(column: Int, row: Int) -> CGPoint {
        let x = tileMarginHorizontal + CGFloat(column) * (tileMarginHorizontal + columnWidth)
        let y = tileMarginVertical + CGFloat(row) * (tileMarginVertical + columnHeight)
        return CGPoint(x: x, y: y)
    }
    
    //Add a tile at a certain row and column VISUALLY!
    func addTileAtColumn(column: Int, row: Int) {
        let tile = CCBReader.load("Tile") as! Tile          //load the tile by loading the CCB file and storing it in a local variable
        gridArray[column][row] = tile            //store this tile in the grid array
        tile.scale = 0          //set the scale of the tile to 0 because we want the tile to appear with a scale up animation
        addChild(tile)          //add the child to the grid
        tile.position = positionForColumn(column, row: row)         //define the position
        let delay = CCActionDelay(duration: 0.3)            //create an action sequence that forms a spawn animation
        let scaleUp = CCActionScaleTo(duration: 0.2, scale: 1)
        let sequence = CCActionSequence(array: [delay, scaleUp])            //action sequence that waits for 0.3 seconds
        tile.runAction(sequence)
    }
    
    //Spawning a random tile
    //determine a random free position on the grid to spawn a new tile
    //having a loop that continues generating a random tile index until it finds a free position on the grid
    func spawnRandomTile() {
        var spawned = false
        while !spawned {
            let randomRow = Int(CCRANDOM_0_1() * Float(gridSize))           //picks a random position and checks if it is occupied
            let randomColumn = Int(CCRANDOM_0_1() * Float(gridSize))
            let positionFree = gridArray[randomColumn][randomRow] == noTile //checking if the tile for the index is a noTile (these represent empty slots)
            if positionFree {               //If the position is occupied the loop continues and generates a new random number, if the picked position is free the loop terminates and the method uses the addTileAtColumn to add a tile at that position.
                addTileAtColumn(randomColumn, row: randomRow)
                spawned = true
            }
        }
    }
    
    //Spawn multiple start tiles
    func spawnStartTiles() {
        for _ in 0..<startTiles {   //starttiles = 2, less than 2 will keep loop
            spawnRandomTile()
        }
    }
    
    func setupGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipeLeft")
        swipeLeft.direction = .Left
        CCDirector.sharedDirector().view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "swipeRight")
        swipeRight.direction = .Right
        CCDirector.sharedDirector().view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: "swipeUp")
        swipeUp.direction = .Up
        CCDirector.sharedDirector().view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: "swipeDown")
        swipeDown.direction = .Down
        CCDirector.sharedDirector().view.addGestureRecognizer(swipeDown)
    }
    
    func swipeLeft() {
        move(CGPoint(x: -1, y: 0))
    }
    
    func swipeRight() {
        move(CGPoint(x: 1, y: 0))
    }
    
    func swipeUp() {
        move(CGPoint(x: 0, y: 1))
    }
    
    func swipeDown() {
        move(CGPoint(x: 0, y: -1))
    }
    
    func move(direction: CGPoint) {
        var movedTilesThisRound = false
        // apply negative vector until reaching boundary, this way we get the tile that is the furthest away
        // bottom left corner
        var currentX = 0
        var currentY = 0
        // Move to relevant edge by applying direction until reaching border
        while indexValid(currentX, y: currentY) {
            let newX = currentX + Int(direction.x)
            let newY = currentY + Int(direction.y)
            if indexValid(newX, y: newY) {
                currentX = newX
                currentY = newY
            } else {
                break
            }
        }
        // store initial row value to reset after completing each column
        var initialY = currentY
        // define changing of x and y value (moving left, up, down or right?)
        var xChange = Int(-direction.x)
        var yChange = Int(-direction.y)
        if xChange == 0 {
            xChange = 1
        }
        if yChange == 0 {
            yChange = 1
        }
        // visit column for column
        while indexValid(currentX, y: currentY) {
            while indexValid(currentX, y: currentY) {
                //implements the actual tile movement
                // get tile at current index
                if let tile = gridArray[currentX][currentY] {
                    // if tile exists at index
                    var newX = currentX
                    var newY = currentY
                    // find the farthest position by iterating in direction of the vector until reaching boarding of
                    // grid or occupied cell
                    while indexValidAndUnoccupied(newX+Int(direction.x), y: newY+Int(direction.y)) {
                        newX += Int(direction.x)
                        newY += Int(direction.y)
                    }
                    var performMove = false
                    // If we stopped moving in vector direction, but next index in vector direction is valid, this
                    // means the cell is occupied. Let's check if we can merge them...
                    if indexValid(newX+Int(direction.x), y: newY+Int(direction.y)) {
                        // get the other tile
                        var otherTileX = newX + Int(direction.x)
                        var otherTileY = newY + Int(direction.y)
                        if let otherTile = gridArray[otherTileX][otherTileY] {
                            // compare the value of other tile and also check if the other tile has been merged this round
                              if tile.value == otherTile.value && !otherTile.mergedThisRound {
                                mergeTilesAtindex(currentX, y: currentY, withTileAtIndex: otherTileX, y: otherTileY)
                                movedTilesThisRound = true
                            } else {
                                // we cannot merge so we want to perform a move
                                performMove = true
                            }
                        }
                    } else {
                        // we cannot merge so we want to perform a move
                        performMove = true
                    }
                    if performMove {
                        // move tile to furthest position
                        if newX != currentX || newY != currentY {
                            // only move tile if position changed
                            moveTile(tile, fromX: currentX, fromY: currentY, toX: newX, toY: newY)
                            movedTilesThisRound = true
                        }
                    }
                }
                // move further in this column
                currentY += yChange
            }
            currentX += xChange
            currentY = initialY
        }
        if movedTilesThisRound {
            nextRound()
        }
    }
    
    func nextRound() {
        spawnRandomTile()
        for column in gridArray {
            for tile in column {
                tile?.mergedThisRound = false
            }
        }
        if !movePossible() {
            lose()
        }
    }
    
    //receive a index position and will return a Bool value that describes wether the provided index is valid
    func indexValid(x: Int, y: Int) -> Bool {
        var indexValid = true
        indexValid = (x >= 0) && (y >= 0)
        if indexValid {
            indexValid = x < Int(gridArray.count)
            if indexValid {
                indexValid = y < Int(gridArray[x].count)
            }
        }
        return indexValid
    }
    
    func moveTile(tile: Tile, fromX: Int, fromY: Int, toX: Int, toY: Int) {
        gridArray[toX][toY] = gridArray[fromX][fromY]
        gridArray[fromX][fromY] = noTile
        let newPosition = positionForColumn(toX, row: toY)
        let moveTo = CCActionMoveTo(duration: 0.2, position: newPosition)
        tile.runAction(moveTo)
    }
    
    func indexValidAndUnoccupied(x: Int, y: Int) -> Bool {
        let indexValid = self.indexValid(x, y: y)
        if !indexValid {
            return false
        }
        // unoccupied?
        return gridArray[x][y] == noTile
    }
    
    func mergeTilesAtindex(x: Int, y: Int, withTileAtIndex otherX: Int, y otherY: Int) {
        // Update game data
        let mergedTile = gridArray[x][y]!
        let otherTile = gridArray[otherX][otherY]!
        score += mergedTile.value + otherTile.value

        otherTile.mergedThisRound = true
        
        gridArray[x][y] = noTile
        
        // Update the UI
        var otherTilePosition = positionForColumn(otherX, row: otherY)
        let moveTo = CCActionMoveTo(duration:0.2, position: otherTilePosition)
        let remove = CCActionRemove()
        let mergeTile = CCActionCallBlock(block: { () -> Void in
            otherTile.value *= 2
        })
        var checkWin = CCActionCallBlock(block: { () -> Void in
            if otherTile.value == self.winTile {self.win()}
        })
          let sequence = CCActionSequence(array: [moveTo, mergeTile, checkWin, remove])
        mergedTile.runAction(sequence)
    }
    
    func win() {
        endGameWithMessage("You win!")
    }
    
    func lose() {
        endGameWithMessage("You lose! :(")
    }
    
    func endGameWithMessage(message: String) {
        println(message)
        let defaults = NSUserDefaults.standardUserDefaults()
        let highscore = defaults.integerForKey("highscore")
        if score > highscore {
            defaults.setInteger(score, forKey: "highscore")
            defaults.synchronize()
        }
    }
    
    func movePossible() -> Bool {
        for i in 0..<gridSize {
            for j in 0..<gridSize {
                if let tile = gridArray[i][j] {
                    let topNeighbor = tileForIndex(i, y: j+1)
                    let bottomNeighbor = tileForIndex(i, y: j-1)
                    let leftNeighbor = tileForIndex(i-1, y: j)
                    let rightNeighbor = tileForIndex(i+1, y: j)
                    let neighbors = [topNeighbor, bottomNeighbor, leftNeighbor, rightNeighbor]
                    for neighbor in neighbors {
                        if let neighborTile = neighbor {
                            if neighborTile.value == tile.value {
                                return true
                            }
                        }
                    }
                } else { // empty space on the grid
                    return true
                }
            }
        }
        return false
    }
    
    //simply takes an index and returns the tile at that grid position.
    func tileForIndex(x: Int, y: Int) -> Tile? {
        return indexValid(x, y: y) ? gridArray[x][y] : noTile
    }
    
    
}
