<cfcomponent extends="system.interface">

	<cfset this.templateData = {}>
	
	<cffunction name="set">
		<cfargument name="value">
		<cfargument name="actualvalue">
		<cfset var avalue = "">
		<cfset var name = "">
		<cfif isDefined("arguments.actualValue")>
			<cfset avalue = arguments.actualValue>
			<cfset name = arguments.value>
		<cfelse>
			<cfset avalue = arguments.value>
			<cfset name = "content">
		</cfif>
		<cfset this.templateData[name] = avalue>

	</cffunction>

	<cffunction name="view">
		<cfargument name="template">
		<cfargument name="viewScope" default="#super#">
			
		<cfset arguments.viewScope.view(arguments.template,this.templateData)>
	</cffunction>

</cfcomponent>
