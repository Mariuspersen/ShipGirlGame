function MainMenu() {
    this.state = 0;
    this.currentBattle;
    this.options = [];
    
    this.draw = function() {
        image(battleBackground, 0, 0, width, height);
        
        this.options.map(x => {
            x.isHighlighted = (x.xPos < mouseX && x.yPos < mouseY && mouseX < x.xPos + x.xSize && mouseY < x.yPos + x.ySize);
          })
          push()
          textAlign(CENTER, CENTER)
        this.options.forEach(x => x.draw())
        pop()
        
    }

    this.delegator = function (event) {
        //0 = mouseMoved,1 = mouseClicked, 2 = keyPressed
        //console.log(this.state,event)
        switch (this.state) {
            case 0:
                switch (event) {
                    case 0:
                        this.draw();
                        break;
                    case 1:
                        let option = this.options.reduce(x => x.isHighlighted)
                        if(option.length != 0 && option.isHighlighted) {
                            switch (this.options.indexOf(option)) {
                                case 0:
                                    let Fleet1 = new Array(6).fill().map(x => new Shipgirl(random(Ships)))
                                    let Fleet2 = new Array(6).fill().map(x => new Shipgirl(random(Ships)))
                                    this.currentBattle = new Battle(Fleet1,Fleet2,2)
                                    this.currentBattle.Draw();
                                    this.state = 1;
                                    break;
                            }
                        }
                        break;
                }
                break;
            case 1:
                switch (event) {
                    case 0:
                        this.currentBattle.stateManager(0);
                        break;
                    case 1:
                        this.currentBattle.stateManager(1);
                        break;
                    case 2:
                        if(this.currentBattle.stateManager(2)) {
                            this.state = 0;
                            this.currentBattle = undefined;
                            this.draw();
                        }
                        break;
                    default:
                        break;
                }
                break;
        }
    }

    this.option = function(_text,_textSize,_xPos,_yPos,_xSize,_ySize) {
        this.text = _text;
        this.textSize = _textSize;
        this.xPos = _xPos - (_xSize / 2);
        this.yPos = _yPos - (_ySize / 2);
        this.xSize = _xSize;
        this.ySize = _ySize;
        this.isHighlighted;

        this.draw = function() {
            fill(172, 110, 96, 200);
            rect(this.xPos,this.yPos,this.xSize,this.ySize);
            if (this.isHighlighted) {
                strokeWeight(1);
                fill(172, 110, 96, 200);
                rect(this.xPos, this.yPos, this.xSize, this.ySize);
              }
              strokeWeight(1)
              fill(0);
              textSize(this.textSize)
              text(this.text, this.xPos + (this.xSize / 2),this.yPos + (this.ySize / 2));
        }
    }
    this.options.push(new this.option('Play',32,width / 2,height /2,200,80))
}