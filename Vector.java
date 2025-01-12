// class for vector containing ints - avoid using PVector to avoid floats
public class Vector {
    // x and y variables
    int x, y;
    
    // constructor
    Vector(int x, int y) {
        this.x = x;
        this.y = y;
    }
    
    // copy the vector
    Vector copy() {
        return new Vector(x, y);
    }
    
    // check if two vectors are equal
    boolean equals(Vector v) {
        return v.x == x && v.y == y;
    }
    
    // print the vector
    void print() {
        System.out.println(x + ", " + y);   
    }
    
    // basic functions with numbers
    Vector add(int x, int y) {
        this.x += x;
        this.y += y;
        return this;
    }
    
    Vector sub(int x, int y) {
        this.x -= x;
        this.y -= y;
        return this;
    }
    
    Vector mult(int n) {
        this.x *= n;
        this.y *= n;
        return this;
    }
    
    Vector div(int n) {
        this.x /= n;
        this.y /= n;
        return this;
    }
    
    // functions with vectors
    Vector add(Vector v) {
        this.x += v.x;
        this.y += v.y;
        return this;
    }
    
    Vector sub(Vector v) {
        this.x -= v.x;
        this.y -= v.y;
        return this;
    }
    
    // invert x and y
    Vector invert() {
        int ySaved = this.y;
        this.y = this.x;
        this.x = ySaved;
        return this;
    }
    
    // make the x and y negative versions of each other
    Vector negative() {
        this.x = -this.x;
        this.y = -this.y;
        return this;
    }
    
    // rotate the vector clockwise if dir is 1, counter-clockwise if dir is -1, in a size by size square
    Vector rotate(int dir, int size) {
        int xSaved = x;
        int ySaved = y;
        
        if (dir == 1) {
            x = size - 1 - ySaved;
            y = xSaved;
        } else {
            x = ySaved;
            y = size - 1 - xSaved;
        }
        
        return this;
    }
    
    // versions of all functions returning a new vector and not changing the original one
    Vector staticAdd(int x, int y) {
        return new Vector(this.x + x, this.y + y);
    }
    
    Vector staticSub(int x, int y) {
        return new Vector(this.x - x, this.y - y);
    }
    
    Vector staticMult(int n) {
        return new Vector(this.x*n, this.y*n);
    }
    
    Vector staticDiv(int n) {
        return new Vector(this.x/n, this.y/n);
    }
    
    Vector staticAdd(Vector v) {
        return new Vector(this.x + v.x, this.y + v.y);
    }
    
    Vector staticSub(Vector v) {
        return new Vector(this.x - v.x, this.y - v.y);
    }
    
    Vector staticInvert() {
        return new Vector(this.y, this.x);
    }
    
    Vector staticNegative() {
        return new Vector(-this.x, -this.y);
    }
    
    Vector staticRotate(int dir, int size) {
        if (dir == 1) {
            return new Vector(size - 1 - y, x);
        } else {
            return new Vector(y, size - 1 - x);
        }
    }
}
