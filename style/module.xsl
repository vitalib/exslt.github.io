<?xml version="1.0"?>
<xsl:stylesheet version="1.1"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:exslt="http://exslt.org/documentation"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                exclude-result-prefixes="exslt dc rdf">

<xsl:import href="utils.xsl" />
<xsl:import href="module.stylesheet.xsl" />
<xsl:import href="module.package.xsl" />

<xsl:variable name="module" select="/exslt:module/@prefix" />
<xsl:variable name="version" select="/exslt:module/@version" />

<xsl:variable name="latest" select="document(concat($module, '.xml'), .)" />
<xsl:variable name="latest-version" select="$latest/exslt:module/@version" />

<xsl:variable name="title">
   <a href="http://www.exslt.org/">EXSLT</a>
   <xsl:text> - </xsl:text>
   <a href="http://www.exslt.org/{$module}/"><xsl:value-of select="/exslt:module/exslt:name" /></a>
</xsl:variable>

<xsl:template match="/">
   <xsl:variable name="latest" select="$version = $latest-version" />
   <xsl:if test="$version = $latest-version">
      <xsl:message><xsl:value-of select="$module" /> : Creating module page...</xsl:message>
      <xsl:call-template name="new-page">
         <xsl:with-param name="dir" select="concat($module, '/')" />
         <xsl:with-param name="href" select="'index.html'" />
         <xsl:with-param name="title" select="$title" />
         <xsl:with-param name="menu">
            <xsl:call-template name="menu">
               <xsl:with-param name="module" select="$module" />
               <xsl:with-param name="type" select="'user'" />
            </xsl:call-template>
         </xsl:with-param>
         <xsl:with-param name="content">
            <xsl:apply-templates mode="user-content" />
         </xsl:with-param>
         <xsl:with-param name="last-modified" select="exslt:module/rdf:Description/exslt:revision[last()]/rdf:Description/dc:date" />
      </xsl:call-template>
      <xsl:message><xsl:value-of select="$module" /> : Creating module developer page...</xsl:message>
      <xsl:call-template name="new-page">
         <xsl:with-param name="dir" select="concat($module, '/')" />
         <xsl:with-param name="href" select="concat($module, '.html')" />
         <xsl:with-param name="title">
            <xsl:copy-of select="$title" />
            <xsl:text> - Implementer Page</xsl:text>
         </xsl:with-param>
         <xsl:with-param name="menu">
            <xsl:call-template name="menu">
               <xsl:with-param name="module" select="$module" />
            </xsl:call-template>
         </xsl:with-param>
         <xsl:with-param name="content">
            <xsl:apply-templates />
         </xsl:with-param>
         <xsl:with-param name="last-modified" select="exslt:module/rdf:Description/exslt:revision[last()]/rdf:Description/dc:date" />
      </xsl:call-template>
      <xsl:message><xsl:value-of select="$module" /> : Creating module zip file list...</xsl:message>
      <xsl:apply-templates select="*" mode="package" />
      <xsl:message><xsl:value-of select="$module" /> : Creating module stylesheet...</xsl:message>
      <xsl:apply-templates select="*" mode="stylesheet" />
   </xsl:if>
   <xsl:message><xsl:value-of select="$module" /> : Creating module version page...</xsl:message>
   <xsl:call-template name="new-page">
         <xsl:with-param name="dir" select="concat($module, '/')" />
      <xsl:with-param name="href" select="concat($module, '.', $version, '.html')" />
      <xsl:with-param name="title">
         <xsl:copy-of select="$title" />
         <xsl:text> - </xsl:text>
         <a href="/{$module}/{$module}.{$version}.html">
            <xsl:text>Version </xsl:text>
            <xsl:value-of select="$version" />
         </a>
      </xsl:with-param>
      <xsl:with-param name="menu">
         <xsl:call-template name="menu">
            <xsl:with-param name="module" select="$module" />
         </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="content">
         <xsl:apply-templates />
      </xsl:with-param>
      <xsl:with-param name="last-modified" select="exslt:module/rdf:Description/exslt:revision[last()]/rdf:Description/dc:date" />
   </xsl:call-template>
   <xsl:message><xsl:value-of select="$module" /> : Creating module update script...</xsl:message>
   <xsl:document href="update.bat" method="text">
      <xsl:apply-templates mode="update-bat" />
      <xsl:call-template name="cd" />
      <xsl:call-template name="transform">
         <xsl:with-param name="input" select="'modules.xml'" />
         <xsl:with-param name="stylesheet" select="'style/home.xsl'" />
      </xsl:call-template>
      <xsl:call-template name="transform">
         <xsl:with-param name="input" select="'modules.xml'" />
         <xsl:with-param name="stylesheet" select="'style/package.xsl'" />
      </xsl:call-template>
      <xsl:call-template name="zip">
         <xsl:with-param name="output" select="'all-exslt.zip'" />
         <xsl:with-param name="file" select="'package.txt'" />
      </xsl:call-template>
      <xsl:call-template name="transform">
         <xsl:with-param name="input" select="'modules.xml'" />
         <xsl:with-param name="stylesheet" select="'style/xml-package.xsl'" />
      </xsl:call-template>
      <xsl:call-template name="zip">
         <xsl:with-param name="output" select="'exslt.zip'" />
         <xsl:with-param name="file" select="'xml-package.txt'" />
      </xsl:call-template>
      <xsl:call-template name="cd">
         <xsl:with-param name="to" select="$module" />
      </xsl:call-template>
   </xsl:document>
</xsl:template>

<xsl:template match="exslt:module">
   <p>
      <b>Version: </b>
      <xsl:value-of select="$version" /><br />
      <b>User Page: </b>
      <a href="index.html">index.html</a><br />
      <b>XML Definition: </b>
      <a href="{$module}.xml">
         <xsl:value-of select="$module" />.xml<xsl:text />
      </a><br />
      <b><a href="../howto.html#module-level">Module Package</a>: </b>
      <a href="{$module}.zip">
         <xsl:value-of select="$module" />.zip<xsl:text />
      </a>
   </p>
   <xsl:apply-templates select="exslt:doc" />
   <p>
      The extension elements and functions defined within this document are governed by the general rules about extensions to XSLT covered in [<a class="offsite" href="http://www.w3.org/TR/xslt#extension">14. Extensions</a>] in [<a href="http://www.w3.org/TR/xslt" class="offsite">XSLT 1.0</a>].
   </p>
   <p>
      XSLT processors are free to support any number of the extension elements and functions described in this document.  However, an XSLT processor must not claim to support EXSLT - <xsl:value-of select="exslt:name" /> unless all the core extensions described within this document are implemented by the processor.  An implementation of an extension element or function in an EXSLT namespace must conform to the behaviour described in this document.
   </p>
   <p class="note">
      Using EXSLT will only make your stylesheet portable amongst the implementations that support EXSLT. Note that there is no requirement for XSLT processors that are compliant to XSLT to  support the extensions described within EXSLT.
   </p>
   <h2>Namespace</h2>
   <p>
      The namespace for EXSLT - <xsl:value-of select="exslt:name" /> is:
   </p>
   <pre>
      <xsl:text>http://exslt.org/</xsl:text>
      <xsl:value-of select="translate(translate(exslt:name, $uc, $lc), ' ', '-')" />
   </pre>
   <p>
      Throughout this document, the prefix <code><xsl:value-of select="$module" /></code> is used to refer to this namespace. Any other prefix can be used within a particular stylesheet (though a prefix must be specified to enable the extension functions to be recognised as extensions).
   </p>
   <xsl:apply-templates select="exslt:elements" />
   <xsl:apply-templates select="exslt:functions" />
   <xsl:apply-templates select="rdf:Description" />
</xsl:template>

<xsl:template match="exslt:module" mode="user-content">
   <p>
      <b>Implementer Page: </b>
      <a href="{$module}.html">
         <xsl:value-of select="$module" />.html<xsl:text />
      </a><br />
      <b><a href="../howto.html#module-level">Module Package</a>: </b>
      <a href="{$module}.zip">
         <xsl:value-of select="$module" />.zip<xsl:text />
      </a>
   </p>
   <xsl:apply-templates select="exslt:user-doc" />
   <xsl:if test="not(exslt:user-doc)">
      <xsl:apply-templates select="exslt:doc" />
   </xsl:if>
   <p>
      XSLT processors may support any number of the extension elements and functions given in this module.
   </p>
   <p class="note">
      Using EXSLT will only make your stylesheet portable amongst the implementations that support EXSLT. Note that there is no requirement for XSLT processors that are compliant to XSLT to support the extensions described within EXSLT.
   </p>
   <h2>Namespace</h2>
   <p>
      The namespace for EXSLT - <xsl:value-of select="exslt:name" /> is:
   </p>
   <xsl:variable name="namespace">
      <xsl:text>http://exslt.org/</xsl:text>
      <xsl:value-of select="translate(translate(exslt:name, $uc, $lc), ' ', '-')" />
   </xsl:variable>
   <pre>
      <xsl:value-of select="$namespace" />
   </pre>
   <p>
      Throughout this document, the prefix <code><xsl:value-of select="$module" /></code> is used to refer to this namespace. Any other prefix can be used within a particular stylesheet (though a prefix must be specified to enable the extension functions to be recognised as extensions).
   </p>
   <p>
      To use these extensions, you need to declare this namespace as an extension namespace in your stylesheet.  If your processor supports this module, then that&apos;s all you need to do, but if it doesn&apos;t, then you need to use a specific third-party implementation or the module stylesheet.  Typically, your stylesheet will look like:
   </p>
<pre>
&lt;xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:<xsl:value-of select="$module" />="<xsl:value-of select="$namespace" />"
                extension-element-prefixes="<xsl:value-of select="$module" />">

&lt;xsl:import href="<xsl:value-of select="$module" />.xsl" />

...
              
&lt;/xsl:stylesheet>
</pre>
   <xsl:apply-templates select="exslt:elements" mode="user-content" />
   <xsl:apply-templates select="exslt:functions" mode="user-content" />
</xsl:template>

<xsl:template match="exslt:elements[exslt:element]" mode="user-content">
   <xsl:variable name="elements">
      <xsl:if test="exslt:element/@core = 'yes'">
         <h3>Core Elements</h3>
         <p>
            The following extension elements are considered stable and are core to EXSLT - <xsl:value-of select="../exslt:name" />.  Processors that claim support of EXSLT - <xsl:value-of select="../exslt:name" /> support these elements.
         </p>
         <table>
            <tr>
               <th class="rowhead">Element</th>
               <th>Syntax</th>
               <th>Download</th>
            </tr>
            <xsl:apply-templates select="exslt:element[@core = 'yes']" mode="user-content" />
         </table>
      </xsl:if>
      <xsl:if test="exslt:element[not(@core = 'yes')]">
               <!--
         <xsl:variable name="rows">
            <xsl:for-each select="exslt:element[not(@core = 'yes')]">
               <xsl:variable name="element-XML" select="document(concat('elements/', @name, '/', $module, '.', @name, '.xml'), .)/exslt:element" />
               <xsl:if test="$element-XML/exslt:implementations/*">
                  <xsl:apply-templates select="." mode="user-content" />
               </xsl:if>
            </xsl:for-each>
         </xsl:variable>
         <xsl:if test="string($rows)">
               -->
            <h3>Other Elements</h3>
            <p>
               The following extension elements are not considered stable and are not part of the core of EXSLT - <xsl:value-of select="../exslt:name" />.  Processors that claim support of EXSLT - <xsl:value-of select="../exslt:name" /> might not support these elements.
            </p>
            <table>
               <tr>
                  <th class="rowhead">Element</th>
                  <th>Syntax</th>
                  <th>Download</th>
               </tr>
               <xsl:for-each select="exslt:element[not(@core = 'yes')]">
                  <xsl:apply-templates select="." mode="user-content" />
               </xsl:for-each>
            </table>
      <!-- </xsl:if> -->
      </xsl:if>
   </xsl:variable>
   <xsl:if test="string($elements)">
      <h2>Elements</h2>
      <xsl:copy-of select="$elements" />
   </xsl:if>
</xsl:template>

<xsl:template match="exslt:elements[exslt:element]">
   <h2>Elements</h2>
   <xsl:if test="exslt:element[@core = 'yes']">
      <h3>Core Elements</h3>
      <p>
         The following extension elements are considered stable and are core to EXSLT - <xsl:value-of select="../exslt:name" />.  Processors that claim support of EXSLT - <xsl:value-of select="../exslt:name" /> must support these elements.
      </p>
      <table>
         <tr>
            <th class="rowhead">Element</th>
            <th>Version</th>
            <th>Status</th>
            <th>Syntax</th>
            <th>Download</th>
         </tr>
         <xsl:apply-templates select="exslt:element[@core = 'yes']" mode="module" />
         <tr>
            <td colspan="5" class="rowhead">* old version of element</td>
         </tr>
      </table>
   </xsl:if>
   <xsl:if test="exslt:element[not(@core = 'yes')]">
      <h3>Other Elements</h3>
      <p>
         The following extension elements are not considered stable and are not part of the core of EXSLT - <xsl:value-of select="../exslt:name" />.  Processors that claim support of EXSLT - <xsl:value-of select="../exslt:name" /> might not support these elements.
      </p>
      <table>
         <tr>
            <th class="rowhead">Element</th>
            <th>Version</th>
            <th>Status</th>
            <th>Syntax</th>
            <th>Download</th>
         </tr>
         <xsl:apply-templates select="exslt:element[not(@core = 'yes')]" mode="module" />
         <tr>
            <td colspan="5" class="rowhead">* old version of element</td>
         </tr>
      </table>
   </xsl:if>
</xsl:template>

<xsl:template match="exslt:functions[exslt:function]" mode="user-content">
   <xsl:variable name="functions">
      <xsl:if test="exslt:function/@core = 'yes'">
         <h3>Core Functions</h3>
         <p>
            The following extension functions are considered stable and are core to EXSLT - <xsl:value-of select="../exslt:name" />.  Processors that claim support of EXSLT - <xsl:value-of select="../exslt:name" /> support these functions.
         </p>
         <table>
            <tr>
               <th class="rowhead">Function</th>
               <th>Syntax</th>
               <th>Download</th>
            </tr>
            <xsl:apply-templates select="exslt:function[@core = 'yes']" mode="user-content" />
         </table>
      </xsl:if>
      <xsl:if test="exslt:function[not(@core = 'yes')]">
               <!--
         <xsl:variable name="rows">
            <xsl:for-each select="exslt:function[not(@core = 'yes')]">
               <xsl:variable name="function-XML" select="document(concat('functions/', @name, '/', $module, '.', @name, '.xml'), .)/exslt:function" />
               <xsl:if test="$function-XML/exslt:implementations/*">
                  <xsl:apply-templates select="." mode="user-content" />
               </xsl:if>
            </xsl:for-each>
         </xsl:variable>
         <xsl:if test="string($rows)">
               -->
            <h3>Other Functions</h3>
            <p>
               The following extension functions are not considered stable and are not part of the core of EXSLT - <xsl:value-of select="../exslt:name" />.  Processors that claim support of EXSLT - <xsl:value-of select="../exslt:name" /> might not support these functions.
            </p>
            <table>
               <tr>
                  <th class="rowhead">Function</th>
                  <th>Syntax</th>
                  <th>Download</th>
               </tr>
               <xsl:for-each select="exslt:function[not(@core = 'yes')]">
                  <xsl:apply-templates select="." mode="user-content" />
               </xsl:for-each>
            </table>
      <!-- </xsl:if> -->
      </xsl:if>
   </xsl:variable>
   <xsl:if test="string($functions)">
      <h2>Functions</h2>
      <xsl:copy-of select="$functions" />
   </xsl:if>
</xsl:template>

<xsl:template match="exslt:functions[exslt:function]">
   <h2>Functions</h2>
   <xsl:if test="exslt:function[@core = 'yes']">
      <h3>Core Functions</h3>
      <p>
         The following extension functions are considered stable and are core to EXSLT - <xsl:value-of select="../exslt:name" />.  Processors that claim support of EXSLT - <xsl:value-of select="../exslt:name" /> must support these functions.
      </p>
      <table>
         <tr>
            <th class="rowhead">Function</th>
            <th>Version</th>
            <th>Status</th>
            <th>Syntax</th>
            <th>Download</th>
         </tr>
         <xsl:apply-templates select="exslt:function[@core = 'yes']" mode="module" />
         <tr>
            <td colspan="5" class="rowhead">* old version of function</td>
         </tr>
      </table>
   </xsl:if>
   <xsl:if test="exslt:function[not(@core = 'yes')]">
      <h3>Other Functions</h3>
      <p>
         The following extension functions are not considered stable and are not part of the core of EXSLT - <xsl:value-of select="../exslt:name" />.  Processors that claim support of EXSLT - <xsl:value-of select="../exslt:name" /> might not support these functions.
      </p>
      <table>
         <tr>
            <th class="rowhead">Function</th>
            <th>Version</th>
            <th>Status</th>
            <th>Syntax</th>
            <th>Download</th>
         </tr>
         <xsl:apply-templates select="exslt:function[not(@core = 'yes')]" mode="module" />
         <tr>
            <td colspan="5" class="rowhead">* old version of function</td>
         </tr>
      </table>
   </xsl:if>
</xsl:template>

<xsl:template match="exslt:element" mode="user-content">
   <xsl:variable name="dir" select="concat('elements/', @name)" />
   <xsl:variable name="element" select="document(concat($dir, '/', $module, '.', @name, '.xml'), .)/exslt:element" />
   <tr>
      <td class="rowhead">
         <a href="{$dir}/index.html">
            <xsl:value-of select="$module" />:<xsl:value-of select="@name" />
         </a>
      </td>
      <td style="text-align: left; font-size: 80%;">
         <pre>
            <xsl:apply-templates select="$element/exslt:definition" mode="element-syntax" />
         </pre>
      </td>
      <td>
         <a href="{$dir}/{$module}.{@name}.zip">
            <xsl:value-of select="$module" />.<xsl:value-of select="@name" />.zip<xsl:text />
         </a>
      </td>
   </tr>
</xsl:template>

<xsl:template match="exslt:function" mode="user-content">
   <xsl:variable name="dir" select="concat('functions/', @name)" />
   <xsl:variable name="function" select="document(concat($dir, '/', $module, '.', @name, '.xml'), .)/exslt:function" />
   <tr>
      <td class="rowhead">
         <a href="{$dir}/index.html">
            <xsl:value-of select="$module" />:<xsl:value-of select="@name" />
         </a>
      </td>
      <td style="text-align: left;">
         <xsl:apply-templates select="$function/exslt:definition" mode="function-syntax" />
      </td>
      <td>
         <xsl:choose>
            <xsl:when test="$function/exslt:implementations/exslt:implementation">
               <a href="{$dir}/{$module}.{@name}.zip">
                  <xsl:value-of select="$module" />.<xsl:value-of select="@name" />.zip<xsl:text />
               </a>
            </xsl:when>
            <xsl:otherwise>-</xsl:otherwise>
         </xsl:choose>
      </td>
   </tr>
</xsl:template>

<xsl:template match="exslt:element" mode="module">
   <xsl:variable name="dir" select="concat('elements/', @name)" />
   <xsl:variable name="element" select="document(concat($dir, '/', $module, '.', @name, '.xml'), .)/exslt:element" />
   <tr>
      <td class="rowhead">
         <a href="{$dir}/{$module}.{@name}.html">
            <xsl:value-of select="$module" />:<xsl:value-of select="@name" />
         </a>
      </td>
      <td>
         <a href="{$dir}/{$module}.{@name}.{@version}.html">
            <xsl:value-of select="@version" />
         </a>
         <xsl:if test="@version != $element/@version">*</xsl:if>
      </td>
      <td><xsl:value-of select="$element/@status" /></td>
      <td style="text-align: left; font-size: 80%;">
         <pre>
            <xsl:apply-templates select="$element/exslt:definition" mode="element-syntax" />
         </pre>
      </td>
      <td>
         <a href="{$dir}/{$module}.{@name}.zip">
            <xsl:value-of select="$module" />.<xsl:value-of select="@name" />.zip<xsl:text />
         </a>
      </td>
   </tr>
   <xsl:document href="{$dir}/refresh.bat" method="text">
      <xsl:call-template name="transform">
         <xsl:with-param name="input" select="concat($module, '.', @name, '.xml')" />
         <xsl:with-param name="stylesheet" select="'../../../style/element.xsl'" />
      </xsl:call-template>
   </xsl:document>
</xsl:template>

<xsl:template match="exslt:function" mode="module">
   <xsl:variable name="dir" select="concat('functions/', @name)" />
   <xsl:variable name="function" select="document(concat($dir, '/', $module, '.', @name, '.xml'), .)/exslt:function" />
   <tr>
      <td class="rowhead">
         <a href="{$dir}/{$module}.{@name}.html">
            <xsl:value-of select="$module" />:<xsl:value-of select="@name" />
         </a>
      </td>
      <td>
         <a href="{$dir}/{$module}.{@name}.{@version}.html">
            <xsl:value-of select="@version" />
         </a>
         <xsl:if test="@version != $function/@version">*</xsl:if>
      </td>
      <td><xsl:value-of select="$function/@status" /></td>
      <td style="text-align: left;">
         <xsl:apply-templates select="$function/exslt:definition" mode="function-syntax" />
      </td>
      <td>
         <xsl:choose>
            <xsl:when test="$function/exslt:implementations/exslt:implementation">
               <a href="{$dir}/{$module}.{@name}.zip">
                  <xsl:value-of select="$module" />.<xsl:value-of select="@name" />.zip<xsl:text />
               </a>
            </xsl:when>
            <xsl:otherwise>-</xsl:otherwise>
         </xsl:choose>
      </td>
   </tr>
   <xsl:document href="{$dir}/refresh.bat" method="text">
      <xsl:call-template name="transform">
         <xsl:with-param name="input" select="concat($module, '.', @name, '.xml')" />
         <xsl:with-param name="stylesheet" select="'../../../style/function.xsl'" />
      </xsl:call-template>
   </xsl:document>
</xsl:template>

</xsl:stylesheet>