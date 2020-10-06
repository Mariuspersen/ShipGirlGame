let Background;
let land;
let placeholder;
let placeholder1;
let pointer;
let Highlite;
let IslandGeneration = []
let spritesheet
let Ships;
const playerOptions = ['Move','Fire guns','Launch Torpedoes','Info'];
const enemyOptions = ['Attack'];
function preload() {
  battleBackground = loadImage('assets/BattleOcean.png');
  placeholder = loadImage('assets/PlaceholderShipgirlNonWeeb.png');
  Highlite = loadImage('assets/Highlight.png');
  pointer = loadImage('assets/Pointer.png');
  spritesheet = loadImage('assets/IslandGenerationFastereFade.png');
  Ships = loadJSON('Ships.json')
}

function setup() {
  Ships = Object.values(Ships)
  createCanvas(1280,800);
  frameRate(30);
  noLoop();  
    for (let i = 0; i < spritesheet.height / 300; i++) {
      for (let j = 0; j < spritesheet.width / 300; j++) {
        IslandGeneration.push(spritesheet.get(300*j,300*i,300,300))
      }    
    }
  let Fleet1 = new Array(6).fill().map(x => new Shipgirl(random(Ships)))
  let Fleet2 = new Array(6).fill().map(x => new Shipgirl(random(Ships)))
  this.TestBattle = new Battle(Fleet1,Fleet2,random([2,3,4]));
}

function draw() {
  this.TestBattle.Draw();
}

function keyPressed() {
  this.TestBattle.stateManager(2)
}

function mouseMoved() {
  this.TestBattle.stateManager(0);
}

function mouseClicked() {
  this.TestBattle.stateManager(1);
}

