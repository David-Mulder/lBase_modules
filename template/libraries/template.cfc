<cfcomponent>

	<cffunction name="view">
	
		<!--- module specific view --->
		<cfset this.mod.view("frontend")>
		
		<!--- app specific view --->
		<cfset this.app.view("welcome")>
		
		<!--- view of external natural module --->
		<cfset this.app.mod("name").view("welcome")>
		<!--- view of external unnatural module --->
		<cfset this.app.mod("name").mod.view("welcome")>
	
	</cffunction>

</cfcomponent>