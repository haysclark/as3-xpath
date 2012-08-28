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

	import flash.utils.describeType;
	import flash.utils.getTimer;
	
	import flexunit.framework.TestCase;
	import flexunit.framework.TestResult;
	import flexunit.framework.TestSuite;
	
	import memorphic.xpath.fixtures.XMLData;
	import memorphic.xpath.model.XPathContext;
	
	
	public class XPathUtilsTests extends TestCase {
				
		private var cds:XML;
		private var menu:XML;
		private var xhtml:XML;
		private var register:XML;
		private var rdf:XML;
		
	    public function XPathUtilsTests( methodName:String = null) {
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

		
	
		public function testFindPath():void
		{			
			var maggieWayCountry:XML = cds..CD.(@id=="cd8").COUNTRY[0];
			var path:String = XPathUtils.findPath(maggieWayCountry);
			var selected:XML = XPathQuery.execQuery(cds, path)[0];
			assertTrue("Verify reference node is correct", maggieWayCountry.parent().@id == "cd8");
			assertEquals("Path should select the same node. 1", maggieWayCountry, selected);
			
			var childOfTarget:XML = maggieWayCountry;
			var target:XML = maggieWayCountry.parent();
			path = XPathUtils.findPath(target, childOfTarget);
			selected = XPathQuery.execQuery(childOfTarget, path)[0];
			assertEquals("Path should select the same node. 2", target, selected);
			
			checkXMLUnaffected();
		}

		/**
		 * Issue #26
		 */
		public function testTwoChildrenOfSameName():void
		{
			var xml:XML = <body>
			  <hr/>
			  <div>text</div>
			  <hr/>
			</body>;
			var hr1:XML = xml.hr[0];
			var hr2:XML = xml.hr[1];
			
			var path1:String = XPathUtils.findPath(hr1);
			var path2:String = XPathUtils.findPath(hr2);
			
			assertTrue("Paths should be different: " + path1, path1 != path2);
			assertEquals("First path should find the first <hr> element", hr1, XPathQuery.execQuery(xml, path1)[0]);
			assertEquals("First path should find the first <hr> element", hr2, XPathQuery.execQuery(xml, path2)[0]);
			
		}

		private function checkXMLUnaffected():void
		{
			assertEquals("test should not change the XML data", XMLData.adobeBlogsRDF.toXMLString(), rdf.toXMLString());
			assertEquals("test should not change the XML data", XMLData.adobeHomeXHTML.toXMLString(), xhtml.toXMLString());
			assertEquals("test should not change the XML data", XMLData.cdCatalogXML.toXMLString(), cds.toXMLString());
			assertEquals("test should not change the XML data", XMLData.foodMenuXML.toXMLString(), menu.toXMLString());
			assertEquals("test should not change the XML data", XMLData.registerHTML.toXMLString(), register.toXMLString());
		}
		

	
	}
		
}