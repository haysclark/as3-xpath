/*
	Copyright (c) 2007 Memorphic Ltd. All rights reserved.
	
	Redistribution and use in source and binary forms, with or without 
	modification, are permitted provided that the following conditions 
	are met:
	
		* Redistributions of source code must retain the above copyright 
		notice, this list of conditions and the following disclaimer.
	    	
	    * Redistributions in binary form must reproduce the above 
	    copyright notice, this list of conditions and the following 
	    disclaimer in the documentation and/or other materials provided 
	    with the distribution.
	    	
	    * Neither the name of MEMORPHIC LTD nor the names of its 
	    contributors may be used to endorse or promote products derived 
	    from this software without specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
	OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
	LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
	THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
	OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package memorphic.xpath.model
{
	
	public class XPathContext
	{
		
		

		internal static var defaultNamespaces:Object = new StandardNamespaces();
		
		internal static var defaultFunctions:Object = new StandardFunctions();
		
		
		
		/**
		 * A table of variable references to use inside XPath statements.
		 * 
		 * For example:
		 * 
		 * var xpath:XPathQuery = new XPathQuery("foo/bar[@id=$nodeID]");
		 * xpath.context.variables.nodeID = "x";
	 	 */		
		public var variables:Object;
		
		
		/**
		 * 
	 	 */		
		public var namespaces:Object;
		
		
		/**
		 * Any function references that you add to this object will be accessible in your XPath statements, using the name that you assign it to.
		 * The first argument must be of type XPathContext. Remaining arguments must match those passed to the function inside the statement.
		 * 
		 * For example:
		 * 
		 * <code>
		 * 	function formatNumber(context:XPathContext, arg1:Number):String
		 * 	{
		 * 		return new NumberFormat("####.##").format(arg1);
		 * 	}
		 * 
		 *  .....
		 * 
		 *  myXPathQuery.context.functions["format-number"] = formatNumber;
		 * 
		 * </code>
	 	 */		
		public var functions:Object;
		
		
		/**
		 * Setting this property to true will cause element position to be computed starting from
		 * 0, instead of 1. The official XPath specification requires that position start from 1,
		 * but Internet Explorer 5.0 (and possibly other implementations) are 0 indexed.
		 */ 
		public var zeroIndexPosition:Boolean = false;
		
		
		/**
		 * 
		 */ 
		public var openAllNamespaces:Boolean = false;
		
				
		
		internal var contextNode:XML;
		internal var contextPosition:int;
		internal var contextSize:int;
		
		
		public function XPathContext()
		{
			variables = new Object();
			namespaces = new Object();
			functions = new Object();
						
		}



		
		
		
		internal final function getNamespace(prefix:String):String
		{
			if(namespaces.hasOwnProperty(prefix)){
				return namespaces[prefix];
			}else{
				return defaultNamespaces[prefix];
			}
		}
		
		

		/**
		 * 
		 * @param name Can be a String or QName
		 * @throws ReferenceError if the variable is not found
		 */		 
		internal final function getVariable(name:*):Object
		{
			var value:* = variables[name];
			if(value == null){
				// XXX: this is problematic. Can't use hasOwnProperty() because only string args are supported and we need to allow QNames
				// but null is a legitimate (though unlikely) value. Need to work this out...
				throw new ReferenceError("There is no variable '" + name + "'.");
			}
			return value;
		}
		

		
		/**
		 * 
		 * @param name Can be a String or QName
		 * 
		 */	
		internal final function getFunction(name:*):Function
		{
			if(functions.hasOwnProperty(name)){
				return functions[name] as Function;
			}else{
				return defaultFunctions[name] as Function;
			}
		}

		/**
		 * 
		 * @param name Can be a String or QName
		 * 
		 */	
		internal final function callFunction(name:Object, args:Array=null):Object
		{
			var applyArgs:Array = [this];
			if(args != null){
				applyArgs = applyArgs.concat(args);
			}
			return getFunction(name).apply(null, applyArgs);
		}
		
		
		/**
		 * Creates a copy of an XPathContext object
		 * @param deepCopy
		 */ 
		public function copy(deepCopy:Boolean=true):XPathContext
		{
			var context:XPathContext = new XPathContext();
			if(deepCopy){
				copyDynamicProps(functions, context.functions);
				copyDynamicProps(namespaces, context.namespaces);
				copyDynamicProps(variables, context.variables);
			}else{
				context.functions = functions;
				context.namespaces = namespaces;
				context.variables = variables;
			}
			context.contextNode = contextNode;
			context.contextPosition = contextPosition;
			context.contextSize = contextSize;
			context.zeroIndexPosition = zeroIndexPosition;
			context.openAllNamespaces = openAllNamespaces;
			return context;
		}
		
		
		private function copyDynamicProps(from:Object, to:Object):void
		{
			for(var p:String in from){
				to[p] = from[p];
			}
		}
		
		
		/**
		 * Inside a predicate, position() represents the index of the current context node, within the node set.
		 * According to the w3c spec, position() is 1-indexed, so the first node will have index 1. 
		 * 
		 * Some XPath implementations (notably Microsoft's) are zero indexed. You can change to this behaviour 
		 * using the <code>zeroIndexPosition</code> property.
		 * 
		 * 
		 * This method is provided for use within custom functions.
		 */ 
		public final function position():int
		{
			//return contextPosition;
			return zeroIndexPosition ? contextPosition : contextPosition + 1;
		}
		
		/**
		 * Inside a predicate, last() represents the size of the current node set and the maximum value of <code>position()>/code>.
		 * This method is provided for use within custom functions.
		 */ 
		public final function last():int
		{
			return contextSize;
		}
		
		/**
		 * Inside a predicate, node() represents the current node, on which the predicate is acting.
		 * This method is provided for use within custom functions.
		 */ 
		public final function node():XML
		{
			return contextNode;
		}
	}
}



