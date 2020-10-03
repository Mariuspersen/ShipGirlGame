function Node(x, y, xsize, ysize,xcord,ycord) {
    this.xPos = x;
    this.yPos = y;
    this.xSize = xsize;
    this.ySize = ysize;
    this.xCord = xcord;
    this.yCord = ycord;
    this.CenterPoint = createVector(this.xPos + (this.xSize / 2), this.yPos + (this.ySize / 2));
    this.Ship = undefined;
    this.Torpedo = undefined;
    this.NodeVisable = false;
    this.inRange = false;
    this.Highlight = false;
    this.isLand = false;
    this.texture = undefined;
    this.unNavigable = false;
  
    this.Draw = function() {
      if(this.isLand) {
        image(this.texture, this.xPos, this.yPos, this.xSize, this.ySize);
      }
      noFill();
      stroke(0, 0, 100, 100);
      rect(this.xPos, this.yPos, this.xSize, this.ySize);
      
      if (this.inRange) {
        fill(0, 255, 0, 40)
        rect(this.xPos, this.yPos, this.xSize, this.ySize);
      }
      if (this.Highlight) {
          fill(255, 255, 0, 100);
          rect(this.xPos, this.yPos, this.xSize, this.ySize);
        }
      if (this.NodeVisable) {
        
        if (this.Ship != null) {
  
          if (!this.Ship.isEnemy) {
            image(this.Ship.Chibi, this.xPos, this.yPos, this.xSize, this.ySize);
            tint(0, 0, 255, 200);
            image(this.Ship.Chibi, this.xPos, this.yPos, this.xSize, this.ySize);
            noTint();
          } else {
            push();
            scale(-1, 1);
            image(this.Ship.Chibi, -this.xPos, this.yPos, -this.xSize, this.ySize);
            tint(255, 0, 0, 150);
            image(this.Ship.Chibi, -this.xPos, this.yPos, -this.xSize, this.ySize);
            noTint();
            pop();
          }
          let HPmap = map(this.Ship.combatHP,0,this.Ship.Healthpoints,this.xSize-this.xSize,this.xSize)
          let HPmapR = map(this.Ship.combatHP,0,this.Ship.Healthpoints,255,0);
          let HPmapG = map(this.Ship.combatHP,0,this.Ship.Healthpoints,0,255);
            fill(HPmapR,HPmapG,0)
            if(HPmap > 0)
            rect(this.xPos,this.yPos + this.ySize,HPmap,-this.ySize*.2);
        }
        
      } else {
        fill(0, 0, 0, 200)
        rect(this.xPos, this.yPos, this.xSize, this.ySize);
      }
    }
    this.Update = function(Shipgirl) {
      this.Ship = Shipgirl;
      this.unNavigable = true;
    }
    this.MoveShipgirl = function(newNode) {
      newNode.Ship = this.Ship;
      this.Ship = undefined;
      this.unNavigable = false;
      newNode.unNavigable = true;
    }
  
    this.setTexture = function(texture)
    {
      this.isLand = true;
      this.texture = IslandGeneration[texture] || IslandGeneration[0];
      this.unNavigable = true;
    }
  }
  
  function ResetVisability(Nodes,resetVisable,resetRange,resetHighlight) {
    for (var x = 0; x < Nodes.length; x++) {
      for (var y = 0; y < Nodes[x].length; y++) {
        if(resetVisable)
          Nodes[x][y].NodeVisable = false;
        if(resetRange)
          Nodes[x][y].inRange = false;
        if(resetHighlight)
          Nodes[x][y].Highlight = false;
      }
    }
  }
  
  function reduce(numerator, denominator) {
    let gcd = function gcd(a, b) {
      return b ? gcd(b, a % b) : a;
    };
    gcd = gcd(numerator, denominator);
    return [numerator / gcd, denominator / gcd];
  }
  
  function SetRange(Nodes, PlayerFleet, xOffsetMultiplier) {
    for (let i = 0; i < Nodes.length; i++) {
      for (let j = 0; j < Nodes[i].length; j++) {
        for (let k = 0; k < PlayerFleet.length; k++) {
          if ((Nodes[PlayerFleet[k].xCord][PlayerFleet[k].yCord].CenterPoint.dist(Nodes[i][j].CenterPoint)) * 2 < (PlayerFleet[k].Range * Math.floor(xOffsetMultiplier)))
            Nodes[i][j].inRange = true;      
        }
      }
    }
  }
  