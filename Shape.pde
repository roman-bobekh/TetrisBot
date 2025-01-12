// class for shapes/tetrominos
class Shape {
    // size and grid (shape) of shape
    int size;
    int[][] grid;
    
    // numerical id and string nOame (I, J, O)
    int id;
    String name;
    
    // position of shape in the board
    Vector pos;
    
    // wall kicks according to SRS (Super Rotation System), the current orientation and the number of the last kick performed
    Vector[][] rotationKicks;
    int orientation = 0;
    int lastKick = 0;
    
    // load data as the constructor
    Shape(int id) {
        loadData(id);
    }
    
    // load data
    void loadData(int id) {
        // set the id
        this.id = id;        
        
        // initialize id and line of shape being read
        int currentId = 1;
        int readingLine = 0;
        
        // loop through data
        for (String line : assets.shapeData) {
            if (line.isEmpty()) {
                // increase id if line is empty
                currentId++;   
            } else if (currentId == id) {
                // if the id being read is the id of the shape read the shape data:
                if (readingLine == 1) {
                    // get size of grid and create empty grid if this is the first line of the grid
                    size = line.split(" ").length;
                    grid = new int[size][size];
                }
                
                if (readingLine == 0) {
                    // if it's reading the name, save it
                    name = line.split(":")[0];
                } else if (readingLine < size + 1) {
                    // split string into array
                    String[] stringArray = line.split(" ");
                    size = stringArray.length;
                    
                    // convert string to int array
                    int[] intArray = parseInt(stringArray);
                    
                    // add array to grid
                    for (int x = 0; x < size; x++) {
                        grid[x][readingLine - 1] = intArray[x];
                    }
                } else {
                    // if it's reading the kick number, get the rotation kicks from the assets
                    rotationKicks = assets.rotationSystem[parseInt(line.split(": ")[1])];
                }
                
                // increase the line being read
                readingLine++;
            }
        }
        
        // create the shape with x centered and just above the visible board, so that the lowest block is in the last line of the vanish zone
        pos = new Vector(boardWidth/2 - ceil(shapeWidth()/2f), -getLimit("y", "max") - 1 + vanishZone);
    }
    
    // copy the shape
    Shape copy() {
        // create new shape and copy the position
        Shape newShape = new Shape(id);
        newShape.pos = pos.copy();
        
        // copy the grid
        for (int x = 0; x < size; x++) {
            for (int y = 0; y < size; y++) {
                newShape.grid[x][y] = grid[x][y];
            }
        }
        
        return newShape;
    }
    
    // rotate the shape (clockwise if dir is 1, counter clockwise if dir is -1)
    boolean rotate(int dir, Board board) {
        // create new grid
        int[][] newGrid = new int[size][size];
        for (int x = 0; x < size; x++) {
            for (int y = 0; y < size; y++) {
                // rotate each vector of the grid to get the destination of the current block
                Vector rotatedBlock = new Vector(x, y).rotate(dir, size);
                newGrid[rotatedBlock.x][rotatedBlock.y] = grid[x][y];
            }
        }
        
        // set grid to the new grid, but save the old grid for later
        int[][] oldGrid = grid;
        grid = newGrid;
        
        boolean kicked = false;
        
        // loop through all rotation kicks
        for (int i = 0; i < rotationKicks[0].length && !kicked; i++) {
            // get the kick by getting the normal kick if the rotation is clockwise, and the negative of the previous kick if it's counter-clockwise
            Vector kick = dir == 1 ? rotationKicks[orientation][i] : rotationKicks[(orientation - 1 + 4) % 4][i].negative();
            if (!checkCollision(kick, board)) {
                // if that kick allows the shape to not collide with anything, move it, save the kick, change the orientation and save that it was kicked
                move(kick);
                lastKick = i;
                orientation = (orientation + dir + 4) % 4;
                kicked = true;
            }
        }

        // reset the grid if the shape couldn't be kicked anywhere
        if (!kicked) {
            grid = oldGrid;
        }
        
        return kicked;
    }
    
    // get the limit of the shape in any direction (for example the x of the leftest or the y of the highest block)
    // dimension is "x" or "y" specifying in which dimension the limit is checked, limit is "min" or "max" specifying what limit is checked
    int getLimit(String dimension, String limit) {
        // get the highest minimum and the lowest maximum to start
        int min = size;
        int max = -1;
        
        if (dimension.equals("x")) {
            // loop through all columns
            for (int x = 0; x < size; x++) {
                // check if the column is empty
                boolean lineEmpty = true;
                for (int y = 0; y < size; y++) {
                    lineEmpty = (grid[x][y] == 1) ? false : lineEmpty;
                }
                
                if (!lineEmpty) {
                    // update minimum and maximum if a block is in that column 
                    min = min(x, min);
                    max = max(x, max);
                }
            }
        } else {
            // loop through all rows
            for (int y = 0; y < size; y++) {
                // check if the row is empty
                boolean lineEmpty = true;
                for (int x = 0; x < size; x++) {
                    lineEmpty = (grid[x][y] == 1) ? false : lineEmpty;
                }
                
                if (!lineEmpty) {
                    // update minimum and maximum if a block is in that row
                    min = min(y, min);
                    max = max(y, max);
                }
            }
        }
        
        // return the minimum or maximum
        if (limit.equals("min")) {
            return min;
        } else {
            return max;
        }
    }
    
    // get the shape width, height, size or top left corner based on the limits
    int shapeWidth() {      
        return getLimit("x", "max") - getLimit("x", "min") + 1;
    }
    
    int shapeHeight() {
        return getLimit("y", "max") - getLimit("y", "min") + 1;
    }
    
    Vector shapeSize() {
        return new Vector(shapeWidth(), shapeHeight());   
    }
    
    Vector topLeft() {
        return new Vector(getLimit("x", "min"), getLimit("y", "min"));   
    }
    
    // draw the shape in the board, with top left being the top left of the board
    void drawInBoard(Vector topLeft, int transparent) {
        // shift the top left corner based on block position
        topLeft = topLeft.staticAdd(pos.staticSub(0, vanishZone).staticMult(blockSize));
        
        push();
        
        // make the shape transparent according to the parameter
        tint(255, transparent);
        
        // loop through all blocks in the shape grid
        for (int x = 0; x < size; x++) {
            for (int y = 0; y < size; y++) {
                // only draw if that block is taken and the block is below the vanish zone 
                if (grid[x][y] == 1 && y + pos.y >= vanishZone) {
                    // draw the block image by calculating the screen pos of the block
                    assets.drawImage(name + "_Block.png", topLeft.staticAdd(new Vector(x, y).mult(blockSize)), blockSize, blockSize);
                }
            }
        } 
        
        pop();
    }
    
    // draw in the gui with center given
    void drawAtCenter(Vector center, int transparent) {
        // get the top left corner of the shape grid by using the shape size and the top left corner of the shape
        Vector topLeft = center.sub(shapeSize().mult(sideBlockSize).div(2)).sub(topLeft().mult(sideBlockSize));
        
        push();
        
        // make the shape transparent according to the parameter
        tint(255, transparent);
        
        // loop through all blocks in the shape grid
        for (int x = 0; x < size; x++) {
            for (int y = 0; y < size; y++) {
                // only draw if that block is taken
                if (grid[x][y] == 1) {
                    // draw the block image by calculating the screen pos of the block
                    assets.drawImage(name + "_Block.png", topLeft.staticAdd(new Vector(x, y).mult(sideBlockSize)), sideBlockSize, sideBlockSize);
                }
            }
        }  
        
        pop();
    }
    
    // check if the shape collides with the board after a movement
    boolean checkCollision(Vector change, Board board) {
        // get the new position of the shape
        Vector newPos = pos.staticAdd(change);
        
        // loop through all blocks in the shape
        for (int x = 0; x < size; x++) {
            for (int y = 0; y < size; y++) {
                // return collision if the block would be taken after the movement
                if (board.isObstacle(newPos.staticAdd(x, y)) && grid[x][y] == 1) {
                    return true;   
                }
            }
        }
        
        return false;
    }
    
    // check if shape is on ground by checking the collision after a movement down
    boolean onGround(Board board) {
        return checkCollision(new Vector(0, 1), board);
    }
    
    // add the movement vector to the position
    void move(Vector movement) {
        pos.add(movement);   
    }
    
    // move the shape if it can
    boolean moveIfCan(Vector movement, Board board) {
        if (!checkCollision(movement, board)) {
            // move if it would not collide with anything after moving
            move(movement);
            return true;
        } else {
            return false;
        }
        
        // return if it moved the shape
    }
    
    // fall to the ground and return the steps it took
    int fall(Board board) {
        int steps = 0;
        
        // move down until the shape touches the ground
        while (!onGround(board)) {
            move(new Vector(0, 1));
            steps++;
        }
        
        return steps;
    }
    
    // return the number of taken corners of the grid
    int numOfCorners(Board board) {
        int corners = 0;
        corners += board.isObstacle(pos.staticAdd(0     , 0     )) ? 1 : 0;
        corners += board.isObstacle(pos.staticAdd(0     , size-1)) ? 1 : 0;
        corners += board.isObstacle(pos.staticAdd(size-1, 0     )) ? 1 : 0;
        corners += board.isObstacle(pos.staticAdd(size-1, size-1)) ? 1 : 0;
        return corners;
    }
    
    // return the number of upper corners (of the T-shape)
    int numOfUpperCorners(Board board) {
        // vectors without rotation
        Vector vector1 = new Vector(0, 0);
        Vector vector2 = new Vector(size-1, 0);
        
        // rotate the vectors to the current orientation to get the current upper corners
        for (int i = 0; i < orientation; i++) {
            vector1.rotate(1, size);
            vector2.rotate(1, size);
        }
        
        // add the position to the vectors
        vector1.add(pos);
        vector2.add(pos);
        
        // return the number of the vectors being taken on the board
        return (board.isObstacle(vector1) ? 1 : 0) + (board.isObstacle(vector2) ? 1 : 0);
    }
}
