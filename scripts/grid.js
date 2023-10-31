class Grid {
    main_canvas
    tiles = new Array()
    canvas = document.createElement("canvas")
    ctx = this.canvas.getContext("2d")
    x = 0
    y = 0
    tilecount_x = 0
    tilecount_y = 0

    dragging = false
    offset_x = 0
    offset_y = 0
    scale = 1;

    constructor(real_canvas,island_tiles, tiles_in_x_direction, tiles_in_y_direction, tile_size) {
        this.canvas.width = tile_size * tiles_in_x_direction
        this.canvas.height = tile_size * tiles_in_y_direction
        this.main_canvas = real_canvas
        this.tilecount_x = tiles_in_x_direction
        this.tilecount_y = tiles_in_y_direction

        this.ctx.lineWidth = 4

        for (let x = 0; x < tiles_in_x_direction; x++) {
            this.tiles.push(new Array())
            for (let y = 0; y < tiles_in_y_direction; y++) {
                this.tiles[x].push(new Tile(
                    tile_size * x, 
                    tile_size * y, 
                    tile_size, 
                    tile_size,
                    island_tiles[15]
                ))
            }
        }
        generate_island(this.tiles,island_tiles)

        let thickness_offset = (this.ctx.lineWidth / 2);

        this.ctx.strokeRect(
            thickness_offset,
            thickness_offset,
            this.canvas.width-(thickness_offset*2),
            this.canvas.height-(thickness_offset*2)
            )
        this.tiles.forEach(col => col.forEach(row => row.draw(this.ctx)))
        this.tiles.forEach(col => col.forEach(tile => tile.draw_terrain(this.ctx)))
        this.main_canvas.addEventListener("mousedown", this.mousedown)
        this.main_canvas.addEventListener("mousemove", this.mousedrag)
        this.main_canvas.addEventListener("mouseup", this.mouseup)
        this.main_canvas.addEventListener("mousewheel",this.mousewheel)
    }

    mousedown = (e) => {
        this.dragging = true;
        this.offset_x = e.clientX - this.x;
        this.offset_y = e.clientY - this.y;
    }

    mousedrag = (e) => {
        if (!this.dragging) return;

        this.x = (e.clientX - this.offset_x);
        this.y = (e.clientY - this.offset_y);
    }

    mouseup = () => {
        this.dragging = false;
    }

    mousewheel = (e) => {
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

        this.scale += e.deltaY / 10000
        this.ctx.lineWidth = this.scale*4
        let thickness_offset = (this.ctx.lineWidth / 2);
        this.tiles.forEach(col => col.forEach(tile => tile.draw(this.ctx)))
        this.tiles.forEach(col => col.forEach(tile => tile.draw_terrain(this.ctx)))
        this.ctx.strokeRect(
            thickness_offset,
            thickness_offset,
            this.canvas.width-(thickness_offset*2),
            this.canvas.height-(thickness_offset*2)
        )

    }

    draw(ctx) {
        ctx?.drawImage(this.canvas, this.x, this.y,this.canvas.width*this.scale,this.canvas.height*this.scale)
    }
}