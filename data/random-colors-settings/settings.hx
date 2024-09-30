// This 1 file is so damn big lmao.
import backend.Paths;
import backend.Mods;
import backend.Controls;
import backend.ClientPrefs;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import flixel.text.FlxTextAlign;
import flixel.util.FlxColor;
import objects.StrumNote;
import sys.io.File;
import sys.io.FileSystem;
import states.PlayState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.sound.FlxSound;

using StringTools;

// BG Stuffs
var BG:FlxSprite;
var grid:FlxBackdrop;

// Left Note Shit.
var noteLeftGroup:FlxTypedSpriteGroup<StrumNote>;
var curColorArrayLeft:Array<FlxColor> = [];
var curColorArrayLeftDark:Array<FlxColor> = [];
var curColorArrayLeftWhite:Array<FlxColor> = [];

// Down Note Shit.
var noteDownGroup:FlxTypedSpriteGroup<StrumNote>;
var curColorArrayDown:Array<FlxColor> = [];
var curColorArrayDownDark:Array<FlxColor> = [];
var curColorArrayDownWhite:Array<FlxColor> = [];

// Up Arrow Shit.
var noteUpGroup:FlxTypedSpriteGroup<StrumNote>;
var curColorArrayUp:Array<FlxColor> = [];
var curColorArrayUpDark:Array<FlxColor> = [];
var curColorArrayUpWhite:Array<FlxColor> = [];

// Right Arrow Shit.
var noteRightGroup:FlxTypedSpriteGroup<StrumNote>;
var curColorArrayRight:Array<FlxColor> = [];
var curColorArrayRightDark:Array<FlxColor> = [];
var curColorArrayRightWhite:Array<FlxColor> = [];

// Global Arrow Shit.
var noteGlobalGroup:FlxTypedSpriteGroup<StrumNote>;
var curColorArrayGlobal:Array<FlxColor> = [];
var curColorArrayGlobalDark:Array<FlxColor> = [];
var curColorArrayGlobalWhite:Array<FlxColor> = [];

var camFollow:FlxObject;

// Generic Cur Selected
var curSelected:Int = 0;

// Cur Selected for Notes
var curSelectedLeft:Int = 0;
var curSelectedDown:Int = 0;
var curSelectedUp:Int = 0;
var curSelectedRight:Int = 0;
var curSelectedGlobal:Int = 0;

// Selector related shit
var selector:FlxSprite;
var selector2:FlxSprite;
var globalText:FlxText;

var controls:Controls;

var paths:Array<String> = [
    'global/colors',
    'global/colorsWhite',
    'global/colorsDark',
    'left/colors',
    'left/colorsDark',
    'left/colorsWhite',
    'down/colors',
    'down/colorsDark',
    'down/colorsWhite',
    'up/colors',
    'up/colorsDark',
    'up/colorsWhite',
    'right/colors',
    'right/colorsDark',
    'right/colorsWhite'
];

var canMove:Bool = true;
var canMoveSelector:Bool = true;

// Initial position for notes spawned
var initialPosLeft:Array<Int> = [];
var initialPosDown:Array<Int> = [];
var initialPosUp:Array<Int> = [];
var initialPosRight:Array<Int> = [];
var initialPosGlobal:Array<Int> = [];

// Stuff for making sure you dont accidentally exit upon hitting exit.
var inputBlock:Array<FlxUIInputText> = [];
var blockInput:Bool = false;

// Stuff for making the inputs work
    // Hex code inputs
var colorInput:FlxUIInputText;
var colorInputDark:FlxUIInputText;
var colorInputWhite:FlxUIInputText;
    // RGB Input
var colorInputR:FlxUINumericStepper;
var colorInputG:FlxUINumericStepper;
var colorInputB:FlxUINumericStepper;
    // RGB Input (Dark)
var colorInputDarkR:FlxUINumericStepper;
var colorInputDarkG:FlxUINumericStepper;
var colorInputDarkB:FlxUINumericStepper;
    // RGB Input (Whites)
var colorInputWhiteR:FlxUINumericStepper;
var colorInputWhiteG:FlxUINumericStepper;
var colorInputWhiteB:FlxUINumericStepper;
var subStateMusic:FlxSound;

function onCustomSubstateCreate(name:String) {
    PlayState.instance.canPause = false; // need to call this else people can break it by simply opening the pause menu lmao.
    PlayState.instance.allowDebugKeys = false; // Ditto but with stuff like the chart menu and the character menu

    FlxG.mouse.visible = true;
    FlxG.sound.music.volume = 0;// just in case

    subStateMusic = new FlxSound();
    subStateMusic.loadEmbedded(Paths.music('offsetSong'));
    subStateMusic.looped = true;
    subStateMusic.play();
    FlxG.sound.list.add(subStateMusic); // so it auto pauses if auto pause is enabled

    controls = Controls.instance;

    doFileCheck();
    setupArrays();

    BG = new FlxSprite().loadGraphic(Paths.image('menuBGMagenta'));
    BG.screenCenter();
    BG.cameras = [PlayState.instance.camOther];
    BG.scrollFactor.set(0, 0);
    add(BG);

    grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
    grid.velocity.set(40, 40);
    grid.cameras = [PlayState.instance.camOther];
    grid.alpha = 0;
    FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
    add(grid);
    
    noteLeftGroup = new FlxTypedSpriteGroup<StrumNote>();
    noteDownGroup = new FlxTypedSpriteGroup<StrumNote>();
    noteUpGroup = new FlxTypedSpriteGroup<StrumNote>();
    noteRightGroup = new FlxTypedSpriteGroup<StrumNote>();
    noteGlobalGroup = new FlxTypedSpriteGroup<StrumNote>();
    
    add(noteLeftGroup);
    add(noteDownGroup);
    add(noteUpGroup);
    add(noteRightGroup);
    add(noteGlobalGroup);

    noteLeftGroup.cameras = [PlayState.instance.camOther];
    noteDownGroup.cameras = [PlayState.instance.camOther];
    noteUpGroup.cameras = [PlayState.instance.camOther];
    noteRightGroup.cameras = [PlayState.instance.camOther];
    noteGlobalGroup.cameras = [PlayState.instance.camOther];

    globalText = new FlxText(0, 0, 0, 'Global Colors', 20);
    globalText.setFormat(Paths.font('vcr.ttf'), 20);
    globalText.cameras = [PlayState.instance.camOther];

    camFollow = new FlxObject(0, 0, 10, 10);
    camFollow.screenCenter();
    camFollow.y += -300;
    camFollow.x += 70;
    camOther.zoom = 1.15;
    PlayState.instance.camOther.follow(camFollow, null, 1);

    doNoteScreenSpawn();
    setAlpha();

    var colorInputBG = new FlxSprite().makeGraphic(600, Std.int(FlxG.height * 1.5), 0xFF000000);
    colorInputBG.alpha = 0.5;
    colorInputBG.cameras = [PlayState.instance.camOther];
    add(colorInputBG);
    
    selector = new FlxSprite().loadGraphic(Paths.image('buttons'));
    selector.frames = Paths.getSparrowAtlas('buttons');
    selector.animation.addByPrefix('idle', 'arrow Down0', 24, false);
    selector.animation.addByPrefix('press', 'arrow down press0', 24, false);
    selector.setGraphicSize(Std.int(selector.width * 0.8));
    selector.updateHitbox();
    selector.cameras = [PlayState.instance.camOther];
    selector.screenCenter();
    selector.y += -190;
    selector.x = noteLeftGroup.members[0].x + 25;
    selector.antialiasing = ClientPrefs.data.antialiasing;
    add(selector);

    selector2 = new FlxSprite().loadGraphic(Paths.image('buttons'));
    selector2.frames = Paths.getSparrowAtlas('buttons');
    selector2.animation.addByPrefix('idle', 'arrow Up0', 24, false);
    selector2.animation.addByPrefix('press', 'arrow Up press0', 24, false);
    selector2.animation.play('idle');
    selector2.setGraphicSize(Std.int(selector2.width * 0.8));
    selector2.updateHitbox();
    selector2.cameras = [PlayState.instance.camOther];
    selector2.screenCenter();
    selector2.y += -370;
    selector2.x = noteLeftGroup.members[0].x + 22;
    selector2.antialiasing = ClientPrefs.data.antialiasing;
    add(selector2);

    setupTextInput();
    setupRGBSteppers();
    setupTextCallbacks();

    colorInputBG.y = colorInput.y - 300;
    colorInputBG.x = colorInput.x - 100;
    

    globalText.x = noteGlobalGroup.members[0].x - 20;
    globalText.y = noteGlobalGroup.members[0].y + 5;

    add(globalText);
}

// Fill it with junk data basically.
function doFileCheck() {
    for (path in paths) {
        path = 'mods/randomColors/data/colors/' + path + '.txt';
        if (!FileSystem.exists(path)) {
            File.saveContent(path, 'FFFFFF\nFFFFFF');
        }
    }
}

function setupTextInput() {

    colorInput = new FlxUIInputText(0, 0, 100, curColorArrayLeft[0]);
    colorInput.cameras = [PlayState.instance.camOther];
    colorInput.screenCenter();
    colorInput.y += -500;
    colorInput.x += 500;
    add(colorInput);

    var colorText = new FlxText(0, 0, 0, 'Note Color', 10);
    colorText.y = colorInput.y - 20;
    colorText.x = colorInput.x;
    colorText.cameras = [PlayState.instance.camOther];
    add(colorText);

    colorInputDark = new FlxUIInputText(0, 0, 100, curColorArrayLeftDark[0]);
    colorInputDark.cameras = [PlayState.instance.camOther];
    colorInputDark.screenCenter();
    colorInputDark.y += -330;
    colorInputDark.x += 500;
    add(colorInputDark);

    var colorText = new FlxText(0, 0, 0, 'Note Color (Outline)', 10);
    colorText.y = colorInputDark.y - 20;
    colorText.x = colorInputDark.x;
    colorText.cameras = [PlayState.instance.camOther];
    add(colorText);

    colorInputWhite = new FlxUIInputText(0, 0, 100, curColorArrayLeftWhite[0]);
    colorInputWhite.cameras = [PlayState.instance.camOther];
    colorInputWhite.screenCenter();
    colorInputWhite.y += -180;
    colorInputWhite.x += 500;
    add(colorInputWhite);

    var colorText = new FlxText(0, 0, 0, 'Note Color (White Area)', 10);
    colorText.y = colorInputWhite.y - 20;
    colorText.x = colorInputWhite.x;
    colorText.cameras = [PlayState.instance.camOther];
    add(colorText);

    inputBlock.push(colorInput);
    inputBlock.push(colorInputDark);
    inputBlock.push(colorInputWhite);
}
// Converts a two length hex number to a 256-max decimal
function convertHexToInt(hex:String):Int {
    var hexArray = hex.split();
    var finalInt:Int = 0;
    for (i in 0...hexArray.length) {
        switch (hexArray[i].toLowerCase()) {
            case '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9':
                finalInt += Std.parseInt(hexArray[i]) * 8;
            case '1':
                finalInt += 8;
            case 'a':
                finalInt += 10 * 8;
            case 'b':
                finalInt += 11 * 8;
            case 'c':
                finalInt += 12 * 8;
            case 'd':
                finalInt += 13 * 8;
            case 'e':
                finalInt += 14 * 8;
            case 'f':
                finalInt += 15 * 8;
        }
        //trace(hexArray[i]);
    }
    return finalInt;
}

function setupRGBSteppers() {
     var leftRGB = acquireRGBArray(curColorArrayLeft[0]);

    colorInputR = new FlxUINumericStepper(colorInput.x, colorInput.y + 40, 16, leftRGB[0], 0, 256, 0);
    colorInputR.cameras = [PlayState.instance.camOther];
    add(colorInputR);
    inputBlock.push(colorInputR);

    var colorText = new FlxText(0, 0, 0, 'RGB Input (R)', 10);
    colorText.y = colorInputR.y - 20;
    colorText.x = colorInputWhite.x;
    colorText.cameras = [PlayState.instance.camOther];
    add(colorText);

    colorInputG = new FlxUINumericStepper(colorInput.x, colorInput.y + 80, 16, leftRGB[1], 0, 256, 0);
    colorInputG.cameras = [PlayState.instance.camOther];
    add(colorInputG);
    inputBlock.push(colorInputG);

    var colorText = new FlxText(0, 0, 0, 'RGB Input (G)', 10);
    colorText.y = colorInputG.y - 20;
    colorText.x = colorInputWhite.x;
    colorText.cameras = [PlayState.instance.camOther];
    add(colorText);
    
    colorInputB = new FlxUINumericStepper(colorInput.x, colorInput.y + 120, 16, leftRGB[2], 0, 256, 0);
    colorInputB.cameras = [PlayState.instance.camOther];
    add(colorInputB);
    inputBlock.push(colorInputB);

    var colorText = new FlxText(0, 0, 0, 'RGB Input (B)', 10);
    colorText.y = colorInputB.y - 20;
    colorText.x = colorInputWhite.x;
    colorText.cameras = [PlayState.instance.camOther];
    add(colorText);

    var leftDarkRGB = acquireRGBArray(curColorArrayLeftDark[0]);

    colorInputDarkR = new FlxUINumericStepper(colorInputDark.x, colorInputDark.y + 40, 16, leftDarkRGB[0], 0, 256, 0);
    colorInputDarkR.cameras = [PlayState.instance.camOther];
    add(colorInputDarkR);
    inputBlock.push(colorInputDarkR);

    var colorText = new FlxText(0, 0, 0, 'RGB Input (R)', 10);
    colorText.y = colorInputDarkR.y - 20;
    colorText.x = colorInputWhite.x;
    colorText.cameras = [PlayState.instance.camOther];
    add(colorText);

    colorInputDarkG = new FlxUINumericStepper(colorInputDark.x, colorInputDark.y + 80, 16, leftDarkRGB[1], 0, 256, 0);
    colorInputDarkG.cameras = [PlayState.instance.camOther];
    add(colorInputDarkG);
    inputBlock.push(colorInputDarkG);

    var colorText = new FlxText(0, 0, 0, 'RGB Input (G)', 10);
    colorText.y = colorInputDarkG.y - 20;
    colorText.x = colorInputWhite.x;
    colorText.cameras = [PlayState.instance.camOther];
    add(colorText);
    
    colorInputDarkB = new FlxUINumericStepper(colorInputDark.x, colorInputDark.y + 116, 16, leftDarkRGB[2], 0, 256, 0);
    colorInputDarkB.cameras = [PlayState.instance.camOther];
    add(colorInputDarkB);
    inputBlock.push(colorInputDarkB);

    var colorText = new FlxText(0, 0, 0, 'RGB Input (B)', 10);
    colorText.y = colorInputDarkB.y - 20;
    colorText.x = colorInputWhite.x;
    colorText.cameras = [PlayState.instance.camOther];
    add(colorText);

    var leftWhiteRGB = acquireRGBArray(curColorArrayLeftWhite[0]);

    colorInputWhiteR = new FlxUINumericStepper(colorInputWhite.x, colorInputWhite.y + 40, 16, leftWhiteRGB[0], 0, 256, 0);
    colorInputWhiteR.cameras = [PlayState.instance.camOther];
    add(colorInputWhiteR);
    inputBlock.push(colorInputWhiteR);

    var colorText = new FlxText(0, 0, 0, 'RGB Input (R)', 10);
    colorText.y = colorInputWhiteR.y - 20;
    colorText.x = colorInputWhite.x;
    colorText.cameras = [PlayState.instance.camOther];
    add(colorText);

    colorInputWhiteG = new FlxUINumericStepper(colorInputWhite.x, colorInputWhite.y + 80, 16, leftWhiteRGB[1], 0, 256, 0);
    colorInputWhiteG.cameras = [PlayState.instance.camOther];
    add(colorInputWhiteG);
    inputBlock.push(colorInputWhiteG);

    var colorText = new FlxText(0, 0, 0, 'RGB Input (G)', 10);
    colorText.y = colorInputWhiteG.y - 20;
    colorText.x = colorInputWhite.x;
    colorText.cameras = [PlayState.instance.camOther];
    add(colorText);
    
    colorInputWhiteB = new FlxUINumericStepper(colorInputWhite.x, colorInputWhite.y + 120, 16, leftWhiteRGB[2], 0, 256, 0);
    colorInputWhiteB.cameras = [PlayState.instance.camOther];
    add(colorInputWhiteB);
    inputBlock.push(colorInputWhiteB);

    var colorText = new FlxText(0, 0, 0, 'RGB Input (B)', 10);
    colorText.y = colorInputWhiteB.y - 20;
    colorText.x = colorInputWhite.x;
    colorText.cameras = [PlayState.instance.camOther];
    add(colorText);
}

function acquireRGBArray(str:String):Array<Int>
{
    var RGBArray = [];
    var hex1 = '';
    var hex2 = '';
    var hex3 = '';
    if (str == null) {
        str = '000000';
    }
    var hex = str.split();
    for (i in 0...6) {
        if (i < 2) {
            hex1 += hex[i];
        }
        if (i >= 2 && i < 4) {
            hex2 += hex[i];
        }
        if (i >= 4) {
            hex3 += hex[i];
        }
        //trace('Cur Hex: ' + hex[i]);
    }
    for (i in 0...3) {
        RGBArray.push(switch (i) {
            case 0:
                convertHexToInt(hex1);
            case 1:
                convertHexToInt(hex2);
            case 2:
                convertHexToInt(hex3);
        });
    }
    return RGBArray;
}

function setupTextCallbacks() {

    colorInput.callback = function(value:String) {
        if (colorInput.text.length > 6) {
            var array = colorInput.text.split();
            var string = '';
            for (i in 0...6) {
                string += array[i];
            }
            colorInput.text = string;
        }

        switch(curSelected) {
            case 0:
                noteLeftGroup.members[curSelectedLeft].rgbShader.r = FlxColor.fromString('#' + colorInput.text);
                curColorArrayLeft[curSelectedLeft] = colorInput.text;

            case 1:
                noteDownGroup.members[curSelectedDown].rgbShader.r = FlxColor.fromString('#' + colorInput.text);
                curColorArrayDown[curSelectedDown] = colorInput.text;

            case 2:
                noteUpGroup.members[curSelectedUp].rgbShader.r = FlxColor.fromString('#' + colorInput.text);
                curColorArrayUp[curSelectedUp] = colorInput.text;

            case 3:
                noteRightGroup.members[curSelectedRight].rgbShader.r = FlxColor.fromString('#' + colorInput.text);
                curColorArrayRight[curSelectedRight] = colorInput.text;

            case 4:
                noteGlobalGroup.members[curSelectedGlobal].rgbShader.r = FlxColor.fromString('#' + colorInput.text);
                curColorArrayGlobal[curSelectedGlobal] = colorInput.text;
                
        }
        
        if (colorInput.text.length == 6)
            flushColorTables();
    }

    colorInputWhite.callback = function(value:String) {
        if (colorInputWhite.text.length > 6) {
            var array = colorInputWhite.text.split();
            var string = '';
            for (i in 0...6) {
                string += array[i];
            }
            colorInputWhite.text = string;
        }

        switch(curSelected) {
            case 0:
                noteLeftGroup.members[curSelectedLeft].rgbShader.g = FlxColor.fromString('#' + colorInputWhite.text);
                curColorArrayLeftWhite[curSelectedLeft] = colorInputWhite.text;

            case 1:
                noteDownGroup.members[curSelectedDown].rgbShader.g = FlxColor.fromString('#' + colorInputWhite.text);
                curColorArrayDownWhite[curSelectedDown] = colorInputWhite.text;

            case 2:
                noteUpGroup.members[curSelectedUp].rgbShader.g = FlxColor.fromString('#' + colorInputWhite.text);
                curColorArrayUpWhite[curSelectedUp] = colorInputWhite.text;

            case 3:
                noteRightGroup.members[curSelectedRight].rgbShader.g = FlxColor.fromString('#' + colorInputWhite.text);
                curColorArrayRightWhite[curSelectedRight] = colorInputWhite.text;

            case 4:
                noteGlobalGroup.members[curSelectedGlobal].rgbShader.g = FlxColor.fromString('#' + colorInputWhite.text);
                curColorArrayGlobalWhite[curSelectedGlobal] = colorInputWhite.text;

        }

        if (colorInputWhite.text.length == 6)
            flushColorTables();
    }

    colorInputDark.callback = function(value:String) {
        if (colorInputDark.text.length > 6) {
            var array = colorInputDark.text.split();
            var string = '';
            for (i in 0...6) {
                string += array[i];
            }
            colorInputDark.text = string;
        }

        switch(curSelected) {
            case 0:
                noteLeftGroup.members[curSelectedLeft].rgbShader.b = FlxColor.fromString('#' + colorInputDark.text);
                curColorArrayLeftDark[curSelectedLeft] = colorInputDark.text;

            case 1:
                noteDownGroup.members[curSelectedDown].rgbShader.b = FlxColor.fromString('#' + colorInputDark.text);
                curColorArrayDownDark[curSelectedDown] = colorInputDark.text;

            case 2:
                noteUpGroup.members[curSelectedUp].rgbShader.b = FlxColor.fromString('#' + colorInputDark.text);
                curColorArrayUpDark[curSelectedUp] = colorInputDark.text;

            case 3:
                noteRightGroup.members[curSelectedRight].rgbShader.b = FlxColor.fromString('#' + colorInputDark.text);
                curColorArrayRightDark[curSelectedRight] = colorInputDark.text;

            case 4:
                noteGlobalGroup.members[curSelectedGlobal].rgbShader.b = FlxColor.fromString('#' + colorInputDark.text);
                curColorArrayGlobalDark[curSelectedGlobal] = colorInputDark.text;

        }

        if (colorInputDark.text.length == 6)
            flushColorTables();
    }

}

function setupArrays() {
    curColorArrayLeft = File.getContent('mods/randomColors/data/colors/left/colors.txt').split('\n');
    curColorArrayDown = File.getContent('mods/randomColors/data/colors/down/colors.txt').split('\n');
    curColorArrayUp = File.getContent('mods/randomColors/data/colors/up/colors.txt').split('\n');
    curColorArrayRight = File.getContent('mods/randomColors/data/colors/right/colors.txt').split('\n');
    curColorArrayGlobal = File.getContent('mods/randomColors/data/colors/global/colors.txt').split('\n');
    
    curColorArrayLeftDark = File.getContent('mods/randomColors/data/colors/left/colorsDark.txt').split('\n');
    curColorArrayDownDark = File.getContent('mods/randomColors/data/colors/down/colorsDark.txt').split('\n');
    curColorArrayUpDark = File.getContent('mods/randomColors/data/colors/up/colorsDark.txt').split('\n');
    curColorArrayRightDark = File.getContent('mods/randomColors/data/colors/right/colorsDark.txt').split('\n');
    curColorArrayGlobalDark = File.getContent('mods/randomColors/data/colors/global/colorsDark.txt').split('\n');
    
    curColorArrayLeftWhite = File.getContent('mods/randomColors/data/colors/left/colorsWhite.txt').split('\n');
    curColorArrayDownWhite = File.getContent('mods/randomColors/data/colors/down/colorsWhite.txt').split('\n');
    curColorArrayUpWhite = File.getContent('mods/randomColors/data/colors/up/colorsWhite.txt').split('\n');
    curColorArrayRightWhite = File.getContent('mods/randomColors/data/colors/right/colorsWhite.txt').split('\n');
    curColorArrayGlobalWhite = File.getContent('mods/randomColors/data/colors/global/colorsWhite.txt').split('\n');
}

function flushColorTables() {
    trace('Saving Color Data!');
    var colorString:String = '';
    var path:String = 'mods/randomColors/data/colors/left/colors.txt';
    for (i in 0...curColorArrayLeft.length) {
        if (i != curColorArrayLeft.length - 1)
            colorString += curColorArrayLeft[i] + '\n';
        if (i == curColorArrayLeft.length - 1)
            colorString += curColorArrayLeft[i];
    }
    //trace('Saving: ' + colorString + '\n');
    File.saveContent(path, colorString);

    colorString = '';
    path = 'mods/randomColors/data/colors/left/colorsDark.txt';
    for (i in 0...curColorArrayLeftDark.length) {
        if (i != curColorArrayLeftDark.length - 1)
            colorString += curColorArrayLeftDark[i] + '\n';
        if (i == curColorArrayLeftDark.length - 1)
            colorString += curColorArrayLeftDark[i];
    }
    //trace('Saving: ' + colorString + '\n');
    File.saveContent(path, colorString);

    colorString = '';
    path = 'mods/randomColors/data/colors/left/colorsWhite.txt';
    for (i in 0...curColorArrayLeftWhite.length) {
        if (i != curColorArrayLeftWhite.length - 1)
            colorString += curColorArrayLeftWhite[i] + '\n';
        if (i == curColorArrayLeftWhite.length - 1)
            colorString += curColorArrayLeftWhite[i];
    }
    //trace('Saving Whites: ' + colorString + '\n');
    File.saveContent(path, colorString);

    colorString = '';
    path = 'mods/randomColors/data/colors/down/colors.txt';
    for (i in 0...curColorArrayDown.length) {
        if (i != curColorArrayDown.length - 1)
            colorString += curColorArrayDown[i] + '\n';
        if (i == curColorArrayDown.length - 1)
            colorString += curColorArrayDown[i];
    }
   // trace('Saving: ' + colorString + '\n');
    File.saveContent(path, colorString);

    colorString = '';
    path = 'mods/randomColors/data/colors/down/colorsDark.txt';
    for (i in 0...curColorArrayDownDark.length) {
        if (i != curColorArrayDownDark.length - 1)
            colorString += curColorArrayDownDark[i] + '\n';
        if (i == curColorArrayDownDark.length - 1)
            colorString += curColorArrayDownDark[i];
    }
    //trace('Saving: ' + colorString + '\n');
    File.saveContent(path, colorString);

    colorString = '';
    path = 'mods/randomColors/data/colors/down/colorsWhite.txt';
    for (i in 0...curColorArrayDownWhite.length) {
        if (i != curColorArrayDownWhite.length - 1)
            colorString += curColorArrayDownWhite[i] + '\n';
        if (i == curColorArrayDownWhite.length - 1)
            colorString += curColorArrayDownWhite[i];
    }
    //trace('Saving Whites: ' + colorString + '\n');
    File.saveContent(path, colorString);

    colorString = '';
    path = 'mods/randomColors/data/colors/up/colors.txt';
    for (i in 0...curColorArrayUp.length) {
        if (i != curColorArrayUp.length - 1)
            colorString += curColorArrayUp[i] + '\n';
        if (i == curColorArrayUp.length - 1)
            colorString += curColorArrayUp[i];
    }
    //trace('Saving: ' + colorString + '\n');
    File.saveContent(path, colorString);

    colorString = '';
    path = 'mods/randomColors/data/colors/up/colorsDark.txt';
    for (i in 0...curColorArrayUpDark.length) {
        if (i != curColorArrayUpDark.length - 1)
            colorString += curColorArrayUpDark[i] + '\n';
        if (i == curColorArrayUpDark.length - 1)
            colorString += curColorArrayUpDark[i];
    }
    //trace('Saving: ' + colorString + '\n');
    File.saveContent(path, colorString);

    colorString = '';
    path = 'mods/randomColors/data/colors/up/colorsWhite.txt';
    for (i in 0...curColorArrayUpWhite.length) {
        if (i != curColorArrayUpWhite.length - 1)
            colorString += curColorArrayUpWhite[i] + '\n';
        if (i == curColorArrayUpWhite.length - 1)
            colorString += curColorArrayUpWhite[i];
    }
    //trace('Saving Whites: ' + colorString + '\n');
    File.saveContent(path, colorString);

    colorString = '';
    path = 'mods/randomColors/data/colors/right/colors.txt';
    for (i in 0...curColorArrayRight.length) {
        if (i != curColorArrayRight.length - 1)
            colorString += curColorArrayRight[i] + '\n';
        if (i == curColorArrayRight.length - 1)
            colorString += curColorArrayRight[i];
    }
    //trace('Saving: ' + colorString + '\n');
    File.saveContent(path, colorString);

    colorString = '';
    path = 'mods/randomColors/data/colors/right/colorsDark.txt';
    for (i in 0...curColorArrayRightDark.length) {
        if (i != curColorArrayRightDark.length - 1)
            colorString += curColorArrayRightDark[i] + '\n';
        if (i == curColorArrayRightDark.length - 1)
            colorString += curColorArrayRightDark[i];
    }
    //trace('Saving: ' + colorString + '\n');
    File.saveContent(path, colorString);

    colorString = '';
    path = 'mods/randomColors/data/colors/right/colorsWhite.txt';
    for (i in 0...curColorArrayRightWhite.length) {
        if (i != curColorArrayRightWhite.length - 1)
            colorString += curColorArrayRightWhite[i] + '\n';
        if (i == curColorArrayRightWhite.length - 1)
            colorString += curColorArrayRightWhite[i];
    }
    //trace('Saving Whites: ' + colorString + '\n');
    File.saveContent(path, colorString);

    colorString = '';
    path = 'mods/randomColors/data/colors/global/colors.txt';
    for (i in 0...curColorArrayGlobal.length) {
        if (i != curColorArrayGlobal.length - 1)
            colorString += curColorArrayGlobal[i] + '\n';
        if (i == curColorArrayGlobal.length - 1)
            colorString += curColorArrayGlobal[i];
    }
    //trace('Saving: ' + colorString + '\n');
    File.saveContent(path, colorString);

    colorString = '';
    path = 'mods/randomColors/data/colors/global/colorsDark.txt';
    for (i in 0...curColorArrayGlobalDark.length) {
        if (i != curColorArrayGlobalDark.length - 1)
            colorString += curColorArrayGlobalDark[i] + '\n';
        if (i == curColorArrayGlobalDark.length - 1)
            colorString += curColorArrayGlobalDark[i];
    }
    //trace('Saving: ' + colorString + '\n');
    File.saveContent(path, colorString);

    colorString = '';
    path = 'mods/randomColors/data/colors/global/colorsWhite.txt';
    for (i in 0...curColorArrayGlobalWhite.length) {
        if (i != curColorArrayGlobalWhite.length - 1)
            colorString += curColorArrayGlobalWhite[i] + '\n';
        if (i == curColorArrayGlobalWhite.length - 1)
            colorString += curColorArrayGlobalWhite[i];
    }
    //trace('Saving Whites: ' + colorString + '\n');
    File.saveContent(path, colorString);
}

function checkForInput() {
    var inputBlocked:Array<Bool> = [];
    for (input in inputBlock) {
            inputBlocked.push(input.hasFocus);
        if (input.hasFocus) {
            blockInput = true;
            return;
        }
    }
    blockInput = false;
}

// TODO: MAKE THIS DELETE WITHOUT NEEDING A RESTART
function deleteNote() {
    switch (curSelected) {
        case 0:
            if (noteLeftGroup.members.length != 1) {
                if (noteLeftGroup.members[curSelectedLeft].animation.curAnim.name != 'addNote')
                {
                    curColorArrayLeft.remove(curColorArrayLeft[curSelectedLeft]);
                    curColorArrayLeftWhite.remove(curColorArrayLeftWhite[curSelectedLeft]);
                    curColorArrayLeftDark.remove(curColorArrayLeftDark[curSelectedLeft]);
                    noteLeftGroup.members[curSelectedLeft].destroy();
                    initialPosLeft.pop();
                    flushColorTables();
                    game.callOnLuas('quickRestart');
                }
            }
        case 1:
            if (noteDownGroup.members.length != 1) {
                if (noteDownGroup.members[curSelectedDown].animation.curAnim.name != 'addNote')
                {
                    curColorArrayDown.remove(curColorArrayDown[curSelectedDown]);
                    curColorArrayDownWhite.remove(curColorArrayDownWhite[curSelectedDown]);
                    curColorArrayDownDark.remove(curColorArrayDownDark[curSelectedDown]);
                    noteDownGroup.members[curSelectedDown].destroy();
                    initialPosDown.pop();
                    flushColorTables();
                    game.callOnLuas('quickRestart');
                }
            }
        case 2:
            if (noteUpGroup.members.length != 1) {
                if (noteUpGroup.members[curSelectedUp].animation.curAnim.name != 'addNote')
                {
                    curColorArrayUp.remove(curColorArrayUp[curSelectedUp]);
                    curColorArrayUpWhite.remove(curColorArrayUpWhite[curSelectedUp]);
                    curColorArrayUpDark.remove(curColorArrayUpDark[curSelectedUp]);
                    noteUpGroup.members[curSelectedUp].destroy();
                    initialPosUp.pop();
                    flushColorTables();
                    game.callOnLuas('quickRestart');
                }
            }
        case 3:
            if (noteRightGroup.members.length != 1){
                if (noteRightGroup.members[curSelectedRight].animation.curAnim.name != 'addNote')
                {
                    curColorArrayRight.remove(curColorArrayRight[curSelectedRight]);
                    curColorArrayRightWhite.remove(curColorArrayRightWhite[curSelectedRight]);
                    curColorArrayRightDark.remove(curColorArrayRightDark[curSelectedRight]);
                    noteRightGroup.members[curSelectedRight].destroy();
                    initialPosRight.pop();
                    flushColorTables();
                    game.callOnLuas('quickRestart');
                }
            }
        case 4:
            if (noteGlobalGroup.members.length != 1) {
                if (noteGlobalGroup.members[curSelectedGlobal].animation.curAnim.name != 'addNote')
                {
                    curColorArrayGlobal.remove(curColorArrayGlobal[curSelectedGlobal]);
                    curColorArrayGlobalWhite.remove(curColorArrayGlobalWhite[curSelectedGlobal]);
                    curColorArrayGlobalDark.remove(curColorArrayGlobalDark[curSelectedGlobal]);
                    noteGlobalGroup.members[curSelectedGlobal].destroy();
                    initialPosGlobal.pop();
                    flushColorTables();
                    game.callOnLuas('quickRestart');
                }
            }
    }
}

function addNote() {
    switch(curSelected) {
        
        case 0:
            if (noteLeftGroup.members[curSelectedLeft].animation.curAnim.name == 'addNote')
            {
                curColorArrayLeft.push('FF7700');
                curColorArrayLeftWhite.push('FFFFFF');
                curColorArrayLeftDark.push('801C00');
                noteLeftGroup.members[curSelectedLeft].texture = 'noteSkins/NOTE_assets' + game.callOnLuas('getNotePostfix');
                noteLeftGroup.members[curSelectedLeft].rgbShader.enabled = true;
                noteLeftGroup.members[curSelectedLeft].rgbShader.r = FlxColor.fromString('#FF7700');
                noteLeftGroup.members[curSelectedLeft].rgbShader.g = FlxColor.fromString('#FFFFFF');
                noteLeftGroup.members[curSelectedLeft].rgbShader.b = FlxColor.fromString('#801C00');
                noteLeftGroup.members[curSelectedLeft].animation.addByPrefix('purble', 'purple', 0);
                noteLeftGroup.members[curSelectedLeft].animation.play('purble');
                noteLeftGroup.members[curSelectedLeft].offset.y = 0;
                var strumNote = new StrumNote(noteLeftGroup.members[curSelectedLeft].x, 120 * noteLeftGroup.members.length, 0, 1);
                strumNote.texture = 'color_select_essentials';
                strumNote.animation.addByPrefix('addNote', 'purple', 0);
                strumNote.animation.play('addNote');
                noteLeftGroup.add(strumNote);
                initialPosLeft.push(strumNote.y);
                var variable = (120 * (noteLeftGroup.members.length-1 % 4)) - 120;
                strumNote.y += -variable;
                strumNote.offset.y = -55;
                strumNote.alpha = 0.5;
                flushColorTables();
            }

        case 1:
            if (noteDownGroup.members[curSelectedDown].animation.curAnim.name == 'addNote')
            {
                curColorArrayDown.push('FF7700');
                curColorArrayDownWhite.push('FFFFFF');
                curColorArrayDownDark.push('801C00');
                noteDownGroup.members[curSelectedDown].texture = 'noteSkins/NOTE_assets' + game.callOnLuas('getNotePostfix');
                noteDownGroup.members[curSelectedDown].rgbShader.enabled = true;
                noteDownGroup.members[curSelectedDown].rgbShader.r = FlxColor.fromString('#FF7700');
                noteDownGroup.members[curSelectedDown].rgbShader.g = FlxColor.fromString('#FFFFFF');
                noteDownGroup.members[curSelectedDown].rgbShader.b = FlxColor.fromString('#801C00');
                noteDownGroup.members[curSelectedDown].animation.addByPrefix('purble', 'blue', 0);
                noteDownGroup.members[curSelectedDown].animation.play('purble');
                noteDownGroup.members[curSelectedDown].offset.y = 0;
                var strumNote = new StrumNote(noteDownGroup.members[curSelectedDown].x, 120 * noteDownGroup.members.length, 0, 1);
                strumNote.texture = 'color_select_essentials';
                strumNote.animation.addByPrefix('addNote', 'blue', 0);
                strumNote.animation.play('addNote');
                initialPosDown.push(strumNote.y);
                noteDownGroup.add(strumNote);
                var variable = (120 * (noteDownGroup.members.length-1 % 4)) - 120;
                strumNote.y += -variable;
                strumNote.offset.y = -55;
                strumNote.alpha = 0.5;
                flushColorTables();
            }

        case 2:
            if (noteUpGroup.members[curSelectedUp].animation.curAnim.name == 'addNote')
            {
                curColorArrayUp.push('FF7700');
                curColorArrayUpWhite.push('FFFFFF');
                curColorArrayUpDark.push('801C00');
                noteUpGroup.members[curSelectedUp].texture = 'noteSkins/NOTE_assets' + game.callOnLuas('getNotePostfix');
                noteUpGroup.members[curSelectedUp].rgbShader.enabled = true;
                noteUpGroup.members[curSelectedUp].rgbShader.r = FlxColor.fromString('#FF7700');
                noteUpGroup.members[curSelectedUp].rgbShader.g = FlxColor.fromString('#FFFFFF');
                noteUpGroup.members[curSelectedUp].rgbShader.b = FlxColor.fromString('#801C00');
                noteUpGroup.members[curSelectedUp].animation.addByPrefix('purble', 'green', 0);
                noteUpGroup.members[curSelectedUp].animation.play('purble');
                noteUpGroup.members[curSelectedUp].offset.y = 0;
                var strumNote = new StrumNote(noteUpGroup.members[curSelectedUp].x, 120 * noteUpGroup.members.length, 0, 1);
                strumNote.texture = 'color_select_essentials';
                strumNote.animation.addByPrefix('addNote', 'green', 0);
                strumNote.animation.play('addNote');
                noteUpGroup.add(strumNote);
                initialPosUp.push(strumNote.y);
                var variable = (120 * (noteUpGroup.members.length-1 % 4)) - 120;
                strumNote.y += -variable;
                strumNote.offset.y = -55;
                strumNote.alpha = 0.5;
                flushColorTables();
            }

        case 3:
            if (noteRightGroup.members[curSelectedRight].animation.curAnim.name == 'addNote')
            {
                curColorArrayRight.push('FF7700');
                curColorArrayRightWhite.push('FFFFFF');
                curColorArrayRightDark.push('801C00');
                noteRightGroup.members[curSelectedRight].texture = 'noteSkins/NOTE_assets' + game.callOnLuas('getNotePostfix');
                noteRightGroup.members[curSelectedRight].rgbShader.enabled = true;
                noteRightGroup.members[curSelectedRight].rgbShader.r = FlxColor.fromString('#FF7700');
                noteRightGroup.members[curSelectedRight].rgbShader.g = FlxColor.fromString('#FFFFFF');
                noteRightGroup.members[curSelectedRight].rgbShader.b = FlxColor.fromString('#801C00');
                noteRightGroup.members[curSelectedRight].animation.addByPrefix('purble', 'red', 0);
                noteRightGroup.members[curSelectedRight].animation.play('purble');
                noteRightGroup.members[curSelectedRight].offset.y = 0;
                var strumNote = new StrumNote(noteRightGroup.members[curSelectedRight].x, 120 * noteRightGroup.members.length, 0, 1);
                strumNote.texture = 'color_select_essentials';
                strumNote.animation.addByPrefix('addNote', 'red', 0);
                strumNote.animation.play('addNote');
                noteRightGroup.add(strumNote);
                var variable = (120 * (noteRightGroup.members.length-1 % 4)) - 120;
                strumNote.y += -variable;
                strumNote.offset.y = -55;
                strumNote.alpha = 0.5;
                flushColorTables();
                initialPosRight.push(strumNote.y);
            }

        case 4:
            if (noteGlobalGroup.members[curSelectedGlobal].animation.curAnim.name == 'addNote')
            {
                curColorArrayGlobal.push('FF7700');
                curColorArrayGlobalWhite.push('FFFFFF');
                curColorArrayGlobalDark.push('801C00');
                noteGlobalGroup.members[curSelectedGlobal].rgbShader.enabled = true;
                noteGlobalGroup.members[curSelectedGlobal].rgbShader.r = FlxColor.fromString('#FF7700');
                noteGlobalGroup.members[curSelectedGlobal].rgbShader.g = FlxColor.fromString('#FFFFFF');
                noteGlobalGroup.members[curSelectedGlobal].rgbShader.b = FlxColor.fromString('#801C00');
                noteGlobalGroup.members[curSelectedGlobal].animation.addByPrefix('purble', 'grey rgb', 0);
                noteGlobalGroup.members[curSelectedGlobal].animation.play('purble');
                noteGlobalGroup.members[curSelectedGlobal].offset.y = 0;
                var strumNote = new StrumNote(noteGlobalGroup.members[curSelectedGlobal].x, 120 * noteGlobalGroup.members.length, 0, 1);
                strumNote.texture = 'color_select_essentials';
                strumNote.animation.addByPrefix('addNote', 'grey', 0);
                strumNote.animation.play('addNote');
                noteGlobalGroup.add(strumNote);
                initialPosGlobal.push(strumNote.y);
                var variable = (120 * (noteGlobalGroup.members.length-1 % 4)) - 120;
                strumNote.y += -variable;
                strumNote.offset.y = -55;
                strumNote.alpha = 0.5;
                flushColorTables();
            }
    }

    updateTexts(false);
}

function onCustomSubstateUpdate(name:String, elapsed:Float)
{
    if (name == 'test') {
        PlayState.instance.setSongTime(0);

        checkForInput();

        globalText.text = switch (curSelected) {
            case 0:
                'Note Table (Left)';
            case 1:
                'Note Table (Down)';
            case 2:
                'Note Table (Up)';
            case 3:
                'Note Table (Right)';
            case 4:
                'Global Table';
        };

        var offset = curSelected == 4 ? 1 : 2;
        globalText.x = selector.x - 30 * offset;

        if (blockInput && FlxG.keys.justPressed.ENTER) {
            for (input in inputBlock) {
                input.hasFocus = false;
                blockInput = false;
            }
        }

        if (!blockInput) {

            if (controls.BACK) {
                game.callOnLuas('leave');
            }

            if (controls.RESET) {
                game.callOnLuas('restart');
            }

            if (controls.ACCEPT) {
                addNote();
            }

            if (FlxG.keys.justPressed.DELETE) {
                deleteNote();
            }

            if (controls.UI_LEFT_P)
                changeSelection(-1, 0);

            if (controls.UI_RIGHT_P)
                changeSelection(1, 0);

            if (controls.UI_UP_P) {
                selector2.animation.play('press');
                changeSelection(-1, curSelected + 1);
            }

            if (controls.UI_DOWN_P) {
                selector.animation.play('press');
                changeSelection(1, curSelected + 1);
            }
            selector.update(elapsed);
            selector2.update(elapsed);
        }
    }
}

function setAlpha() {
    for (i in 0...noteLeftGroup.members.length) {
        if (curSelectedLeft != i) {
            noteLeftGroup.members[i].alpha = 0.5;
            noteLeftGroup.members[i].offset.y = -55;
        }
        if (curSelectedLeft == i) {
            noteLeftGroup.members[i].alpha = 1;
            noteLeftGroup.members[i].offset.y = 0;
        }
    }

    for (i in 0...noteDownGroup.members.length) {
        if (curSelectedDown != i) {
            noteDownGroup.members[i].alpha = 0.5;
            noteDownGroup.members[i].offset.y = -55;
        }
        if (curSelectedDown == i) {
            noteDownGroup.members[i].alpha = 1;
            noteDownGroup.members[i].offset.y = 0;
        }
    }

    for (i in 0...noteUpGroup.members.length) {
        if (curSelectedUp != i) {
            noteUpGroup.members[i].alpha = 0.5;
            noteUpGroup.members[i].offset.y = -55;
        }
        if (curSelectedUp == i) {
            noteUpGroup.members[i].alpha = 1;
            noteUpGroup.members[i].offset.y = 0;
        }
    }

    for (i in 0...noteRightGroup.members.length) {
        if (curSelectedRight != i) {
            noteRightGroup.members[i].alpha = 0.5;
            noteRightGroup.members[i].offset.y = -55;
        }
        if (curSelectedRight == i) {
            noteRightGroup.members[i].alpha = 1;
            noteRightGroup.members[i].offset.y = 0;
        }
    }

    for (i in 0...noteGlobalGroup.members.length) {
        if (curSelectedGlobal != i) {
            noteGlobalGroup.members[i].alpha = 0.5;
            noteGlobalGroup.members[i].offset.y = -55;
        }
        if (curSelectedGlobal == i) {
            noteGlobalGroup.members[i].alpha = 1;
            noteGlobalGroup.members[i].offset.y = 0;
        }
    }
}

function updateTexts(movedSelector:Bool) {
    if (movedSelector) {
        switch (curSelected) {
            case 0:
                canMoveSelector = false;
                FlxTween.tween(selector, {x: noteLeftGroup.members[0].x + 22}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                    canMoveSelector = true;
                }});
                FlxTween.tween(selector2, {x: noteLeftGroup.members[0].x + 22}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                    canMoveSelector = true;
                }});

            case 1:
                canMoveSelector = false;
                FlxTween.tween(selector, {x: noteDownGroup.members[0].x + 22}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                    canMoveSelector = true;
                }});
                FlxTween.tween(selector2, {x: noteDownGroup.members[0].x + 22}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                    canMoveSelector = true;
                }});

            case 2:
                canMoveSelector = false;
                FlxTween.tween(selector, {x: noteUpGroup.members[0].x + 22}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                    canMoveSelector = true;
                }});
                FlxTween.tween(selector2, {x: noteUpGroup.members[0].x + 22}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                    canMoveSelector = true;
                }});

            case 3:
                canMoveSelector = false;
                FlxTween.tween(selector, {x: noteRightGroup.members[0].x + 22}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                    canMoveSelector = true;
                    }});
                    FlxTween.tween(selector2, {x: noteRightGroup.members[0].x + 22}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                        canMoveSelector = true;
                    }});

            case 4:
                canMoveSelector = false;
                FlxTween.tween(selector, {x: noteGlobalGroup.members[0].x + 22}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                    canMoveSelector = true;
                }});
                FlxTween.tween(selector2, {x: noteGlobalGroup.members[0].x + 22}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                canMoveSelector = true;
                }});
        }
    }
    
    // Base Color
    colorInput.text = switch (curSelected) {
        case 0:
            curColorArrayLeft[curSelectedLeft];
        case 1:
            curColorArrayDown[curSelectedDown];
        case 2:
            curColorArrayUp[curSelectedUp];
        case 3:
            curColorArrayRight[curSelectedRight];
        case 4:
            curColorArrayGlobal[curSelectedGlobal];
    };

    colorInputR.value = acquireRGBArray(switch (curSelected) {
        case 0:
            curColorArrayLeft[curSelectedLeft];
        case 1:
            curColorArrayDown[curSelectedDown];
        case 2:
            curColorArrayUp[curSelectedUp];
        case 3:
            curColorArrayRight[curSelectedRight];
        case 4:
            curColorArrayGlobal[curSelectedGlobal];
    })[0];
    colorInputG.value = acquireRGBArray(switch (curSelected) {
        case 0:
            curColorArrayLeft[curSelectedLeft];
        case 1:
            curColorArrayDown[curSelectedDown];
        case 2:
            curColorArrayUp[curSelectedUp];
        case 3:
            curColorArrayRight[curSelectedRight];
        case 4:
            curColorArrayGlobal[curSelectedGlobal];
    })[1];
    colorInputB.value = acquireRGBArray(switch (curSelected) {
        case 0:
            curColorArrayLeft[curSelectedLeft];
        case 1:
            curColorArrayDown[curSelectedDown];
        case 2:
            curColorArrayUp[curSelectedUp];
        case 3:
            curColorArrayRight[curSelectedRight];
        case 4:
            curColorArrayGlobal[curSelectedGlobal];
    })[2];

    // Outline Color
    colorInputDark.text = switch (curSelected) {
        case 0:
            curColorArrayLeftDark[curSelectedLeft];
        case 1:
            curColorArrayDownDark[curSelectedDown];
        case 2:
            curColorArrayUpDark[curSelectedUp];
        case 3:
            curColorArrayRightDark[curSelectedRight];
        case 4:
            curColorArrayGlobalDark[curSelectedGlobal];
    };
    
    colorInputDarkR.value = acquireRGBArray(switch (curSelected) {
        case 0:
            curColorArrayLeftDark[curSelectedLeft];
        case 1:
            curColorArrayDownDark[curSelectedDown];
        case 2:
            curColorArrayUpDark[curSelectedUp];
        case 3:
            curColorArrayRightDark[curSelectedRight];
        case 4:
            curColorArrayGlobalDark[curSelectedGlobal];
    })[0];
    colorInputDarkG.value = acquireRGBArray(switch (curSelected) {
        case 0:
            curColorArrayLeftDark[curSelectedLeft];
        case 1:
            curColorArrayDownDark[curSelectedDown];
        case 2:
            curColorArrayUpDark[curSelectedUp];
        case 3:
            curColorArrayRightDark[curSelectedRight];
        case 4:
            curColorArrayGlobalDark[curSelectedGlobal];
    })[1];
    colorInputDarkB.value = acquireRGBArray(switch (curSelected) {
        case 0:
            curColorArrayLeftDark[curSelectedLeft];
        case 1:
            curColorArrayDownDark[curSelectedDown];
        case 2:
            curColorArrayUpDark[curSelectedUp];
        case 3:
            curColorArrayRightDark[curSelectedRight];
        case 4:
            curColorArrayGlobalDark[curSelectedGlobal];
    })[2];

    // White Color
    colorInputWhite.text = switch (curSelected) {
        case 0:
            curColorArrayLeftWhite[curSelectedLeft];
        case 1:
            curColorArrayDownWhite[curSelectedDown];
        case 2:
            curColorArrayUpWhite[curSelectedUp];
        case 3:
            curColorArrayRightWhite[curSelectedRight];
        case 4:
            curColorArrayGlobalWhite[curSelectedGlobal];
    };

    colorInputWhiteR.value = acquireRGBArray(switch (curSelected) {
        case 0:
            curColorArrayLeftWhite[curSelectedLeft];
        case 1:
            curColorArrayDownWhite[curSelectedDown];
        case 2:
            curColorArrayUpWhite[curSelectedUp];
        case 3:
            curColorArrayRightWhite[curSelectedRight];
        case 4:
            curColorArrayGlobalWhite[curSelectedGlobal];
    })[0];
    colorInputWhiteG.value = acquireRGBArray(switch (curSelected) {
        case 0:
            curColorArrayLeftWhite[curSelectedLeft];
        case 1:
            curColorArrayDownWhite[curSelectedDown];
        case 2:
            curColorArrayUpWhite[curSelectedUp];
        case 3:
            curColorArrayRightWhite[curSelectedRight];
        case 4:
            curColorArrayGlobalWhite[curSelectedGlobal];
    })[1];
    colorInputWhiteB.value = acquireRGBArray(switch (curSelected) {
        case 0:
            curColorArrayLeftWhite[curSelectedLeft];
        case 1:
            curColorArrayDownWhite[curSelectedDown];
        case 2:
            curColorArrayUpWhite[curSelectedUp];
        case 3:
            curColorArrayRightWhite[curSelectedRight];
        case 4:
            curColorArrayGlobalWhite[curSelectedGlobal];
    })[2];
}

function changeSelection(change:Int = 0, direction:Int = 0) {
    if (canMove) {
        var mustRevert:Bool = false;
        var mustLoop:Bool = false;
        switch (direction) {
            case 0:
                if (canMoveSelector) {
                    curSelected += change;
                    if (curSelected > 4)
                        curSelected = 0;
                    if (curSelected < 0)
                        curSelected = 4;

                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    updateTexts(true);
                }

            case 1:
                curSelectedLeft += change;

                if (curSelectedLeft >= noteLeftGroup.members.length){
                    curSelectedLeft = 0;
                    mustRevert = true;
                }
                if (curSelectedLeft < 0){
                    curSelectedLeft = noteLeftGroup.members.length-1;
                    mustLoop = true;
                }

                canMove = false;

                for (i in 0...noteLeftGroup.members.length) {
                    if (curSelectedLeft != i) {
                        noteLeftGroup.members[i].alpha = 0.5;
                        noteLeftGroup.members[i].offset.y = -55;
                        if (noteLeftGroup.members[i].y < noteLeftGroup.members[curSelectedLeft].y) {
                            noteLeftGroup.members[i].offset.y = 55;
                        }
                    }
                    if (curSelectedLeft == i) {
                        noteLeftGroup.members[i].alpha = 1;
                        noteLeftGroup.members[i].offset.y = 0;
                    }
                    if (mustRevert) {
                        FlxTween.tween(noteLeftGroup.members[i], {y: initialPosLeft[i]}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                            selector.animation.play('idle');
                            selector2.animation.play('idle');
                        }});
                    }
                    if (mustLoop) {
                        var variable = 120 * (noteLeftGroup.members.length-1 % 4);
                        FlxTween.tween(noteLeftGroup.members[i], {y: initialPosLeft[i] + -variable}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                                canMove = true;
                                selector.animation.play('idle');
                                selector2.animation.play('idle');
                        }});
                    }
                    if (!mustLoop && !mustRevert) {
                        var int = change < 0 ? 120 : -120;
                        FlxTween.tween(noteLeftGroup.members[i], {y: noteLeftGroup.members[i].y + int}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                            selector.animation.play('idle');
                            selector2.animation.play('idle');
                        }});
                    }
                }
                updateTexts(false);
                
                FlxG.sound.play(Paths.sound('scrollMenu'));

            case 2:
                curSelectedDown += change;
                if (curSelectedDown >= noteDownGroup.members.length){
                    curSelectedDown = 0;
                    mustRevert = true;
                }
                if (curSelectedDown < 0) {
                    curSelectedDown = noteDownGroup.members.length-1;
                    mustLoop = true;
                }

                canMove = false;
                
                for (i in 0...noteDownGroup.members.length) {
                    if (curSelectedDown != i) {
                        noteDownGroup.members[i].alpha = 0.5;
                        noteDownGroup.members[i].offset.y = -55;
                        if (noteDownGroup.members[i].y < noteDownGroup.members[curSelectedDown].y) {
                            noteDownGroup.members[i].offset.y = 55;
                        }
                    }
                    if (curSelectedDown == i) {
                        noteDownGroup.members[i].alpha = 1;
                        noteDownGroup.members[i].offset.y = 0;
                    }
                    if (mustRevert) {
                        FlxTween.tween(noteDownGroup.members[i], {y: initialPosDown[i]}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                            selector.animation.play('idle');
                            selector2.animation.play('idle');
                        }});
                    }
                    if (mustLoop) {
                        var variable = 120 * (noteDownGroup.members.length-1 % 4);
                        FlxTween.tween(noteDownGroup.members[i], {y: initialPosDown[i] + -variable}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                            selector.animation.play('idle');
                            selector2.animation.play('idle');
                        }});
                    }
                    if (!mustLoop && !mustRevert) {
                        var int = change < 0 ? 120 : -120;
                        FlxTween.tween(noteDownGroup.members[i], {y: noteDownGroup.members[i].y + int}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                            selector.animation.play('idle');
                            selector2.animation.play('idle');
                        }});
                    }
                }
                updateTexts(false);
                FlxG.sound.play(Paths.sound('scrollMenu'));

            case 3:
                curSelectedUp += change;
                if (curSelectedUp >= noteUpGroup.members.length){
                    curSelectedUp = 0;
                    mustRevert = true;
                }
                if (curSelectedUp < 0) {
                    curSelectedUp = noteUpGroup.members.length-1;
                    mustLoop = true;
                }

                canMove = false;
                updateTexts(false);

                for (i in 0...noteUpGroup.members.length) {
                    if (curSelectedUp != i) {
                        noteUpGroup.members[i].alpha = 0.5;
                        noteUpGroup.members[i].offset.y = -55;
                        if (noteUpGroup.members[i].y < noteUpGroup.members[curSelectedUp].y) {
                            noteUpGroup.members[i].offset.y = 55;
                        }
                    }
                    if (curSelectedUp == i) {
                        noteUpGroup.members[i].alpha = 1;
                        noteUpGroup.members[i].offset.y = 0;
                    }
                    if (mustRevert) {
                        FlxTween.tween(noteUpGroup.members[i], {y: initialPosUp[i]}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                            selector.animation.play('idle');
                            selector2.animation.play('idle');
                        }});
                    }
                    if (mustLoop) {
                        var variable = 120 * (noteUpGroup.members.length-1 % 4);
                        FlxTween.tween(noteUpGroup.members[i], {y: initialPosUp[i] + -variable}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                            selector.animation.play('idle');
                            selector2.animation.play('idle');
                        }});
                    }
                    if (!mustLoop && !mustRevert) {
                        var int = change < 0 ? 120 : -120;
                        FlxTween.tween(noteUpGroup.members[i], {y: noteUpGroup.members[i].y + int}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                            selector.animation.play('idle');
                            selector2.animation.play('idle');
                        }});
                    }
                }
                FlxG.sound.play(Paths.sound('scrollMenu'));

            case 4:
                curSelectedRight += change;
                if (curSelectedRight >= noteRightGroup.members.length){
                    curSelectedRight = 0;
                    mustRevert = true;
                }
                if (curSelectedRight < 0) {
                    curSelectedRight = noteRightGroup.members.length-1;
                    mustLoop = true;
                }

                canMove = false;
                updateTexts(false);

                for (i in 0...noteRightGroup.members.length) {
                    if (curSelectedRight != i) {
                        noteRightGroup.members[i].alpha = 0.5;
                        noteRightGroup.members[i].offset.y = -55;
                        if (noteRightGroup.members[i].y < noteRightGroup.members[curSelectedRight].y) {
                            noteRightGroup.members[i].offset.y = 55;
                        }
                    }
                    if (curSelectedRight == i) {
                        noteRightGroup.members[i].alpha = 1;
                        noteRightGroup.members[i].offset.y = 0;
                    }
                    if (mustRevert) {
                        FlxTween.tween(noteRightGroup.members[i], {y: initialPosRight[i]}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                            selector.animation.play('idle');
                            selector2.animation.play('idle');
                        }});
                    }
                    if (mustLoop) {
                        var variable = 120 * (noteRightGroup.members.length-1 % 4);
                        FlxTween.tween(noteRightGroup.members[i], {y: initialPosRight[i] + -variable}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                            selector.animation.play('idle');
                            selector2.animation.play('idle');
                        }});
                    }
                    if (!mustLoop && !mustRevert) {
                        var int = change < 0 ? 120 : -120;
                        FlxTween.tween(noteRightGroup.members[i], {y: noteRightGroup.members[i].y + int}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                            selector.animation.play('idle');
                            selector2.animation.play('idle');
                        }});
                    }
                }
                FlxG.sound.play(Paths.sound('scrollMenu'));

            case 5:
                curSelectedGlobal += change;
                if (curSelectedGlobal >= noteGlobalGroup.members.length){
                    curSelectedGlobal = 0;
                    mustRevert = true;
                }
                if (curSelectedGlobal < 0) {
                    curSelectedGlobal = noteGlobalGroup.members.length-1;
                    mustLoop = true;
                }

                canMove = false;
                updateTexts(false);

                for (i in 0...noteGlobalGroup.members.length) {
                    if (curSelectedGlobal != i) {
                        noteGlobalGroup.members[i].alpha = 0.5;
                        noteGlobalGroup.members[i].offset.y = -55;
                        if (noteGlobalGroup.members[i].y < noteGlobalGroup.members[curSelectedGlobal].y) {
                            noteGlobalGroup.members[i].offset.y = 55;
                        }
                    }
                    if (curSelectedGlobal == i) {
                        noteGlobalGroup.members[i].alpha = 1;
                        noteGlobalGroup.members[i].offset.y = 0;
                    }
                    if (mustRevert) {
                        FlxTween.tween(noteGlobalGroup.members[i], {y: initialPosGlobal[i]}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                            selector.animation.play('idle');
                            selector2.animation.play('idle');
                        }});
                    }
                    if (mustLoop) {
                        var variable = 120 * (noteGlobalGroup.members.length-1 % 4);
                        FlxTween.tween(noteGlobalGroup.members[i], {y: initialPosGlobal[i] + -variable}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                            selector.animation.play('idle');
                            selector2.animation.play('idle');
                        }});
                    }
                    if (!mustLoop && !mustRevert) {
                        var int = change < 0 ? 120 : -120;
                        FlxTween.tween(noteGlobalGroup.members[i], {y: noteGlobalGroup.members[i].y + int}, 0.2, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                            selector.animation.play('idle');
                            selector2.animation.play('idle');
                        }});
                    }
                }
                FlxG.sound.play(Paths.sound('scrollMenu'));
        }
    }
}

function doNoteScreenSpawn() {
    for (i in 0...curColorArrayLeft.length) {
        var strumNote = new StrumNote(FlxG.width * 0.15, 120 * noteLeftGroup.members.length, 0, 1);
        strumNote.rgbShader.enabled = true;
        strumNote.rgbShader.r = FlxColor.fromString('#' + curColorArrayLeft[i]);
        strumNote.rgbShader.g = FlxColor.fromString('#' + curColorArrayLeftWhite[i]);
        strumNote.rgbShader.b = FlxColor.fromString('#' + curColorArrayLeftDark[i]);
        strumNote.animation.addByPrefix('purble', 'purple', 0);
        strumNote.animation.play('purble');
        noteLeftGroup.add(strumNote);
        initialPosLeft.push(strumNote.y);
    }

    var strumNote = new StrumNote(FlxG.width * 0.15, 120 * noteLeftGroup.members.length, 0, 1);
    strumNote.texture = 'color_select_essentials';
    strumNote.animation.addByPrefix('addNote', 'purple', 0);
    strumNote.animation.play('addNote');
    noteLeftGroup.add(strumNote);
    initialPosLeft.push(strumNote.y);

    
    for (i in 0...curColorArrayDown.length) {
        var strumNote = new StrumNote(FlxG.width * 0.25, 120 * noteDownGroup.members.length, 1, 1);
        strumNote.rgbShader.enabled = true;
        strumNote.rgbShader.r = FlxColor.fromString('#' + curColorArrayDown[i]);
        strumNote.rgbShader.g = FlxColor.fromString('#' + curColorArrayDownWhite[i]);
        strumNote.rgbShader.b = FlxColor.fromString('#' + curColorArrayDownDark[i]);
        strumNote.animation.addByPrefix('purble', 'blue', 0);
        strumNote.animation.play('purble');
        noteDownGroup.add(strumNote);
        initialPosDown.push(strumNote.y);
    }

    var strumNote = new StrumNote(FlxG.width * 0.25, 120 * noteDownGroup.members.length, 0, 1);
    strumNote.texture = 'color_select_essentials';
    strumNote.animation.addByPrefix('addNote', 'blue', 0);
    strumNote.animation.play('addNote');
    noteDownGroup.add(strumNote);
    initialPosDown.push(strumNote.y);
    
    for (i in 0...curColorArrayUp.length) {
        var strumNote = new StrumNote(FlxG.width * 0.35, 120 * noteUpGroup.members.length, 2, 1);
        strumNote.rgbShader.enabled = true;
        strumNote.rgbShader.r = FlxColor.fromString('#' + curColorArrayUp[i]);
        strumNote.rgbShader.g = FlxColor.fromString('#' + curColorArrayUpWhite[i]);
        strumNote.rgbShader.b = FlxColor.fromString('#' + curColorArrayUpDark[i]);
        strumNote.animation.addByPrefix('purble', 'green', 0);
        strumNote.animation.play('purble');
        noteUpGroup.add(strumNote);
        initialPosUp.push(strumNote.y);
    }

    var strumNote = new StrumNote(FlxG.width * 0.35, 120 * noteUpGroup.members.length, 0, 1);
    strumNote.texture = 'color_select_essentials';
    strumNote.animation.addByPrefix('addNote', 'green', 0);
    strumNote.animation.play('addNote');
    noteUpGroup.add(strumNote);
    initialPosUp.push(strumNote.y);
    
    for (i in 0...curColorArrayRight.length) {
        var strumNote = new StrumNote(FlxG.width * 0.45, 120 * noteRightGroup.members.length, 3, 1);
        strumNote.rgbShader.enabled = true;
        strumNote.rgbShader.r = FlxColor.fromString('#' + curColorArrayRight[i]);
        strumNote.rgbShader.g = FlxColor.fromString('#' + curColorArrayRightWhite[i]);
        strumNote.rgbShader.b = FlxColor.fromString('#' + curColorArrayRightDark[i]);
        strumNote.animation.addByPrefix('purble', 'red', 0);
        strumNote.animation.play('purble');
        noteRightGroup.add(strumNote);
        initialPosRight.push(strumNote.y);
    }

    var strumNote = new StrumNote(FlxG.width * 0.45, 120 * noteRightGroup.members.length, 0, 1);
    strumNote.texture = 'color_select_essentials';
    strumNote.animation.addByPrefix('addNote', 'red', 0);
    strumNote.animation.play('addNote');
    noteRightGroup.add(strumNote);
    initialPosRight.push(strumNote.y);
    
    for (i in 0...curColorArrayGlobal.length) {
        var strumNote = new StrumNote(FlxG.width * 0.55, 120 * noteGlobalGroup.members.length, 0, 1);
        strumNote.rgbShader.enabled = true;
        strumNote.rgbShader.r = FlxColor.fromString('#' + curColorArrayGlobal[i]);
        strumNote.rgbShader.g = FlxColor.fromString('#' + curColorArrayGlobalWhite[i]);
        strumNote.rgbShader.b = FlxColor.fromString('#' + curColorArrayGlobalDark[i]);
        strumNote.texture = 'color_select_essentials';
        strumNote.animation.addByPrefix('purble', 'grey rgb', 0);
        strumNote.animation.play('purble');
        noteGlobalGroup.add(strumNote);
        initialPosGlobal.push(strumNote.y);
    }

    var strumNote = new StrumNote(FlxG.width * 0.55, 120 * noteGlobalGroup.members.length, 0, 1);
    strumNote.texture = 'color_select_essentials';
    strumNote.animation.addByPrefix('addNote', 'grey', 0);
    strumNote.animation.play('addNote');
    noteGlobalGroup.add(strumNote);
    initialPosGlobal.push(strumNote.y);
}