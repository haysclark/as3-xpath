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

package memorphic.xpath.fixtures
{
	import flash.utils.ByteArray;

	public class XMLData
	{


		public static function get adobeBlogsRDF():XML
		{
			return new XML(adobeBlogsRDFString);
		}
		
		
		public static function get adobeHomeXHTML():XML{
			return new XML(adobeHomeXHTMLString);
		}

		public static function get foodMenuXML():XML{
			return new XML(foodMenuString);
		}

		public static function get cdCatalogXML():XML{
			return new XML(cdCatalogXMLString);
		}
		public static function get registerHTML():XML{
			return new XML(registerHTMLString);
		}



		[Embed(source="flash_xpath.rdf", mimeType="application/octet-stream")]
		private static const XPATH_FLASH_RDF_RAW:Class;
		
		public static const adobeBlogsRDFString:String = getString(new XPATH_FLASH_RDF_RAW());

		[Embed(source="adobe.xhtml", mimeType="application/octet-stream")]
		private static const ADOBE_HOME_RAW:Class;
		
		public static const adobeHomeXHTMLString:String = getString(new ADOBE_HOME_RAW());

		[Embed(source="cd_catalog.xml", mimeType="application/octet-stream")]
		private static const CD_CAT_RAW:Class;
		
		public static const cdCatalogXMLString:String = getString(new CD_CAT_RAW());

		[Embed(source="menu.xml", mimeType="application/octet-stream")]
		private static const MENU_RAW:Class;
		
		public static const foodMenuString:String = getString(new MENU_RAW());


		[Embed(source="register.html", mimeType="application/octet-stream")]
		private static const REGISTER_RAW:Class;
		
		public static const registerHTMLString:String = getString(new REGISTER_RAW());


		private static function getString(data:ByteArray):String
		{
			return data.readUTFBytes(data.length);
		}



	}

}