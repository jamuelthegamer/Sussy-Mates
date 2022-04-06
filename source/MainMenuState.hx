package;

import lime.ui.MouseButton;
import flixel.addons.display.FlxBackdrop;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.1'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var modVer:String = " DEMO";

	var starFG:FlxBackdrop;
	var starBG:FlxBackdrop;
	var logo:FlxSprite;
	
	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'credits',
		'options'
	];

	var debugKeys:Array<FlxKey>;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		FlxG.mouse.visible = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		
		starBG = new FlxBackdrop(Paths.image('mainmenu/starBG'), 1, 1, true, true);
		starBG.updateHitbox();
		starBG.antialiasing = true;
		starBG.scrollFactor.set();
		add(starBG);

		starFG = new FlxBackdrop(Paths.image('mainmenu/starFG'), 1, 1, true, true);
		starFG.updateHitbox();
		starFG.antialiasing = true;
		starFG.scrollFactor.set();
		add(starFG);

		logo = new FlxSprite(0, -350);
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.animation.addByPrefix('idle', 'logo bumpin', 24, false);
		logo.setGraphicSize(Std.int(logo.width * 0.47));
		logo.updateHitbox();
		logo.screenCenter(X);
		add(logo);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 208 - (Math.max(optionShit.length, 4) - 4) * 80;
			var offY:Float = FlxG.height * 0.8;
			var menuItem:FlxSprite = new FlxSprite();
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/buttons');
			menuItem.animation.addByPrefix('idle', optionShit[i] + " idle", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " sel", 24);
			menuItem.animation.play('idle');
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.updateHitbox();
			menuItem.screenCenter(X);
			menuItem.ID = i;
			menuItems.add(menuItem);
			switch(i) {
				case 0:
					menuItem.y = (i * 180) + offset;
					menuItem.setGraphicSize(Std.int(menuItem.width * 0.9));
					menuItem.updateHitbox();
				case 1:
					menuItem.y = (i * 180) + offset;
					menuItem.setGraphicSize(Std.int(menuItem.width * 0.9));
					menuItem.updateHitbox();
				case 2:
					menuItem.x -= 100;
					menuItem.y = offY;
				case 3:
					menuItem.x += 100;
					menuItem.y = offY;
			}
		}

		var verBG:FlxSprite = new FlxSprite(0, FlxG.height + 28).makeGraphic(FlxG.width, FlxG.height - 28, FlxColor.fromRGB(80, 80, 80, 180));
		verBG.updateHitbox();
		add(verBG);

		var versionShit:FlxText = new FlxText(12, FlxG.height + 24, 0, "FNF': VS Sussy Mates" + " - Psych Engine v" + psychEngineVersion, 12);
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.scrollFactor.set();
		versionShit.updateHitbox();
		versionShit.screenCenter(X);
		add(versionShit);
		
		FlxTween.tween(logo, {y: -35}, 1.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(verBG, {y: FlxG.height - 28}, 1.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(versionShit, {y: FlxG.height - 24}, 1.5, {ease: FlxEase.expoInOut});

		super.create();
	}

	var selectedSomethin:Bool = false;

	var canClick:Bool = true;
	var usingMouse:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			menuItems.forEach(function(spr:FlxSprite)
			{
				if(usingMouse)
				{
					if(!FlxG.mouse.overlaps(spr))
						spr.animation.play('idle');
				}
			
				if (FlxG.mouse.overlaps(spr))
				{
					if(canClick)
					{
						curSelected = spr.ID;
						usingMouse = true;
						spr.animation.play('selected');
					}
							
					if(FlxG.mouse.pressed && canClick)
					{
						mouseButtons();
					}
				}
			});
			
			#if desktop
			if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			starFG.x -= 0.03;
			starBG.x -= 0.01;
		});
	}

	function mouseButtons()
	{
		selectedSomethin = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));

		canClick = false;

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (curSelected != spr.ID)
			{
				FlxTween.tween(spr, {alpha: 0}, 0.4, {
				ease: FlxEase.quadOut,
				onComplete: function(twn:FlxTween)
				{
					spr.kill();
				}
				});
			} else {
				FlxG.mouse.visible = false;
				
				FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
				{
					var daChoice:String = optionShit[curSelected];

					switch (daChoice)
					{
						case 'story_mode':
							MusicBeatState.switchState(new StoryMenuState());
						case 'freeplay':
							MusicBeatState.switchState(new FreeplayState());
						case 'credits':
							MusicBeatState.switchState(new CreditsState());
						case 'options':
							MusicBeatState.switchState(new options.OptionsState());
					}
				});
			}
		});
	}
}
