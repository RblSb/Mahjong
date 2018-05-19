package;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;
#end

class Macro {
	
	public static macro function fromString(typePath:Expr):Expr {
		var type = Context.getType(typePath.toString());
		switch (type.follow()) {
		case TAbstract(_.get() => ab, _) if (ab.meta.has(":enum")):
			var code = "new " + type.toString() + "(switch(type) {";
			for (field in ab.impl.get().statics.get()) {
				if (field.meta.has(":enum") && field.meta.has(":impl")) {
					code += 'case "' + field.name + '": ' + field.name + ";";
				}
			}
			code += 'default: throw("Unknown case " + type);';
			code += "})";
			return Context.parse(code, Context.currentPos());
		default: throw new Error(type.toString() + " should be @:enum abstract", typePath.pos);
		}
	}
	
	public static macro function getBuildTime():Expr {
		return macro $v{Date.now().toString()};
	}
	
}