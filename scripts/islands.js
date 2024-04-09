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

        const texture = this.loadTexture(gl,this.tileset[0])
        gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL,true)

        gl.clearColor(1.0, .0, .0, 1.0)
        gl.clear(gl.COLOR_BUFFER_BIT)

        const shaderProgram = this.initShaderProgram(gl, assets.vert, assets.frag)
        const programInfo = {
            program: shaderProgram,
            attribLocations: {
                vertexPosition: gl.getAttribLocation(shaderProgram, "aVertexPosition"),
                textureCoord: gl.getAttribLocation(shaderProgram, "aTextureCoord"),
            },
            uniformLocations: {
                uSampler: gl.getUniformLocation(shaderProgram, "uSampler"),
            },
        };

        const buffers = this.initBuffers(gl)
        this.drawScene(gl, programInfo, buffers,texture)

        for (let x = 0; x < this.tiles.length; x++)
            for (let y = 0; y < this.tiles[x].length; y++) {
                const north = this.tiles[x]?.[y - 1]
                const south = this.tiles[x]?.[y + 1]
                const west = this.tiles[x - 1]?.[y]
                const east = this.tiles[x + 1]?.[y]
                const current = this.tiles[x][y]
                current.image.src = webgl_canvas.toDataURL()
            }
    }

    initShaderProgram(gl, vsSource, fsSource) {
        const vertexShader = this.loadShader(gl, gl.VERTEX_SHADER, vsSource);
        const fragmentShader = this.loadShader(gl, gl.FRAGMENT_SHADER, fsSource);

        // Create the shader program

        const shaderProgram = gl.createProgram();
        gl.attachShader(shaderProgram, vertexShader);
        gl.attachShader(shaderProgram, fragmentShader);
        gl.linkProgram(shaderProgram);

        // If creating the shader program failed, alert

        if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
            alert(
                `Unable to initialize the shader program: ${gl.getProgramInfoLog(
                    shaderProgram,
                )}`,
            );
            return null;
        }

        return shaderProgram;
    }

    loadShader(gl, type, source) {
        const shader = gl.createShader(type);

        // Send the source to the shader object

        gl.shaderSource(shader, source);

        // Compile the shader program

        gl.compileShader(shader);

        // See if it compiled successfully

        if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
            alert(
                `An error occurred compiling the shaders: ${gl.getShaderInfoLog(shader)}`,
            );
            gl.deleteShader(shader);
            return null;
        }

        return shader;
    }

    initBuffers(gl) {
        const positionBuffer = this.initPositionBuffer(gl);
        const colorBuffer = this.initColorBuffer(gl);
        const textureCoordBuffer = this.initTextureBuffer(gl);

        return {
            position: positionBuffer,
            textureCoord: textureCoordBuffer,
            color: colorBuffer,
        };
    }
    initPositionBuffer(gl) {
        // Create a buffer for the square's positions.
        const positionBuffer = gl.createBuffer();

        // Select the positionBuffer as the one to apply buffer
        // operations to from here out.
        gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

        // Now create an array of positions for the square.
        const positions = [1.0, 1.0, -1.0, 1.0, 1.0, -1.0, -1.0, -1.0];

        // Now pass the list of positions into WebGL to build the
        // shape. We do this by creating a Float32Array from the
        // JavaScript array, then use it to fill the current buffer.
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);

        return positionBuffer;
    }
    drawScene(gl, programInfo, buffers,texture) {
        gl.clearColor(0.0, 0.0, 0.0, 0.0); // Clear to black, fully opaque
        gl.clearDepth(1.0); // Clear everything
        gl.enable(gl.DEPTH_TEST); // Enable depth testing
        gl.depthFunc(gl.LEQUAL); // Near things obscure far things
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT); // Clear the canvas before we start drawing on it.

        this.setPositionAttribute(gl, buffers, programInfo);

        //this.setColorAttribute(gl, buffers, programInfo)
        this.setTextureAttribute(gl, buffers, programInfo);
        // Tell WebGL we want to affect texture unit 0
        gl.activeTexture(gl.TEXTURE0);

        // Bind the texture to texture unit 0
        gl.bindTexture(gl.TEXTURE_2D, texture);

        // Tell the shader we bound the texture to texture unit 0
        gl.uniform1i(programInfo.uniformLocations.uSampler, 0);
        // Tell WebGL to use our program when drawing
        gl.useProgram(programInfo.program);

        {
            const offset = 0;
            const vertexCount = 4;
            gl.drawArrays(gl.TRIANGLE_STRIP, offset, vertexCount);
        }
    }
    setPositionAttribute(gl, buffers, programInfo) {
        const numComponents = 2; // pull out 2 values per iteration
        const type = gl.FLOAT; // the data in the buffer is 32bit floats
        const normalize = false; // don't normalize
        const stride = 0; // how many bytes to get from one set of values to the next
        // 0 = use type and numComponents above
        const offset = 0; // how many bytes inside the buffer to start from
        gl.bindBuffer(gl.ARRAY_BUFFER, buffers.position);
        gl.vertexAttribPointer(
            programInfo.attribLocations.vertexPosition,
            numComponents,
            type,
            normalize,
            stride,
            offset,
        );
        gl.enableVertexAttribArray(programInfo.attribLocations.vertexPosition);
    }
    initColorBuffer(gl) {
        const colors = [
            1.0,
            1.0,
            1.0,
            1.0, // white
            1.0,
            0.0,
            0.0,
            1.0, // red
            0.0,
            1.0,
            0.0,
            1.0, // green
            0.0,
            0.0,
            1.0,
            1.0, // blue
        ];

        const colorBuffer = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, colorBuffer);
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(colors), gl.STATIC_DRAW);

        return colorBuffer;
    }
    setColorAttribute(gl, buffers, programInfo) {
        const numComponents = 4;
        const type = gl.FLOAT;
        const normalize = false;
        const stride = 0;
        const offset = 0;
        gl.bindBuffer(gl.ARRAY_BUFFER, buffers.color);
        gl.vertexAttribPointer(
            programInfo.attribLocations.vertexColor,
            numComponents,
            type,
            normalize,
            stride,
            offset,
        );
        gl.enableVertexAttribArray(programInfo.attribLocations.vertexColor);
    }
    loadTexture(gl, image) {
        const texture = gl.createTexture();
        gl.bindTexture(gl.TEXTURE_2D, texture);

        // Because images have to be downloaded over the internet
        // they might take a moment until they are ready.
        // Until then put a single pixel in the texture so we can
        // use it immediately. When the image has finished downloading
        // we'll update the texture with the contents of the image.
        const level = 0;
        const internalFormat = gl.RGBA;
        const width = 1;
        const height = 1;
        const border = 0;
        const srcFormat = gl.RGBA;
        const srcType = gl.UNSIGNED_BYTE;
        const pixel = new Uint8Array([0, 0, 255, 255]); // opaque blue
        gl.texImage2D(
            gl.TEXTURE_2D,
            level,
            internalFormat,
            width,
            height,
            border,
            srcFormat,
            srcType,
            pixel,
        );

        gl.bindTexture(gl.TEXTURE_2D, texture);
        gl.texImage2D(
            gl.TEXTURE_2D,
            level,
            internalFormat,
            srcFormat,
            srcType,
            image,
        );

        // WebGL1 has different requirements for power of 2 images
        // vs. non power of 2 images so check if the image is a
        // power of 2 in both dimensions.
        if (this.isPowerOf2(image.width) && this.isPowerOf2(image.height)) {
            // Yes, it's a power of 2. Generate mips.
            gl.generateMipmap(gl.TEXTURE_2D);
        } else {
            // No, it's not a power of 2. Turn off mips and set
            // wrapping to clamp to edge
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
            gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        }
        return texture;
    };
    setTextureAttribute(gl, buffers, programInfo) {
        const num = 2; // every coordinate composed of 2 values
        const type = gl.FLOAT; // the data in the buffer is 32-bit float
        const normalize = false; // don't normalize
        const stride = 0; // how many bytes to get from one set to the next
        const offset = 0; // how many bytes inside the buffer to start from
        gl.bindBuffer(gl.ARRAY_BUFFER, buffers.textureCoord);
        gl.vertexAttribPointer(
            programInfo.attribLocations.textureCoord,
            num,
            type,
            normalize,
            stride,
            offset,
        );
        gl.enableVertexAttribArray(programInfo.attribLocations.textureCoord);
    }
    initTextureBuffer(gl) {
        const textureCoordBuffer = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, textureCoordBuffer);

        const textureCoordinates = [
            // Front
            0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0,
        ];

        gl.bufferData(
            gl.ARRAY_BUFFER,
            new Float32Array(textureCoordinates),
            gl.STATIC_DRAW,
        );

        return textureCoordBuffer;
    }
    isPowerOf2(value) {
        return (value & (value - 1)) === 0;
    }
}