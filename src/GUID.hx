package;

/**
 * ...
 * @author YellowAfterlife
 */
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