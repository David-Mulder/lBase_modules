<cfcomponent extends="system.model">
	<cffunction name="getPages">
		<cfset var qry_pages = "">
		<cfset var arr_pages = []>		
		<cfdirectory action="list" directory="#expandPath('/modules/manual/views/pages/')#" name="qry_pages">
		<cfloop query="qry_pages">
			<cfset arrayAppend(arr_pages,replace(qry_pages.name,".html",""))>
		</cfloop>
		<cfreturn arr_pages>
	</cffunction>
</cfcomponent>
