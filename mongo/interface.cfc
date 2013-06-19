<cfcomponent extends="system.interface">
	<cffunction name="init">
		<cfset this.mod.lib("mongo").setup()>
	</cffunction>
	<cffunction name="model">
		<cfargument name="collectionName">
		<cfset var model = super.model("base")>
		<cfset model._collection = arguments.collectionName>
		<cfreturn model>
		<cfoutput>HERE</cfoutput><cfabort>
	</cffunction>
</cfcomponent>
