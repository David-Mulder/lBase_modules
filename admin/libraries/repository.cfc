<cfcomponent extends="system.library">

	<cfset this.repositoryURL = "http://localhost:8080/lbaseRepos/api/">

	<cffunction name="list">
		
		<cfset var data = "">
		<cfhttp url="#this.repositoryURL#repositories" result="repositories">
		<cfreturn deserializeJSON(repositories.filecontent)>
		
	</cffunction>
	
	<cffunction name="install">
		<cfargument name="module">
		<cfargument name="version">
			
		<cfset var cfhttpinfo = {}>
		<cfset var directory = GetTempDirectory()>
		<cfset var filename = hash(arguments.module & arguments.version) & ".zip">
		<cfset var destination = '/modules/#arguments.module#/'>
		<cfhttp url="#this.repositoryURL#repository/#arguments.module#/#arguments.version#" file="#filename#" path="#directory#" result="cfzipinfo">
		<cfset var fullpath = cfzipinfo.filecontent>
		<cfzip action="list" zipfile="#fullpath#">
		
		<cfif directoryExists(expandPath(destination))>
			<cfset directoryDelete(expandPath(destination),true)>
		</cfif>
		
		<cfzip action="extract" zipfile="#fullpath#" destination="#expandpath(destination)#">
		<cfdump var="#fullpath#"><cfabort>
		<cfreturn deserializeJSON(repositories.filecontent)>
		
	</cffunction>

</cfcomponent>