function wfc(tiles,tilecount_x,tilecount_y,tileset) {
    initial_tile = random_int(tiles.length)
    initial_tileimage = random_int(tileset.length)
    tiles[initial_tile].image = tileset[0]

    const neighbors = find_neighbors(tiles,initial_tile,tilecount_x,tilecount_y)
    neighbors.forEach(tile_index => {
        determine_image(tiles,tile_index,tilecount_x,tilecount_y,tileset)
    });
    

    
}

function determine_image(tiles,current_tile,tilecount_x,tilecount_y,tileset) {
    const neighbors = find_neighbors(tiles,current_tile,tilecount_x,tilecount_y)
    tiles[current_tile].image = tileset[0]
    
}

function random_int(max) {
    return Math.floor(Math.random() * max);
}

function find_neighbors(tiles, tile_index ,tilecount_x,tilecount_y) {
    let neighbors = []
    const x = tile_index % tilecount_x;
    const y = Math.floor(tile_index / tilecount_x)

    if (x > 0) {
        neighbors.push(y * tilecount_x + (x - 1));
    }

    // Right neighbor
    if (x < tilecount_x - 1) {
        neighbors.push(y * tilecount_x + (x + 1));
    }

    // Top neighbor
    if (y > 0) {
        neighbors.push((y - 1) * tilecount_x + x);
    }

    // Bottom neighbor
    if (y < tilecount_y - 1) {
        neighbors.push((y + 1) * tilecount_x + x);
    }

    return neighbors;

}

const direction = {
    top: 0,
    bottom: 1,
    right: 2,
    left: 3,
}
