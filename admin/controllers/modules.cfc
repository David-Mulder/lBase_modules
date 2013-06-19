<cfcomponent extends="system.controller">

	<cffunction name="init">
		<cfset this.register(this.mod.lib("repository"))>
	</cffunction>

	<cffunction name="index">
		
	</cffunction>

	<cffunction name="install">
		<cfargument name="module">
		<cfargument name="version">
		<cfif not isDefined("arguments.module")>
			<cfdump var="#this.repository.list()#">
		<cfelse>
			<cfset this.repository.install(arguments.module,arguments.version)>
		</cfif>
	</cffunction>

	<cffunction name="update">
		
	</cffunction>

	<cffunction name="publish">
		
	</cffunction>

</cfcomponent>
