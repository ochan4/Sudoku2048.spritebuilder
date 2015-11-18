import Foundation

class MainScene: CCNode {
    //if a node belongs to a doc class, define as class *new
    weak var grid: Grid!
    weak var scoreLabel: CCLabelTTF!
    weak var highscoreLabel: CCLabelTTF!

    
    func didLoadFromCCB (){
        NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: "highscore", options: .allZeros, context: nil)
        updateHighscore()
    
    }
    
    func updateHighscore() {
        let newHighscore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
        highscoreLabel.string = "\(newHighscore)"
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "highscore" {
            updateHighscore()
        }
    }
}


//1. setting up classes in xcode
    //define class type #CCNode, CCColor
    //Declare Doc Var Root in SpriteBuilder

//2. Rendering a grid Background
    //calculate the position of each cell in code, instead of defining them initially upfront
        //relevant factors:
        //the size of the grid
        //the size of the tiles
        //the margin between the tiles
    //use double for loop

//3. Spawn the first tile
    //create a data structure for our grid (a 2D array) 
    //and we will add methods that will spawn tiles 
    //and add them to our data structure and visual grid.
        //Whenever we need to write a complex piece of code, breaking down the problem into smaller ones should be the first step.
            //Large Problem:
                //We need to spawn a certain amount of randomly positioned tiles when our program starts. 
                //We need to add the tiles to a data structure and we need to add them visually to the grid.
            //Small problems:
                //We need the capability to spawn a random tile
                //We need to spawn n random tiles when the program starts
                //We need a data structure to store spawned tiles
                //We need to determine where (visually) on the grid a tile needs to be added
            //Transform to Methods
//4. Adding the user Interaction
    //Move the tiles
    //Move all tiles to the edges
    //Adding guesture to recognizer
    //Implementing the move method
//5. Implementing the move method
    //Select the tile that needs be moved
    //Determine how far this tile can be moved
    //Repeat 1 and 2 until each tile in the game has been selected
//6. Checking if tiles can be merged







