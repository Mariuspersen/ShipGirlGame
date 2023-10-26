const mainbody = document.getElementById("mainbody")
const canvas = document.getElementById("game")
const context = canvas.getContext("2d")

const grid = new Grid(canvas,30,20,200,200);

let assets

async function main() {
    canvas.height = window.innerHeight;
    canvas.width = window.innerWidth;
    context.lineWidth = 2;
    
    assets = await load_assets()
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
    let assets = {};

    assets.background = await load_asset("assets/BattleOcean.png");
    assets.pointer = await load_asset("assets/Pointer.png");
    assets.island_tileset = await load_asset("assets/IslandTileset.png");
    assets.ship = await load_asset("assets/ship.png");

    return assets;
}

main()