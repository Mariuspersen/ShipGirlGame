function generate_islands(tiles, tileset) {
    tiles.forEach(x => x.forEach(y => {
        console.log(y.intensity)
        if(y.intensity < .36) {
            y.image = tileset[0]
        }
        if(y.intensity < .31) {
            y.image = tileset[2]
        }
    }))
}

function random_int(max) {
    return Math.floor(Math.random() * max);
}
