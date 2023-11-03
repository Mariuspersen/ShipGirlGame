function generate_island(tiles, tileset,islands) {
    initial_x = random_int(tiles.length)
    initial_y = random_int(tiles[initial_x].length)
    island = islands[random_int(islands.length)]

    island.forEach(island_part => {
        if(island_part.x+initial_x < tiles.length && island_part.y+initial_y < tiles[0].length)
        tiles[island_part.x+initial_x][island_part.y+initial_y].image = tileset[island_part.value]
    })

}

function random_int(max) {
    return Math.floor(Math.random() * max);
}
