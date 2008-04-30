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

package memorphic.xpath {

	import flexunit.framework.TestCase;
	import flexunit.framework.TestResult;
	
	import memorphic.xpath.fixtures.XMLData;
	import memorphic.xpath.model.XPathContext;
	
	public class XPathTests extends TestCase {
		
		
			TestResult.rethrowErrors = true;
		
		private var cds:XML;
		private var menu:XML;
		private var xhtml:XML;
		private var register:XML;
		private var rdf:XML;
		
	    public function XPathTests( methodName:String = null) {
			super( methodName );
        }

		
		public override function setUp():void
		{
			XPathQuery.defaultContext = new XPathContext();
			cds = XMLData.cdCatalogXML;
			menu = XMLData.foodMenuXML;
			xhtml = XMLData.adobeHomeXHTML;
			rdf = XMLData.adobeBlogsRDF;
			register = XMLData.registerHTML;
		}
		
		public override function tearDown():void
		{			
			cds = null;
			menu = null;
			xhtml = null;
			rdf = null;
			register = null;
			
		}

		
		
		/*
		This test was added after bug report
		*/
		public function testIdenticalNodes():void
		{			
			var tree3:XML = <Root attr="test">
								<Child>
									<X attr="test"/>
									<X attr="test"><InnerX />
									</X>
									<X attr="test"><InnerX />
									</X>
								</Child>
							</Root>;
			var xpath:XPathQuery = new XPathQuery("//InnerX");
			var result:XMLList = xpath.exec(tree3) as XMLList;
			assertEquals("length should be 2", 2, result.length());
			
		}


		private function checkXMLUnaffected():void
		{
			assertEquals("test should not change the XML data", XMLData.adobeBlogsRDF.toXMLString(), rdf.toXMLString());
			assertEquals("test should not change the XML data", XMLData.adobeHomeXHTML.toXMLString(), xhtml.toXMLString());
			assertEquals("test should not change the XML data", XMLData.cdCatalogXML.toXMLString(), cds.toXMLString());
			assertEquals("test should not change the XML data", XMLData.foodMenuXML.toXMLString(), menu.toXMLString());
			assertEquals("test should not change the XML data", XMLData.registerHTML.toXMLString(), register.toXMLString());
		}
		
		
		
		public function testSimpleSteps():void
		{
		
			// all of these queries should have the same results
			var paths:Array = ["breakfast-menu/food/name",
							"breakfast-menu//name",
							"/breakfast-menu/food/name",
							"/breakfast-menu/food//name",
							"/breakfast-menu//name",
							"//food/name",
							"//food//name",
							"//name",
							"/child::breakfast-menu/child::food/child::name",
							"/breakfast-menu/food/parent::node()/food/name",
							"/breakfast-menu/food/../food/name",
							"descendant::breakfast-menu/food/name",
							"descendant-or-self::node()/name[local-name(.)='name']",
							"/descendant-or-self::node()/name[string(local-name(.))='name']",
							"/descendant-or-self::node()/name[local-name(../child::node()) = 'name']",
							"//*/name",
							"*//name",
							"*/food/name",
							"*/*/name"];
			var result:XMLList;
			var n:int = paths.length;
			var expected:XMLList = menu.food.name;
			for(var i:int=0; i<n; i++){

				result = XPathQuery.execQuery(menu, paths[i]) as XMLList;
				assertTrue(i+" result should be XMLList", result is XMLList);
				assertEquals(i+" should select 5 items", 5, result.length());
				assertEquals(i+" should select a <name> node", "name", result[0].name());
				// after issue #12, this is now checking instance equality instead of toXMLString equality
				assertEquals(i+" should match the expected result", expected, result);
			}
			checkXMLUnaffected();
		}
		
		// added to verify fix bug #9
		public function testAncestor():void
		{			
			var xpath:XPathQuery = new XPathQuery("../self::node()");
			var startNode:XML = menu.food[3].price[0];
			var resultNode:XML = xpath.exec(startNode)[0];
			assertEquals("Should be parent of the node we started with", startNode.parent(), resultNode);
			checkXMLUnaffected();
		}
		
		public function testPosition():void
		{
			
			var paths:Array = [
							"breakfast-menu/food[2]/name",
							"breakfast-menu/food[7-5]/name",
							"breakfast-menu/food[(7-5)]/name",
							"breakfast-menu/food[(2+2)-(5 *3-13)]/name",
							"breakfast-menu/food[position() = 2]/name",
							"breakfast-menu/food[position()=2]/name",
							"breakfast-menu/food[last()-3]/name"];
			
			var result:XMLList;
			var n:int = paths.length;
			var expected:String = menu.food.name.toXMLString();
			for(var i:int=0; i<n; i++){
				result = XPathQuery.execQuery(menu, paths[i]);
				assertEquals(i+" should be only one element", 1, result.length());
				assertEquals(i+" check name", "Strawberry Belgian Waffles", result.toString());
				assertEquals(i+" should be second element", menu.food.name[1], result[0]);
				
				
			}
			checkXMLUnaffected();
		}
		
		
		public function testNamespaces():void
		{
			var xpath:XPathQuery = new XPathQuery("//xhtml:head");
			xpath.context.namespaces.xhtml = "http://www.w3.org/1999/xhtml";
			var result:XMLList = xpath.exec(xhtml);
			
			assertEquals("only select one node", 1, result.length());
			assertEquals("local name should be <head>", "head", result[0].localName());
			
			checkXMLUnaffected();
		}
		
		public function testWildCardNamespace():void
		{
			var xpath:XPathQuery = new XPathQuery("//*:head");
			var result:XMLList = xpath.exec(xhtml);
			
			assertEquals("only select one node", 1, result.length());
			assertEquals("local name should be <head>", "head", result[0].localName());
			
			checkXMLUnaffected();
		}
		
		public function testOpenAllNamespaces():void
		{
			
			var xpath:XPathQuery = new XPathQuery("//head");
			var result:XMLList = xpath.exec(xhtml);
			
			assertEquals("Shouldn't match anything - I didn't map the namespace", 0, result.length());
			
			xpath.context.openAllNamespaces = true;
			var result2:XMLList = xpath.exec(xhtml);
			assertEquals("only select one node", 1, result2.length());
			assertEquals("local name should be <head>", "head", result2[0].localName());
			
			
			xpath.context.openAllNamespaces = false;
			var result3:XMLList = xpath.exec(xhtml);
			assertEquals("Shouldn't match anything - I didn't map the namespace", 0, result3.length());
			
			checkXMLUnaffected();
			
		}
		
		
		public function testVariables():void
		{
			var context:XPathContext = new XPathContext();
			context.variables = {a:1};
			var xpath:XPathQuery = new XPathQuery("breakfast-menu/food[$a]/name/text()", context);
			assertEquals("1 let's see if this works?", "Belgian Waffles", xpath.exec(menu));
			
			XPathQuery.defaultContext.variables.a = 1;
			xpath = new XPathQuery("breakfast-menu/food[$a]/name/text()");
			assertEquals("2 let's see if this works?", "Belgian Waffles", xpath.exec(menu));
			
			delete XPathQuery.defaultContext.variables.a;
			xpath = new XPathQuery("breakfast-menu/food[$a]/name/text()");
			var error:Error = null;
			try{
				 xpath.exec(menu);
			}catch(e:ReferenceError){
				error = e;
			}
			assertNotNull("3 This should throw an error because no variable", error);
			
			checkXMLUnaffected();
		}


		public function testAxisNamesCanBeNCNames():void
		{
			// just make sure that /foo/self is allowed as an equivalent to /foo/child::self
			// and "self" is not interpreted as an axis
		}

		public function _testSubPathsInFilterExpressions():void
		{
			// this is to make sure that I really only have to use context.copy() in Location Paths
			var xpath:XPathQuery = new XPathQuery("contextSizeTest(breakfast-menu/food, count(/breakfast-menu/food)))");
			xpath.context.functions.contextSizeTest = function (context:XPathContext, nodeset1:XMLList, num:int):Boolean
			{
				return context.last() == num;
			}
			
			assertTrue("xxx", xpath.exec(menu));
			
			checkXMLUnaffected();
		}



		public function testFilterExpr():void
		{
			
			var xpath:XPathQuery = new XPathQuery( "breakfast-menu/food[secondNode(.)[1]=.]/name");
			xpath.context.functions.secondNode = function (context:XPathContext, nodeset:XMLList):XMLList
			{
				if(context.position() == 2){
					return XMLList(nodeset[0]);
				}else{
					return new XMLList();
				}
			}
			var result:XMLList = xpath.exec(menu);
			assertEquals("only select one node", 1, result.length());
			assertEquals("check name", "Strawberry Belgian Waffles", result.toString());
			
			checkXMLUnaffected();
		}
		
		
		public function testDescendants():void
		{
			var xpath:XPathQuery = new XPathQuery( "//*[1]/attribute::id");
			assertEquals("check id att", "cd1", xpath.exec(cds));
			
			checkXMLUnaffected();
		}
		
		public function testAttribute():void
		{
			var xpath:XPathQuery = new XPathQuery( "CATALOG/CD[1]/attribute::id");
			assertEquals("1 check id att", "cd1", xpath.exec(cds));
			xpath = new XPathQuery( "CATALOG/CD[1]/@id");
			assertEquals("2 check id att", "cd1", xpath.exec(cds));
			
			checkXMLUnaffected();
		}
		
		public function testAssociativity():void
		{
			var xpath:XPathQuery = new XPathQuery("(3 > 2) > 1");
			assertFalse("This is coerced left-associativity > ", xpath.exec(null));
			xpath = new XPathQuery("3 > (2 > 1)");
			assertTrue("make sure that the opposite associativity is different > ", xpath.exec(null));
			xpath = new XPathQuery("3 > 2 > 1");
			assertFalse("should be left-associative > ", xpath.exec(null));
			
			xpath = new XPathQuery("(6 * 2) mod 3");
			assertEquals("This is coerced left-associativity- mod", 0, xpath.exec(null));
			xpath = new XPathQuery("6 * (2 mod 3)");
			assertEquals("make sure that the opposite associativity is different- mod", 12, xpath.exec(null));
			xpath = new XPathQuery("6 * 2 mod 3");
			assertEquals("should be left-associative- mod", 0, xpath.exec(null));
			
			checkXMLUnaffected();
		}
		
		
		public function testAttributeExistence():void
		{
			var c:XPathContext = new XPathContext();
			c.namespaces.h = "http://www.w3.org/1999/xhtml";
			var xpath:XPathQuery = new XPathQuery( "count(//h:img[@alt='' or string-length(@alt)>0])", c);
			var numImgWithAlt:int = xpath.exec(register);
			assertEquals("Reference check for number of alt tags", 6, numImgWithAlt);
			
			xpath = new XPathQuery( "count(//h:img[@alt=''])", c);
			var numImgWithEmptyAlt:int = xpath.exec(register);
			assertEquals("Reference check for number of empty alt tags", 4, numImgWithEmptyAlt);
			
			xpath = new XPathQuery( "count(//h:img[@alt])", c);
			assertEquals("Num images with alt attribute should be "+numImgWithAlt, numImgWithAlt, xpath.exec(register));
			
			xpath = new XPathQuery( "count(//h:img[@alt and string-length(@alt)=0])", c);
			assertEquals("Num images with empty alt attribute should be "+numImgWithEmptyAlt, numImgWithEmptyAlt, xpath.exec(register));
			checkXMLUnaffected();
		}
		
		
		// added to verify fix to bug #13 (brought up on Flashcoders mailing list)
		public function testAttributeSelfAxis():void
		{
			
			var data:XML = <p>
			  <a href="http://www.memorphic.com">link 1</a>
			  <a href="http://www.google.com">link 2</a>
			</p>;
			var url:String;
			url = XPathQuery.execQuery(data, "/p/a/@href[string(.) = 'http://www.memorphic.com']");
			assertEquals("1 should match just the memorphic url", "http://www.memorphic.com", url);
			url = XPathQuery.execQuery(data, "/p/a/@href[string() = 'http://www.memorphic.com']");
			assertEquals("1.1 should match just the memorphic url", "http://www.memorphic.com", url);
			url = XPathQuery.execQuery(data, "/p/a/@href[contains(self::node(),'memorphic')]");
			assertEquals("2 should match just the memorphic url", "http://www.memorphic.com", url);
			
			assertEquals("3 check id att", "cd4", XPathQuery.execQuery(cds, "//@id[contains(.,'cd4')]"));
			checkXMLUnaffected();
		}
		
		
		public function testAbsolutePathFromChildStartNode():void
		{
			var xpath:XPathQuery = new XPathQuery( "/CATALOG/CD[1]/@id");
			var child:XML = cds.CD[3].COUNTRY[0];
			assertEquals("sanity check", "cd1", xpath.exec(cds));
			assertEquals("results should be the same because it's absolute", "cd1", xpath.exec(child));
			checkXMLUnaffected();
		}
		
		
		public function testCustomFunctionExecsPath():void
		{
			var path:String = "/CATALOG/CD[last()]";
			var context:XPathContext = new XPathContext();
			context.functions.lastCD = function(context:XPathContext):XMLList
			{
				return XPathQuery.execQuery(context.node(), path);
			}
			XPathQuery.defaultContext = context;
			assertTrue("sanity check", XPathQuery.execQuery(cds, path + " = " + path));
			assertTrue("call 'out' should not affect absolute paths", XPathQuery.execQuery(cds, path + " = lastCD()"));
			
		}

	}
		
}