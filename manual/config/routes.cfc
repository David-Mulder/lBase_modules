<cfcomponent extends="system.config.modules.routes">
	<cfset routes["/"] = "manual/page">
	<cfset routes["/helppage/(*)"] = "manual/page/$1">
	<cfset routes["/application"] = "manual/inspect/application/application/application">
	<cfset routes["/(*)"] = "manual/inspect/$1/module/$1">
	<cfset routes["/(*)/(*)/(*)"] = "manual/inspect/$1/$2/$3">
	<cfset routes["/(*)/(*)"] = "manual/inspect/application/$1/$2">
</cfcomponent>
