const mainbody = document.getElementById("mainbody")
const canvas = document.getElementById("game")
const context = canvas.getContext("2d")

let grid
let assets

async function main() {
    canvas.height = window.innerHeight;
    canvas.width = window.innerWidth;
    
    assets = await load_assets()
    grid = new Grid(canvas,assets.island_tiles,5,5,200,200);
    window.requestAnimationFrame(loop)
}

async function loop() {
    context.drawImage(assets.background,0,0,canvas.width,canvas.height)
    grid.draw(context);
    window.requestAnimationFrame(loop)
}

function load_asset(path) {
    return new Promise((resolve,reject) => {
        const asset = new Image()
        asset.src = path
        asset.onload = () => resolve(asset)
        asset.onerror = reject
    })
}

async function load_assets() {
    const assets = {}

    assets.background = await load_asset("assets/BattleOcean.png")
    assets.pointer = await load_asset("assets/Pointer.png")
    assets.island_tileset = await load_asset("assets/IslandTileset.png")
    assets.ship = await load_asset("assets/ship.png")
    assets.island_tiles = new Array()

    const tile_size = 300

    const tile = document.createElement("canvas")
    const tile_ctx = tile.getContext("2d")
    tile.width = tile_size;
    tile.height = tile_size;

    let count = 0;
    for (let row = 0; row < assets.island_tileset.width/tile_size; row++) {
        for (let col = 0; col < assets.island_tileset.height/tile_size; col++) {
            tile_ctx.drawImage(
                assets.island_tileset,
                col*tile_size,
                row*tile_size,
                tile_size,
                tile_size,
                0,
                0,
                tile_size,
                tile_size
            )

            const tile_image = new Image()
            tile_image.src = tile.toDataURL()
            tile_image.value = count++
            assets.island_tiles.push(tile_image)
            tile_ctx.clearRect(0, 0, tile.width, tile.height);
            
        }
    }

    return assets;
}

main()