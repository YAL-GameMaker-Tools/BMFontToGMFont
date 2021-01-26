package;

import haxe.DynamicAccess;
import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;
using haxe.io.Path;
using BmFontToGmFont;

/**
 * ...
 * @author YellowAfterlife
 */
class BmFontToGmFont {
	public static function each(r:EReg, s:String, f:EReg->Void) {
		var i:Int = 0;
		while (r.matchSub(s, i)) {
			f(r);
			var p = r.matchedPos();
			i = p.pos + p.len;
		}
	}
	#if (gms2)
	static var yy:Bool = true;
	#else
	static var yy:Bool = false;
	#end
	
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
		if (outPath == null) {
			var outName = fntPath.withoutExtension();
			//trace(outName, FileSystem.exists(outName + ".yy"));
			if (FileSystem.exists(outName + ".yy")) {
				outPath = outName + ".yy";
				yy = true;
			} else if (FileSystem.exists(outName + ".font.gmx")) {
				outPath = outName + ".font.gmx";
				yy = false;
			} else {
				outPath = outName + (yy ? ".yy" : ".font.gmx");
			}
		} else {
			yy = Path.extension(outPath) == "yy";
		}
		Sys.println('fontPath=$fntPath');
		Sys.println('outPath=$outPath');
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
			if (FileSystem.exists(outPath)) {
				#if gms23
				font.oldFont = YyJsonParser.parse(File.getContent(outPath));
				#else
				var curr = Json.parse(File.getContent(outPath));
				font.textureGroupId = curr.textureGroupId;
				#end
			}
			font.image = null;
			var yyStr:String;
			#if gms23
			yyStr = font.toYy23();
			#else
			yyStr = Json.stringify(font, null, "    ");
			#end
			File.saveContent(outPath, yyStr);
		} else {
			var outRoot = Xml.createDocument();
			GmxTools.addChildSep(outRoot, font.toXML());
			File.saveContent(outPath, outRoot.toString());
		}
		Sys.println("OK!");
	} // main
	
} // Main
