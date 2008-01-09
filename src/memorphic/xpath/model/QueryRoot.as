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
			// docRoot = <xml-document xmlns="http://www.memorphic.com/ns/2007/xpath-as3#internal"/>;
			var docRoot:XML = <xpathas3-document-root/>
			var rootWrapped:Boolean = false;
			if(xml != null){
				xmlRoot = XMLUtil.rootNode(xml);
				xmlIsRoot = (xml == xmlRoot);
				
				if(docRoot.localName() == xmlRoot.localName()){
					docRoot = xmlRoot;
				}else{
					docRoot.appendChild(xmlRoot);
					rootWrapped = true;
				}
				if(xmlIsRoot){
					contextNode = docRoot;
				}else{
					contextNode = xml;
				}			
			}else{
				// use an empty XML object instead of null, to reduce RTE's
				contextNode = new XML();
			} 
			
			context.contextNode = contextNode;
			context.contextPosition = 0;
			context.contextSize = 1;
			
			var result:Object = expr.exec(context);
			
			if(rootWrapped){
				delete docRoot.children()[0];
			}
			return result;
		}
	}
}