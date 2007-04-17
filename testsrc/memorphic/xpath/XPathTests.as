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
	import flexunit.framework.TestSuite;
	import memorphic.xpath.fixtures.XMLData;
	import flexunit.framework.TestResult;
	import memorphic.xpath.model.XPathContext;
	import flash.utils.getTimer;
	
	
	public class XPathTests extends TestCase {
		
		
			TestResult.rethrowErrors = true;
		
	    public function XPathTests( methodName:String = null) {
			super( methodName );
        }

		
		public override function setUp():void
		{
			XPathQuery.defaultContext = new XPathContext();
		}
		
		public override function tearDown():void
		{
			
		}


		
		public function testSimpleSteps():void
		{
			
			var data:XML = XMLData.foodMenuXML;
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
			var expected:String = data.food.name.toXMLString();
			for(var i:int=0; i<n; i++){

				result = XPathQuery.execQuery(data, paths[i]) as XMLList;
				assertTrue(i+" result should be XMLList", result is XMLList);
				assertEquals(i+" should select 5 items", 5, result.length());
				assertEquals(i+" should select a <name> node", "name", result[0].name());
				assertEquals(i+" should match the expected result", expected, result.toXMLString());

			}
			
		}
		
		
		public function testPosition():void
		{
			var data:XML = XMLData.foodMenuXML;
			
			var paths:Array = [
							"breakfast-menu/food[2]/name",
							"breakfast-menu/food[7-5]/name",
							"breakfast-menu/food[(7-5)]/name",
							"breakfast-menu/food[(2+2)-(5 *3-13)]/name",
							"breakfast-menu/food[position() = 2]/name",
							"breakfast-menu/food[position()=2]/name",
							"breakfast-menu/food[last()-3]/name",
							"breakfast-menu/food/name[string() = 'Strawberry Belgian Waffles']"];
			
			var result:XMLList;
			var n:int = paths.length;
			var expected:String = data.food.name.toXMLString();
			for(var i:int=0; i<n; i++){
				result = XPathQuery.execQuery(data, paths[i]);
				assertEquals(i+" should be only one element", 1, result.length());
				assertEquals(i+" check name", "Strawberry Belgian Waffles", result.toString());
				assertEquals(i+" should be second element", data.food.name[1], result[0]);
				
				
			}
			
		}
		
		
		public function testNamespaces():void
		{
			var data:XML = XMLData.adobeHomeXHTML;
			
			var xpath:XPathQuery = new XPathQuery("//xhtml:head");
			xpath.context.namespaces.xhtml = "http://www.w3.org/1999/xhtml";
			var result:XMLList = xpath.exec(data);
			
			assertEquals("only select one node", 1, result.length());
			assertEquals("local name should be <head>", "head", result[0].localName());
			
		}
		
		public function testWildCardNamespace():void
		{
			var data:XML = XMLData.adobeHomeXHTML;
			
			var xpath:XPathQuery = new XPathQuery("//*:head");
			var result:XMLList = xpath.exec(data);
			
			assertEquals("only select one node", 1, result.length());
			assertEquals("local name should be <head>", "head", result[0].localName());
			
		}
		
		public function testOpenAllNamespaces():void
		{
			var data:XML = XMLData.adobeHomeXHTML;
			
			var xpath:XPathQuery = new XPathQuery("//head");
			var result:XMLList = xpath.exec(data);
			
			assertEquals("Shouldn't match anything - I didn't map the namespace", 0, result.length());
			
			xpath.context.openAllNamespaces = true;
			var result2:XMLList = xpath.exec(data);
			assertEquals("only select one node", 1, result2.length());
			assertEquals("local name should be <head>", "head", result2[0].localName());
			
			
			xpath.context.openAllNamespaces = false;
			var result3:XMLList = xpath.exec(data);
			assertEquals("Shouldn't match anything - I didn't map the namespace", 0, result3.length());
			
			
		}
		
		
		public function testVariables():void
		{
			var menu:XML = XMLData.foodMenuXML;
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
			
		}



		public function testFilterExpr():void
		{
			
			var data:XML = XMLData.foodMenuXML;
			var xpath:XPathQuery = new XPathQuery( "breakfast-menu/food[secondNode(.)[1]=.]/name");
			xpath.context.functions.secondNode = function (context:XPathContext, nodeset:XMLList):XMLList
			{
				if(context.position() == 2){
					return XMLList(nodeset[0]);
				}else{
					return new XMLList();
				}
			}
			var result:XMLList = xpath.exec(data);
			assertEquals("only select one node", 1, result.length());
			assertEquals("check name", "Strawberry Belgian Waffles", result.toString());
		}
		
		
		public function testDescendants():void
		{
			var data:XML = XMLData.cdCatalogXML;
			var xpath:XPathQuery = new XPathQuery( "//*[1]/attribute::id");
			assertEquals("check id att", "cd1", xpath.exec(data));
		}
		
		public function testAttribute():void
		{
			var data:XML = XMLData.cdCatalogXML;
			var xpath:XPathQuery = new XPathQuery( "CATALOG/CD[1]/attribute::id");
			assertEquals("1 check id att", "cd1", xpath.exec(data));
			xpath = new XPathQuery( "CATALOG/CD[1]/@id");
			assertEquals("2 check id att", "cd1", xpath.exec(data));
			
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
		}
		

	}
		
}