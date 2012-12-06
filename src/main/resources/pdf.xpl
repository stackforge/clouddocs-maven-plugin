<?xml version="1.0" encoding="UTF-8"?>

<p:declare-step version="1.0" xmlns:p="http://www.w3.org/ns/xproc"
		xmlns:l="http://xproc.org/library"
		xmlns:db="http://docbook.org/ns/docbook"
		xmlns:ut="http://grtjn.nl/ns/xproc/util"
		xmlns:c="http://www.w3.org/ns/xproc-step"
		xmlns:cx="http://xmlcalabash.com/ns/extensions" name="main">

  <p:import href="classpath:/rackspace-library.xpl"/><!-- classpath:/ -->
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

  <p:input port="source"/>
  <p:output port="result"/>

  <p:input port="parameters" kind="parameter"/>
  <ut:parameters name="params"/>
  <p:sink/>

  <p:group name="group">
    <p:output port="result" primary="true">
      <p:pipe step="validate-post-wadl-idrefs" port="result"/>
    </p:output>
    <p:output port="secondary" primary="false" sequence="true"/>
    
    <p:variable name="project.build.directory" select="//c:param[@name = 'project.build.directory']/@value">
      <p:pipe step="params" port="parameters"/>
    </p:variable>

    <!-- <cx:message name="msg1"> -->
    <!--   <p:with-option name="message" select="'Entering xproc pipeline'"/> -->
    <!-- </cx:message> -->

    <!-- <cx:message name="msg2"> -->
    <!--   <p:with-option name="message" select="'Validating DocBook version'"/> -->
    <!-- </cx:message> -->

    <l:validate-docbook-format>
      <p:input port="source">
	<p:pipe step="main" port="source"/>
      </p:input>
      <p:with-option name="docbookNamespace" select="'http://docbook.org/ns/docbook'"/>
    </l:validate-docbook-format>

    <p:xslt name="pdfprops">
      <p:input port="source">  
	<p:pipe step="main" port="source"/>  
      </p:input>  
      <p:input port="stylesheet">
	<p:inline>
	  <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	    <xsl:param name="security"/>
	    <xsl:template match="/">
<c:result xmlns:c="http://www.w3.org/ns/xproc-step">	
pdfsuffix=<xsl:if test="not($security = 'external') and not($security = '')">-<xsl:value-of select="$security"/></xsl:if><xsl:if test="/*/db:info/db:pubdate">-<xsl:value-of select="translate(/*/db:info/db:pubdate,'-','')"/></xsl:if>
</c:result>      
	    </xsl:template>
	  </xsl:stylesheet>
	</p:inline>
      </p:input>
      <p:input port="parameters" >
	<p:pipe step="main" port="parameters"/>
      </p:input>  
    </p:xslt>

    <p:store name="store" encoding="utf-8" method="text"  media-type="text">
      <p:with-option name="href" select="concat('file://',$project.build.directory,'/docbkx/autopdf/pdf.properties')"/>
    </p:store>

    <p:add-xml-base>
      <p:input port="source">
	<p:pipe step="main" port="source"/>
      </p:input>
    </p:add-xml-base>
    
    <p:xinclude fixup-xml-base="true"/>

    <cx:message>
      <p:with-option name="message" select="'Validating post-xinclude'"/>
    </cx:message>

    <p:delete match="//@security[. = '']"/>

    <l:docbook-xslt2-preprocess/>

    <l:validate-transform name="validate-post-xinclude">
      <p:input port="schema">
	<p:document href="classpath:/rng/rackbook.rng"/>
      </p:input>
    </l:validate-transform>

    <cx:message  name="msg3">
      <p:with-option name="message" select="'Validating images'"/>
    </cx:message>
    <l:validate-images/>

    <cx:message  name="msg4">
      <p:with-option name="message" select="'Performing programlisting keep together'"/>
    </cx:message>

    <l:programlisting-keep-together/>

    <p:delete match="//db:imageobject[@role='html']"/>
    <p:delete match="//db:imageobject/@role[. ='fo']"/>

    <cx:message name="msg5">
      <p:with-option name="message" select="'Adding extension info'"/>
    </cx:message>
    
    <l:extensions-info/>
    
    <cx:message name="msg6">
      <p:with-option name="message" select="'Making replacements'"/>
    </cx:message>
    <l:search-and-replace/>
    
    <cx:message name="msg7">
      <p:with-option name="message" select="'Normalize wadls'"/>
    </cx:message>

    <l:normalize-wadls />

    <l:process-embedded-wadl/>
    <p:delete match="//@rax:original-wadl" xmlns:rax="http://docs.rackspace.com/api"/>
    <p:delete match="//db:td/db:para[not(./*) and normalize-space(.) ='']"/>
    
    <l:validate-transform-idrefs name="validate-post-wadl-idrefs">
      <p:input port="schema">
	<p:document href="classpath:/rng/rackbook.rng"/>
      </p:input>
    </l:validate-transform-idrefs>

  </p:group>

</p:declare-step>