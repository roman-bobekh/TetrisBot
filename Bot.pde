// class for the tetris bot
class Bot {
    // initialize move sequence
    List<String> sequence = new ArrayList<String>();;
    
    // define the speed of the bot, how many times per second does it move
    float speed = 1;
    
    // initialize the theoretical move count and the last update
    float moves;
    long lastUpdate;
    
    // calculate sequence of moves
    void calculate(Game game) {
        List<String> bestSequence = new ArrayList<String>();
        int bestScore = -100000000;
        
        // loop through pieces: either the current one or the swapped one (if available)
        for (int swap = 0; swap < (game.shapeSwapped ? 1 : 2); swap++) {
            // make a copy of either the current, the held or the next shape based on swap
            Shape shapeCopy;
            if (swap == 0) {
                shapeCopy = game.fallingShape.copy();
            } else {
                if (game.heldShape == null) {
                    shapeCopy = game.shuffledShapes.get(0).copy();
                } else {
                    shapeCopy = game.heldShape.copy();
                }
            }
          
            // loop through all 4 directions
            for (int dir = 0; dir < 4; dir++) {
                // loop through all x offsets based on minimum and maximum block of shape
                for (int x = -(shapeCopy.getLimit("x", "min")+shapeCopy.pos.x); x < boardWidth - (shapeCopy.getLimit("x", "max")+shapeCopy.pos.x); x++) {
                    // make a copy of the game to test the new move sequence
                    Game gameCopy = game.copy();
                    List<String> currentSequence = new ArrayList<String>();
                    
                    // create sequence of moves based on swap, x offset and direction
                    if (swap == 1) {
                        gameCopy.swap(); 
                        currentSequence.add("swap");
                    }
                    if (dir == 1) {
                        gameCopy.rotateClockwise();
                        currentSequence.add("rotateClockwise");
                    } else if (dir == 2) {
                        for (int i = 0; i < 2; i++) {
                            gameCopy.rotateClockwise();
                            currentSequence.add("rotateClockwise");
                        }
                    } else if (dir == 3) {
                        gameCopy.rotateCounterclockwise();
                        currentSequence.add("rotateCounterclockwise");
                    }
                    for (int i = 0; i < abs(x); i++) {
                        if (Math.signum(x) == 1) {
                            gameCopy.right();
                            currentSequence.add("right");
                        } else {
                            gameCopy.left();
                            currentSequence.add("left");
                        }
                    }
                    
                    // drop the piece at the end
                    gameCopy.drop();
                    currentSequence.add("drop");
                    
                    // end the move of the game copy
                    gameCopy.board.imprint(gameCopy.fallingShape);
                    gameCopy.clearedLines = gameCopy.board.getClearedLines();
                    gameCopy.board.clearLines(gameCopy.clearedLines);
                    
                    // calculate the sequence score based on a couple factors
                    int sequenceScore = -gameCopy.board.holeAmount() * 150 - gameCopy.board.heightChange() * 30 - gameCopy.board.blocksAboveHoles() * 50;
                    
                    // if the sequence score is greater than the best one yet, replace it
                    if (sequenceScore > bestScore) {
                        bestScore = sequenceScore;
                        bestSequence = currentSequence;
                    }
                }
                
                // rotate the shape copy
                shapeCopy.rotate(1, game.board);
            }
        }
            
        // set the sequence to the best sequence
        sequence = bestSequence;
        
        // save the calculation time as the last update and reset the move count
        lastUpdate = System.currentTimeMillis();
        moves = 0;
        
        // speed 6 times higher than the speed of the game to keep up
        speed = 6 * game.speed;
        
        // collect the memory garbage from the game copies
        System.gc();
    }
    
    // move the shape according to the calculated sequence
    void move(Game game) {
        // increase the move count by the speed times the time passed
        moves += (System.currentTimeMillis() - lastUpdate) / 1000f * speed;
        lastUpdate = System.currentTimeMillis();
        
        // move while the theoretical move count is greater than 1
        for (; moves >= 1 && sequence.size() >= 1; moves--) {
            // pass element of sequence to the game
            switch(sequence.get(0)) {
                case "left":
                    game.left();
                    break;
                case "right":
                    game.right();
                    break;
                case "down":
                    game.down();
                    break;
                case "drop":
                    game.drop();
                    break;
                case "swap":
                    game.swap();
                    break;
                case "rotateClockwise":
                    game.rotateClockwise();
                    break;
                case "rotateCounterclockwise":
                    game.rotateCounterclockwise();
                    break;
            }
            
            // remove the move because it was executed
            sequence.remove(0);
        }
    }
}
