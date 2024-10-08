//**********************************************************************************************
//*
//*   raylib.lights - Some useful functions to deal with lights data
//*   Translated to Zig
//*
//*   CONFIGURATION:
//*
//*   #define RLIGHTS_IMPLEMENTATION
//*       Generates the implementation of the library into the included file.
//*       If not defined, the library is in header only mode and can be included in other headers
//*       or source files without problems. But only ONE file should hold the implementation.
//*
//*   LICENSE: zlib/libpng
//*
//*   Copyright (c) 2017-2024 Victor Fisac (@victorfisac) and Ramon Santamaria (@raysan5)
//*
//*   This software is provided "as-is", without any express or implied warranty. In no event
//*   will the authors be held liable for any damages arising from the use of this software.
//*
//*   Permission is granted to anyone to use this software for any purpose, including commercial
//*   applications, and to alter it and redistribute it freely, subject to the following restrictions:
//*
//*     1. The origin of this software must not be misrepresented; you must not claim that you
//*     wrote the original software. If you use this software in a product, an acknowledgment
//*     in the product documentation would be appreciated but is not required.
//*
//*     2. Altered source versions must be plainly marked as such, and must not be misrepresented
//*     as being the original software.
//*
//*     3. This notice may not be removed or altered from any source distribution.
//*
//**********************************************************************************************/
const rl = @import("raylib");
//----------------------------------------------------------------------------------
// Constants
//----------------------------------------------------------------------------------
const Self = @This();

// Light data
const LightType = enum(c_int) {
    LIGHT_DIRECTIONAL = 0,
    LIGHT_POINT = 1,
};

lightType: LightType,
enabled: bool,
position: rl.Vector3,
target: rl.Vector3,
color: rl.Color,
attenuation: f32 = 0.0,
// Shader locations
enabledLoc: c_int,
typeLoc: c_int,
positionLoc: c_int,
targetLoc: c_int,
colorLoc: c_int,
attenuationLoc: c_int = -1,

// Create a light and get shader locations
pub fn CreateLight(lightType: LightType, position: rl.Vector3, target: rl.Vector3, color: rl.Color, shader: rl.Shader) Self {
    var light = Self{
        .enabled = true,
        .lightType = lightType,
        .position = position,
        .target = target,
        .color = color,
        .enabledLoc = rl.getShaderLocation(
            shader,
            "lights[0].enabled",
        ),
        .typeLoc = rl.getShaderLocation(
            shader,
            "lights[0].type",
        ),
        .positionLoc = rl.getShaderLocation(
            shader,
            "lights[0].position",
        ),
        .targetLoc = rl.getShaderLocation(
            shader,
            "lights[0].target",
        ),
        .colorLoc = rl.getShaderLocation(
            shader,
            "lights[0].color",
        ),
    };
    light.updateLightValues(shader);
    return light;
}
//// Send light properties to shader
//// NOTE: Light shader locations should be available
pub fn updateLightValues(light: *const Self, shader: rl.Shader) void {
    rl.setShaderValue(
        shader,
        light.enabledLoc,
        &light.enabled,
        rl.ShaderUniformDataType.shader_uniform_int,
    );
    rl.setShaderValue(
        shader,
        light.typeLoc,
        &light.lightType,
        rl.ShaderUniformDataType.shader_uniform_int,
    );
    rl.setShaderValue(
        shader,
        light.positionLoc,
        &[3]f32{ light.position.x, light.position.y, light.position.z },
        rl.ShaderUniformDataType.shader_uniform_vec3,
    );
    rl.setShaderValue(
        shader,
        light.targetLoc,
        &[3]f32{ light.target.x, light.target.y, light.target.z },
        rl.ShaderUniformDataType.shader_uniform_vec3,
    );
    rl.setShaderValue(
        shader,
        light.colorLoc,
        &[4]f32{
            @floatFromInt(light.color.r),
            @floatFromInt(light.color.g),
            @floatFromInt(light.color.b),
            @floatFromInt(light.color.a),
        },
        rl.ShaderUniformDataType.shader_uniform_vec4,
    );
}
