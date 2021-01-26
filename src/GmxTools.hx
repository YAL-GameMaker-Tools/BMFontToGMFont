package ;

/**
 * ...
 * @author YellowAfterlife
 */
class GmxTools {
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
}