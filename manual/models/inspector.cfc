<cfcomponent extends="system.model">
	<cffunction name="getModuleData">
		<cfargument name="name">
		<cfargument name="path" default="/modules/#arguments.name#">
		<cfset var console = this.app.module("core").lib("console")>
		<cfset var str_data = {
			name:arguments.name,
			controllers:[],
			models:[],
			libraries:[],
			hasCustomInterface:false,
			hasCustomManual:false
		}>
		<cfset var controllerDirectory = expandpath(arguments.path) & "/controllers/">
		<cfset var modelDirectory = expandpath(arguments.path) & "/models/">
		<cfset var libraryDirectory = expandpath(arguments.path) & "/libraries/">
		<cfif directoryExists(controllerDirectory)>
			<cfdirectory action="list" directory="#controllerDirectory#" name="qry_controllers">
			<cfloop query="qry_controllers">
				<cfset arrayAppend(str_data.controllers,replace(qry_controllers.name,".cfc",""))>
			</cfloop>
		</cfif>
		<cfif directoryExists(modelDirectory)>
			<cfdirectory action="list" directory="#expandpath(arguments.path)#/models/" name="qry_models">
			<cfloop query="qry_models">
				<cfset arrayAppend(str_data.models,replace(qry_models.name,".cfc",""))>
			</cfloop>
		</cfif>
		<cfif directoryExists(libraryDirectory)>
			<cfdirectory action="list" directory="#expandpath(arguments.path)#/libraries/" name="qry_libraries">
			<cfloop query="qry_libraries">
				<cfset arrayAppend(str_data.libraries,replace(qry_libraries.name,".cfc",""))>
			</cfloop>
		</cfif>
		<cfreturn str_data>
	</cffunction>
</cfcomponent>
