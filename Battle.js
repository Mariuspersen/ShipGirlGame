function Battle(Fleet1, Fleet2, MapSize) {
  this.PlayerFleet = Fleet1;
  this.EnemyFleet = Fleet2;
  this.EnemyCurrentLocation = [];
  this.Reduced = reduce(width, height);
  this.xSize = (((MapSize + (this.Reduced.reduce((a, b) => a == b) == 20) + (this.Reduced.reduce((a, b) => a == b) * 3)) * this.Reduced[0]) - this.Reduced[1]);
  this.ySize = Math.round(this.xSize * (height / width));
  this.xOffsetMultiplier = (width / this.xSize);
  this.yOffsetMultiplier = (height / this.ySize);
  this.Nodes = [];
  this.LineofBattle = false;
  this.LoBEnemy = false;
  this.CalculateBaseActions = (fleet) => Math.floor(Math.min(...fleet.map(x => x.Speed))*(this.xSize*.02))
  this.startingActionsPlayerFleet = this.CalculateBaseActions(this.PlayerFleet)
  this.startingActionsEnemyFleet = this.CalculateBaseActions(this.EnemyFleet)
  this.HUD = new UI(this.startingActionsPlayerFleet,this.startingActionsEnemyFleet);
  this.highlightedNode = undefined;
  this.coords = new Array(2).fill();
  this.state = 0;
  this.count = 0;
  this.damage = undefined;
  this.location = undefined;
  this.selectedNode = undefined;
  this.tempNodes = undefined;
  this.angle = undefined;

  for (let i = 0; this.ySize < this.PlayerFleet.length; i++) {
    this.PlayerFleet.pop();
  }
  this.PlayerFleet[0].isFlagship = true;
  this.PlayerFleet = this.PlayerFleet.map(x => {
    x.isEnemy = false;
    return x;
  })

  this.EnemyFleet = this.EnemyFleet.map(x => {
    x.isEnemy = true;
    return x;
  })

  //CreateNodes
  {
    for (let i = 0; i < this.xSize; i++) {
      this.Nodes.push([]);
      for (let j = 0; j < this.ySize; j++) {
        this.Nodes[i][j] = (new Node(i * this.xOffsetMultiplier, j * this.yOffsetMultiplier, this.xOffsetMultiplier, this.yOffsetMultiplier,i,j));
      }
    }
    {
      //Ah, yes, australia noiseSeed(698)
      noiseDetail(3, 0.8);
      for (let i = 3; i < this.Nodes.length - 3; i++) {
         for (let j = 2; j < this.Nodes[i].length - 2; j++) {
           if (.88 < noise(i*0.1,j*0.1))
             this.Nodes[i][j].setTexture()
         }
       }
    }

    CreateIsland(0,this.Nodes);

    //Fill in nodes with the player ships
    let spawnOffset = Math.ceil((this.ySize / 2) - (this.PlayerFleet.length / 2));
    for (let i = 0; i < this.PlayerFleet.length; i++) {
      this.PlayerFleet[i].xCord = 0;
      this.PlayerFleet[i].yCord = i+spawnOffset;
      this.Nodes[0][i+spawnOffset].Update(this.PlayerFleet[i]);
    }

    //Fill in mirrored enemy ships
    spawnOffset = Math.ceil(this.ySize / 2 - this.EnemyFleet.length / 2);
    for (i = 0; i < this.EnemyFleet.length; i++) {
      this.EnemyFleet[i].xCord = this.Nodes.length -1;
      this.EnemyFleet[i].yCord = i+spawnOffset;
      this.Nodes[this.Nodes.length -1][i+spawnOffset].Update(this.EnemyFleet[i]);
    }
    this.EnemyAI = new AI(this.EnemyFleet,this.Nodes,this.PlayerFleet);
  }
  this.Draw = function() {
    image(battleBackground, 0, 0, width, height);
    //Find which nodes are visable to the player fleet
    for (let i = 0; i < this.Nodes.length; i++) {
      for (let j = 0; j < this.Nodes[i].length; j++) {
        for (let k = 0; k < this.PlayerFleet.length; k++) {
            if((this.Nodes[this.PlayerFleet[k].xCord][this.PlayerFleet[k].yCord].CenterPoint.dist(this.Nodes[i][j].CenterPoint)) * 2 < (this.PlayerFleet[k].LineofSight * Math.floor(this.xOffsetMultiplier)))
              this.Nodes[i][j].NodeVisable = true;
          }
        }
      }
    let sunk = this.EnemyFleet.filter(x => x.combatHP < 0)
    this.EnemyFleet = this.EnemyFleet.filter(x => x.combatHP > 0)
    sunk.forEach(x => this.Nodes[x.xCord][x.yCord].Ship = undefined)
    //Draw nodes
    this.Nodes.forEach(x => x.forEach(x  => x.Draw()));
    this.HUD.Draw();
    if(this.count > 0)
    {
      fill(255,0,0)
      textSize(32)
      textAlign(CENTER)
      text(`${this.damage}`,this.location.x,this.location.y)
      textAlign(LEFT)
      this.count--
    }
  }

  this.updateDisplayDamage = function(x,y) {
      this.count = 100;
      this.damage = x;
      this.location = y;

  }

  this.FleetUpdatePosition = function (keyCodePressed,fleet) {
    let moveSuccsess = true;
    let tempPos = fleet.map(x => JSON.parse(JSON.stringify([x.xCord, x.yCord])));
    switch (this.LineofBattle||this.LoBEnemy&&fleet[0].isEnemy) {
      case false:
        let reverseNeeded = false;
        if (fleet[0].xCord > fleet[1].xCord || fleet[0].yCord > fleet[1].yCord) {
          fleet.reverse();
          tempPos.reverse();
          reverseNeeded = true;
        }
        switch (keyCodePressed) {
          case UP_ARROW:
            if (fleet[0].yCord != 0 && !this.Nodes[fleet[0].xCord][fleet[0].yCord - 1].unNavigable) {
              let obstructions = true;
              for (let i = 0; i < fleet.length; i++) {
                if (this.Nodes[fleet[i].xCord][fleet[i].yCord - 1].Ship ? this.Nodes[fleet[i].xCord][fleet[i].yCord - 1].Ship?.isEnemy !== this.Nodes[fleet[i].xCord][fleet[i].yCord].Ship?.isEnemy : false || this.Nodes[fleet[i].xCord][fleet[i].yCord - 1].isLand) {
                  obstructions = false;
                }
              }
              if (obstructions) {
                for (let i = 0; i < fleet.length; i++) {
                  this.Nodes[fleet[i].xCord][fleet[i].yCord].MoveShipgirl(this.Nodes[fleet[i].xCord][--fleet[i].yCord]);
                }
              } else moveSuccsess = false;
            } else moveSuccsess = false;
            break;
          case DOWN_ARROW:
            if ((fleet[fleet.length - 1].yCord != this.Nodes[fleet[fleet.length - 1].xCord].length - 1) && fleet.length <= this.Nodes[0].length) {
              let obstructions = true;
              for (let i = fleet.length - 1; i >= 0; i--) {
                if (this.Nodes[fleet[i].xCord][fleet[i].yCord + 1].Ship ? this.Nodes[fleet[i].xCord][fleet[i].yCord + 1].Ship?.isEnemy !== this.Nodes[fleet[i].xCord][fleet[i].yCord].Ship.isEnemy : false ||  this.Nodes[fleet[i].xCord][1+fleet[i].yCord].isLand) {
                  obstructions = false;
                }
              }
              if (obstructions) {
                for (let i = fleet.length - 1; i >= 0; i--) {
                  this.Nodes[fleet[i].xCord][fleet[i].yCord].MoveShipgirl(this.Nodes[fleet[i].xCord][++fleet[i].yCord]);
                }
              } else moveSuccsess = false;
            } else moveSuccsess = false;

            break;
          case LEFT_ARROW:
            if (fleet[0].xCord != 0) {
              let obstructions = true;
              for (let i = 0; i < fleet.length; i++) {
                if (this.Nodes[fleet[i].xCord - 1][fleet[i].yCord].Ship ? this.Nodes[fleet[i].xCord - 1][fleet[i].yCord].Ship?.isEnemy !== this.Nodes[fleet[i].xCord][fleet[i].yCord].Ship.isEnemy : false || this.Nodes[fleet[i].xCord - 1][fleet[i].yCord].unNavigable)
                  obstructions = false;
              }
              if (obstructions) {
                for (var i = 0; i < fleet.length; i++) {
                  this.Nodes[fleet[i].xCord][fleet[i].yCord].MoveShipgirl(this.Nodes[--fleet[i].xCord][fleet[i].yCord]);
                }
              } else moveSuccsess = false;
            } else moveSuccsess = false;
            break;
          case RIGHT_ARROW:
            if (fleet[0].xCord != this.Nodes.length - 1) {
              let obstructions = true;
              for (let i = fleet.length - 1; i >= 0; i--) {
                if (this.Nodes[1 + fleet[i].xCord][fleet[i].yCord].unNavigable || this.Nodes[1 + fleet[i].xCord][fleet[i].yCord].Ship ? this.Nodes[1 + fleet[i].xCord][fleet[i].yCord].Ship?.isEnemy !== this.Nodes[fleet[i].xCord][fleet[i].yCord].Ship?.isEnemy : false)
                  obstructions = false;   
              }
              if (obstructions) {
                for (let i = fleet.length - 1; i >= 0; i--) {
                  this.Nodes[fleet[i].xCord][fleet[i].yCord].MoveShipgirl(this.Nodes[++fleet[i].xCord][fleet[i].yCord]);
                }
              } else moveSuccsess = false;
            } else moveSuccsess = false;
            break;
        }
        if (reverseNeeded) {
          fleet.reverse();
          tempPos.reverse();
        }
        break;
      case true:
        let moveNeeded = false;
        switch (keyCodePressed) {
          case UP_ARROW:
            if (fleet[0].yCord != 0) {
              if (!(this.Nodes[fleet[0].xCord][fleet[0].yCord - 1].unNavigable)) {
                moveNeeded = true;
                this.Nodes[fleet[0].xCord][fleet[0].yCord].MoveShipgirl(this.Nodes[fleet[0].xCord][--fleet[0].yCord]);
              }
            }
            break;
          case DOWN_ARROW:
            if (fleet[0].yCord != this.Nodes[0].length - 1) {
              if (!(this.Nodes[fleet[0].xCord][1 + fleet[0].yCord].unNavigable)) {
                moveNeeded = true;
                this.Nodes[fleet[0].xCord][fleet[0].yCord].MoveShipgirl(this.Nodes[fleet[0].xCord][++fleet[0].yCord]);
              }
            }
            break;
          case LEFT_ARROW:
            if (fleet[0].xCord != 0) {
              if (!(this.Nodes[fleet[0].xCord - 1][fleet[0].yCord].unNavigable)) {
                moveNeeded = true;
                this.Nodes[fleet[0].xCord][fleet[0].yCord].MoveShipgirl(this.Nodes[--fleet[0].xCord][fleet[0].yCord]);
              }
            }
            break;
          case RIGHT_ARROW:
            if (fleet[0].xCord != this.Nodes.length - 1) {
              if (!(this.Nodes[1 + fleet[0].xCord][fleet[0].yCord].unNavigable)) {
                moveNeeded = true;
                this.Nodes[fleet[0].xCord][fleet[0].yCord].MoveShipgirl(this.Nodes[++fleet[0].xCord][fleet[0].yCord]);
              }
            }
            break;
        }
        if (moveNeeded) {
          for (let i = 1; i < fleet.length; i++) {
            this.Nodes[fleet[i].xCord][fleet[i].yCord].MoveShipgirl(this.Nodes[tempPos[i - 1][0]][tempPos[i - 1][1]]);
            fleet[i].xCord = tempPos[i - 1][0];
            fleet[i].yCord = tempPos[i - 1][1];
          }
        } else moveSuccsess = false;
        break;
    }
    return moveSuccsess;
  }

  this.isFormationChangePossible = function(fleet) {
    let fleetInLineColumns = true;
    let fleetInLineRows = true;
    for (let i = 1; i < fleet.length; i++) {
      if (fleet[0].xCord != fleet[i].xCord)
        fleetInLineColumns = false;
      if (fleet[0].yCord != fleet[i].yCord)
        fleetInLineRows = false;
    }
    if (fleetInLineColumns || fleetInLineRows)
      return true;
    else
      return false;
  }

  this.HighlightNode = function (mouseVector) {
    let coords = new Array(2).fill();
    ResetVisability(this.Nodes, false, true, true);
    let shortestDist = [undefined, undefined];
    for (let i = 0; i < this.Nodes.length; i++) {
      for (let j = 0; j < this.Nodes[i].length; j++) {
        if (!shortestDist[0]) {
          shortestDist = [this.Nodes[i][j].CenterPoint.dist(mouseVector), this.Nodes[i][j]];
          this.coords = [i, j]
        } else if (shortestDist[0] > this.Nodes[i][j].CenterPoint.dist(mouseVector)) {
          shortestDist = [this.Nodes[i][j].CenterPoint.dist(mouseVector), this.Nodes[i][j]];
          this.coords = [i, j]
        }
      }
    }
    this.highlightedNode = shortestDist[1];
    shortestDist[1].Highlight = true;
    if (this.state === 0) {
      for (let i = 0; i < this.PlayerFleet.length; i++) {
        if (this.Nodes[this.PlayerFleet[i].xCord][this.PlayerFleet[i].yCord] == shortestDist[1]) {
          SetRange(this.Nodes, [shortestDist[1].Ship], this.xOffsetMultiplier);
        }
      }
    }
  }

  this.stateManager = function (event) {
    //0 = mouseMoved,1 = mouseClicked, 2 = keyPressed
    switch (event) {
      case 0:
        switch (this.state) {
          case 0:
            this.HighlightNode(createVector(mouseX, mouseY));
            this.Draw();
            break;
          case 1:
            this.HUD.Menu(this.highlightedNode, false, playerOptions);
            break;
          case 2:
            this.HighlightNode(createVector(mouseX, mouseY));
            this.Draw();
            break;
          case 3:
            this.HUD.Menu(this.highlightedNode, false, enemyOptions);
            break;
          case 4:
            this.HUD.Menu(this.highlightedNode, false, this.highlightedNode.Ship.Info(),true);
            break;
          case 5:
            this.Draw();
            let nodePoint = this.Nodes[this.PlayerFleet[0].xCord][this.PlayerFleet[0].yCord].CenterPoint.copy();
            let mousePoint = createVector(mouseX, mouseY);
            let pointerVector = p5.Vector.sub(mousePoint,nodePoint)
            push()
            fill(255,0,0)
            translate(nodePoint.x,nodePoint.y)
            this.angle = Math.atan2(pointerVector.y,pointerVector.x);
            rotate(this.angle + HALF_PI) 
            imageMode(CENTER)
            image(pointer, 0, 0 - 50)
            pop()
          break;
        }
        break;
      case 1:
        if (this.highlightedNode.Ship && this.HUD.Actions > 0)
          switch (this.state) {
            case 0:
              if (!this.highlightedNode.Ship.isEnemy) {
                this.state = 1;
                this.HUD.Menu(this.highlightedNode, true, playerOptions)
              }
              break;
            case 1:
              switch (this.HUD.Menu(this.highlightedNode, true, playerOptions)) {
                case 0:
                  this.state = 5;
                  break;
                case 1:
                  this.state = 2;
                  rangeMap = this.Nodes.map(x => x.map(x => x.inRange));
                  selectedNode = this.highlightedNode
                  break;
                case 3:
                  if (this.highlightedNode.Ship)
                    this.HUD.Menu(this.highlightedNode, false, this.highlightedNode.Ship.Info(),true);
                  this.state = 4;
                  break;
                default:
                  this.state = 0;
                  this.Draw();
                  break;
              }
              break;
            case 2:
              if (this.highlightedNode.Ship.isEnemy) {
                this.state = 3;
                this.HUD.Menu(this.highlightedNode, true, enemyOptions)
              }
              break;
            case 3:
              switch (this.HUD.Menu(this.highlightedNode, true, enemyOptions)) {
                case 0:
                  let dealtDamage = selectedNode.Ship.FireGuns(this.highlightedNode.Ship, rangeMap[this.coords[0]][this.coords[1]])
                  this.HUD.Actions--;
                  this.state = 0;
                  this.Draw();
                  if (typeof dealtDamage[0] == 'number') {
                    this.updateDisplayDamage(dealtDamage[0], this.highlightedNode.CenterPoint)
                  } else this.HUD.currentInfo = dealtDamage;
                  if(dealtDamage.length > 1)
                    this.HUD.currentInfo = dealtDamage[1];
              }
              case 4:
                this.Draw();
                this.state = 0;
                break;
              case 5:
                let direction;
                if (this.angle > -QUARTER_PI && this.angle < QUARTER_PI)
                  direction = RIGHT_ARROW;
                else if (this.angle > QUARTER_PI && this.angle < HALF_PI + QUARTER_PI)
                  direction = DOWN_ARROW;
                else if (this.angle > - HALF_PI - QUARTER_PI && this.angle < -QUARTER_PI)
                  direction = UP_ARROW;
                else direction = LEFT_ARROW
                if (direction) {
                  //let indx = this.PlayerFleet.indexOf(this.highlightedNode.Ship);
                  if (this.FleetUpdatePosition(direction, this.PlayerFleet)) {
                    //this.PlayerFleet[indx].turnUsed = true;
                    this.HUD.Actions--;
                  }
                  this.state = 0;
                  this.Draw();
                }
                break;
          }
        break;
      case 2:
         if (keyCode === UP_ARROW || keyCode === DOWN_ARROW || keyCode === LEFT_ARROW || keyCode === RIGHT_ARROW) {
           if(this.FleetUpdatePosition(this.EnemyAI.DoTurn(this.Nodes[this.EnemyFleet[0].xCord][this.EnemyFleet[0].yCord],this.Nodes[this.PlayerFleet[0].xCord][this.PlayerFleet[0].yCord]),this.EnemyFleet)) {
             this.HUD.baseActionsEnemy--
           }
           else {
             if (this.isFormationChangePossible(this.EnemyFleet))
              this.LoBEnemy = !this.LoBEnemy
             this.FleetUpdatePosition(this.EnemyAI.DoTurn(this.Nodes[this.EnemyFleet[0].xCord][this.EnemyFleet[0].yCord],this.Nodes[this.PlayerFleet[0].xCord][this.PlayerFleet[0].yCord],this.EnemyFleet),this.EnemyFleet);
           }
            this.Draw();
            console.log(this.LineofBattle)
          }
        if (keyCode === ENTER) {
          if (this.isFormationChangePossible(this.PlayerFleet)) {
            this.LineofBattle = !this.LineofBattle;
            this.HUD.currentInfo = `Line of Battle: ${this.LineofBattle ? "Enabled" : "Disabled"}`
          } else {
            textSize(32);
            fill(255)
            textAlign(CENTER);
            text('Fleet needs to be in a single line to change formation', width / 2, height / 2)
          }
          this.Draw();
        }
        else if(keyCode === 32 && this.HUD.Actions <= 0)
        {
          this.HUD.Actions = ++this.HUD.baseActions;
          this.PlayerFleet.map(x => x.turnUsed = false);
          this.Draw();
        }
        else if(keyCode === ESCAPE)
        {
          this.state = 0;
          this.Draw();
        }
        break;
      default:
        break;
    }
  }
}