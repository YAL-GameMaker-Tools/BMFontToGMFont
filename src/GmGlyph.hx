package ;

/**
 * ...
 * @author YellowAfterlife
 */
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