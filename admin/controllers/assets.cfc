<cfcomponent extends="system.controller">
	
	<cffunction name="regenerate">

		<cfset var modules = this.lbase.getModules()>
		<cfset assetModules = []>
		<cfloop array="#modules#" index="module">
			<cfif directoryExists(expandPath("/modules/"&module&"/assets/"))>
				<cfset arrayappend(assetModules, module)>
			</cfif>
		</cfloop>
		
		<cfset var assetPreProcessors = this.lbase.getAssetPreProcessors()>
		<cfset xml = this.mod.view("urlrewrite.xml.html",{
			modules:assetModules,
			assetPreProcessors:assetPreProcessors
		},false)>
		
		<cffile action="write" file="#expandPath('/WEB-INF/urlrewrite.xml')#" output="#xml#">
	</cffunction>

</cfcomponent>