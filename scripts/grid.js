class Grid {
    real
    tiles = new Array()
    canvas = document.createElement("canvas")
    ctx = this.canvas.getContext("2d")
    x = 0
    y = 0

    isDragging = false
    offsetX = 0
    offsetY = 0
    scale = 1;

    constructor(real_canvas, tiles_in_x_direction, tiles_in_y_direction, tile_size) {
        this.canvas.width = tile_size * tiles_in_x_direction
        this.canvas.height = tile_size * tiles_in_y_direction
        this.real = real_canvas

        for (let x = 0; x < tiles_in_x_direction; x++) {
            for (let y = 0; y < tiles_in_y_direction; y++) {
                this.tiles.push(new Tile(tile_size * x, tile_size * y, tile_size, tile_size));
            }
        }

        this.tiles.forEach(tile => tile.draw(this.ctx))

        this.real.addEventListener("mousedown", this.mousedown)
        this.real.addEventListener("mousemove", this.mousedrag)
        this.real.addEventListener("mouseup", this.mouseup)
        this.real.addEventListener("mousewheel",this.mousewheel)
    }

    mousedown = (e) => {
        this.isDragging = true;
        this.offsetX = e.clientX - this.x;
        this.offsetY = e.clientY - this.y;
    }

    mousedrag = (e) => {
        if (!this.isDragging) return;

        this.x = (e.clientX - this.offsetX);
        this.y = (e.clientY - this.offsetY);
    }

    mouseup = () => {
        this.isDragging = false;
    }

    mousewheel = (e) => {
        this.scale += e.deltaY / 10000
        console.log(this.scale)
    }

    draw(ctx) {
        ctx.drawImage(this.canvas, this.x, this.y,this.canvas.width/this.scale,this.canvas.height/this.scale)
    }
}