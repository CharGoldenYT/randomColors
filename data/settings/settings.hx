import backend.Paths;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import objects.Note;
import sys.io.File;
import sys.io.FileSystem;

var BG:FlxSprite;

// Left Note Shit.
var noteLeftGroup:FlxTypedGroup<Note>;
var curColorArrayLeft:Array<FlxColor> = [];
var leftArrowCam:FlxCamera;

// Down Note Shit.
var noteDownGroup:FlxTypedGroup<Note>;
var curColorArrayDown:Array<FlxColor> = [];
var downArrowCam:FlxCamera;

// Up Arrow Shit.
var noteUpGroup:FlxTypedGroup<Note>;
var curColorArrayUp:Array<FlxColor> = [];
var upArrowCam:FlxCamera;

// Right Arrow Shit.
var noteRightGroup:FlxTypedGroup<Note>;
var curColorArrayRight:Array<FlxColor> = [];
var rightArrowCam:FlxCamera;

// Global Arrow Shit.
var noteGlobalGroup:FlxTypedGroup<Note>;
var curColorArrayGlobal:Array<FlxColor> = [];
var globalArrowCam:FlxCamera;

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
}

function onCustomSubstateUpdate(name:String, elapsed:Float)
{
    if (name == 'test' && FlxG.keys.justPressed.ENTER) {
        game.callOnLuas('openSubState', 'noteColorSelectorSubState')
    }
}

function doFileCheck() {
    for (path in paths) {
        path = 'mods/randomColors/data/colors/' + path + '.txt';
        if (!FileSystem.exists(path)) {
            File.saveContent(path, 'FFFFFF\nFFFFFF\nFFFFFF\nFFFFFF\nFFFFFF\nFFFFFF\nFFFFFF')
        }
    }
}

function doNoteScreenSpawn() {

}