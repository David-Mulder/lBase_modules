<cfcomponent extends="system.config.base">

	<!--- autoregister *all* libraries --->
	<cfset config["autoregister"] = {}>
	<cfset config["autoregister"]["libraries"] = ["console","site","xss"]>

</cfcomponent>