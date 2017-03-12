package;

import haxe.DynamicAccess;
import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;
using haxe.io.Path;
using BmFontToGMX;

/**
 * ...
 * @author YellowAfterlife
 */
class BmFontToGMX {
	public static function each(r:EReg, s:String, f:EReg->Void) {
		var i:Int = 0;
		while (r.matchSub(s, i)) {
			f(r);
			var p = r.matchedPos();
			i = p.pos + p.len;
		}
	}
	#if (gms2)
	static inline var yy:Bool = true;
	#else
	static inline var yy:Bool = false;
	#end
	public static function addValueNode<T>(q:Xml, name:String, val:T) {
		var r:Xml = Xml.createElement(name);
		r.addChild(Xml.createPCData(Std.string(val)));
		q.addChild(r);
		q.addChild(Xml.createPCData("\n"));
		return r;
	}
	public static function addChildSep(q:Xml, x:Xml) {
		q.addChild(x);
		q.addChild(Xml.createPCData("\n"));
	}
	public static function addNode(q:Xml, name:String):Xml {
		var r:Xml = Xml.createElement(name);
		q.addChild(r);
		q.addChild(Xml.createPCData("\n"));
		return r;
	}
	public static function addGroupNode(q:Xml, name:String):Xml {
		var r:Xml = Xml.createElement(name);
		q.addChild(r);
		q.addChild(Xml.createPCData("\n"));
		r.addChild(Xml.createPCData("\n"));
		return r;
	}
	
	static function main() {
		var args = Sys.args();
		if (args.length == 0) {
			#if (gms2)
			Sys.println("Usage: BmFontToYY [drive:]path [output path]");
			#else
			Sys.println("Usage: BmFontToGMX [drive:]path [output path]");
			#end
			return;
		}
		//
		var fntPath = args[0];
		var fntText = File.getContent(fntPath);
		var outPath = args[1];
		if (outPath == null) outPath = fntPath.withoutExtension() + (yy ? ".yy" : ".font.gmx");
		var font = new GmFont();
		font.name = fntPath.withoutDirectory().withoutExtension();
		var glyphs = [];
		var rxParam = ~/(\w+)=(?|"([^"]+)"|(\w+))/g;
		(~/^(\w+)(.+)$/gm).each(fntText, function(rxLine:EReg) {
			var trail = rxLine.matched(2);
			inline function readParams(f:String->String->Void) {
				rxParam.each(trail, function(r:EReg) {
					f(r.matched(1), r.matched(2));
				});
			}
			switch (rxLine.matched(1)) {
				case "info": readParams(function(key:String, val:String) {
					switch (key) {
						case "face": font.fontName = val;
						case "size": font.size = Std.parseFloat(val); // todo: convert units
						case "bold": font.bold = val == "1";
						case "italic": font.italic = val == "1";
					}
				});
				case "page": readParams(function(key:String, val:String) {
					switch (key) {
						case "id": if (val != "0") {
							Sys.println("Font should be single-page!");
							Sys.exit(1);
						};
						case "file": {
							var pagePath = Path.directory(fntPath);
							if (pagePath == "") pagePath = ".";
							pagePath += "/" + val;
							if (FileSystem.exists(pagePath)) {
								var outPath1 = Path.withoutExtension(outPath);
								if (Path.extension(outPath1) == "font") {
									outPath1 = Path.withoutExtension(outPath1);
								}
								File.copy(pagePath, outPath1 + ".png");
								font.image = Path.withoutDirectory(outPath1 + ".png");
							} else font.image = val;
						};
					}
				});
				case "chars": //
				case "char": {
					var g = new GmGlyph();
					readParams(function(key, val) {
						switch (key) {
							case "id": g.character = Std.parseInt(val);
							case "x": g.x = Std.parseInt(val);
							case "y": g.y = Std.parseInt(val);
							case "width": g.w = Std.parseInt(val);
							case "height": g.h = Std.parseInt(val);
							case "xoffset": g.offset = Std.parseInt(val);
							case "xadvance": g.shift = Std.parseInt(val);
						}
					});
					glyphs.push({ Key: g.character, Value: g });
				};
			}
		});
		//
		glyphs.sort(function(a, b) { return a.Value.character - b.Value.character; });
		font.glyphs = glyphs;
		font.ranges = ({
			var ranges:Array<{ x:Int, y:Int }> = [];
			var rangeNext = glyphs[0].Value.character;
			var rangeStart = rangeNext;
			inline function check(glyph:Int) {
				if (glyph != rangeNext) {
					ranges.push({ x: rangeStart, y: rangeNext - 1 });
					rangeStart = glyph;
					rangeNext = glyph + 1;
					return true;
				} else return false;
			}
			for (glyph in glyphs) {
				if (!check(glyph.Value.character)) rangeNext++;
			}
			check( -1);
			ranges;
		});
		//
		if (yy) {
			font.image = null;
			File.saveContent(outPath, Json.stringify(font, null, "    "));
		} else {
			var outRoot = Xml.createDocument();
			outRoot.addChildSep(font.toXML());
			File.saveContent(outPath, outRoot.toString());
		}
	} // main
	
} // Main
class GmStruct {
	public var id:GUID;
	public var modelName:String;
	public var mvc:String;
	public function new(model:String, v:String = "1.0") {
		id = new GUID();
		modelName = model;
		mvc = v;
	}
}
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
	public var styleName:String = "";
	public var textureGroup:Int = 0;
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
}
class GmGlyph extends GmStruct {
	public var character:Int;
	public var x:Float;
	public var y:Float;
	public var w:Float;
	public var h:Float;
	public var shift:Float;
	public var offset:Float;
	public function new() {
		super("GMGlyph");
	}
	public function toXML():Xml {
		var c = Xml.createElement("glyph");
		c.set("character", "" + character);
		c.set("x", "" + x);
		c.set("y", "" + y);
		c.set("w", "" + w);
		c.set("h", "" + h);
		c.set("shift", "" + shift);
		c.set("offset", "" + offset);
		return c;
	}
}
abstract GUID(String) {
	public function new() {
		var h = "0123456789ABCDEF";
		var r = "";
		for (i in 0 ... 32) {
			switch (i) {
				case 8, 12, 16, 20: r += "-";
				default:
			}
			r += h.charAt(Math.floor(Math.random() * 16));
		}
		this = r;
	}
}
