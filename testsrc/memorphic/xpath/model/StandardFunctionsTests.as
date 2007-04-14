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
	import flexunit.framework.TestCase;
	import memorphic.xpath.fixtures.XMLData;
	import memorphic.xpath.XPathQuery;

	public class StandardFunctionsTests extends TestCase
	{
		
		private var feed:XML;
		private var cds:XML;
		private var reg:XML;
		private var xpath:XPathQuery;
		
		public override function setUp():void
		{
			feed = XMLData.adobeBlogsRDF;
			cds = XMLData.cdCatalogXML;
			reg = XMLData.registerHTML;
			var context:XPathContext = new XPathContext();
			context.namespaces.rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
			context.namespaces.dc = "http://purl.org/dc/elements/1.1/";
			context.namespaces.rss = "http://purl.org/rss/1.0/";
			XPathQuery.defaultContext = context;
		}
		
		public override function tearDown():void
		{
			xpath = null;
			feed = null;
		}
		
		
		public function testPosition():void
		{
			xpath = new XPathQuery("/rdf:RDF/rss:item[position()=8]/rss:title");
			var title:String = xpath.exec(feed).toString();
			assertEquals("title should match", "Daniel Dura on Apollo", title);
		}
		
		
		public function testLast():void
		{
			// item whose position is 2 less than the last one
			xpath = new XPathQuery("/rdf:RDF/rss:item[position()=last()-2]/rss:title");
			var title:String = xpath.exec(feed).toString();
			assertEquals("title should match", "LipSync MX v2", title);
			
			// last item (shortcut syntax)
			xpath = new XPathQuery("/rdf:RDF/rss:item[last()]/rss:title");
			title = xpath.exec(feed).toString();
			assertEquals("title should match", "How to Wow with Flash", title);
		}
		
		public function testCount():void
		{
			
			xpath = new XPathQuery("count(rdf:RDF/rss:item)");
			var numItems:int = xpath.exec(feed);
			assertEquals("should be 15 items", 15, numItems);
			
			// item whose position is the same as the number of children it has in the dublin-core namespace
			// (they all have 4)
			xpath = new XPathQuery("/rdf:RDF/rss:item[count(dc:*)]/rss:title");
			var title:String = xpath.exec(feed).toString();
			assertEquals("title should match", "The Best Apollo Information Out There", title);
			
			// items with at least 3 children that contain the word "Flex"
			xpath = new XPathQuery("/rdf:RDF/rss:item[count(child::node()[contains(text(), 'Flex')]) >= 3]");
			var result:XMLList = xpath.exec(feed);
			assertEquals("should have selected 2 items", 2, result.length());
			assertEquals("first item title should match", "Flex Web Services Question", result[0].*::title.toString());
			assertEquals("second item title should match", "Updated Debug Flash Player 7 for Flex 1.5 and Flex Builder 1.5", result[1].*::title.toString());
			
			xpath = new XPathQuery("count(/doesntexist)");
			var num:int = xpath.exec(feed);
			assertEquals("testing count() on empty node set", 0, num);
		}
		
		public function testID():void
		{
			var cdData:XML = XMLData.cdCatalogXML;
			xpath = new XPathQuery("id('cd10')/TITLE");
			var result:XMLList = xpath.exec(cdData);
			assertEquals("title should be Percy Sledge classic", "When a man loves a woman", result.toString());
		}
		
		
		public function testNamesWithNamespaces():void
		{
			xpath = new XPathQuery("local-name(/rdf:RDF/child::node()[2])");
			var localName:String = xpath.exec(feed);
			assertEquals("localName should match", "item", localName);
			
			xpath = new XPathQuery("namespace-uri(/rdf:RDF/child::node()[2])");
			var uri:String = xpath.exec(feed);
			assertEquals("uri should match", "http://purl.org/rss/1.0/", uri);
			
			xpath = new XPathQuery("name(/rdf:RDF/child::node()[2])");
			var name:String = xpath.exec(feed);
			assertEquals("name should match", "http://purl.org/rss/1.0/:item", name);
		
		}
		
		public function testNamesWithoutNamespaces():void
		{
			
			xpath = new XPathQuery("local-name(CATALOG/CD[1])");
			var localName:String = xpath.exec(cds);
			assertEquals("localName should match", "CD", localName);
			
			xpath = new XPathQuery("namespace-uri(CATALOG/CD[1])");
			var uri:String = xpath.exec(cds);
			assertEquals("uri should match", "", uri);
			
			xpath = new XPathQuery("name(CATALOG/CD[1])");
			var name:String = xpath.exec(cds);
			assertEquals("name should match", "CD", name);
		
		}
		
		public function testString():void
		{
			xpath = new XPathQuery("string(CATALOG/CD[(position() > 2) and (position() < 7)]/ARTIST)");
			assertEquals("string() should only act on the first node in the set", "Dolly Parton", xpath.exec(cds));
			
			xpath = new XPathQuery("string(CATALOG[position() > last()])");
			assertEquals("empty node set should become ''", "", xpath.exec(cds));
			
			xpath = new XPathQuery("string(count(CATALOG/CD))");
			assertEquals("string() should convert a number to a string", "26", xpath.exec(cds));
			assertTrue("string() should convert a number to a string",  xpath.exec(cds) is String);
			
			xpath = new XPathQuery("string(3 = 3)");
			assertEquals("string() should convert a true to 'true'", "true", xpath.exec(null));
			xpath = new XPathQuery("string(1 = 3)");
			assertEquals("string() should convert a false to 'false'", "false", xpath.exec(null));
		}
		
		public function testConcat():void
		{
			xpath = new XPathQuery("concat('a','b')");
			assertEquals("should concat into one string", "ab", xpath.exec(null));
			xpath = new XPathQuery("concat('a','b', '')");
			assertEquals("should concat into one string", "ab", xpath.exec(null));
			xpath = new XPathQuery("concat('','b')");
			assertEquals("should concat into one string", "b", xpath.exec(null));
			
			xpath = new XPathQuery("concat(CATALOG/CD[1]/COUNTRY, CATALOG/CD[2]/COUNTRY, CATALOG/CD[3]/COUNTRY)");
			assertEquals("should concat into one string", "USAUKUSA", xpath.exec(cds));
			
		}
		
		public function testStartsWith():void
		{
			xpath = new XPathQuery("starts-with('a','b')");
			assertEquals("should be false", false, xpath.exec(null));
			
			xpath = new XPathQuery("starts-with('a','a')");
			assertEquals("should be true", true, xpath.exec(null));
			
			xpath = new XPathQuery("starts-with('hello','hell')");
			assertEquals("should be true", true, xpath.exec(null));
			
			xpath = new XPathQuery("starts-with('hello','ello')");
			assertEquals("should be false", false, xpath.exec(null));
			
			xpath = new XPathQuery("starts-with('ello','hello')");
			assertEquals("should be false", false, xpath.exec(null));
			
			xpath = new XPathQuery("starts-with('hell','hello')");
			assertEquals("should be false", false, xpath.exec(null));
			
			xpath = new XPathQuery("starts-with('h','H')");
			assertEquals("should be false", false, xpath.exec(null));
		}

		public function testContains():void
		{
			xpath = new XPathQuery("contains('a','b')");
			assertEquals("should be false", false, xpath.exec(null));
			
			xpath = new XPathQuery("contains('a','a')");
			assertEquals("should be true", true, xpath.exec(null));
			
			xpath = new XPathQuery("contains('abc','a')");
			assertEquals("should be true", true, xpath.exec(null));
			
			xpath = new XPathQuery("contains('xzyabc','a')");
			assertEquals("should be true", true, xpath.exec(null));
			xpath = new XPathQuery("contains('xzya','a')");
			assertEquals("should be true", true, xpath.exec(null));
			
			xpath = new XPathQuery("contains('xzybc','a')");
			assertEquals("should be false", false, xpath.exec(null));
			
			xpath = new XPathQuery("contains('The rain in Spain falls mainly on the plain','in fal')");
			assertEquals("should be true", true, xpath.exec(null));
			
			xpath = new XPathQuery("contains('The rain in Spain falls mainly on the plain','spain')");
			assertEquals("should be false because Spain is upper-case", false, xpath.exec(null));
			
			xpath = new XPathQuery("contains(/CATALOG, 'Luciano Pavarotti')");
			assertEquals("should be true", true, xpath.exec(cds));
			xpath = new XPathQuery("contains(/CATALOG, 'Flat Buoy Slimey')");
			assertEquals("should be false", false, xpath.exec(cds));
			
			// tests TypeConversions:xmlToString() (pretty printing consideration)
			xpath = new XPathQuery("contains(/CATALOG, /CATALOG/CD[1])");
			assertEquals("should be true", true, xpath.exec(cds));
			
		}
		
		public function testSubstringBefore():void
		{
			// [From spec] For example, substring-before("1999/04/01","/") returns 1999.
			xpath = new XPathQuery("substring-before('1999/04/01','/')");
			assertEquals("result should match example in spec", "1999", xpath.exec(null));
			
			xpath = new XPathQuery("substring-before(id('cd6')/TITLE, ' only')");
			assertEquals("only first two words of 'One night only'", "One night", xpath.exec(cds));
		}
		
		public function testSubstringAfter():void
		{
			// [From spec] For example, substring-after("1999/04/01","/") returns 04/01, 
			xpath = new XPathQuery("substring-after('1999/04/01','/')");
			assertEquals("result should match example in spec", "04/01", xpath.exec(null));
			// and substring-after("1999/04/01","19") returns 99/04/01.
			xpath = new XPathQuery('substring-after("1999/04/01","19")');
			assertEquals("result should match example in spec", "99/04/01", xpath.exec(null));
			
			xpath = new XPathQuery('substring-after("Peter Piper picked a peck of pickled pepper","pepper")');
			assertEquals("result should be empty", "", xpath.exec(null));
			
		}
		
		public function testSubstring():void
		{
			//[From spec] For example, substring("12345",2) returns "2345".
			xpath = new XPathQuery("substring('12345',2)");
			assertEquals("result should match example in spec", "2345", xpath.exec(null));
			// For example, substring("12345",2,3)  returns "234"
			xpath = new XPathQuery("substring('12345',2,3)");
			assertEquals("result should match example in spec", "234", xpath.exec(null));
		}
		
		
		public function testNormalizeSpace():void
		{
			xpath = new XPathQuery("normalize-space(//div[@class='Hit' and contains(h3, 'Apollo')][1]/div[@class='Abstract'])");
			xpath.context.openAllNamespaces = true;
			assertEquals("result should have spaces removed",
					"There was a bit of a buzz in the air on Monday when Adobe rolled out " + 
					"the first public alpha release of its Apollo desktop internet application " + 
					"client – along with a whole truckload of developer tools and documentation. " + 
					"Apollo is an interesting proposition, a platform that mixes Flash (though you " + 
					"do need to use code that's …", xpath.exec(reg));

		}
	}
}