function generate_island(tiles, tileset) {
    initial_x = random_int(tiles.length)
    initial_y = random_int(tiles[initial_x].length)

    let island = [
        {
            x: 0,
            y: 0,
            value: 7
        },
        {
            x: 1,
            y: 0,
            value: 11
        },
        {
            x: 0,
            y: 1,
            value: 13
        },
        {
            x: 1,
            y: 1,
            value: 14
        },
    ]

    console.log(JSON.stringify(island))
    island.forEach(island_part => {
        if(island_part.x+initial_x < tiles.length && island_part.y+initial_y < tiles[0].length)
        tiles[island_part.x+initial_x][island_part.y+initial_y].image = tileset[island_part.value]
    })

}

function random_int(max) {
    return Math.floor(Math.random() * max);
}
