package ;

/**
 * ...
 * @author YellowAfterlife
 */
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