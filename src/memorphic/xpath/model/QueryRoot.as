package memorphic.xpath.model
{
	import memorphic.utils.XMLUtil;
	
	final public class QueryRoot
	{

		private var expr:IExpression;
		
		
		public function QueryRoot(rootExpr:IExpression)
		{
			expr = rootExpr;
		}
		
		public function execRoot(xml:XML, context:XPathContext):Object
		{
			var xmlRoot:XML
			var xmlIsRoot:Boolean = false;
			var contextNode:XML;
			
			// xpath requires root "/" to be the document root, which is not represented in e4x, so we
			// have to do a a little bit of ugliness. In fact, that's really what this class is for
			if(xml != null){
				xmlRoot = XMLUtil.rootNode(xml);
				xmlIsRoot = (xml == xmlRoot);
			} 
			if(xmlIsRoot){
				// contextNode = <xml-document xmlns="http://www.memorphic.com/ns/2007/xpath-as3#internal"/>;
				contextNode = <xml-document/>;
				contextNode.appendChild(xmlRoot.copy());
			}else{
				contextNode = xml;
			}			
			context.contextNode = contextNode;
			context.contextPosition = 0;
			context.contextSize = 1;
			
			return expr.exec(context);
		}
	}
}