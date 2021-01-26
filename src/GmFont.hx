package ;
import haxe.DynamicAccess;
import haxe.Json;
using GmxTools;

/**
 * ...
 * @author YellowAfterlife
 */
class GmFont extends GmStruct {
	public var name:String = "";
	public var fontName:String = "";
	public var TTFName:String = "";
	public var AntiAlias:Float = 0;
	public var bold:Bool = false;
	public var charset:Int = 1;
	public var first:Int = 0;
	public var last:Int = 0;
	public var glyphs:Array<{ Key:Int, Value:GmGlyph }>;
	public var image:String = null;
	public var includeTTF:Bool = false;
	public var italic:Bool = false;
	public var kerningPairs:Array<Dynamic> = [];
	public var ranges:Array<{ x:Int, y:Int }> = [];
	public var size:Float;
	public var styleName:String = "Regular";
	public var textureGroupId:String = "";
	public var sampleText:String = "abcdef ABCDEF\\u000a0123456789 .,<>\"'&!?\\u000athe quick brown fox jumps over the lazy dog\\u000aTHE QUICK BROWN FOX JUMPS OVER THE LAZY DOG";
	#if gms23
	public var oldFont:DynamicAccess<Dynamic>;
	#end
	public function new() {
		super("GMFont");
	}
	public function toXML():Xml {
		var outFont = Xml.createElement("font");
		outFont.addChild(Xml.createPCData("\n"));
		outFont.addGroupNode("texgroups").addValueNode("texgroup0", 0);
		outFont.addValueNode("charset", charset);
		outFont.addValueNode("includeTTF", includeTTF ? 1 : 0);
		outFont.addValueNode("TTFName", TTFName);
		outFont.addValueNode("name", fontName);
		outFont.addValueNode("size", size);
		outFont.addValueNode("bold", bold ? 1 : 0);
		outFont.addValueNode("italic", italic ? 1 : 0);
		outFont.addValueNode("image", image);
		var outGlyphs = outFont.addGroupNode("glyphs");
		for (g in glyphs) outGlyphs.addChildSep(g.Value.toXML());
		var outRanges = outFont.addGroupNode("ranges"), outRangeId = 0;
		for (r in ranges) {
			outRanges.addValueNode("range" + outRangeId++, r.x + "," + r.y);
		}
		return outFont;
	}
	#if gms23
	public function toYy23():String {
		var b = new StringBuf();
		var indent:Int = 0;
		function addLine(s:String, d:Int = 0) {
			b.add("\r\n");
			indent += d;
			for (i in 0 ... indent) b.add("  ");
			b.add(s);
		}
		function addPair(k:String, val:Dynamic) {
			addLine('"$k": ' + Json.stringify(val) + ",");
		}
		function addFields(fds:Array<String>):Void {
			for (fd in fds) addPair(fd, Reflect.field(this, fd));
		}
		function old(fd:String, ?def:Dynamic):Dynamic {
			return oldFont != null ? oldFont[fd] : def;
		}
		b.add("{");
		indent++;
		addPair("hinting", 0);
		addPair("glyphOperations", 0);
		addPair("interpreter", 0);
		addPair("pointRounding", 0);
		addPair("fontName", fontName);
		addPair("styleName", styleName);
		var szs = "" + size; if (szs.indexOf(".") < 0) szs += ".0";
		addLine('"size": ' + szs + ',');
		addFields(["bold", "italic", "charset", "AntiAlias", "first", "last", "sampleText", "includeTTF", "TTFName"]);
		//
		var otxg = old("textureGroupId");
		addLine('"textureGroupId": {', 1);
			addPair("name", otxg != null ? otxg.name : "Default");
			addPair("path", otxg != null ? otxg.path : "texturegroups/Default");
		addLine("},", -1);
		
		addPair("ascenderOffset", 0);
		
		addLine('"glyphs": {', 1);
		for (gp in glyphs) {
			var g:GmGlyph = gp.Value;
			addLine('"' + g.character + '": {'
				+ '"x": ' + g.x
				+ ',"y": ' + g.y
				+ ',"w": ' + g.w
				+ ',"h": ' + g.h
				+ ',"character": ' + g.character
				+ ',"shift": ' + g.shift
				+ ',"offset": ' + g.offset
			+ ',},');
		}
		addLine("},", -1);
		
		addLine('"kerningPairs": [],');
		
		addLine('"ranges": [', 1);
		for (rg in ranges) {
			addLine('{"lower":' + rg.x + ',"upper":' + rg.y + ',},');
		}
		addLine("],", -1);
		
		addPair("regenerateBitmap", false);
		addPair("canGenerateBitmap", true);
		addPair("maintainGms1Font", false);
		
		var opar = old("parent");
		addLine('"parent": {', 1);
			addPair("name", opar != null ? opar.name : "Fonts");
			addPair("path", opar != null ? opar.path : "folders/Fonts.yy");
		addLine("},", -1);
		
		addPair("resourceVersion", "1.0");
		addPair("name", old("name", name));
		addPair("tags", old("tags", []));
		addPair("resourceType", "GMFont");
		
		addLine("}", -1);
		return b.toString();
		
	}
	#end
}