function CreateIsland(_Size, _Nodes) {
    let seed = [].concat.apply([], _Nodes.map(x => x.filter(y => y.isLand)).filter(z => z.length != 0));
    let controlNodes = [];
    //console.log(seed)


    for (let i = 0; i < _Nodes.length; i++) {
        controlNodes.push([])
        for (let j = 0; j < _Nodes[i].length; j++) {
            controlNodes[i].push(0)
        }
    }

    for (let i = 0; i < seed.length; i++) {
        for (let j = -1; j < 2; j++) {
            for (let k = -1; k < 2; k++) {
                if (!_Nodes[seed[i].xCord + j][seed[i].yCord + k].isLand || (j == 0 && k == 0)) {
                    if (j == -1 && k == -1)
                        controlNodes[seed[i].xCord + j][seed[i].yCord + k] = controlNodes[seed[i].xCord + j][seed[i].yCord + k] | 2
                    if (j == -1 && k == 0)
                        controlNodes[seed[i].xCord + j][seed[i].yCord + k] = controlNodes[seed[i].xCord + j][seed[i].yCord + k] | 6
                    if (j == -1 && k == 1)
                        controlNodes[seed[i].xCord + j][seed[i].yCord + k] = controlNodes[seed[i].xCord + j][seed[i].yCord + k] | 4
                    if (j == 0 && k == -1)
                        controlNodes[seed[i].xCord + j][seed[i].yCord + k] = controlNodes[seed[i].xCord + j][seed[i].yCord + k] | 3
                    if (j == 0 && k == 0)
                        controlNodes[seed[i].xCord + j][seed[i].yCord + k] = controlNodes[seed[i].xCord + j][seed[i].yCord + k] | 15
                    if (j == 0 && k == 1)
                        controlNodes[seed[i].xCord + j][seed[i].yCord + k] = controlNodes[seed[i].xCord + j][seed[i].yCord + k] | 12
                    if (j == 1 && k == -1)
                        controlNodes[seed[i].xCord + j][seed[i].yCord + k] = controlNodes[seed[i].xCord + j][seed[i].yCord + k] | 1
                    if (j == 1 && k == 0)
                        controlNodes[seed[i].xCord + j][seed[i].yCord + k] = controlNodes[seed[i].xCord + j][seed[i].yCord + k] | 9
                    if (j == 1 && k == 1)
                        controlNodes[seed[i].xCord + j][seed[i].yCord + k] = controlNodes[seed[i].xCord + j][seed[i].yCord + k] | 8
                }
            }
        }
    }

    for (let i = 0; i < _Nodes.length; i++) {
        for (let j = 0; j < _Nodes[i].length; j++) {
            switch (controlNodes[i][j]) {
                case 1:
                    _Nodes[i][j].setTexture(11)
                    break;
                case 2:
                    _Nodes[i][j].setTexture(7)
                    break;
                case 3:
                    _Nodes[i][j].setTexture(3)
                    break;
                case 4:
                    _Nodes[i][j].setTexture(13)
                    break;
                case 5:
                    _Nodes[i][j].setTexture(9)
                    break;
                case 6:
                    _Nodes[i][j].setTexture(5)
                    break;
                case 7:
                    _Nodes[i][j].setTexture(1)
                    break;
                case 8:
                    _Nodes[i][j].setTexture(14)
                    break;
                case 9:
                    _Nodes[i][j].setTexture(10)
                    break;
                case 10:
                    _Nodes[i][j].setTexture(6)
                    break;
                case 11:
                    _Nodes[i][j].setTexture(2)
                    break;
                case 12:
                    _Nodes[i][j].setTexture(12)
                    break;
                case 13:
                    _Nodes[i][j].setTexture(8)
                    break;
                case 14:
                    _Nodes[i][j].setTexture(4)
                    break;
                case 15:
                    _Nodes[i][j].setTexture(0)
                    break;
            }
        }
    }
}