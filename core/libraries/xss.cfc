<!---
	The XSS library handles outputting of all variables in views. This is done to prevent any trouble with XSS attacks.
--->
<cfcomponent extends="system.library">

	<cfset this.returnValues = false>

	<!---
		__callInOutput is a function allowing the other functions to be called in a `enableCFoutputOnly="no"` setting
	--->
	<cffunction name="__callInOutput"><cfargument name="filter" hint="Name of one of the other functions on this component"><cfargument name="value"><cfsetting enableCFoutputOnly="yes">
 
		<cfinvoke component="#this#" method="#arguments.filter#" value="#arguments.value#">

	<cfsetting enableCFoutputOnly="no"></cffunction>

	<!---
		html encode and output the first argument for output inside a html context
	--->
	<cffunction name="html">
		<cfargument name="value" required="yes">
		<cfset var value = htmleditformat(arguments[1])>
		<cfif this.returnValues>
			<cfreturn value>
		</cfif>
		<cfoutput>#value#</cfoutput>
	</cffunction>
	
	<!---
		html encode and output the first argument for output inside a attribute context
		an example of this would be <div data-id=""></div>
	--->
	<cffunction name="attr">
		<cfargument name="value" required="yes">
		<cfset var value = htmleditformat(arguments[1])>
		<cfif this.returnValues>
			<cfreturn value>
		</cfif>
		<cfoutput>#value#</cfoutput>
	</cffunction>

	<!---
		Simply output the provided argument doing nothing
	--->
	<cffunction name="unsafe">
		<cfargument name="value" required="yes">
		<cfset var value = arguments[1]>
		<cfif this.returnValues>
			<cfreturn value>
		</cfif>test
		<cfoutput>#value#</cfoutput>
	</cffunction>

</cfcomponent>