// asset class to take care of images, text files, sounds and font
class Assets {
    // initialize variables the game is going to access
    PApplet applet;
    Map<String, PImage> images;
    Map<String, SoundFile> sounds;
    String[] shapeData;
    Vector[][][] rotationSystem;
    PFont font;
    
    Assets(PApplet applet) {
        // save applet
        this.applet = applet;
        
        // load font, rotation kicks, images, sounds and shape data
        font = createFont("Font.ttf", 32);
        loadKicks();
        loadImages();
        loadSounds();
        shapeData = loadStrings("shapes.txt");
    }
    
    void loadKicks() {
        // load data
        String[] data = loadStrings("srs.txt");
        
        // create a rotation system consisting out of rotation tables
        rotationSystem = new Vector[3][][];
        Vector[][] rotationTable = new Vector[4][0];
        
        // n - the current rotation tables, currentLine - line of rotation table
        int n = 0;
        int currentLine = 0;
        
        // loop through file
        for (String line : data) {
            if (line.isEmpty()) {
                // if the line is empty, add table to rotation system, increase n, reset line and rotation table
                rotationSystem[n] = rotationTable;
                n++;
                currentLine = 0;
                rotationTable = new Vector[4][];
            } else {
                // split tests by /
                String[] stringTests = line.split("/");
                
                // convert string to list of vectors for the rotation kicks
                Vector[] tests = new Vector[stringTests.length];
                for (int j = 0; j < tests.length; j++) {
                    String[] splitVector = stringTests[j].split(", ");
                    tests[j] = new Vector(parseInt(splitVector[0]), parseInt(splitVector[1]));
                }
                
                // add line to rotation table and increase current line
                rotationTable[currentLine] = tests;
                currentLine++;
            }
        }
        
        // add last rotaion table
        rotationSystem[n] = rotationTable;
    }
    
    void loadImages() {
        // get all names of images and create a new image hashmap
        String[] imageNames = new File(sketchPath("data/images")).list();
        images = new HashMap<String, PImage>();
        
        // loop through image names and put the according image in the hashmap
        for (String image : imageNames) {
            images.put(image, loadImage(sketchPath("data/images/" + image))); 
        }
    }
    
    void loadSounds() {
        // lower the general sound
        new Sound(applet).volume(0.2);
        
        // get all names of sounds and create a new sound hashmap
        String[] soundNames = new File(sketchPath("data/sounds")).list();
        sounds = new HashMap<String, SoundFile>();
        
        // loop through sound names and put the according sound in the hashmap
        for (String sound : soundNames) {
            sounds.put(sound, new SoundFile(applet, sketchPath("data/sounds/" + sound))); 
        }
        
        // lower volume of tetris soundtrack
        sounds.get("Soundtrack.wav").amp(0.5);
    }
    
    // helper methods to handle playing sounds
    void play(String sound) {
        // stop the existing sound before playing a new one
        sounds.get(sound).stop();
        sounds.get(sound).play(); 
    }
    
    void stop(String sound) {
        sounds.get(sound).stop();   
    }
    
    void loop(String sound) {
        sounds.get(sound).loop();   
    }
    
    // helper methods to handle drawing images
    void drawImage(String image, Vector pos, Vector size) {
        image(images.get(image), pos.x, pos.y, size.x, size.y);
    }
    
    void drawImage(String image, Vector pos, int w, int h) {
        image(images.get(image), pos.x, pos.y, w, h);
    }
    
    void drawImage(String image, int x, int y, Vector size) {
        image(images.get(image), x, y, size.x, size.y);
    }
    
    void drawImage(String image, int x, int y, int w, int h) {
        image(images.get(image), x, y, w, h);
    }
}
