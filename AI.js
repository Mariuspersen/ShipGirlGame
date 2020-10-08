function AI(_controlFleet,_Nodes,_opposingFleet,_xOffsetMult) {
    this.Fleet = _controlFleet;
    this.Target = _opposingFleet;
    this.Nodes = _Nodes;
    this.xOffsetMult =_xOffsetMult;
    //A* Related
    Array.prototype.remove = function(item){this.splice(this.indexOf(item),1)}    
    this.openSet = [];
    this.closedSet = [];
    this.start = this.Nodes[this.Fleet[0].xCord][this.Fleet[0].yCord];
    this.end = this.Nodes[this.Target[0].xCord][this.Target[0].yCord];
    this.path;

    this.DoTurn = function (_updateStart, _updateEnd,_updateTarget,_updateFleet) {
        if (_updateEnd)
            this.end = _updateEnd;
        if (_updateStart)
            this.start = _updateStart;
        if(_updateTarget)
            this.Target = _updateTarget;
        if(_updateFleet)
            this.Fleet = _updateFleet;
        ResetVisability(this.Nodes, false, true, false);
        SetRange(this.Nodes, this.Fleet, this.xOffsetMult);
        let rangemap = this.Nodes.map(x => x.map(x => x.inRange))
        let _randTarget = random(this.Target)
        let notShot = this.Fleet.filter(x => !x.turnUsed)
        console.log(notShot.length)
        let damageDealt = random(notShot)?.FireGuns(_randTarget, rangemap[_randTarget.xCord][_randTarget.yCord])
        if(damageDealt === undefined || typeof damageDealt[0] !== 'number') {
            return this.Move();
        }
    }
    this.Move = function() {
        let moveTo = this.Astar(this.end);
        if (moveTo) {
            let direction;
            let pointerVector = p5.Vector.sub(moveTo.CenterPoint, this.Nodes[this.Fleet[0].xCord][this.Fleet[0].yCord].CenterPoint)
            push()
            translate(this.Nodes[this.Fleet[0].xCord][this.Fleet[0].yCord].CenterPoint.x, this.Nodes[this.Fleet[0].xCord][this.Fleet[0].yCord].CenterPoint.y)
            let Angle = Math.atan2(pointerVector.y, pointerVector.x)
            pop()
            if (Angle > -QUARTER_PI && Angle < QUARTER_PI)
                direction = RIGHT_ARROW;
            else if (Angle > QUARTER_PI && Angle < HALF_PI + QUARTER_PI)
                direction = DOWN_ARROW;
            else if (Angle > -HALF_PI - QUARTER_PI && Angle < -QUARTER_PI)
                direction = UP_ARROW;
            else direction = LEFT_ARROW
            if (direction)
                return direction;
        } else console.log("no Path")
    }

    this.Astar = function(_endGoal) {
        this.closedSet = [];
        let path = [];
        let tempG = 0;
        this.openSet.push(this.start);
        let current;
        while(this.openSet.length > 0) {
            let iMin = 0;
            for (let i = 0; i < this.openSet.length; i++) {
                if(this.openSet[i].f < this.openSet[iMin].f)
                iMin = i;
            }
            current = this.openSet[iMin];
            if (current.xCord === _endGoal.xCord && current.yCord === _endGoal.yCord) {
                let temp = current;
                push()
                while (temp.previous) {
                    path.push(temp.previous);
                    temp = temp.previous;
                    
                    strokeWeight(12)
                    stroke(255,0,0)
                    point(this.Nodes[temp.xCord][temp.yCord].CenterPoint);
                    
                    
                }
                //stroke(0,255,0)
                //point(this.Nodes[path[path.length -2]?.xCord][path[path.length -2]?.yCord]?.CenterPoint)
                pop();
                this.openSet = [];
                this.Nodes.forEach(x => {x.forEach ( y => y.ResetAstar())});
                //console.log(path[path.length -1])
                return path[path.length -2]
            }
            this.openSet.remove(current);
            this.closedSet.push(current);
            if (current.Neighbours.length == 0) {
                if (current.xCord != _Nodes.length - 1)
                    current.Neighbours.push(_Nodes[current.xCord + 1][current.yCord])
                if (current.xCord != 0)
                    current.Neighbours.push(_Nodes[current.xCord - 1][current.yCord]);
                if (current.yCord != _Nodes[0].length - 1)
                    current.Neighbours.push(_Nodes[current.xCord][current.yCord + 1])
                if (current.yCord != 0)
                    current.Neighbours.push(_Nodes[current.xCord][current.yCord - 1]);
            }
            for (let i = 0; i < current.Neighbours.length; i++) {
                let neighbour = current.Neighbours[i];
                if(!this.closedSet.includes(neighbour,0) && !neighbour.isLand) {
                    tempG = current.g + this.Distance(neighbour,current);
                    let betterPath = false;
                    if(this.openSet.includes(neighbour)) {
                        if(tempG < neighbour.g) {
                            neighbour.g = tempG;
                            betterPath = true;
                        }
                    }
                    else {
                        neighbour.g = tempG;
                        this.openSet.push(neighbour);
                        betterPath = true;
                    }
                    if(betterPath) {
                        neighbour.h = this.Distance(neighbour,_endGoal)
                        neighbour.f = neighbour.g + neighbour.h;
                        //console.log(current)
                        neighbour.previous = current;
                    }
                }
            }            
        }
        this.Nodes.forEach(x => {x.forEach ( y => y.ResetAstar())});
                //console.log(path.length)
                return path[path.length -1]
    }
    this.Distance = function(a,b) {
        //console.log(Math.abs(a.xCord - b.xCord) + Math.abs(a.yCord - b.yCord))
        return Math.abs(a.xCord - b.xCord) + Math.abs(a.yCord - b.yCord)
    }
}