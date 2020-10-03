function UI(startingActions) {
  this.baseActions = startingActions;
  let offSet = 50;
  this.Actions = this.baseActions || 6;
  this.Turn = 0;
  this.currentInfo = '';

  this.Draw = function () {
    let cirlceText;
    push()

    strokeWeight(7)
    stroke(172, 110, 96, 200)
    fill(255, 225, 210, 200);
    circle(offSet, height - offSet, 250)
    if (this.Actions > 0) {
      cirlceText = this.Actions
      textSize(100)
      textAlign(CENTER, CENTER)
      text(cirlceText, offSet +20, height - offSet)
    } else {
      cirlceText = "Next"
      textSize(70)
      textAlign(LEFT, CENTER)
      text(cirlceText, 4, height - 60)
      strokeWeight(2)
      textSize(20)
      textAlign(CENTER, CENTER)
      text("Press SPACEBAR to finish turn",width/2,height -20)
    }
    strokeWeight(2)
    textSize(20)
    textAlign(RIGHT, CENTER)
    text(this.currentInfo,width - 20,height -20)
    pop()
  }

  this.Menu = function (givenNode, mouseClick, options) {
    this.tempOptions = options;
    let menuOptions = this.tempOptions.map(x => {
      let currentIndex = this.tempOptions.indexOf(x);
      return new this.menuOption(x, (currentIndex + 1) * 30, currentIndex)
    })
    if (givenNode.Ship) {
      let adjX = givenNode.CenterPoint.x + ((givenNode.CenterPoint.x + 200 > width) * -200);
      let adjY = givenNode.CenterPoint.y + ((givenNode.CenterPoint.y + 200 > height) * -200);
      push()
      translate(adjX, adjY);
      strokeWeight(10)
      stroke(172, 110, 96)
      fill(255, 225, 210);
      rect(0, 0, 200, menuOptions.length * 30 + 20);
      menuOptions.map(x => {
        x.isHighlighted = (adjX + x.Pos.x < mouseX && adjY + x.Pos.y < mouseY && mouseX < adjX + x.Pos.x + x.Size.x && mouseY < adjY + x.Pos.y + x.Size.y);
      })
      menuOptions.forEach((x, i) => x.Draw());
      pop()
    }
    if (mouseClick && menuOptions.reduce((a, x) => a.isHighlighted ? a : x).isHighlighted) {
      return menuOptions.reduce((a, x) => a.isHighlighted ? a : x).Index;
    }
  }

  this.menuOption = function (name, pos, index) {
    this.Index = index
    this.Name = name;
    this.Pos = createVector(10, pos - 20);
    this.Size = createVector(180, 30)
    this.isHighlighted = false;

    this.Draw = function () {
      if (this.isHighlighted) {
        strokeWeight(1);
        fill(172, 110, 96, 200);
        rect(this.Pos.x, this.Pos.y, this.Size.x, this.Size.y);
      }
      strokeWeight(1)
      fill(0)
      textSize(20)
      text(this.Name, 15, this.Pos.y + 22);
    }
  }
}