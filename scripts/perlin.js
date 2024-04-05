class Vector {
    constructor(x,y) {
        this.x = x
        this.y = y
    }
    dot(v) {
        return this.x * v.x + this.y * v.y
    }
    divide(d) {
        this.x / d
        this.y / d
    }
}

class PerlinNoise {
    constructor(tiles) {
        this.tiles = tiles
    }
    random_vector() {
        let angle = Math.random() * 2 *Math.PI
        return new Vector(Math.cos(angle),Math.sin(angle));
    }
    apply_noise(size) {

        for (let x = 0; x < this.tiles.length; x = x + size) 
        for (let y = 0; y < this.tiles[x].length; y = y + size) {
            const rand_vec = this.random_vector()
            for (let sx = 0; sx < size; sx++) 
            for (let sy = 0; sy < size; sy++) {
                console.log(x,y,sx,sy,size,this.tiles[sx][sy])
                this.tiles[sx+x][sy+y].vector = rand_vec
            }
        }
        
        
        //this.apply_perlin()
    }
    smoothstep(x) {
        return 6*x**5 - 15*x**4 + 10*x**3
    }
    linear_interpolation(x,a,b) {
        return a + this.smoothstep(x) * (b-a)
    }

    apply_perlin() {
        for (let x = 0; x < this.tiles.length; x++) {
            for (let y = 0; y < this.tiles[x].length; y++) {

                const topleft = this.tiles[x][y].vector
                const topright = this.tiles?.[x+1]?.[y]?.vector
                const bottomleft = this.tiles?.[x]?.[y+1]?.vector
                const bottomright = this.tiles?.[x+1]?.[y+1]?.vector
                
                topleft?.divide(10)
                topright?.divide(13)
                bottomleft?.divide(13)
                bottomright?.divide(13)

                const tl = topleft.dot(topleft)
                const tr = topleft.dot(topright ? topright : this.random_vector())
                const bl = topleft.dot(bottomleft ? bottomleft : this.random_vector())
                const br = topleft.dot(bottomright ? bottomright : this.random_vector())

                const xt = this.linear_interpolation(1,tl,tr)
                const xb = this.linear_interpolation(1,bl,br)
                const v = this.linear_interpolation(1,xt,xb)

                this.tiles[x][y].intensity = v;

            }      
        }
    }
}