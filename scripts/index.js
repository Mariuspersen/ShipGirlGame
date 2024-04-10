const mainbody = document.getElementById("mainbody")
const canvas = document.getElementById("game")
const context = canvas.getContext("2d")
const fps_counter = document.getElementById("fps-counter")

const webglcanvas = document.createElement("canvas")
const webgl = webglcanvas.getContext("webgl")

let grid
let assets

async function main() {
    canvas.height = window.innerHeight;
    canvas.width = window.innerWidth;
    
    assets = await load_assets()
    grid = new Grid(canvas,assets.island_tiles,10,10,100,1);
    window.requestAnimationFrame(loop)
}


async function loop() {
    calculate_fps()
    context.drawImage(assets.background,0,0,canvas.width,canvas.height)
    grid.draw(context);
    window.requestAnimationFrame(loop)
}

let last = performance.now()
let frames = 0
let fps = 0
function calculate_fps() {
    const current = performance.now()
    const delta = current - last
    last = current;
    frames++
    fps_counter.innerText = Math.round((1/delta)*1000)
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
    assets.island_tileset = await load_asset("assets/tileset.png")
    assets.ship = await load_asset("assets/ship.png")
    assets.frag = await (await fetch("assets/fragment.glsl")).text()
    assets.vert = await (await fetch("assets/vertex.glsl")).text()
    assets.island_tiles = new Array()

    const tile_size = 256

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