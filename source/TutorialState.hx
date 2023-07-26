package;

import flixel.FlxState;
import flixel.FlxText;
import flixel.FlxG;
import flixel.input.touch.FlxTouch;

class TutorialState extends FlxState
{
    override public function create(): Void {
        super.create();

        // 添加适应屏幕可观测区域的白色文本
        var text: FlxText = new FlxText(0, 0, FlxG.width, '在/storage/emulated/0/中创建一个.GOP文件夹。再将游戏apk中的assets/assets和assets/mods"这两个文件夹解压进.GOP。前提是要开启读取手机存储权限');
        text.setFormat(null, 16, 0xFFFFFF, "center");
        text.autoSize = true;
        text.y = (FlxG.height - text.height) / 2;
        add(text);

        // 添加换行符
        add(new FlxText(0, text.y + text.height + 10, FlxG.width, ""));

        // 添加适应屏幕可观测区域的白色文本（英文版）
        var englishText: FlxText = new FlxText(0, 0, FlxG.width, "Create a .GOP folder in /storage/emulated/0. Extract the 'assets/assets' and 'assets/mods' folders from the game APK into the .GOP folder. Make sure to enable read storage permission.");
        englishText.setFormat(null, 16, 0xFFFFFF, "center");
        englishText.autoSize = true;
        englishText.y = text.y + text.height + 20;
        add(englishText);
    }

    override public function update(elapsed: Float): Void {
        super.update(elapsed);

        // 当任意一根手指离开屏幕时，切换回上一个状态
        if (FlxG.touch.justReleased()) {
            System.exit(0);
        }
    }
}
