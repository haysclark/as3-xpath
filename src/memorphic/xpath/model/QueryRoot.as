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
			var xmlIsRoot:Boolean = true;
			
			// xpath requires root "/" to be parent of the document root, so we have to 
			// do a a little bit of ugliness. In fact, that's really what this class is for
			if(xml != null){
				xmlRoot = XMLUtil.rootNode(xml);
				xmlIsRoot = (xml == xmlRoot);
			} 
			
			var documentWrapper:XML = <xml-document/>;
			documentWrapper.appendChild(xmlRoot);
			
			var xmlParent:XML = xmlIsRoot ? documentWrapper : xml.parent();
			
			context.contextNode = xmlParent;
			context.contextPosition = 0;
			context.contextSize = 1;
			
			context.documentWrapper = documentWrapper;
			
			var result:Object = expr.exec(context);
			
			// undo the ugliness so the XML is not permanently affected
			delete documentWrapper.children()[0];
			
			return result;
		}
	}
}