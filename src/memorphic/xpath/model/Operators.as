package memorphic.xpath.model
{
	public class Operators
	{
		
		public static const OR:String = "or";
		public static const AND:String = "and";
		public static const EQUALS:String = "=";
		public static const NOT_EQUALS:String = "!=";
		public static const MULTIPLY:String = "*";
		public static const DIVIDE:String = "div";
		public static const MODULO:String = "mod";
		public static const ADD:String = "+";
		public static const SUBTRACT:String = "-";
		public static const LESS_THAN:String = "<"; 
		public static const GREATER_THAN:String = ">"; 
		public static const LESS_THAN_OR_EQUAL:String = "<=";
		public static const GREATER_THAN_OR_EQUAL:String = ">=";  
		public static const UNION:String = "|"; 
		
		public static function isOperator(value:String):Boolean{
			switch(value){
			case OR: case AND: case EQUALS: case NOT_EQUALS:
			case MULTIPLY: case DIVIDE: case MODULO: case ADD:
			case SUBTRACT: case LESS_THAN: case GREATER_THAN:
			case LESS_THAN_OR_EQUAL: case GREATER_THAN_OR_EQUAL:
			case UNION:
				return true;
			default:
				return false;
			}
		}
	}
}