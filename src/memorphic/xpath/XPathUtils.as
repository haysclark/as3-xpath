package memorphic.xpath
{
	import memorphic.utils.XMLUtil;
	import flash.xml.XMLNodeType;
	import memorphic.xpath.model.XPathContext;
	
	public class XPathUtils
	{
		
		public static function findPath(toNode:*, fromNode:XML=null, context:XPathContext=null):String
		{
			var path:String = "";
			var pathPrefix:String = "";
			var currentNode:XML;
			if(toNode is XMLList){
				if(toNode.length() == 0){
					throw new ArgumentError("Argument 'toNode'cannot be an empty XMLList");
				}else{
					var firstNode:Boolean = true;
					for each(var n:XML in toNode){
						if(firstNode){
							firstNode = false;
						}else{
							path += "|";
						}
						path += findPath(n, fromNode, context);
					}
				}
			}else if(!(toNode is XML)){
				throw new ArgumentError("Argument 'toNode' must be an XML or XMLList object.");
			}
			if(fromNode == null){
				fromNode = XMLUtil.rootNode(toNode);
			}
			if(context == null){
				context = new XPathContext();
			}
			
			if(fromNode.parent() != null){
				var commonAncestor:XML = XMLUtil.commonAncestor(fromNode, toNode); 
				if(commonAncestor==null){
					throw new ArgumentError("The supplied arguments 'fromNode' and 'toNode' were not from the same XML document.");
				}
				if(commonAncestor !== fromNode.parent()){
					while(commonAncestor != fromNode.parent()) {
						pathPrefix = "../" + pathPrefix;
						fromNode = fromNode.parent();
					}
					//while(toNode.contains(fromNode));	
					if(toNode == fromNode){
						return pathPrefix + "self::node()";
					}	
				}else{
					pathPrefix = ".";
				}
			}
			if(toNode.nodeKind() == "attribute"){
				path = "/@" + toNode.name();
				currentNode = toNode.parent() as XML;
			}else if(toNode.nodeKind() == "text"){
				path = "/text()";
				currentNode = toNode.parent() as XML;
			}else if(toNode.nodeKind() == "comment"){
				path = "/comment()";
				currentNode = toNode.parent() as XML;
			}
			else{ 
				currentNode = toNode;
			}
			while(true){
				if(currentNode){
					path = "/" + currentNode.name()
						+ getPeerPositionPredicate(currentNode, context)
						+ path;
					if(currentNode == fromNode){
						break;
					}
				}else{
					throw new ArgumentError("The supplied 'fromNode' argument is not an ancestor of 'toNode'.");
				}
				currentNode = currentNode.parent();
			}
			return pathPrefix + path;
		}
		
		
		private static function getPeerPositionPredicate(node:XML, context:XPathContext):String
		{
			var parent:XML = node.parent();
			if(!parent){
				return "";
			}
			var peers:XMLList = node.parent()[node.name()];
			var n:int = peers.length();
			for(var i:int=0; i<n; i++){
				if(peers[i] == node){
					break;
				}
			}
			return "[" + (i + (context.zeroIndexPosition ? 0 : 1)) + "]";
		}
		
	}
}