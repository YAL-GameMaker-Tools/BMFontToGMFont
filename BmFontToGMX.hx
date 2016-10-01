package;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
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
	public static function addValueNode<T>(q:Xml, name:String, val:T) {
		var r:Xml = Xml.createElement(name);
		r.addChild(Xml.createPCData(Std.string(val)));
		q.addChild(r);
		q.addChild(Xml.createPCData("\n"));
		return r;
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
			Sys.println("Usage: BmFontToGMX [drive:]path [output path]");
			return;
		}
		//
		var fntPath = args[0];
		var fntText = File.getContent(fntPath);
		var outPath = args.length > 1 ? args[1] : Path.withoutExtension(fntPath) + ".font.gmx";
		var outRoot = Xml.createDocument();
		var outFont = outRoot.addGroupNode("font");
		var outGlyphs = null;
		var glyphs:Array<Int> = [];
		outFont.addGroupNode("texgroups").addValueNode("texgroup0", 0);
		outFont.addValueNode("charset", 1);
		outFont.addValueNode("includeTTF", 0);
		outFont.addValueNode("TTFName", "");
		//
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
						case "face": outFont.addValueNode("name", val);
						case "size": { // todo: remap
							outFont.addValueNode("size", val);
						};
						case "bold", "italic": {
							outFont.addValueNode(key, val);
						};
					}
				});
				case "page": readParams(function(key:String, val:String) {
					switch (key) {
						case "id": if (val != "0") {
							Sys.println("Font should be single-page!");
							Sys.exit(1);
						};
						case "file": {
							outFont.addValueNode("image", val);
							var pagePath = Path.directory(fntPath) + "/" + val;
							if (FileSystem.exists(pagePath)) {
								var outPath1 = Path.withoutExtension(outPath);
								if (Path.extension(outPath1) == "font") {
									outPath1 = Path.withoutExtension(outPath1);
								}
								File.copy(pagePath, outPath1 + ".png");
							}
						};
					}
				});
				case "chars": outGlyphs = outFont.addGroupNode("glyphs");
				case "char": {
					var c = outGlyphs.addNode("glyph");
					readParams(function(key, val) {
						switch (key) {
							case "id": {
								c.set("character", val);
								glyphs.push(Std.parseInt(val));
							};
							case "x": c.set("x", val);
							case "y": c.set("y", val);
							case "width": c.set("w", val);
							case "height": c.set("h", val);
							case "xadvance": c.set("shift", val);
							case "xoffset": c.set("offset", val);
						}
					});
				};
			}
		});
		//
		glyphs.sort(function(a, b) { return a - b; });
		var outRanges = outFont.addGroupNode("ranges");
		var rangeNum = 0;
		var rangeNext = glyphs[0];
		var rangeStart = rangeNext;
		glyphs.push( -1);
		for (glyph in glyphs) {
			if (glyph != rangeNext) {
				outRanges.addValueNode("range" + rangeNum++, rangeStart + "," + (rangeNext - 1));
			} else rangeNext++;
		}
		//
		File.saveContent(outPath, outRoot.toString());
	}
	
}
