<cfcomponent extends="system.library" lbase:scope="request">
	
	<cfset this.counter = 0>
	<cfset this.limit = 150>
	<cfset this.loggedVariables = []>
	
	<cffunction name="init">
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="serializeToJSON" access="public" returntype="string" output="false" hint="Converts ColdFusion data into a JSON (JavaScript Object Notation) representation of the data.">
		<cfargument 
			name="var" 
			type="any" 
			required="true"
			hint="A ColdFusion data value or variable that represents one." />
		<cfargument
			name="serializeQueryByColumns"
			type="boolean"
			required="false"
			default="false"
			hint="A Boolean value that specifies how to serialize ColdFusion queries.
				<ul>
					<li><code>false</code>: (Default) Creates an object with two entries: an array of column names and an array of row arrays. This format is required by the HTML format cfgrid tag.</li>
					<li><code>true</code>: Creates an object that corresponds to WDDX query format.</li>
				</ul>">
		<cfargument 
			name="strictMapping" 
			type="boolean" 
			required="false" 
			default="false" 
			hint="A Boolean value that specifies whether to convert the ColdFusion data strictly, as follows: 
				<ul>
					<li><code>false:</code> (Default) Convert the ColdFusion data to a JSON string using ColdFusion data types.</li>
					<li><code>true:</code> Convert the ColdFusion data to a JSON string using underlying Java/SQL data types.</li>					
				</ul>" />
		
		<!--- VARIABLE DECLARATION --->
		<cfset var jsonString = "" />
		<cfset var tempVal = "" />
		<cfset var arKeys = "" />
		<cfset var colPos = 1 />
		<cfset var md = "" />
		<cfset var rowDel = "" />
		<cfset var colDel = "" />
		<cfset var className = "" />
		<cfset var i = 1 />
		<cfset var column = "" />
		<cfset var datakey = "" />
		<cfset var recordcountkey = "" />
		<cfset var columnlist = "" />
		<cfset var columnlistkey = "" />
		<cfset var columnJavaTypes = "" />
		<cfset var dJSONString = "" />
		<cfset var escapeToVals = "\\,\"",\/,\b,\t,\n,\f,\r" />
		<cfset var escapeVals = "\,"",/,#Chr(8)#,#Chr(9)#,#Chr(10)#,#Chr(12)#,#Chr(13)#" />
		
		<cfset var _data = arguments.var />
		
		<cfif arrayFind(this.loggedVariables,getHashCode(arguments.var))>
			<cfreturn 0 />
		</cfif>
		<cfset arrayAppend(this.loggedVariables,getHashCode(arguments.var))>
		
		<cfif arguments.strictMapping>		
			<!--- GET THE CLASS NAME --->			
			<cfset className = getClassName(_data) />							
		</cfif>
			
		<!--- TRY STRICT MAPPING --->
		
		<cfif Len(className) AND CompareNoCase(className,"java.lang.String") eq 0>
			<cfreturn '"' & ReplaceList(_data, escapeVals, escapeToVals) & '"' />
		
		<cfelseif Len(className) AND CompareNoCase(className,"java.lang.Boolean") eq 0>
			<cfreturn ReplaceList(ToString(_data), 'YES,NO', 'true,false') />
		
		<cfelseif Len(className) AND CompareNoCase(className,"java.lang.Integer") eq 0>
			<cfreturn ToString(_data) />
			
		<cfelseif Len(className) AND CompareNoCase(className,"java.lang.Long") eq 0>
			<cfreturn ToString(_data) />
			
		<cfelseif Len(className) AND CompareNoCase(className,"java.lang.Float") eq 0>
			<cfreturn ToString(_data) />
			
		<cfelseif Len(className) AND CompareNoCase(className,"java.lang.Double") eq 0>
			<cfreturn ToString(_data) />				
		
		<!--- BINARY --->
		<cfelseif IsBinary(_data)>
			<cfthrow message="JSON serialization failure: Unable to serialize binary data to JSON." />
		
		<!--- BOOLEAN --->
		<cfelseif IsBoolean(_data) AND NOT IsNumeric(_data)>
			<cfreturn ReplaceList(YesNoFormat(_data), 'Yes,No', 'true,false') />			
			
		<!--- NULL --->
		<cfelseif isNull(_data)>
			<cfreturn 'null' />
			
		<!--- NUMBER --->
		<cfelseif IsNumeric(_data)>
			<cfif getClassName(_data) eq "java.lang.String">
				<cfreturn Val(_data).toString() />
			<cfelse>
				<cfreturn _data.toString() />
			</cfif>
		
		<!--- DATE --->
		<cfelseif isDate(_data) and _data.getClass().getName() eq "java.util.Date">
			<cfreturn '"#DateFormat(_data, "yyyy-mm-dd")# #TimeFormat(_data, "HH:mm:ss")#"' />
		
		<!--- STRING --->
		<cfelseif IsSimpleValue(_data)>
			<cfreturn '"' & ReplaceList(_data, escapeVals, escapeToVals) & '"' />
			
		<!--- RAILO XML --->
		<cfelseif StructKeyExists(server,"railo") and IsXML(_data)>
			<cfreturn '"' & ReplaceList(ToString(_data), escapeVals, escapeToVals) & '"' />
		
		<!--- CUSTOM FUNCTION --->
		<cfelseif IsCustomFunction(_data)>			
			<cfreturn serializeToJSON( GetMetadata(_data), arguments.serializeQueryByColumns, arguments.strictMapping) />
			
		<!--- OBJECT --->
		<cfelseif IsObject(_data)>
			
			<cfset dJSONString = ArrayNew(1) />
			<cftry>
				<cfset arKeys = StructKeyArray(_data) />
				<cfcatch>
					
					<cfif _data.getClass().getName() eq "org.bson.types.ObjectId">
						<cfreturn '"' & ReplaceList(_data.toString(), escapeVals, escapeToVals) & '"' />
					</cfif>
					<cfset arMethods = GetMetadata(_data).getDeclaredMethods()>
					<cfset dJSONString = {} />
					<cfloop from="1" to="#ArrayLen(arMethods)#" index="i">
						<cfset dJSONString[arMethods[i].getName()] = arMethods[i].toString()>
					</cfloop>
					<cfreturn serializeToJSON(dJSONString)>
				</cfcatch>
			</cftry>
			
			<cfloop from="1" to="#ArrayLen(arKeys)#" index="i">
				<cfif not arrayfind(["app","lbase","mod"],arKeys[i]) or true>
					
					<cfset tempVal = serializeToJSON(_data[ arKeys[i] ], arguments.serializeQueryByColumns, arguments.strictMapping ) />
				<cfelse>
					<cfset tempVal = '"LBASE_REFERENCE"'>
				</cfif>
				<cfset ArrayAppend(dJSONString,'"' & arKeys[i] & '":' & tempVal) />
			</cfloop>

			<cfreturn '{'&ArrayToList(dJSONString,",")&'}' />		
		
		<!--- ARRAY --->
		<cfelseif IsArray(_data)>
			<cfset dJSONString = ArrayNew(1) />
			<cfloop from="1" to="#ArrayLen(_data)#" index="i">
				<cfset tempVal = serializeToJSON( _data[i], arguments.serializeQueryByColumns, arguments.strictMapping ) />
				<cfset ArrayAppend(dJSONString,tempVal) />
			</cfloop>	
					
			<cfreturn "[" & ArrayToList(dJSONString,",") & "]" />
		
		<!--- STRUCT --->
		<cfelseif IsStruct(_data)>
			<cfset dJSONString = ArrayNew(1) />
			<cfset arKeys = StructKeyArray(_data) />
			<cfloop from="1" to="#ArrayLen(arKeys)#" index="i">
				<cfset tempVal = serializeToJSON(_data[ arKeys[i] ], arguments.serializeQueryByColumns, arguments.strictMapping ) />
				<cfset ArrayAppend(dJSONString,'"' & arKeys[i] & '":' & tempVal) />
			</cfloop>
						
			<cfreturn "{" & ArrayToList(dJSONString,",") & "}" />
		
		<!--- QUERY --->
		<cfelseif IsQuery(_data)>
			
			<cfset dJSONString = ArrayNew(1) />
			
			<!--- Add query meta data --->
			<cfset recordcountKey = "ROWCOUNT" />
			<cfset columnlistKey = "COLUMNS" />
			<cfset columnlist = "" />
			<cfset dataKey = "DATA" />
			<cfset md = GetMetadata(_data) />
			<cfset columnJavaTypes = StructNew() />					
			<cfloop from="1" to="#ArrayLen(md)#" index="column">
				<cfset columnlist = ListAppend(columnlist,UCase(md[column].Name),',') />
				<cfif StructKeyExists(md[column],"TypeName")>
					<cfset columnJavaTypes[md[column].Name] = getJavaType(md[column].TypeName) />
				<cfelse>
					<cfset columnJavaTypes[md[column].Name] = "" />
				</cfif>
			</cfloop>				
			
			<cfif arguments.serializeQueryByColumns>
				<cfset ArrayAppend(dJSONString,'"#recordcountKey#":' & _data.recordcount) />
				<cfset ArrayAppend(dJSONString,',"#columnlistKey#":[' & ListQualify(columnlist, '"') & ']') />
				<cfset ArrayAppend(dJSONString,',"#dataKey#":{') />
				<cfset colDel = "">
				<cfloop list="#columnlist#" delimiters="," index="column">
					<cfset ArrayAppend(dJSONString,colDel) />
					<cfset ArrayAppend(dJSONString,'"#column#":[') />
					<cfset rowDel = "">	
					<cfloop from="1" to="#_data.recordcount#" index="i">
						<cfset ArrayAppend(dJSONString,rowDel) />
						<cfif (arguments.strictMapping or StructKeyExists(server,"railo")) AND Len(columnJavaTypes[column])>
							<cfset tempVal = serializeToJSON( JavaCast(columnJavaTypes[column],_data[column][i]), arguments.serializeQueryByColumns, arguments.strictMapping ) />
						<cfelse>
							<cfset tempVal = serializeToJSON( _data[column][i], arguments.serializeQueryByColumns, arguments.strictMapping ) />
						</cfif>							
						<cfset ArrayAppend(dJSONString,tempVal) />
						<cfset rowDel = ",">	
					</cfloop>
					<cfset ArrayAppend(dJSONString,']') />
					<cfset colDel = ",">
				</cfloop>				
				<cfset ArrayAppend(dJSONString,'}') />			
			<cfelse>			
				<cfset ArrayAppend(dJSONString,'"#columnlistKey#":[' & ListQualify(columnlist, '"') & ']') />
				<cfset ArrayAppend(dJSONString,',"#dataKey#":[') />				
				<cfset rowDel = "">
				<cfloop from="1" to="#_data.recordcount#" index="i">
					<cfset ArrayAppend(dJSONString,rowDel) />
					<cfset ArrayAppend(dJSONString,'[') />
					<cfset colDel = "">					
					<cfloop list="#columnlist#" delimiters="," index="column">
						<cfset ArrayAppend(dJSONString,colDel) />
						<cfif (arguments.strictMapping or StructKeyExists(server,"railo")) AND Len(columnJavaTypes[column])>
							<cfset tempVal = serializeToJSON( JavaCast(columnJavaTypes[column],_data[column][i]), arguments.serializeQueryByColumns, arguments.strictMapping ) />
						<cfelse>
							<cfset tempVal = serializeToJSON( _data[column][i], arguments.serializeQueryByColumns, arguments.strictMapping ) />
						</cfif>	
						<cfset ArrayAppend(dJSONString,tempVal) />
						<cfset colDel=","/>
					</cfloop>					
					<cfset ArrayAppend(dJSONString,']') />
					<cfset rowDel = "," />
				</cfloop>				
				<cfset ArrayAppend(dJSONString,']') />			
			</cfif>
			
			<cfreturn "{" & ArrayToList(dJSONString,"") & "}">
			
		<!--- XML --->
		<cfelseif IsXML(_data)>
			<cfreturn '"' & ReplaceList(ToString(_data), escapeVals, escapeToVals) & '"' />
					
		
		<!--- UNKNOWN OBJECT TYPE --->
		<cfelse>
			<cfreturn "{UNKNOWNTYPE:'TYPE OF OBJECT NOT RECOGNIZED'}" />
		</cfif>
		
	</cffunction>
	
	
	<cffunction name="getJavaType" access="private" returntype="string" output="false" hint="Maps SQL to Java types. Returns blank string for unhandled SQL types.">
		<cfargument 
			name="sqlType" 
			type="string" 
			required="true"
			hint="A SQL datatype." />			
		
		<cfswitch expression="#arguments.sqlType#">
					
			<cfcase value="bit">
				<cfreturn "boolean" />
			</cfcase>
			
			<cfcase value="tinyint,smallint,integer">
				<cfreturn "int" />
			</cfcase>
			
			<cfcase value="bigint">
				<cfreturn "long" />
			</cfcase>
			
			<cfcase value="real,float">
				<cfreturn "float" />
			</cfcase>
			
			<cfcase value="double">
				<cfreturn "double" />
			</cfcase>
			
			<cfcase value="char,varchar,longvarchar">
				<cfreturn "string" />
			</cfcase>
			
			<cfdefaultcase>
				<cfreturn "" />
			</cfdefaultcase>
		
		</cfswitch>
		
	</cffunction>
	
	<cffunction name="getClassName" access="private" returntype="string" output="false" hint="Returns a variable's underlying java Class name.">
		<cfargument 
			name="data" 
			type="any" 
			required="true"
			hint="A variable." />
			
		<!--- GET THE CLASS NAME --->			
		<cftry>				
			<cfreturn arguments.data.getClass().getName() />			
			<cfcatch type="any">
				<cfreturn "" />
			</cfcatch>			
		</cftry>
		
	</cffunction>
	
	<cfset this.groupStarted = false>
	<cffunction name="sendMsg">
		<cfargument name="msg" default="">
		<cfargument name="label" default="">
		<cfargument name="type" default="LOG">
		<cfargument name="forceLabel" default="#false#">
		
		<cftry>
		<cfif this.counter eq 0>
			<cfheader name="X-Wf-Protocol-1" value="http://meta.wildfirehq.org/Protocol/JsonStream/0.2">
			<cfheader name="X-Wf-1-Plugin-1" value="http://meta.firephp.org/Wildfire/Plugin/FirePHP/Library-FirePHPCore/0.3">
			<cfheader name="X-Wf-1-Structure-1" value="http://meta.firephp.org/Wildfire/Structure/FirePHP/FirebugConsole/0.1">
			<cfif isDefined("this.app.config.routes.module")>
				<cfheader name="X-Wf-1-Page-1" value="modules.#this.app.config.routes.module#.controllers.#this.app.config.routes.controller#.#this.app.config.routes.page#(#ArrayToList(this.app.config.routes.arguments)#)">
			<cfelse>
				<cfheader name="X-Wf-1-Page-1" value="application.controllers.#this.app.config.routes.controller#.#this.app.config.routes.page#(#ArrayToList(this.app.config.routes.arguments)#)">
			</cfif>
		</cfif>
		
		<cfif this.counter eq this.limit>
			<cfset this.limit = 999>
			<cfif this.groupStarted>
				<cfset this.groupEnd()>
			</cfif>
			<cfset this.sendMsg(msg="Console message limit reached",label="FireCFML",type="DEBUG",forceLabel=true)>
			<cfset this.limit = 0>
		</cfif>
		<cfif this.counter gt this.limit>
			<cfreturn false>
		</cfif>
		
		<cfset var location = "">
		
		<cftry>
			<cfthrow type="custom">
			<cfcatch>
				<cfloop array="#cfcatch.tagcontext#" index="str_stackitem">
					<cfif str_stackitem.template neq replace(GetCurrentTemplatePath(),"\","/","all")>
						<cfset codepath = replace(str_stackitem.template,replace(expandpath("/"),"\","/","all"),"/")>
						<cfset location = replace(codepath,"/",".","all")>
						<cfset location = mid(location,2,len(location)-5)>
						<cfset location = location & ":" & str_stackitem.line & " ">
						<!---
						<cfif listfirst(codepath,"/") eq "application" or  listfirst(codepath,"/") eq "modules">
							<cfif listfirst(codepath,"/") eq "application">
								<cfset location = "application/">
							<cfelseif listfirst(codepath,"/") eq "modules">
								<cfset location = "Module ">
								<cfset codepath = listdeleteat(codepath,1,"/")>
								<cfset location = location & ucase(listgetat(codepath,1,"/")) & ": ">
							</cfif>
							<cfset codepath = listdeleteat(codepath,1,"/")>
							<cfif listfirst(codepath,"/") eq "libraries">
								<cfset codepath = listdeleteat(codepath,1,"/")>
								<cfset libname = listgetat(codepath,1,"/")>
								<cfset location = location & "library " & ucase(left(libname,len(libname)-4))>
							<cfelseif listfirst(codepath,"/") eq "controllers">
								<cfset codepath = listdeleteat(codepath,1,"/")>
								<cfset libname = listgetat(codepath,1,"/")>
								<cfset location = location & "controller " & ucase(left(libname,len(libname)-4))>
							</cfif>
							<cfset location = location & " line " & str_stackitem.line>
						<cfelse>
							<cfset location = replace(str_stackitem.template,replace(expandpath("/"),"\","/","all"),"/") & ":" & str_stackitem.line>
						</cfif>
						--->
						<cfbreak>
					</cfif>
				</cfloop>
			</cfcatch>
		</cftry>
		
		<cfif arguments.forceLabel>
			<cfset consoleLabel = arguments.label>
		<cfelseif this.groupStarted>
			<cfif len(arguments.label)>
				<cfset consoleLabel = arguments.label>
			<cfelse>
				<cfset consoleLabel = location>
			</cfif>
		<cfelseif len(arguments.label)>
			<cfset consoleLabel = location & ": " & arguments.label>
		<cfelse>
			<cfset consoleLabel = location>
		</cfif>
		
		<cfset this.loggedVariables = []>
		<cfset message = serializeToJSON([{
			Type:arguments.type,
			File:"file.cfm",
			Line:3,
			Label:consoleLabel
		},arguments.msg])>

		<cfset msgString = '#len(message)#|#message#|'>
		<cfset maxlength = 4000>
		<cfset maxi = ceiling(len(msgString)/maxlength)>
		<cfloop from="1" to="#maxi#" index="i">
			<cfset this.counter = this.counter + 1>
			<cfset start = (i-1)*maxlength+1>
			<cfset end = i*maxlength+1>
			<cfif arraylen(msgString.getBytes()) gt end>
				<cfheader name="X-Wf-1-1-1-#this.counter#" value="#mid(msgString,start,maxlength)#|\">	
			<cfelse>
				<cfset msg = "">
				<cfif i gt 1>
					<cfset msg = "|">
				</cfif>
				<cfset msg = msg & mid(msgString,start,maxlength)>
				<cfheader name="X-Wf-1-1-1-#this.counter#" value="#msg#">
			</cfif>
		</cfloop>
		<cfcatch></cfcatch>
		</cftry>

	</cffunction>
	
	<cffunction name="log">
		
		<cfset this.sendMsg(argumentCollection=arguments,type="LOG")>
		
	</cffunction>
	
	<cffunction name="debug">
		
		<cfset this.sendMsg(argumentCollection=arguments,type="DEBUG")>
		
	</cffunction>
	
	<cffunction name="info">
		
		<cfset this.sendMsg(argumentCollection=arguments,type="INFO")>
		
	</cffunction>
	
	<cffunction name="error">
		
		<cfset this.sendMsg(argumentCollection=arguments,type="ERROR")>
		
	</cffunction>
	
	<cffunction name="groupStart">
		<cfargument name="label">
		
		<cfset this.sendMsg(argumentCollection=arguments,type="GROUP_START")>
		<cfset this.groupStarted = true>
		
	</cffunction>
	
	<cffunction name="groupEnd">
		
		<cfset this.groupStarted = false>
		<cfset this.sendMsg(argumentCollection=arguments,type="GROUP_END")>
		
	</cffunction>
	
	<cffunction name="cfERROR">

		<cfset var arr_stack = []>
		<cfset var errlocation = "">
		<cftry>
			<cfthrow type="custom">
			<cfcatch>
				<cfloop from="1" to="#arraylen(cfcatch.tagcontext)#" index="stackItemI">
					<cfset var str_stackitem = cfcatch.tagcontext[stackItemI]>
					<cfset var nonDebuggingScope = str_stackitem.template eq GetCurrentTemplatePath() or str_stackitem.template contains "Application.cfc">
					<cfif not nonDebuggingScope>
						<cfset arrayAppend(arr_stack,replace(str_stackitem.template,application.approot,"/") & ":" & str_stackitem.line)>
						<cfif errlocation eq "">
							<cfset errlocation = replace(str_stackitem.template,application.approot,"/") & ":" & str_stackitem.line>
						</cfif>
					</cfif>
				</cfloop>
			</cfcatch>
		</cftry>
		
		<cfset this.groupStarted = true>
		<cfset this.sendMsg(type="GROUP_START",label=arguments.message,forceLabel=true)>
			<cfif isDefined("arguments.detail") and len(arguments.detail) gt 0><cfset this.sendMsg(msg=arguments.detail,type="ERROR",label="Detail")></cfif>
			<cfif isDefined("arguments.extendedinfo") and len(arguments.extendedinfo) gt 0><cfset this.sendMsg(msg=arguments.extendedinfo,type="ERROR",label="Extended info")></cfif>
			<cfif isDefined("arguments.missingfilename") and len(arguments.missingfilename) gt 0><cfset this.sendMsg(msg=arguments.missingfilename,type="ERROR",label="File in question")></cfif>
			<cfset this.sendMsg(msg=errlocation,type="ERROR",label="Location")>
			<cfset this.sendMsg(msg={stacktrace:arr_stack},type="INFO",label="Stack")>
			<cfset this.sendMsg(msg=arguments,type="INFO",label="Full info")>
		<cfset this.sendMsg(type="GROUP_END")>


	</cffunction>
	
	<cffunction name="cfDEBUG">
		<cfargument name="msg">
		<cfset this.groupStart("Generated information about provided argument")>
			<cfset this.sendMsg(msg=arguments.msg,type="LOG",label="Value")>
			<cftry>
				<cfset this.sendMsg(msg=arguments.msg.toString(),type="DEBUG",label=".toString()")>
				<cfcatch>
					<cfset this.sendMsg(msg="toString() could not be called",type="ERROR",label=".toString()")>
				</cfcatch>
			</cftry>
			<!--- Feel free to expand --->
			<!---<cfset this.sendMsg(msg=getMetadata(arguments.msg),type="DEBUG",label="getMetadata()")>--->
			<cftry>
				<cfset this.sendMsg(msg=arguments.msg.getClass().getName(),type="DEBUG",label="Java type")>
				<cfcatch>
					<cfset this.sendMsg(msg="Java Class could not be determined",type="ERROR",label="Java type")>
				</cfcatch>
			</cftry>
			<cftry>
				<cfset this.sendMsg(msg=getMetadata(arguments.msg).getPackage().toString(),type="DEBUG",label="Java Package")>
				<cfcatch>
					<cfset this.sendMsg(msg="Java Package could not be determined",type="ERROR",label="Java Package")>
				</cfcatch>
			</cftry>
		<cfset this.groupEnd()>
		
	</cffunction>
	
	<cffunction name="WARN">
		
		<cfset this.sendMsg(argumentCollection=arguments,type="WARN")>
		
	</cffunction>
	
	<cffunction name="setLimit">
		<cfset this.limit = arguments[1]>
	</cffunction>
	
</cfcomponent>