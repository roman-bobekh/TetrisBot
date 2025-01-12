// class for managing the tetris board (the grid)
class Board {
    // create an empty grid with positive x being right and positive y being down
    String[][] grid = new String[boardWidth][boardHeight + vanishZone];
    
    // copy the board
    Board copy() {
        // copy grid to new board and return it
        Board newBoard = new Board();
        for (int x = 0; x < boardWidth; x++) {
            for (int y = 0; y < boardHeight + vanishZone; y++) {
                newBoard.grid[x][y] = grid[x][y];
            }
        }
        
        return newBoard;
    }
    
    /* draw the board with following parameters:
            shape - the shape that is currently falling
            lineAnimationProgress - progress of animation after a line cleas (0 to 1)
            clearedLines - list of all lines cleared
            lockProgress - progress of shape locking
            endAnimationProgress - progress of end animation after losing
    */  
    void drawBoard(Shape shape, float lineAnimationProgress, float endAnimationProgress, float lockProgress, List<Integer> clearedLines) {
        // calculate top left of board by subtracting half of the board size in pixels from the center of the screen
        Vector topLeft = new Vector(width/2, height/2).sub(new Vector(boardWidth, boardHeight).mult(blockSize).div(2));
        
        // draw outline of the board
        stroke(255);
        noFill();
        strokeWeight(2);
        rect(topLeft.x - 1, topLeft.y - 1, boardWidth * blockSize + 2, boardHeight * blockSize + 2);
        
        // draw grid by combining vertical and horizontal lines
        strokeWeight(1);
        stroke(50);
        for (int x = 1; x < boardWidth; x++) {
            line(topLeft.x + x*blockSize, topLeft.y, topLeft.x + x*blockSize, topLeft.y + boardHeight*blockSize);
        }
        for (int y = 1; y < boardHeight; y++) {
            line(topLeft.x, topLeft.y + y*blockSize, topLeft.x + boardWidth*blockSize, topLeft.y + y*blockSize);
        }
        
        push();
        
        // loop through all grid positions below the vanish zone
        for (int x = 0; x < boardWidth; x++) {
            for (int y = vanishZone; y < boardHeight + vanishZone; y++) {
                if (grid[x][y] != null) {
                    // if there's a block in the box, calculate the box position
                    Vector blockPos = topLeft.staticAdd(new Vector(x, y-vanishZone).mult(blockSize));
                    
                    if (lineAnimationProgress == -1 || !clearedLines.contains(y)) {
                        // if the line is not being cleared and animated, check if there's an end animation
                        if (endAnimationProgress == -1) {
                            // if there's no end animation, leave the color as it is
                            tint(255);
                        } else {
                            // if there's and end animation, calculate the disappearing progress of this specific y position by
                            // converting the y to a relative y from 0 to 1, subtracting the relative y from the animation progress
                            // to get the progress of that line and multiply by 10 to make the line dissapear 10 times faster
                            float normalizedProgress = (endAnimationProgress - (float)(boardHeight + vanishZone - 1 - y)/(boardHeight + 6)) * 10;
                            if (normalizedProgress < 0) {
                                // if the animation of the block hasn't begun, don't change it
                                tint(255);
                            } else {
                                if (normalizedProgress > 1) {
                                    // if the animation of the block is over, make the block transparent
                                    tint(255, 0);
                                } else {
                                    // if the animation is going on, convert the progress to an alpha value
                                    tint(255, 255 - normalizedProgress * 255);
                                }
                            }
                        }
                    } else {
                        // if the line is being animated, make the block more transparent as the animation progress goes on to produce a disappearing effect
                        tint(255, 255 - lineAnimationProgress*255);
                    }
                    
                    // draw the image of the block in the grid
                    assets.drawImage(grid[x][y] + "_Block.png", blockPos, blockSize, blockSize);
                }
            }
        }
        
        // if neither animation is going on, draw the falling shape
        if (lineAnimationProgress == -1 && endAnimationProgress == -1) {
            if (lockProgress > 1) {
                // if the shape hasn't started to lock yet, draw normal shape
                shape.drawInBoard(topLeft, 255);
            } else {
                // if the shape is locking, draw shape with adjusted transparency
                shape.drawInBoard(topLeft, (int)(255 - lockProgress*200));
            }
            
            // copy falling shape and make it fall to the ground
            Shape fallenShape = shape.copy();
            fallenShape.fall(this);
            
            // unless the fallen shape has the same position as the falling one, draw it with high transparency
            if (!fallenShape.pos.equals(shape.pos)) {
                fallenShape.drawInBoard(topLeft, 100);
            }
        }
        
        pop();
    }
    
    // check if place in grid is taken
    boolean isObstacle(Vector pos) {
        // if position is outside the board (but not on top) return that it's taken
        if (pos.y >= boardHeight + vanishZone || pos.x < 0 || pos.x >= boardWidth) {
            return true;   
        }
        
        // if the position is above the board, return that it's free
        if (pos.y < 0) {
            return false;   
        }
        
        // else check in the grid
        return grid[pos.x][pos.y] != null;
    }
    
    // imprint the shape onto the grid
    boolean imprint(Shape shape) {
        // save if the shape is completely outside of the boundaries of the board
        boolean outOfBounds = true;
        
        // loop through the shape grid
        for (int x = 0; x < shape.size; x++) {
            for (int y = 0; y < shape.size; y++) {
                // if the shape has the block, save it to the grid
                if (shape.grid[x][y] == 1) {
                    // get the position of the block in the grid
                    Vector posInGrid = shape.pos.staticAdd(x, y);
                    if (posInGrid.y >= vanishZone) {
                        // if the block is not in the vanish zone, save that it's not out of bounds
                        outOfBounds = false;
                    }
                    
                    // imprint the block into the grid
                    grid[posInGrid.x][posInGrid.y] = shape.name;  
                }
            }
        }
        
        // if the shape is out of bounds, return it to end the game
        return outOfBounds;
    }
    
    // get the full lines
    List<Integer> getClearedLines() {
        // create empty list
        List<Integer> clearedLines = new ArrayList<Integer>();
        
        // loop through the lines
        for (int y = 0; y < boardHeight + vanishZone; y++) {
            // check if the line is full by checking each block
            boolean fullLine = true;
            for (int x = 0; x < boardWidth; x++) {
                if (grid[x][y] == null) {
                    fullLine = false;
                }
            }
            
            if (fullLine) {
                // if the line is full, add the y position to the list
                clearedLines.add(y);
            }
        }
        
        // return the cleared lines
        return clearedLines;
    }
    
    // clear lines from list
    void clearLines(List<Integer> lines) {
        // loop through list and clear every line
        for (int line : lines) {
            clearLine(line);
        }
    }
    
    // clear specific lines
    void clearLine(int lineNr) {
        // loop from the cleared line to the top
        for (int y = lineNr; y > 0; y--) {
            // replace this line with the line 1 block higher
            for (int x = 0; x < boardWidth; x++) {
                grid[x][y] = grid[x][y-1];
            }
        }
        
        // fill the empty line on the top
        for (int x = 0; x < boardWidth; x++) {
            grid[x][0] = null;
        }
    }
    
    // return the number of lines with blocks in them
    int linesWithBlocks() {
        int lines = 0;
        
        // loop through every row
        for (int y = 0; y < boardHeight + vanishZone; y++) {
            // check if the line is empty
            boolean emptyLine = true;
            for (int x = 0; x < boardWidth; x++) {
                emptyLine = grid[x][y] == null ? emptyLine : false;
            }
            
            if (!emptyLine) {
                // if line isn't empty increase the line counter
                lines++;
            }
        }
        
        return lines;
    }
    
    // return a list of heights
    int[] heightList() {
        // initialize height array
        int[] heights = new int[boardWidth];
        
        // loop through all rows
        for (int x = 0; x < boardWidth; x++) {
            // get the height
            int currentHeight = boardHeight + vanishZone;
            for (int y = 0; y < boardHeight + vanishZone; y++) {
                if (grid[x][y] != null) {
                    currentHeight = y;
                    break;
                }
            }
            
            // add height to the array
            heights[x] = currentHeight;
        }
        
        return heights;
    }
    
    // return the amount of holes with a roof
    int holeAmount() {

        // get the height list
        int[] heights = heightList();
        int holes = 0;
        
        // loop through all blocks
        for (int x = 0; x < boardWidth; x++) {
            for (int y = 0; y < boardHeight + vanishZone; y++) {
                if (grid[x][y] == null && heights[x] < y) {
                    // if there's a hole under the highest block, add it
                    holes++;   
                }
            }
        }
        
        return holes;
    }
    
    // return the change of heights or "bumpiness" of the board
    int heightChange() {
        // load height list
        int[] heights = heightList();
        int total = 0;
        
        // loop through columns and add the difference between them
        for (int i = 0; i < boardWidth - 1; i++) {
            total += abs(heights[i] - heights[i+1]);
        }
        
        return total;
    }
    
    int blocksAboveHoles() {
        // get the height list
        int blocks = 0;
        int[] heights = heightList();
        
        // loop through all blocks
        for (int x = 0; x < boardWidth; x++) {
            for (int y = 0; y < boardHeight + vanishZone; y++) {
                // if there's a hole under the highest block
                if (grid[x][y] == null && heights[x] < y) {
                    // add how deep the hole is under the highest block
                    blocks += y - heights[x];   
                }
            }
        }
        
        return blocks;
    }
}
