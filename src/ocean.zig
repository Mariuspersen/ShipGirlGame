const rl = @import("raylib");
const std = @import("std");
//----------------------------------------------------------------------------------
// Constants
//----------------------------------------------------------------------------------
const Self = @This();

const ShaderVariable = struct {
    location: i32,
    dataType: rl.ShaderUniformDataType,

    fn init(shader: rl.Shader, name: [*:0]const u8, dataType: rl.ShaderUniformDataType) ShaderVariable {
        return .{
            .location = rl.getShaderLocation(shader, name),
            .dataType = dataType,
        };
    }

    fn setVariable(self: *ShaderVariable, shader: rl.Shader, value: anytype) void {
        rl.setShaderValue(shader, self.location, &value, self.dataType);
    }
};

shader: rl.Shader,
time: ShaderVariable,

pub fn init(shader: rl.Shader) Self {
    return .{
        .time = ShaderVariable.init(shader, "time", .shader_uniform_float),
        .shader = shader,
    };
}

pub fn update(self: *Self) void {
    self.time.setVariable(self.shader, @as(f32, @floatCast(rl.getTime())));
}