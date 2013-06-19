<cfcomponent extends="system.library" lbase:scope="application">
	<cffunction name="setup">
		<cfif mongoIsValid("mongo")>
			<cfset mongoDeRegister("mongo")>
		</cfif>
		<cfset mongoRegister( name="mongo", server="127.0.0.1", db="testing" )>
	</cffunction>
</cfcomponent>