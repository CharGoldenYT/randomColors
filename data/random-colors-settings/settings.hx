import backend.Paths;
import backend.Mods;
import backend.ClientPrefs;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import objects.StrumNote;
import sys.io.File;
import sys.io.FileSystem;
import states.PlayState;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;

using StringTools;

var BG:FlxSprite;

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

var selector:FlxSprite;
var selector2:FlxSprite;

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

function onCustomSubstateCreate(name:String) {
    doFileCheck();
    setupArrays();
    FlxG.sound.playMusic(Paths.music('offsetSong'));
    BG = new FlxSprite().loadGraphic(Paths.image('menuBG'));
    BG.screenCenter();
    BG.cameras = [PlayState.instance.camOther];
    BG.alpha = 0.6;
    BG.scrollFactor.set(0, 0);
    add(BG);
    
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

    camFollow = new FlxObject(0, 0, 10, 10);
    camFollow.screenCenter();
    camFollow.y += -300;
    camFollow.x += 70;
    camOther.zoom = 1.15;
    PlayState.instance.camOther.follow(camFollow, null, 1);
    doNoteScreenSpawn();
    setAlpha();

    selector = new FlxSprite().loadGraphic(Paths.image('buttons'));
    selector.frames = Paths.getSparrowAtlas('buttons');
    selector.animation.addByPrefix('idle', 'arrow Down', 0);
    selector.animation.addByPrefix('press', 'arrow down press', 0);
    selector.setGraphicSize(Std.int(selector.width * 0.8));
    selector.updateHitbox();
    selector.cameras = [PlayState.instance.camOther];
    selector.screenCenter();
    selector.y += -190;
    selector.x = noteLeftGroup.members[0].x + 15;
    add(selector);

    selector2 = new FlxSprite().loadGraphic(Paths.image('buttons'));
    selector2.frames = Paths.getSparrowAtlas('buttons');
    selector2.animation.addByPrefix('idle', 'arrow Up', 0);
    selector2.animation.addByPrefix('press', 'arrow up press', 0);
    selector2.setGraphicSize(Std.int(selector2.width * 0.8));
    selector2.updateHitbox();
    selector2.cameras = [PlayState.instance.camOther];
    selector2.screenCenter();
    selector2.y += -370;
    selector2.x = noteLeftGroup.members[0].x + 15;
    selector2.flipY = true;
    add(selector2);
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

function onCustomSubstateUpdate(name:String, elapsed:Float)
{
    if (name == 'test') {
        if (FlxG.keys.justPressed.ENTER)
            game.callOnLuas('openSubState', 'noteColorSelectorSubState');

        if (FlxG.keys.justPressed.LEFT)
            changeSelection(-1, 0);

        if (FlxG.keys.justPressed.RIGHT)
            changeSelection(1, 0);

        if (FlxG.keys.justPressed.UP)
            changeSelection(-1, curSelected + 1);

        if (FlxG.keys.justPressed.DOWN)
            changeSelection(1, curSelected + 1);

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

/**
var curSelectedLeft:Int = 0;
var curSelectedDown:Int = 0;
var curSelectedUp:Int = 0;
var curSelectedRight:Int = 0;
var curSelectedGlobal:Int = 0; 
 */
 var canMove:Bool = true;
 var initialPosLeft:Array<Int> = [];
 var initialPosDown:Array<Int> = [];
 var initialPosUp:Array<Int> = [];
 var initialPosRight:Array<Int> = [];
 var initialPosGlobal:Array<Int> = [];
function changeSelection(change:Int = 0, direction:Int = 0) {
    if (canMove) {
        var mustRevert:Bool = false;
        var mustLoop:Bool = false;
        switch (direction) {
            case 0:
                curSelected += change;
                if (curSelected > 4)
                    curSelected = 0;
                if (curSelected < 0)
                    curSelected = 4;

                FlxG.sound.play(Paths.sound('scrollMenu'));

                switch (curSelected) {
                    case 0:
                        selector.x = noteLeftGroup.members[0].x + 15;
                        selector2.x = noteLeftGroup.members[0].x + 15;
                    case 1:
                        selector.x = noteDownGroup.members[0].x + 15;
                        selector2.x = noteDownGroup.members[0].x + 15;
                    case 2:
                        selector.x = noteUpGroup.members[0].x + 15;
                        selector2.x = noteUpGroup.members[0].x + 15;
                    case 3:
                        selector.x = noteRightGroup.members[0].x + 15;
                        selector2.x = noteRightGroup.members[0].x + 15;
                    case 4:
                        selector.x = noteGlobalGroup.members[0].x + 15;
                        selector2.x = noteGlobalGroup.members[0].x + 15;
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
                    }
                    if (curSelectedLeft == i) {
                        noteLeftGroup.members[i].alpha = 1;
                        noteLeftGroup.members[i].offset.y = 0;
                    }
                    if (mustRevert) {
                        FlxTween.tween(noteLeftGroup.members[i], {y: initialPosLeft[i]}, 0.1, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                        }});
                    }
                    if (mustLoop) {
                        var variable = 120 * (noteLeftGroup.members.length-1 % 4);
                        FlxTween.tween(noteLeftGroup.members[i], {y: initialPosLeft[i] + -variable}, 0.1, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                        }});
                    }
                    if (!mustLoop && !mustRevert) {
                        var int = change < 0 ? 120 : -120;
                        FlxTween.tween(noteLeftGroup.members[i], {y: noteLeftGroup.members[i].y + int}, 0.1, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                        }});
                    }
                }
                
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

                
                for (i in 0...noteDownGroup.members.length) {
                    if (curSelectedDown != i) {
                        noteDownGroup.members[i].alpha = 0.5;
                        noteDownGroup.members[i].offset.y = -55;
                    }
                    if (curSelectedDown == i) {
                        noteDownGroup.members[i].alpha = 1;
                        noteDownGroup.members[i].offset.y = 0;
                    }
                    if (mustRevert) {
                        FlxTween.tween(noteDownGroup.members[i], {y: initialPosDown[i]}, 0.1, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                        }});
                    }
                    if (mustLoop) {
                        var variable = 120 * (noteDownGroup.members.length-1 % 4);
                        FlxTween.tween(noteDownGroup.members[i], {y: initialPosDown[i] + -variable}, 0.1, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                        }});
                    }
                    if (!mustLoop && !mustRevert) {
                        var int = change < 0 ? 120 : -120;
                        FlxTween.tween(noteDownGroup.members[i], {y: noteDownGroup.members[i].y + int}, 0.1, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                        }});
                    }
                }
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

                for (i in 0...noteUpGroup.members.length) {
                    if (curSelectedUp != i) {
                        noteUpGroup.members[i].alpha = 0.5;
                        noteUpGroup.members[i].offset.y = -55;
                    }
                    if (curSelectedUp == i) {
                        noteUpGroup.members[i].alpha = 1;
                        noteUpGroup.members[i].offset.y = 0;
                    }
                    if (mustRevert) {
                        FlxTween.tween(noteUpGroup.members[i], {y: initialPosUp[i]}, 0.1, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                        }});
                    }
                    if (mustLoop) {
                        var variable = 120 * (noteUpGroup.members.length-1 % 4);
                        FlxTween.tween(noteUpGroup.members[i], {y: initialPosUp[i] + -variable}, 0.1, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                        }});
                    }
                    if (!mustLoop && !mustRevert) {
                        var int = change < 0 ? 120 : -120;
                        FlxTween.tween(noteUpGroup.members[i], {y: noteUpGroup.members[i].y + int}, 0.1, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
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

                for (i in 0...noteRightGroup.members.length) {
                    if (curSelectedRight != i) {
                        noteRightGroup.members[i].alpha = 0.5;
                        noteRightGroup.members[i].offset.y = -55;
                    }
                    if (curSelectedRight == i) {
                        noteRightGroup.members[i].alpha = 1;
                        noteRightGroup.members[i].offset.y = 0;
                    }
                    if (mustRevert) {
                        FlxTween.tween(noteRightGroup.members[i], {y: initialPosRight[i]}, 0.1, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                        }});
                    }
                    if (mustLoop) {
                        var variable = 120 * (noteRightGroup.members.length-1 % 4);
                        FlxTween.tween(noteRightGroup.members[i], {y: initialPosRight[i] + -variable}, 0.1, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                        }});
                    }
                    if (!mustLoop && !mustRevert) {
                        var int = change < 0 ? 120 : -120;
                        FlxTween.tween(noteRightGroup.members[i], {y: noteRightGroup.members[i].y + int}, 0.1, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
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

                for (i in 0...noteGlobalGroup.members.length) {
                    if (curSelectedGlobal != i) {
                        noteGlobalGroup.members[i].alpha = 0.5;
                        noteGlobalGroup.members[i].offset.y = -55;
                    }
                    if (curSelectedGlobal == i) {
                        noteGlobalGroup.members[i].alpha = 1;
                        noteGlobalGroup.members[i].offset.y = 0;
                    }
                    if (mustRevert) {
                        FlxTween.tween(noteGlobalGroup.members[i], {y: initialPosGlobal[i]}, 0.1, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                        }});
                    }
                    if (mustLoop) {
                        var variable = 120 * (noteGlobalGroup.members.length-1 % 4);
                        FlxTween.tween(noteGlobalGroup.members[i], {y: initialPosGlobal[i] + -variable}, 0.1, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                        }});
                    }
                    if (!mustLoop && !mustRevert) {
                        var int = change < 0 ? 120 : -120;
                        FlxTween.tween(noteGlobalGroup.members[i], {y: noteGlobalGroup.members[i].y + int}, 0.1, {ease: FlxEase.quartOut, onComplete: function(twn:Flxtween) {
                            canMove = true;
                        }});
                    }
                }
                FlxG.sound.play(Paths.sound('scrollMenu'));
        }
    }
}

function doFileCheck() {
    for (path in paths) {
        path = 'mods/randomColors/data/colors/' + path + '.txt';
        if (!FileSystem.exists(path)) {
            File.saveContent(path, 'FFFFFF\nFFFFFF');
        }
    }
}

//x:Float, y:Float, leData:Int, player:Int

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
    strumNote.animation.addByPrefix('purble', 'purple', 0);
    strumNote.animation.play('purble');
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
    strumNote.animation.addByPrefix('purble', 'blue', 0);
    strumNote.animation.play('purble');
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
    strumNote.animation.addByPrefix('purble', 'green', 0);
    strumNote.animation.play('purble');
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
    strumNote.animation.addByPrefix('purble', 'red', 0);
    strumNote.animation.play('purble');
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
    strumNote.animation.addByPrefix('purble', 'grey', 0);
    strumNote.animation.play('purble');
    noteGlobalGroup.add(strumNote);
    initialPosGlobal.push(strumNote.y);
}