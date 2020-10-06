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
//let FogofWar;
//let VisableArea;
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
  //Shipname,Displacement,Guns,Armour,Speed,Beam,Torpedoes
  /*this.Ships = [
  new Shipgirl('Dreadnought',21060,[[300,10],[76,27]],[279,76,279,305,279,203],21,25,[[5,460]]),
  new Shipgirl('Tordenskjold',3920,[[210,2],[120,6],[76,6],[37,6]],[178,203],17,14.78,[[2,450]]),
  new Shipgirl('Tordenskjold',3920,[[210,2],[120,6],[76,6],[37,6]],[178,203],17,14.78,[[2,450]]),
  new Shipgirl('Harald Haarfagre',3858,[[210,2],[120,6],[76,6],[37,6]],[178,203],16.9,14.78,[[2,450]]),
  new Shipgirl('Eidsvol',4233,[[210,2],[150,6],[76,6],[76,2],[20,2],[12.7,2],[7.92,4]],[152.4,228.6],17.2,15.7,[[450,2]]),
  new Shipgirl('Norge',4233,[[210,2],[150,6],[76,6],[76,2],[20,2],[12.7,2],[7.92,4]],[152.4,228.6],17.2,15.7,[[450,2]]),
  new Shipgirl('Sverige',7688,[[283,4],[152,8],[75,4],[75,2],[57,2],[6.5,2]],[200,200,100,28],22.5,18.63,[[450,2]]),
  new Shipgirl('Ilmarinen',3900,[[254,4],[105,8],[40,4],[20,2]],[55,100,120,20,30],14.5,16.864,[[0,0]]),
  new Shipgirl('Laforey',1026,[[102,3],[37,2]],[6],29,8.43,[[4,533]]),
  new Shipgirl('Mikasa',15380,[[305,4],[152,14],[76,20],[47,12]],[229,76,254,356,356,152],18,23.2,[[4,450]]),
  new Shipgirl('Royal Sovereign',14380,[[342,4],[152,10],[57,10],[47,12]],[457,406,432,152,356,76],17.5,22.9,[[450,7]]),
  new Shipgirl('Deutschland',14218,[[280,4],[170,14],[88,22]],[225,280,40],18,22.2,[[450,6]]),
  new Shipgirl('Lamberton',1090,[[102,4],[76,2]],[6],35,9.7,[[0,0]]),
  new Shipgirl('Draug',587,[[76,6]],[19],26.5,7.3,[[457,3]])]*/
  //saveJSON(JSON.parse(JSON.stringify(this.Ships)))
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

