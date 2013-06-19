<cfcomponent extends="system.library">
	<cffunction name="hello">
		<cfset this.app.module("core").lib("console").log("hello world")>
		<cfreturn "world">
	</cffunction>
</cfcomponent>