package;

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
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.input.touch.FlxTouch;
import haxe.Json;

using StringTools;
typedef LogoData =
{
	
	logox:Float,
	logoy:Float,
	scaleX:Float,
	scaleY:Float,
	storyX:Float,
	storyY:Float,
	storyScaleX:Float,
	storyScaleY:Float,
	FreeX:Float,
	FreeY:Float,
	FreeScaleX:Float,
	FreeScaleY:Float,
	CreditsX:Float,
	CreditsY:Float,
	CreditsScaleX:Float,
	CreditsScaleY:Float,
	optionX:Float,
	optionY:Float,
	optionScaleX:Float,
	optionScaleY:Float,
	backX:Float,
	backY:Float,
	backScaleX:Float,
	backScaleY:Float,
	windowX:Float,
	windowY:Float,
	windowScaleX:Float,
	windowScaleY:Float,
	Background:String
}
class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.3';
	public static var GOPVersion:String = '1.0'; //This is also used for Discord RPC
    public static var curSelected:Int = 0;
	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	var cantouch:Bool = true;
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'credits',
		'options'
	];

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
	    FlxG.mouse.visible = true;
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
       var logoJSON:LogoData = Json.parse(Paths.getTextFromFile('images/mainEditor.json'));
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image(logoJSON.Background));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
        var back:FlxSprite = new FlxSprite(logoJSON.backX, logoJSON.backY);
		back.frames = Paths.getSparrowAtlas('backbutton');
		back.scale.set(logoJSON.backScaleX, logoJSON.backScaleY);
		add(back);
		var window:FlxSprite = new FlxSprite(logoJSON.windowX,logoJSON.windowY);
		back.frames = Paths.getSparrowAtlas('window');
		window.scale.set(logoJSON.windowScaleX, logoJSON.windowScaleY);
		add(window);
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);
		var logo:FlxSprite = new FlxSprite(logoJSON.logox, logoJSON.logoy);
		logo.frames = Paths.getSparrowAtlas('logoBumpin-GOP');
		logo.animation.addByPrefix('bump', 'logo bumpin', 24,true);
		logo.scale.set(logoJSON.scaleX, logoJSON.scaleY);
	    logo.animation.play('bump');
		add(logo);
		var window:FlxSprite = new FlxSprite(logoJSON.windowX, logoJSON.windowY);
		logo.frames = Paths.getSparrowAtlas('logoBumpin-GOP');
		logo.animation.addByPrefix('bump', 'logo bumpin', 24,true);
		logo.scale.set(logoJSON.scaleX, logoJSON.scaleY);
	    logo.animation.play('bump');
		add(logo);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			switch (i)
			{
				case 0:
					menuItem.setPosition(logoJSON.storyX, logoJSON.storyY);
					menuItem.setScaleX(logoJSON.storyScaleX);
					menuItem.setScaleY(logoJSON.storyScaleY);
				case 1:
					menuItem.setPosition(logoJSON.FreeX, logoJSON.FreeY);
					menuItem.setScaleX(logoJSON.FreeScaleX);
					menuItem.setScaleY(logoJSON.FreeScaleY);
				case 2:
					menuItem.setPosition(logoJSON.CreditsX, logoJSON.CreditsY);
					menuItem.setScaleX(logoJSON.CreditsScaleX);
					menuItem.setScaleY(logoJSON.CreditsScaleY);
				case 3:
					menuItem.setPosition(logoJSON.optionX, logoJSON.optionY);
					menuItem.setScaleX(logoJSON.optionScaleX);
					menuItem.setScaleY(logoJSON.optionScaleY);
	//6
			}
		}

		FlxG.camera.follow(camFollowPos, null, 1);

        var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "GOP vs Imposter v" + GOPVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		

		

		super.create();
	}

	

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		/*if (!selectedSomethin)
		{

			if (FlxG.keys.justReleased.BACKSPACE)
			{
				selectedSomethin = true;
				cantouch = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}
			}*/
			menuItems.forEach(function(cnm:FlxSprite)
{       for (touch in FlxG.touches.list)

       {   
        
        
            if (touch.justPressed)
            {
            if (touch.overlaps(cnm))
            {
            curSelected = cnm.ID;
            cantouch = false;
            selectedSomethin = true;
            FlxG.sound.play(Paths.sound('confirmMenu'));
                switch (optionShit[curSelected])
            {
                case 'story_mode':
                    MusicBeatState.switchState(new StoryMenuState());
                case 'freeplay':
                    MusicBeatState.switchState(new FreeplayState());
                case 'credits':
                    MusicBeatState.switchState(new CreditsState());
                case 'options':
                    LoadingState.loadAndSwitchState(new options.OptionsState());
            }
            }
         /*   else
            {
            //do nothing lol
            //我觉得我对haxe有更深入的了解了
         他奶奶滴加了这行代码全面屏手机就会出bug   }*/
            
        }
         /*   else
            {
            //洽汐来！
            }
            cnm.updateHitbox(); */
        }
        cnm.updateHitbox(); 
    
});

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	
	for (touch in FlxG.touches.list)

       {   
       if (touch.justPressed)
            {
            if (touch.overlaps(back))
            {
            MusicBeatState.switchState(new TitleState());
           }
           }
           }
}
}