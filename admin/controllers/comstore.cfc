<cfcomponent extends="system.controller">
	
	<cffunction name="purge">
		<cfargument name="hash" default="#null#">
		
		<cfset result = this.comstore.purge(hash=arguments.hash)>

		<cfdump var="#result#">
	</cffunction>
	
	<cffunction name="list">
		<cfset list = this.comstore.list()>
		<cfset this.mod.view("sessionlist",{
			componentRefs=list
		})>
	</cffunction>
	
</cfcomponent>