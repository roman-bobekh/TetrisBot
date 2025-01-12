// import libraries
import java.util.Collections;
import java.util.List;
import java.util.Arrays;
import java.util.Map;
import processing.sound.*;

// number of shapes
int shapeCount = 7;

// board size + vanish zone
int boardWidth = 10;
int boardHeight = 20;
int vanishZone = 10;

// size of blocks in the board and in the gui
int blockSize = 40;
int sideBlockSize = 30;

// assets and game variables
Assets assets;
Game game;

void setup() {
    // setup the screen
    size(1000, 1000);
    
    // initialize assets and game
    assets = new Assets(this);
    game = new Game();
    
    // tetris logo
    surface.setIcon(assets.images.get("Logo.png"));
}

// pass on events to game
void draw() {
    game.loop();
}

void keyPressed() {
    game.keyPress();   
}

void mouseClicked() {
    game.click();   
}
