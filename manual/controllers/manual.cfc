<cfcomponent extends="system.controller">
	
	<cffunction name="page">
		<cfargument name="page" default="welcome">
		<cfset var arr_pages = this.mod.model("manual").getPages()>
		<cfset this.app.module("template").set("leftColumn",this.mod.view("navigation/pages.html",{
			arr_pages:arr_pages
		},false))>
		<cfset this.app.module("template").set("modules",this.lbase.getModules())>
		<cfset this.app.module("template").set(this.mod.view("pages/"&arguments.page&".html",{},false))>
		<cfset this.app.module("template").view("template",this.mod)>
			
	</cffunction>
	
	<cffunction name="inspect">
		<cfargument name="scope">
		<cfargument name="type">
		<cfargument name="item">
		
		<cfset var console = this.app.module("core").console>
		<cfset console.log(arguments)>
		
		<cfif arguments.scope eq "application">
			<cfset var metaObjectPath = "application.">
			<cfset var filePath = "application/">
			<cfset var lbasePath = "this.app.">
		<cfelse>
			<cfset var metaObjectPath = "modules."&arguments.scope&".">
			<cfset var filePath = "modules/"&arguments.scope&"/">
			<!---
			<cfset var lbasePath = 'this.app.module("'&arguments.scope&'").'>
			--->
			<cfset var lbasePath = 'this.mod.'>
		</cfif>
		<cfif arguments.type eq "application">
			<cfset metaObjectPath = "system._core.baseinterface">
			<cfset filePath = "/system/_core/baseinterface.cfc">
			<cfset var lbaseTypeName = "">
		<cfelseif arguments.type eq "module">
			<cfset var lbaseTypeName = "">
			<cfset metaObjectPath = metaObjectPath & "interface">
			<cfset filePath = filePath & "interface.cfc">
			<cfif not fileExists(expandPath(filePath))>
				<cfset metaObjectPath = "system._core.baseinterface">
				<cfset filePath = "/system/_core/baseinterface.cfc">
			</cfif>
		<cfelseif arguments.type eq "library">
			<cfset var directoryName = "libraries">
			<cfset var lbaseTypeName = "lib">
		<cfelseif arguments.type eq "model">
			<cfset var directoryName = "models">
			<cfset var lbaseTypeName = "model">
		<cfelseif arguments.type eq "controller">
			<cfset var directoryName = "controllers">
			<cfset var lbaseTypeName = "">
			<cfif arguments.scope eq "application">
				<cfset var lbasePath = "/"&arguments.item>
			<cfelse>
				<cfset var lbasePath = "/"&arguments.scope&"/"&arguments.item>				
			</cfif>
		</cfif>
		<cfif arguments.type neq "module" and arguments.type neq "application">
			<cfset metaObjectPath = metaObjectPath & directoryName & "." & arguments.item>
			<cfset filePath = filePath & directoryName & "/" & arguments.item & ".cfc">
		</cfif>
		<cfif lbaseTypeName eq "">
		<cfelse>
			<cfset lbasePath = lbasePath & lbaseTypeName & '("' & arguments.item & '")'>
		</cfif>
		
		<cfset var metaObject = createObject(metaObjectPath)>
		<cfset var metaData = duplicate(getMetaData(metaObject))>
		<cfif not isDefined("metaData.functions")>
			<cfset metaData.functions = []>
		</cfif>
		<!---<cfdump var="#getMetaData(metaObject)#">
		<cfdump var="#Serializejson(metaData)#"><cfabort>--->
		<cfset metaData.name = arguments.item>
		<cfset metaData.type = arguments.type>
		<cfset metaData.scope = arguments.scope>
		
		<cfset var filecontent = "">
		<cffile action="read" file="#expandPath(filepath)#" variable="filecontent">

		<cfset var filelines = listtoarray(filecontent,chr(10))>
		<cfset var lineContext = "">
		<cfset var lineContextName = "">
		<cfset var functionDocBuffer = "">
		<cfset var functionBuffer = []>
		<cfset var variable = "">
		<cfset var functionDocs = {}>
		<cfset var functionCode = {}>
		<cfset var lineNumber = 0>
		<cfset var localVariables = ["this","form","url"]>
		<cfset var nonlocalVariables = []>
		<cfset var commentDepth = 0>
		
		<cfloop array="#filelines#" index="line">
			<cfset lineNumber = lineNumber + 1>
			<cfif trim(line) eq "--->" and (lineContext eq "functiondoc")>
				<cfset lineContext = "component">
			<cfelseif lineContext eq "functiondoc">
				<cfset functionDocBuffer = functionDocBuffer & mid(line,commentDepth+1,max(0,len(line)-commentDepth)) & chr(10)>
			<cfelseif trim(line) eq "<!---" and (lineContext eq "component" or lineContext eq "")>
				<cfif lineContext eq "component">
					<cfset commentDepth = 2>
				<cfelseif lineContext eq "">
					<cfset commentDepth = 1>
				</cfif>
				<cfset lineContext = "functiondoc">
			<cfelseif right(trim(line),13) eq "</cffunction>">
				<cfset lineContext = "component">
				<cfset arrayAppend(functionBuffer,{
					code:line
				})>
				<cfset functionCode[lineContextName].source = functionBuffer>
				<cfset functionCode[lineContextName].nonlocals = nonlocalVariables>
				<cfset nonlocalVariables = []>
				<cfset localVariables = ["this","form","url"]>
				<cfset functionBuffer = []>
				<cfset lineContextName = "">
			<cfelseif left(trim(line),12) eq "<cfcomponent">
				<cfset linecontext = "component">
				<cfset metaData.docs = functionDocBuffer>
				<cfset functionDocBuffer = "">
			<cfelseif left(trim(line),12) eq "<cffunction ">
				<cfset var matches = REFindNoCase("<cffunction name=""(.*?)""",line,1,true)>
				<cfset lineContextName = mid(line,matches.pos[2],matches.len[2])>
				<cfset functionDocs[lineContextName] = functionDocBuffer>
				<cfset functionDocBuffer = "">
				<cfset lineContext = "function">
				<cfset arrayAppend(functionBuffer,{
					code:line
				})>
				<cfset functionCode[lineContextName] = {startline:lineNumber}>
			<cfelseif lineContext eq "function">
				<cfset var linedata = {
					code:line
				}>
				<cfif line contains "  ">
					<cfset linedata.warning = "Multiple spaces">
				</cfif>
				<cfset variable = "">
				<cfset var localvar = REFindNoCase("<cfset var ([_a-zA-Z]*?) =",line,1,true)>
				<cfif arraylen(localvar.pos) eq 2>
					<cfset variable = mid(line,localvar.pos[2],localvar.len[2])>
					<cfset arrayappend(localVariables,variable)>
				<cfelse>
					<cfset variable = null>
					<cfset var nonlocalvar = REFindNoCase("<cfset ([_a-zA-Z]*?)[\[\. ].*?=",line,1,true)>
					<cfif arraylen(nonlocalvar.pos) eq 2>
						<cfset variable = mid(line,nonlocalvar.pos[2],nonlocalvar.len[2])>
					</cfif>
					<cfset var nonlocalvar = REFindNoCase('<cfloop .*?(item|index)="([_a-zA-Z]*?)"',line,1,true)>
					<cfif arraylen(nonlocalvar.pos) eq 3>
						<cfset variable = mid(line,nonlocalvar.pos[3],nonlocalvar.len[3])>
					</cfif>
					<cfset var nonlocalvar = REFindNoCase('<cffile .*?variable="([_a-zA-Z]*?)"',line,1,true)>
					<cfif arraylen(nonlocalvar.pos) eq 2>
						<cfset variable = mid(line,nonlocalvar.pos[2],nonlocalvar.len[2])>
					</cfif>
				
					<cfif not isNull(variable) and not arrayfind(localVariables,variable)>
						<cfset rightcase = arrayfindnocase(localVariables,variable)>
						<cfif rightcase>
							<cfset linedata.warning = "Bad casing '#localVariables[rightcase]#'">
						<cfelse>
							<cfset linedata.warning = "Non local '#variable#'">
							<cfset arrayappend(nonlocalVariables,variable)>
						</cfif>
					</cfif>
				</cfif>
				<cfset arrayAppend(functionBuffer,linedata)>
			</cfif>
			
		</cfloop>

		<cfloop array="#metaData.functions#" index="metaFunction">
			<cfset metaFunction.hasError = false>
			<cfif isDefined("functionDocs."&metaFunction.name)>
				<cfset metaFunction.docs = functionDocs[metaFunction.name]>
			</cfif>
			<cfif isDefined("functionCode."&metaFunction.name)>
				<cfset var source = functionCode[metaFunction.name].source>
				<cfloop from="1" to="#arraylen(source)#" index="line">
					<cfif asc(left(source[line].code,1)) eq 9>
						<cfset source[line].code = mid(source[line].code,2,len(source[line].code)-1)>
					</cfif>
					<cfif asc(right(source[line].code,1)) eq 13>
						<cfset source[line].code = mid(source[line].code,1,len(source[line].code)-1)>
					</cfif>
					<cfif isDefined("source[line].warning")>
						<cfset metaFunction.hasError = true>
					</cfif>
					<cfset source[line].code = source[line].code>
				</cfloop>
				<cfset metaFunction.source = source>
				<cfset metaFunction.sourceStartLine = functionCode[metaFunction.name].startline>
				<cfset metaFunction.nonlocals = functionCode[metaFunction.name].nonlocals>
			</cfif>
		</cfloop>

		<cfset metaData.lbasePath = lbasePath>
		<cfif arguments.scope eq "application">
			<cfset var moduleData = this.mod.model("inspector").getModuleData(arguments.scope,"/application")>
		<cfelse>
			<cfset var moduleData = this.mod.model("inspector").getModuleData(arguments.scope)>
		</cfif>
		<cfset this.app.module("template").set("modules",this.lbase.getModules())>
		<cfset this.app.module("template").set("leftColumn",this.mod.view("navigation/module.html",moduleData,false))>
		<cfset this.app.module("template").set(this.mod.view("componentDocs",metaData,false))>
		<cfset this.app.module("template").view("template",this.mod)>
		<!---<cfset console.log(metaData)>--->
		
	</cffunction>
	
</cfcomponent>
