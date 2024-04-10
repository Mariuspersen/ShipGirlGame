class Tile {
    constructor(x,y,w,h,image,intensity) {
        this.x = x
        this.y = y
        this.width = w
        this.height = h
        this.image = image
        this.fade = new Image()
        this.vector = undefined
        this.intensity = intensity
    }

    draw(ctx) {
        ctx.strokeRect(this.x,this.y,this.width,this.height)
    }
    draw_terrain(ctx) {
        ctx.drawImage(this.image,this.x,this.y,this.width,this.height)
        ctx.drawImage(this.fade,this.x,this.y,this.width,this.height)
    }
    get_index() {
        return {
            x: this.x/this.width,
            y: this.y/this.height
        }
    }
}