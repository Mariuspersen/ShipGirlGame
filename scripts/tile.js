class Tile {
    constructor(x,y,w,h,image) {
        this.x = x
        this.y = y
        this.width = w
        this.height = h
        this.image = image
    }

    draw(ctx) {
        if(this.image != null) {
            ctx?.drawImage(this.image,this.x,this.y,this.width,this.height)
        }
        ctx?.strokeRect(this.x,this.y,this.width,this.height)
    }
}