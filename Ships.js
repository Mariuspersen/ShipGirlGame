const sum = (accumulator, item) => accumulator + item;
const multiplyArray = (item) => item[0] * item[1];
//Ship name without Navy Prefix
//Highest known Displacement, in metric tons 
//Guns format should be 2D array with x being calibre and y being number of guns
//Armour should be 2D Array with x being Position of Armour and y being armour value
//Highest known speed, even if it's a trail number with no guns or anything onboard
function Shipgirl(Shipname, Displacement, Guns, Armour, Speed, Beam, Torpedoes) {
  //Base Stats
  this.Name = typeof Shipname === 'object' ? Shipname.Name : Shipname;
  this.Healthpoints = Displacement && Armour ? Math.floor(Displacement + Armour.reduce(sum)) : Shipname.Healthpoints;
  this.Firepower = Guns ? Math.floor(Guns.map(multiplyArray).reduce(sum)) : Shipname.Firepower;
  this.TorpedoPower = Torpedoes ? Math.floor(Torpedoes.map(multiplyArray).reduce(sum)) : Shipname.TorpedoPower;
  this.Armour = Armour ? Math.max(...Armour) : Shipname.Armour;
  this.Speed = Speed ? Speed : Shipname.Speed;
  this.LineofSight = Beam ? Math.floor(Math.sqrt(13 * (Beam * 1.5))) : Shipname.LineofSight;
  this.Range = Guns ? Math.floor((Math.max(...Guns[0]) * 76.2) / 1000) : Shipname.Range
  this.combatHP = this.Healthpoints;
  this.xCord = undefined;
  this.yCord = undefined;
  this.isEnemy = undefined;
  this.turnUsed = false;
  this.isFlagship = false;


  this.Info = function(){
    return [`${this.Name}`,`HP: ${this.combatHP}`,`FP: ${this.Firepower}`,`TP: ${this.TorpedoPower}`,`Armour: ${this.Armour}`,`Speed: ${this.Speed} knots`,`LoS: ${this.LineofSight}km`,`Range: ${this.Range}km`];
  }

  this.FireGuns = function(Enemy, inRange){
    if(inRange)
    {
    let DamageDealt = Math.floor(this.Firepower + Enemy.Armour);
    Enemy.combatHP = Enemy.combatHP - DamageDealt;
    this.turnUsed = true;
    return [DamageDealt,`${this.Name} inflicted ${DamageDealt} damage to ${Enemy.Name}! `];
    }
    else return `${Enemy.Name} is out of range!`;
  }

  /*this.LaunchTorpedo(n,v) = function(){
    return function(){
        this.dirVector = v
        this.currentNode = n;
    }
  }
  */
  
}