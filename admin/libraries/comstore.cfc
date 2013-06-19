<cfcomponent extends="system.library">

	<!---
		Returns a structure containing information about all components saved in the application or session scope
	--->
	<cffunction name="list">
		
		<cfif isDefined("application.lbase.sessions")>
			<cfset sessions = application.lbase.sessions>
		<cfelse>
			<cfset sessions = {}>
		</cfif>
		<cfset sessions["application"] = application>
		<cfset componentRefs = {}>
		
		<cfloop collection="#sessions#" item="sessionID">
			<cfset sessionScope = sessions[sessionID]>
			<cfif isDefined("sessionScope.lbase.store")>
				<cfset comStore = sessionScope.lbase.store>
				<cfloop collection="#comStore#" item="hash">
					<cfif isDefined("componentRefs[hash]")>
						<cfset componentRefs[hash].count = componentRefs[hash].count + 1>
					<cfelse>
						<cfset sessionComponent = comStore[hash]>
						<cfset metadata = getMetaData(sessionComponent)>
						<cfset componentRefs[hash] = {
							hash:hash,
							component:metadata.fullname,
							count:1
						}>
						<cfif sessionID eq "application">
							<cfset componentRefs[hash].scope = "application">
						<cfelse>
							<cfset componentRefs[hash].scope = "session">
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfreturn componentRefs>
		
	</cffunction>

	<cffunction name="purge">
		<cfargument name="hash" default="#null#">
		
		<cfif isNull(arguments.hash)>
		
			<cfset returnMessage = "All caches were emtied">
			
			<cfset session.lbase = {}>
			<cfset application.lbase = {}>
			<cfset session.lbase = {}>
		
		<cfelse>
			
			<cfset returnMessage = "Searching for hash...">
			
			<cfif isDefined("application.lbase.sessions")>
				<cfset sessions = application.lbase.sessions>
			<cfelse>
				<cfset sessions = {}>
			</cfif>
			<cfset sessions["application"] = application>
			<cfloop collection="#sessions#" item="sessionID">
				<cfset sessionScope = sessions[sessionID]>
				<cfif isDefined("sessionScope.lbase.store")>
					<cfset comStore = sessionScope.lbase.store>
					<cfloop collection="#comStore#" item="exHash">
						<cfif exHash eq arguments.hash>
							<cfset returnMessage = returnMessage & "Hash found (#getMetaData(comStore[exHash]).fullname#)...">
							<cfset structDelete(comStore,exHash)>
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn returnMessage>
		
	</cffunction>

</cfcomponent>