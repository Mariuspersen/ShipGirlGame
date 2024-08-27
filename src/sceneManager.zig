const Self = @This();

const Menu = @import("menu.zig");
const Intro = @import("intro.zig");
const sceneList = @import("sceneList.zig").sceneList;

//TODO: write a scenemanager thats not ass

currentScene: sceneList = sceneList.Intro,
intro: Intro = undefined,
mainMenu: Menu = undefined,

pub fn init() Self {
    var temp = Self{};
    switch (temp.currentScene) {
        .Intro => temp.intro = Intro.load(),
        .MainMenu => temp.mainMenu = Menu.load()
    }
    return temp;
}

pub fn loop(self: *Self) void {
    switch (self.currentScene) {
        .Intro => {
            if (self.intro.looping) {
                self.intro.loop();
            } else {
                self.switchScene(self.intro.nextScene);
            }
            
        },
        .MainMenu => {
            if (self.mainMenu.looping) {
                self.mainMenu.loop();
            } else {
                //self.switchScene(self.intro.nextScene);
            }
            
        },
    }
}

pub fn switchScene(self: *Self,newScene: sceneList) void {
    switch (self.currentScene) {
        .Intro => self.intro.unload(),
        .MainMenu => self.mainMenu.unload(),
    }
    switch (newScene) {
        .Intro => self.intro = Intro.load(),
        .MainMenu => self.mainMenu = Menu.load()
    }
    self.currentScene = newScene;
}