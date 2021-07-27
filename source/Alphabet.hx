package;

import haxe.iterators.StringIterator;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

using StringTools;

/*
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends FlxSpriteGroup
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	// for menu shit
	public var targetY:Float = 0;
	public var isMenuItem:Bool = false;

	public var text:String = "";

	var _finalText:String = "";
	var _curText:String = "";

	public var widthOfWords:Float = FlxG.width;

	var yMulti:Float = 1;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;
	
	var listOAlphabets:List<AlphaCharacter> = new List<AlphaCharacter>();
	
	var isBold:Bool = false;
	
	var pastX:Float = 0;
	var pastY:Float  = 0;

	public var personTalking:String = 'gf';

	public function new(x:Float, y:Float, str:String = "", ?bold:Bool = false, typed:Bool = false, shouldMove:Bool = false)
	{
		pastX = x;
		pastY = y;

		super(x, y);

		_finalText = str;
		text = str;
		isBold = bold;

		if (text != "")
		{
			addText();
		}
	}

	public function reType(text)
	{
		for (i in listOAlphabets)
			remove(i);
		_finalText = text;
		this.text = text;

		lastSprite = null;

		updateHitbox();

		listOAlphabets.clear();
		x = pastX;
		y = pastY;
		
		addText();
	}

	public function addText()
	{
		var charlist: Array<String> = doSplitWords();

		var xpos: Float = 0;
		var ypos: Float = 0;

		for (char in charlist)
		{
			if (char == " ")
				xpos += 40;
			else if (char == "\n")
			{
				ypos += 60;
				xpos = 0;
			}
			else
			{
				if (char.toLowerCase().charCodeAt(0) >= "a".code && char.toLowerCase().charCodeAt(0) <= "z".code)
				{
					var sprite: AlphaCharacter = new AlphaCharacter(xpos, ypos);
					listOAlphabets.add(sprite);

					sprite.set_char(char, isBold);

					add(sprite);
					xpos += sprite.width;
				}
			}
		}
	}

	function doSplitWords(): Array<String>
	{
		return _finalText.split("");
	}


	/*public function startTypedText():Void
	{
		_finalText = text;
		doSplitWords();

		// trace(arrayShit);

		var loopNum:Int = 0;

		var xPos:Float = 0;
		var curRow:Int = 0;

		new FlxTimer().start(0.05, function(tmr:FlxTimer)
		{
			// trace(_finalText.fastCodeAt(loopNum) + " " + _finalText.charAt(loopNum));
			if (_finalText.fastCodeAt(loopNum) == "\n".code)
			{
				yMulti += 1;
				xPosResetted = true;
				xPos = 0;
				curRow += 1;
			}

			if (splitWords[loopNum] == " ")
			{
				lastWasSpace = true;
			}

			#if (haxe >= "4.0.0")
			var isNumber:Bool = AlphaCharacter.numbers.contains(splitWords[loopNum]);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(splitWords[loopNum]);
			#else
			var isNumber:Bool = AlphaCharacter.numbers.indexOf(splitWords[loopNum]) != -1;
			var isSymbol:Bool = AlphaCharacter.symbols.indexOf(splitWords[loopNum]) != -1;
			#end

			if (AlphaCharacter.alphabet.indexOf(splitWords[loopNum].toLowerCase()) != -1 || isNumber || isSymbol)
				// if (AlphaCharacter.alphabet.contains(splitWords[loopNum].toLowerCase()) || isNumber || isSymbol)

			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
					// if (isBold)
					// xPos -= 80;
				}
				else
				{
					xPosResetted = false;
				}

				if (lastWasSpace)
				{
					xPos += 20;
					lastWasSpace = false;
				}
				// trace(_finalText.fastCodeAt(loopNum) + " " + _finalText.charAt(loopNum));

				// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0);
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 55 * yMulti);
				listOAlphabets.add(letter);
				letter.row = curRow;
				if (isBold)
				{
					letter.createBold(splitWords[loopNum]);
				}
				else
				{
					if (isNumber)
					{
						letter.createNumber(splitWords[loopNum]);
					}
					else if (isSymbol)
					{
						letter.createSymbol(splitWords[loopNum]);
					}
					else
					{
						letter.createLetter(splitWords[loopNum]);
					}

					letter.x += 90;
				}

				if (FlxG.random.bool(40))
				{
					var daSound:String = "GF_";
					FlxG.sound.play(Paths.soundRandom(daSound, 1, 4));
				}

				add(letter);

				lastSprite = letter;
			}

			loopNum += 1;

			tmr.time = FlxG.random.float(0.04, 0.09);
		}, splitWords.length);
	}*/

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.30);
			x = FlxMath.lerp(x, (targetY * 20) + 90, 0.30);
		}

		super.update(elapsed);
	}
}



class AlphaCharacter extends FlxSprite
{
	private var char: String; 

	public function get_char(): String
	{
		return char;
	}

	public function set_char(letter: String, bold: Bool = true): Void
	{
		char = letter;
		create(letter, bold);
	}

	public function new(x:Float, y:Float)
	{
		super(x, y);
		var tex = Paths.getSparrowAtlas('alphabet');
		set_frames(tex);
		antialiasing = cast(FlxG.save.data.antialiasing,Bool);
	}

	private static var symboloffsets: Map<String, Int> = [
		"." => 50,
		"_" => 50,
	];

	private function create(letter: String, bold: Bool = false)
	{
		var prefix: String;
		var offset: Int = 0;

		if (symboloffsets.get(letter) != null)
		{
			offset = symboloffsets.get(letter);
		}

		if (bold)
		{
			prefix = letter.toUpperCase().charCodeAt(0)+"-bold";
		}
		else
		{
			prefix = letter.charCodeAt(0)+"-";
		}

		animation.addByPrefix(letter, prefix, 24);
		animation.play(letter);
		y += offset;
		updateHitbox();
	}
}
