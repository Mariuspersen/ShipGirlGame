class IslandGenerator {
    tiles
    tileset
    tilesize
    constructor(tiles, tileset, tilesize) {
        this.tiles = tiles
        this.tileset = tileset
        this.tilesize = tilesize
    }
    generate() {
        for (let x = 0; x < this.tiles.length; x++)
            for (let y = 0; y < this.tiles[x].length; y++) {
                const element = this.tiles[x][y];
                this.initialize_tile(element)
            }
    }
    remove() {
        for (let x = 0; x < this.tiles.length; x++)
            for (let y = 0; y < this.tiles[x].length; y++) {
                const element = this.tiles[x][y];
                element.image = undefined;
            }
    }
    initialize_tile(tile) {
        if (tile.intensity < .23) {
            tile.image = this.tileset[4]
        }
        else if (tile.intensity < .27) {
            tile.image = this.tileset[3]
        }
        else if (tile.intensity < .31) {
            tile.image = this.tileset[2]
        }
        else if (tile.intensity < .36) {
            tile.image = this.tileset[0]
        }
    }
    generate_fade() {
        const webgl_canvas = document.createElement("canvas")
        webgl_canvas.height = this.tilesize
        webgl_canvas.width = this.tilesize
        const gl = webgl_canvas.getContext("webgl")

        gl.enable(gl.BLEND)
        gl.blendFunc(gl.ONE, gl.CONSTANT_ALPHA)

        const grass_tiles = this.tiles.map(x => x.filter(y => y.image == this.tileset[5]))
        
        grass_tiles.forEach(x => x.forEach(y => {
            const index = y.get_index()
            const north = this.tiles[index.x]?.[index.y - 1]
            const south = this.tiles[index.x]?.[index.y + 1]
            const west = this.tiles[index.x - 1]?.[index.y]
            const east = this.tiles[index.x + 1]?.[index.y]

            gl.clearColor(.0, .0, .0, .0)
            gl.clear(gl.COLOR_BUFFER_BIT)
            this.render(gl,
                north?.image || this.tileset[4],
                south?.image || this.tileset[4],
                west?.image || this.tileset[4],
                east?.image || this.tileset[4],
                this.tilesize
            )
            y.fade.src = webgl_canvas.toDataURL()
        }))

        /*for (let x = 0; x < this.tiles.length; x++)
            for (let y = 0; y < this.tiles[x].length; y++) {
                const north = this.tiles[x]?.[y - 1]
                const south = this.tiles[x]?.[y + 1]
                const west = this.tiles[x - 1]?.[y]
                const east = this.tiles[x + 1]?.[y]
                const current = this.tiles[x][y]

                gl.clearColor(.0, .0, .0, .0)
                gl.clear(gl.COLOR_BUFFER_BIT)

                this.render(gl,
                    north?.image || this.tileset[5],
                    south?.image || this.tileset[5],
                    west?.image || this.tileset[5],
                    east?.image || this.tileset[5],
                    this.tilesize
                )
                current.fade.src = webgl_canvas.toDataURL()
            }
        */
    }
    //Stolen from https://webglfundamentals.org/webgl/lessons/webgl-2-textures.html
    render(gl, north, south, west, east) {

        // setup GLSL program
        var program = this.createProgram(gl, assets.vert, assets.frag)
        gl.useProgram(program);

        // look up where the vertex data needs to go.
        var positionLocation = gl.getAttribLocation(program, "a_position");
        var texcoordLocation = gl.getAttribLocation(program, "a_texCoord");

        // Create a buffer to put three 2d clip space points in
        var positionBuffer = gl.createBuffer();

        // Bind it to ARRAY_BUFFER (think of it as ARRAY_BUFFER = positionBuffer)
        gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
        // Set a rectangle the same size as the image.
        this.setRectangle(gl, 0, 0,this.tilesize, this.tilesize);

        // provide texture coordinates for the rectangle.
        var texcoordBuffer = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, texcoordBuffer);
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
            0.0, 0.0,
            1.0, 0.0,
            0.0, 1.0,
            0.0, 1.0,
            1.0, 0.0,
            1.0, 1.0,
        ]), gl.STATIC_DRAW);

        var textures = [north, south, west, east].map(image => {
            var texture = gl.createTexture();
            gl.bindTexture(gl.TEXTURE_2D, texture);

            // Set the parameters so we can render any size image.
            // gl.NEAREST is also allowed, instead of gl.LINEAR, as neither mipmap.
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
            // Prevents s-coordinate wrapping (repeating).
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
            // Prevents t-coordinate wrapping (repeating).
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

            // Upload the image into the texture.
            gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);

            // add the texture to the array of textures.
            return texture
        })

        // lookup uniforms
        var resolutionLocation = gl.getUniformLocation(program, "u_resolution");

        // lookup the sampler locations.
        var northLocation = gl.getUniformLocation(program, "north");
        var southLocation = gl.getUniformLocation(program, "south");
        var westLocation = gl.getUniformLocation(program, "west");
        var eastLocation = gl.getUniformLocation(program, "east");

        gl.viewport(0, 0, this.tilesize, this.tilesize);

        // Clear the canvas
        gl.clearColor(0, 0, 0, 0);
        gl.clear(gl.COLOR_BUFFER_BIT);

        // Tell it to use our program (pair of shaders)
        gl.useProgram(program);

        // Turn on the position attribute
        gl.enableVertexAttribArray(positionLocation);

        // Bind the position buffer.
        gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

        // Tell the position attribute how to get data out of positionBuffer (ARRAY_BUFFER)
        var size = 2;          // 2 components per iteration
        var type = gl.FLOAT;   // the data is 32bit floats
        var normalize = false; // don't normalize the data
        var stride = 0;        // 0 = move forward size * sizeof(type) each iteration to get the next position
        var offset = 0;        // start at the beginning of the buffer
        gl.vertexAttribPointer(
            positionLocation, size, type, normalize, stride, offset);

        // Turn on the texcoord attribute
        gl.enableVertexAttribArray(texcoordLocation);

        // bind the texcoord buffer.
        gl.bindBuffer(gl.ARRAY_BUFFER, texcoordBuffer);

        // Tell the texcoord attribute how to get data out of texcoordBuffer (ARRAY_BUFFER)
        var size = 2;          // 2 components per iteration
        var type = gl.FLOAT;   // the data is 32bit floats
        var normalize = false; // don't normalize the data
        var stride = 0;        // 0 = move forward size * sizeof(type) each iteration to get the next position
        var offset = 0;        // start at the beginning of the buffer
        gl.vertexAttribPointer(
            texcoordLocation, size, type, normalize, stride, offset);

        // set the resolution
        gl.uniform2f(resolutionLocation, this.tilesize, this.tilesize);

        // set which texture units to render with.
        gl.uniform1i(northLocation, 0);  // texture unit 0
        gl.uniform1i(southLocation, 1);  // texture unit 1
        gl.uniform1i(westLocation, 2);  // texture unit 2
        gl.uniform1i(eastLocation, 3);  // texture unit 3
        // Set each texture unit to use a particular texture.
        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(gl.TEXTURE_2D, textures[0]);
        gl.activeTexture(gl.TEXTURE1);
        gl.bindTexture(gl.TEXTURE_2D, textures[1]);
        gl.activeTexture(gl.TEXTURE2);
        gl.bindTexture(gl.TEXTURE_2D, textures[2]);
        gl.activeTexture(gl.TEXTURE3);
        gl.bindTexture(gl.TEXTURE_2D, textures[3]);

        // Draw the rectangle.
        gl.drawArrays(gl.TRIANGLES, 0, 6);
    }

    randomInt(range) {
        return Math.floor(Math.random() * range);
    }

    setRectangle(gl, x, y, width, height) {
        var x1 = x;
        var x2 = x + width;
        var y1 = y;
        var y2 = y + height;
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
            x1, y1,
            x2, y1,
            x1, y2,
            x1, y2,
            x2, y1,
            x2, y2,
        ]), gl.STATIC_DRAW);
    }
    createProgram(gl, vertex_src, frag_src) {
        const vertexShader = this.compileShader(gl, vertex_src, gl.VERTEX_SHADER)
        const fragmentShader = this.compileShader(gl, frag_src, gl.FRAGMENT_SHADER)
        // create a program.
        var program = gl.createProgram();
        // attach the shaders.
        gl.attachShader(program, vertexShader);
        gl.attachShader(program, fragmentShader);

        // link the program.
        gl.linkProgram(program);

        // Check if it linked.
        var success = gl.getProgramParameter(program, gl.LINK_STATUS);
        if (!success) {
            // something went wrong with the link
            console.error("program failed to link:" + gl.getProgramInfoLog(program));
        }

        return program;
    };
    compileShader(gl, shaderSource, shaderType) {
        // Create the shader object
        var shader = gl.createShader(shaderType);

        // Set the shader source code.
        gl.shaderSource(shader, shaderSource);

        // Compile the shader
        gl.compileShader(shader);

        // Check if it compiled
        var success = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
        if (!success) {
            // Something went wrong during compilation; get the error
            console.error("could not compile shader:" + gl.getShaderInfoLog(shader));
        }

        return shader;
    }

}