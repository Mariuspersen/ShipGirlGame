class Tile {
    constructor(x,y,w,h) {
        this.x = x;
        this.y = y;
        this.width = w;
        this.height = h;
    }

    draw(ctx) {
        ctx?.strokeRect(this.x,this.y,this.width,this.height)
    }
}