//**********************************************************************************************
//*
//*   raylib.lights - Some useful functions to deal with lights data
//*   Translated to Zig by Marius
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
pub const DIRECTIONAL: i32 = 0;
pub const POINT: i32 = 1;

lightType: i32,
enabled: i32,
position: rl.Vector3,
target: rl.Vector3,
color: rl.Color,
attenuation: f32 = 0.0,
// Shader locations
enabledLoc: i32,
typeLoc: i32,
positionLoc: i32,
targetLoc: i32,
colorLoc: i32,
attenuationLoc: i32 = -1,

// Create a light and get shader locations
pub fn CreateLight(lightType: i32, position: rl.Vector3, target: rl.Vector3, color: rl.Color, shader: rl.Shader) Self {
    var light = Self{
        .enabled = 1,
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
        &light.position,
        rl.ShaderUniformDataType.shader_uniform_vec3,
    );
    rl.setShaderValue(
        shader,
        light.targetLoc,
        &light.target,
        rl.ShaderUniformDataType.shader_uniform_vec3,
    );
    rl.setShaderValue(
        shader,
        light.colorLoc,
        &[4]f32{
            @as(f32, @floatFromInt(light.color.r)) / 255.0,
            @as(f32, @floatFromInt(light.color.g)) / 255.0,
            @as(f32, @floatFromInt(light.color.b)) / 255.0,
            @as(f32, @floatFromInt(light.color.a)) / 255.0,
        },
        rl.ShaderUniformDataType.shader_uniform_vec4,
    );
}
