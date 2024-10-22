const rl = @import("raylib");
const std = @import("std");
const Assets = @import("assetManager.zig");

const Self = @This();
const SIZE_X = 100;
const SIZE_Y = 100;
const HALF_X = @divExact(SIZE_X, 2);
const HALF_Y = @divExact(SIZE_Y, 2);

const ShaderVariable = struct {
    location: i32,
    dataType: rl.ShaderUniformDataType,

    fn init(shader: rl.Shader, name: [*:0]const u8, dataType: rl.ShaderUniformDataType) ShaderVariable {
        return .{
            .location = rl.getShaderLocation(shader, name),
            .dataType = dataType,
        };
    }

    pub fn setVariable(self: *ShaderVariable, shader: rl.Shader, value: anytype) void {
        rl.setShaderValue(shader, self.location, &value, self.dataType);
    }
};

shader: rl.Shader,
model: rl.Model,
time: ShaderVariable,
amplitude: ShaderVariable,
frequency: ShaderVariable,

pub fn init(shader: rl.Shader) !Self {
    var temp = .{
        .shader = shader,
        .model = try Assets.oceanModel.getModel(),
        .time = ShaderVariable.init(shader, "time", .shader_uniform_float),
        .amplitude = ShaderVariable.init(shader, "amplitude", .shader_uniform_float),
        .frequency = ShaderVariable.init(shader, "frequency", .shader_uniform_float),
    };

    for (0..@as(usize, @intCast(temp.model.materialCount))) |i| {
        temp.model.materials[i].shader = temp.shader;
    }

    return temp;
}

pub fn deinit(self: *Self) void {
    self.model.unload();
}

pub fn update(self: *Self) void {
    self.time.setVariable(self.shader, @as(f32, @floatCast(rl.getTime())));
}

pub fn draw(self: *Self) void {
    self.shader.activate();
    defer self.shader.deactivate();

    for (0..SIZE_X) |x|
        for (0..SIZE_Y) |y| {
            self.model.draw(
                rl.Vector3.init(
                    @as(f32, @floatFromInt(@as(i32, @intCast(x * 8)) - HALF_X*8)),
                    0.0,
                    @as(f32, @floatFromInt(@as(i32, @intCast(y * 8)) - HALF_Y*8)),
                ),
                1.0,
                rl.Color.white,
            );
        };
}

pub fn setVariable(self: *Self, comptime name: []const u8, value: anytype) void {
    if (!@hasField(Self, name)) {
        @compileError("No field with that name");
    }
    var field = @field(self, name);
    field.setVariable(self.shader, value);
}
