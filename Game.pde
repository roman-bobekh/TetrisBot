class Game {
    // initialize board, bot, shapes and shuffled shape lists
    Board board = new Board();
    Bot bot = new Bot();
    List<Integer> shapes;
    List<Shape> shuffledShapes = new ArrayList<Shape>();
    List<Shape> shuffledShapes2 = new ArrayList<Shape>();
    
    // initialize the falling shape, held shape and save if the shape is swapped
    Shape fallingShape;
    Shape heldShape;
    boolean shapeSwapped;
    
    // initialize variables for the lock delay
    long lockStart;
    int lockLimit;
    int lockDelay;
    
    // initialize the last update loop and the partial blocks dropped
    long lastUpdate;
    float blocksDropped;
    
    // initialize the score, combo count, back to back count and the last move
    int score;
    int combo;
    int backToBack;
    String lastMove;
    
    // initialize the current level and start level, current speed and cleared line count
    int level;
    int startLevel = 1;
    int lineCount;
    float speed;
    
    // initialize the game state, start and duration of the line animation and the cleared lines
    String state = "start";
    long lineAnimationStart;
    int lineAnimationLength = 100;
    List<Integer> clearedLines = new ArrayList<Integer>();
    
    // initialize the start and duration of the end animation
    long endAnimationStart;
    int endAnimationLength = 1000;
    
    // initialize the message, its start and duration
    String message = null;
    long messageStart = -1;
    int messageLength = 5000;
    
    // save if the button is highlighted
    boolean buttonHighlighted = false;
    
    // save if current game is a copy
    boolean isCopy;
   
    // game constructor
    Game(boolean isCopy) {
        // add the numbers 1 to shape count to the shape list
        shapes = new ArrayList<Integer>();
        for (int i = 1; i <= shapeCount; i++) {
            shapes.add(i);
        }
        
        this.isCopy = isCopy;
    }
    
    // copy all variables that can be changed
    Game copy() {
        Game newGame = new Game(true);
        
        // copy board, bot, shapes and shuffled shape lists
        newGame.board = board.copy();
        
        newGame.shuffledShapes = new ArrayList<Shape>();
        for (Shape shape : shuffledShapes) {
            newGame.shuffledShapes.add(shape.copy());
        }
        
        newGame.shuffledShapes2 = new ArrayList<Shape>();
        for (Shape shape : shuffledShapes2) {
            newGame.shuffledShapes2.add(shape.copy());
        }

        // copy the falling shape, held shape and save if the shape is swapped
        newGame.fallingShape = fallingShape.copy();
        if (heldShape == null) {
            newGame.heldShape = null;
        } else {
            newGame.heldShape = heldShape.copy();
        }
        newGame.shapeSwapped = shapeSwapped;
        
        // copy variables for the lock delay
        newGame.lockStart = lockStart;
        newGame.lockLimit = lockLimit;
        newGame.lockDelay = lockDelay;
        
        // copy the last update loop and the partial blocks dropped
        newGame.lastUpdate = lastUpdate;
        newGame.blocksDropped = blocksDropped;
        
        // copy the score, combo count, back to back count and the last move
        newGame.score = score;
        newGame.combo = combo;
        newGame.backToBack = backToBack;
        newGame.lastMove = lastMove;
        
        // copy the current level, current speed and cleared line count
        newGame.level = level;
        newGame.lineCount = lineCount;
        newGame.speed = speed;
        
        // copy the game state, start and the cleared lines
        newGame.state = state;
        newGame.lineAnimationStart = lineAnimationStart;
        newGame.clearedLines = new ArrayList<Integer>(clearedLines);
        
        // copy the start of the end animation
        newGame.endAnimationStart = endAnimationStart;
        
        // copy the message, its start and duration
        newGame.message = message;
        newGame.messageStart = messageStart;
        
        // copy the button highlight
        newGame.buttonHighlighted = buttonHighlighted;
        
        return newGame;
    }
    
    // draw the game during "game" state with the progress of the line and end animation as arguments (-1 for no animation)
    void drawGame(float lineAnimationProgress, float endAnimationProgress) {
        // normal font, center text and dark grey background
        textFont(assets.font);
        textAlign(CENTER, CENTER);
        background(10);
        
        // pass the shape, animation, lockProgress and cleared lines as arguments to the board to draw
        board.drawBoard(fallingShape, lineAnimationProgress, endAnimationProgress, (System.currentTimeMillis() - lockStart) / (float)lockDelay, clearedLines);
        
        // white, 32-sized text
        fill(255);
        textSize(32);
        
        // write score in the center, hold, level and lines on the left and next on the right
        text("Score: " + score, width/2, 50);
        text("Hold:", 150, 80);
        text("Next:", width - 150, 80);
        text("Level: " + level, 150, 380);
        text("Lines: " + lineCount, 150, 430);
        
        // check if time passed since start of the current message is less than its duration to draw it
        float timePassed = System.currentTimeMillis() - messageStart;
        if (timePassed < messageLength) {
            if (timePassed < 300) {
                // if the message is fading in (first 300ms), set transparency based on the time passed
                fill(255, timePassed/300 * 255);
            } else if (timePassed > messageLength - 300) {
                // if the message is fading out (last 300ms), set transparency based on the time passed
                fill(255, (messageLength - timePassed) / 300 * 255);
            }
            
            // draw the message on the bottom left
            textSize(40);
            text(message, 150, 750);   
        }
        
        // draw to rects with a stroke of 5 and a dark grey color, one on the left for the hold, one on the right for the next shapes 
        strokeWeight(5);
        noFill();
        stroke(30);
        rect(60, 120, 180, 180);
        rect(width - 240, 120, 180, 450);
        
        if (heldShape != null) {
            // draw the held shape in the center of the rect if a shape is being held, apply transparency if it was already swapped
            heldShape.drawAtCenter(new Vector(150, 210), shapeSwapped ? 100 : 255);
        }
        
        // draw the next shapes in the long rectangle
        shuffledShapes.get(0).drawAtCenter(new Vector(width - 150, 200), 255);
        shuffledShapes.get(1).drawAtCenter(new Vector(width - 150, 340), 150);
        shuffledShapes.get(2).drawAtCenter(new Vector(width - 150, 480), 50);   
    }
    
    // draw the starting screen
    void drawStart() {
        // normal font, center text and dark grey background
        textFont(assets.font);
        textAlign(CENTER, CENTER);
        background(10);
        
        // draw the logo in the top center of the screen
        assets.drawImage("Logo.png", width/2 - 250, 150, 500, 347);
            
        // write play in the bottom center of the screen 
        fill(255);
        textSize(80);
        text("Play", width/2, 690);
        
        // draw a rect around "play", light grey if the button is highlighted, dark grey if it isn't
        strokeWeight(5);
        noFill();
        if (buttonHighlighted) {
            stroke(200);
        } else {
            stroke(30);
        }
        rect(width/2 - 250, 620, 500, 160);
    }
    
    // draw the end screen
    void drawEnd() { 
        // normal font, center text and dark grey background
        textFont(assets.font);
        textAlign(CENTER, CENTER);
        background(10);
        
        // write game over in the top center of the screen 
        fill(255);
        textSize(150);
        text("Game over", width/2, 150);
        
        // write the stats in the center of the screen
        textSize(40);
        text("Score: " + score, width/2, 385);
        text("Level: " + level, width/2, 445);
        text("Lines cleared: " + lineCount, width/2, 505);
        
        // write play again in the bottom center of the screen 
        textSize(80);
        text("Play again", width/2, 740);
        
        // draw a rect around "play again", light grey if the button is highlighted, dark grey if it isn't
        strokeWeight(5);
        noFill();
        if (buttonHighlighted) {
            stroke(200);
        } else {
            stroke(30);
        }
        rect(width/2 - 250, 670, 500, 160);
    }
    
    // main game loop
    void loop() {
        // check which state the game is in
        if (state.equals("game")) {
            // let the bot play
            bot.move(this);
            
            // if the shape is still floating, reset the lock start completely
            if (!fallingShape.onGround(board)) {
                lockStart = -1;
            }

            // if the shape is on the ground and the lock delay is over, finish the piece
            if (fallingShape.onGround(board) && System.currentTimeMillis() - lockStart > lockDelay) {
                finishShape();
            } else {
                // calculate the time passed since the last update and increase the theoretical blocks dropped by time passed (in secs) times speed (in blocks/sec)
                long timePassed = (System.currentTimeMillis() - lastUpdate);
                blocksDropped += speed * (timePassed/1000f);
                
                // save the time of this update
                lastUpdate = System.currentTimeMillis();
                
                // while the theoretical block count is more than 1, fall and decrease it until it's less than 1
                while (blocksDropped >= 1) {
                    if (!fallingShape.onGround(board)) {
                        // if the shape can fall, make it fall, reset the lock start if it's on the ground and save the last move
                        fallingShape.move(new Vector(0, 1));     
                        lockResetCheck();
                        lastMove = "move";
                    }
                    blocksDropped--;
                }
            }
            
            // if the game is in normal play mode, draw normal game
            drawGame(-1, -1);
        } else if (state.equals("lineAnimation")) {
            // if a line clear is being animated, pass the time since the animation start to drawGame()
            float timePassed = System.currentTimeMillis() - lineAnimationStart;
            drawGame(timePassed / lineAnimationLength, -1);
            
            if (timePassed > lineAnimationLength) {
                // if the animation already ended, clear the lines, pick the next shape and reset the state
                board.clearLines(clearedLines);
                pickNextShape(false);
                state = "game";
            }
        } else if (state.equals("endAnimation")) {
            // if the end is being animated, pass the time since the animation start to drawGame()
            float timePassed = System.currentTimeMillis() - endAnimationStart;
            drawGame(-1, timePassed / endAnimationLength);
            
            if (timePassed > endAnimationLength) {
                // if the animation already ended, set the state to end
                state = "end";
                buttonHighlighted = false;
            }
        } else if (state.equals("start")) {
            // if it's the start, draw the start
            drawStart();
            
            // check if mouse is on button
            if (mouseX > width/2 - 250 && mouseX < width/2 + 250 && mouseY > 620 && mouseY < 780) {
                if (!buttonHighlighted) {
                    // if the button wasn't highlighted before, play the select sound and save the highlight
                    if (!isCopy) {
                        assets.play("Select.wav"); 
                    }
                    buttonHighlighted = true;
                }
            } else {
                buttonHighlighted = false;
            }
        } else if (state.equals("end")) {
            // if it's the end, draw the end
            drawEnd();
            
            // check if mouse is on button
            if (mouseX > width/2 - 250 && mouseX < width/2 + 250 && mouseY > 670 && mouseY < 830) {
                if (!buttonHighlighted) {
                    // if the button wasn't highlighted before, play the select sound and save the highlight
                    if (!isCopy) {
                        assets.play("Select.wav"); 
                    }
                    buttonHighlighted = true;
                }
            } else {
                buttonHighlighted = false;
            }
        }
    }
    
    // input events
    void left() {
        // move the shape to the left if it can, save the move, lock reset and play the move sound
        if (fallingShape.moveIfCan(new Vector(-1, 0), board)) {
            lockResetCheck();
            lastMove = "move";
            if (!isCopy) {
                assets.play("Move.wav");
            }
        }
    }
    
    void right() {
        // move shape to the right if it can, save move, lock reset and play move sound
        if (fallingShape.moveIfCan(new Vector(1, 0), board)) {
            lockResetCheck();
            lastMove = "move";
            if (!isCopy) {
                assets.play("Move.wav");
            }
        }
    }
    
    void down() {
        // move shape to the left if it can, save move, increase score, lock reset and play soft drop sound
        if (fallingShape.moveIfCan(new Vector(0, 1), board)) {
            lockResetCheck();
            lastMove = "move";
            score++;
            if (!isCopy) {
                assets.play("SoftDrop.wav");
            }
        }
    }
    
    void drop() {
        // make shape fall, increase score by blocks fallen times 2, end the lock delay, save move and play hard drop sound
        score += fallingShape.fall(board) * 2;
        lockStart = -1;
        lastMove = "move";
        if (!isCopy) {
            assets.play("HardDrop.wav");
        }
    }
    
    void rotateClockwise() {
        // rotate shape, lock reset, save rotation and play rotation sound
        if (fallingShape.rotate(1, board)) {
            lockResetCheck();
            lastMove = "rotation";
            if (!isCopy) {
                assets.play("Rotate.wav");
            }
        }
    }
    
    void rotateCounterclockwise() {
        // rotate shape, lock reset, save rotation and play rotation sound
        if (fallingShape.rotate(-1, board)) {
            lockResetCheck();
            lastMove = "rotation";
            if (!isCopy) {
                assets.play("Rotate.wav");
            }
        }
    }
    
    // swap the shape
    void swap() {
        // only swap if the shape wasn't swapped this round already
        if (!shapeSwapped) {
            // play the hold sound
            if (!isCopy) {
                assets.play("Hold.wav");
            }
            
            if (heldShape == null) {
                // if no shape is being held, hold the current shape and reset it and pick the next shape
                heldShape = fallingShape;
                heldShape.loadData(heldShape.id);
                pickNextShape(true);
            } else {
                // if a shape is being held, swap the falling and heldShape, reset the new held shape and reset the shape round variables
                Shape newShape = heldShape;
                heldShape = fallingShape;
                fallingShape = newShape;
                heldShape.loadData(heldShape.id);
                resetShapeVars();
            }
            
            shapeSwapped = true;
        }
    }
    
    // event when mouse is clicked
    void click() {
        if (state.equals("start")) {
            // if the mouse is on the button, restart the game and play the sound
            if (buttonHighlighted) {
                restartGame();  
                if (!isCopy) {
                    assets.play("Ok.wav");
                }
            }
        } else if (state.equals("end")) {
            // if the mouse is on the button, restart the game and play the sound
            if (buttonHighlighted) {
                restartGame();  
                if (!isCopy) {
                    assets.play("Ok.wav");
                }
            }
        }
    }
    
    // reset variables to restart the game
    void restartGame() {
        // reset the bloard and the held shpae
        board = new Board();
        heldShape = null;
        
        // shuffle the next shapes
        shuffle(shuffledShapes);
        shuffle(shuffledShapes2);
        
        // reset the theoretical blocks dropped
        blocksDropped = 0;
        
        // reset score variables
        score = 0;
        combo = 0;
        backToBack = 0;
        
        // reset level and line count
        level = startLevel;
        lineCount = 0;
        
        // reset state and animations
        state = "game";
        lineAnimationStart = -1;
        endAnimationStart = -1;
        
        // reset message
        message = null;
        messageStart = -1;
  
        // pick the next shape to start the game
        pickNextShape(false);
        
        // stop the previous music and play the soundtrack
        if (!isCopy) {
            assets.loop("Soundtrack.wav");
            assets.stop("GameOver.wav");
        }
    }
    
    // pick the next shape/start a shape round
    void pickNextShape(boolean isSwap) {
        // set the shape to the next shape and shift a shape from shuffledShapes2 to shuffledShapes
        fallingShape = shuffledShapes.get(0);  
        shuffledShapes.remove(0);
        shuffledShapes.add(shuffledShapes2.get(0));
        shuffledShapes2.remove(0);
        
        // if shuffledShapes2 is empty, reshuffle it
        if (shuffledShapes2.size() == 0) {
            shuffle(shuffledShapes2);
        }
        
        // reset the variables for the shape round
        resetShapeVars();
        
        // let the bot calculate its moves for the shape but if it's not a swap
        if (!isSwap) {
            bot.calculate(this);
        }
    }
    
    // reset the variables for the shape round
    void resetShapeVars() {
        // reset the lock limit and lock start
        lockLimit = 20;
        lockStart = System.currentTimeMillis();
        
        // reset last update and theoretical blocks dropped
        lastUpdate = System.currentTimeMillis();
        blocksDropped = 0;
        
        shapeSwapped = false;
        lastMove = "move";
        
        // get the speed based on the level
        speed = 1 / pow((0.8-((level-1)*0.007)), level-1); // formula from harddrop.com
        
        // set the lock delay based on the level according to https://www.reddit.com/r/Tetris/comments/e1ov09/how_does_level_25_and_up_work_for_tetriscom/f8s4n31?utm_source=share&utm_medium=web2x&context=3
        if (level < 20) {
            lockDelay = 500;
        } else if (level < 25) {
            lockDelay = 500 - (level - 19) * 50;
        } else if (level < 30) {
            lockDelay = 200 - (level - 25) * 10;
        } else {
            lockDelay = 150;
        }
    }
    
    // finish piece after it dropped (including picking the next shape)
    void finishShape() {
        // check if the board tops out (game over) after imprinting the current shape
        if (board.imprint(fallingShape) && false) {
            // if it's game over, start the game animation and play the game over sound
            state = "endAnimation";
            endAnimationStart = System.currentTimeMillis();
            
            if (!isCopy) {
                assets.play("GameOver.wav");
                assets.stop("Soundtrack.wav");
            }
        } else {
            // if it's not game over, get the lines cleared, increase the score
            clearedLines = board.getClearedLines();
            score += calculateScore();
            
            if (clearedLines.size() > 0) {
                // if lines were cleared animate them
                lineAnimationStart = System.currentTimeMillis();
                state = "lineAnimation";
            } else {
                // else just pick the next shape
                pickNextShape(false);
            }
        }
    }
    
    // fill a list of shapes with shuffled shapes
    void shuffle(List<Shape> list) {
        // shuffle shape numbers
        List<Integer> numbers = new ArrayList<Integer>(shapes);
        Collections.shuffle(numbers);
        
        // add shapes to the list based on the shuffled numbers
        list.clear();
        for (Integer num : numbers) {
            list.add(new Shape(num));
        }
    }
    
    // reset the lock start if needed
    void lockResetCheck() {
        if (fallingShape.onGround(board) && lockLimit > 0) {
            // if the shape is on the ground and is still under the lock limit, reset the lock start and decrease the lock limit
            lockStart = System.currentTimeMillis();
            lockLimit--;
        }
    }
    
    // calculate the score after a landing, score according to https://tetris.wiki/Scoring
    int calculateScore() {
        // reset the variables
        int newScore = 0;
        String tSpin = "none";
        String newMessage ="";
        
        // check if it's a t-spin according to https://tetris.wiki/T-Spin
        // the shape should be a t-shape, it should have been rotated last move and the number of the taken corners of the shape should be 3
        if (fallingShape.name.equals("T") && lastMove.equals("rotation") && fallingShape.numOfCorners(board) == 3) {
            // if the number of upper corners of the t-shape is 2, it's a normal t-spin
            if (fallingShape.numOfUpperCorners(board) == 2) {
                tSpin = "normal";
            } else {
                // but if the last kick of the shape was the last rotation kick, it's also normal
                if (fallingShape.lastKick == 4) {
                    tSpin = "normal";
                } else {
                    // else it's a mini t-spin
                    tSpin = "mini";
                }
            }
        }

        // check the number of lines cleared
        switch(clearedLines.size()) {
            case 0:
                // if no lines were cleared, set the message and score according to the t-spin
                if (tSpin.equals("mini")) {
                    newScore += 100 * level;  
                    newMessage = "Mini T-Spin";
                } else if (tSpin.equals("normal")) {
                    newScore += 400 * level;
                    newMessage = "T-Spin";
                }
                break;
            case 1:
                // if one line was cleared, set the message and score according to the t-spin, play sound
                if (tSpin.equals("mini")) {
                    newScore += 200 * level;   
                    newMessage = "Mini T-Spin\n Single";
                } else if (tSpin.equals("normal")) {
                    newScore += 800 * level;
                    newMessage = "T-Spin\n Single";
                } else {
                    newScore += 100 * level;
                }
                
                if (!isCopy) {
                    assets.play("Single.wav");
                }
                
                break;
            case 2:
                // if two lines were cleared, set the message and score according to the t-spin, play sound
                if (tSpin.equals("mini")) {
                    newScore += 400 * level;   
                    newMessage = "Mini T-Spin\n Double";
                } else if (tSpin.equals("normal")) {
                    newScore += 1200 * level;
                    newMessage = "T-Spin\n Double";
                } else {
                    newScore += 300 * level;
                }
                
                if (!isCopy) {
                    assets.play("Double.wav");
                }
                
                break;
            case 3:
                // if three lines were cleared, set the message and score according to the t-spin, play sound
                if (tSpin.equals("normal")) {
                    newScore += 1600 * level;
                    newMessage = "T-Spin\n Triple";
                } else {
                    newScore += 500 * level;
                }
                
                if (!isCopy) {
                    assets.play("Triple.wav");
                }
                
                break;
            case 4:
                // if four lines were cleared, set the message and score, play sound
                newScore += 800 * level;
                
                if (!isCopy) {
                    assets.play("Tetris.wav");
                }
                
                newMessage = "Tetris";
                break;
        }
        
        // if a single, double or triple without a t-spin happened, reset back to back
        if (clearedLines.size() < 4 && clearedLines.size() > 0 && tSpin.equals("none")) {
            backToBack = 0;
        } else if (clearedLines.size() > 0) {
            // check if other lines were cleared
            if (backToBack > 0) {
                // if it's a back to back increase the score and add "back to back" to the message
                newScore *= 1.5;
                newMessage += "\n\nBack to\n back";
            }
            // increase the back to back counter
            backToBack++;
        }
            
        // check if lines were cleared
        if (clearedLines.size() > 0) {
            if (combo > 0) {
                // if combo: add "Combo" to the message
                newMessage += (newMessage == "") ? ("Combo " + combo): ("\n\nCombo " + combo);
            }
            
            // increase score and increase combo count
            newScore += 50*combo*level; 
            combo++;
        } else {
            // no lines: reset combo
            combo = 0;
        }
        
        // if all lines of board will be cleared, add "all clear" to the message and play the sound effect
        if (board.linesWithBlocks() - clearedLines.size() == 0) {
            newMessage += (newMessage == "") ? ("All clear") : ("\n\nAll clear");
            if (!isCopy) {
                assets.play("Clear.wav");
            }
        }
        
        // if there's a message, set the message to the new message and reset the message start
        if (newMessage != "") {
            message = newMessage;
            messageStart = System.currentTimeMillis();
        }
        
        // add the lines to the line count and adjust the leveel
        lineCount += clearedLines.size();
        level = lineCount / 10 + startLevel;
        
        return newScore;
    }
}
