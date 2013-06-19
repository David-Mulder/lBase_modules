<cfcomponent extends="system.config.base">
	<cfset config["autoregister"] = {}>
	<cfset config["autoregister"]["libraries"] = ["comstore"]>
	<cfset config["autoregister"]["modules"] = ["core"]>
</cfcomponent>