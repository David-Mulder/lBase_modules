<cfcomponent extends="system.model">
	<cfset this._collection = "">
	<cfset this.data = null>
	<cfset this._multipleDocuments = false>

	<!---
		Selects documents in a collection and sets them in the object. Afterwards they can be accessed through the .data property.
		
		     <cfset var documents = this.mongo.model("test").find()>
		     <cfset this.console.log(documents.data)>
	--->
	<cffunction name="find">
		<cfargument name="query" default="#{}#" hint="A mongoDB selection structure" type="struct">
		<cfargument name="projection" default="#null#" hint="A structure defining which fields you want to retrieve" type="struct">
		<cfargument name="skip" default="#null#">
		<cfargument name="size" default="#null#">
		<cfset this.data = mongoCollectionfind("mongo", this._collection, arguments.query, arguments.projection,arguments.skip,arguments.size)>
		<cfset this._multipleDocuments = true>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="findOne">
		<cfset this.find(argumentCollection=arguments,size=1)>
		<cfif arraylen(this.data) eq 1>
			<cfset this.data = this.data[1]>
			<cfset this._multipleDocuments = false>
		</cfif>
		<cfreturn this>
	</cffunction>

	<!---
		The save() method saves the data which is set in the .data property of this object.
		
		     <cfset var document = this.mongo.model("test")>
		     <cfset var document.data = {
		     	someDocument: true
		     }>
		     <cfset document.save()>
		
		In the above case a new document will be inserted. An existing document can be updated as follows
		
		     <cfset var document = this.mongo.model("test").findOne({
		     	name:"unique_name"
		     })>
		     <cfset var document.data = {
		     	someDocument: true
		     }>
		     <cfset document.save()>
		
	--->
	<cffunction name="save">
		<cfif this._multipleDocuments>
			<cfset var document = {}>
			<cfloop array="#this.data#" index="document">
				<cfset mongoCollectionsave("mongo",this._collection,document)>
			</cfloop>
		<cfelse>
			<cfset mongoCollectionsave("mongo",this._collection,this.data)>
		</cfif>
	</cffunction>
	
	<!---
		Set either one property of the current document or the entire document. Useful for method chaining.
		
			<cfset var document = this.mongo.model("test").findOne({
		     	name:"unique_name"
		    }).set("someDocument",true).save()>
		    
		This function can also be called with just a single argument, in that case the entire document will be set (and any current one will be overwritten).
	--->
	<cffunction name="set">
		<cfargument name="property">
		<cfargument name="value">
		<cfif arraylen(StructKeyArray(arguments)) eq 1>
			<cfset this.data = arguments[1]>
		<cfelse>
			<cfif isNull(this.data)>
				<cfset this.data = {}>
			</cfif>
			<cfset this.data[arguments[1]] = arguments[2]>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="count">
		<cfargument name="query" default="#{}#" hint="A mongoDB selection structure">
		<cfif isNull(this.data)>
			<cfreturn mongoCollectioncount( "mongo", this._collection, arguments.query)>
		<cfelse>
			<cfif this._multipleDocuments>
				<cfreturn arraylen(this.data)>
			<cfelse>
				<cfreturn 1>
			</cfif>
		</cfif>
	</cffunction>	

	<!---
		Call the drop() method on a collection to drop it from the database.
	--->
	<cffunction name="drop">
		
	</cffunction>
	
	<!---
		Removes documents from a collection.
		
		You can first find documents and then remove them, or provide the query straight to this function
	--->
	<cffunction name="remove">
		<cfargument name="query" required="no">
		<cfargument name="justOne" required="no">
		
	</cffunction>
	
	<!---
		The update() method modifies an existing document or documents in a collection.
		By default the update() method updates a single document.
		To update all documents in the collection that match the update query criteria, specify the multi option. To insert a document if no document matches the update query criteria, specify the upsert option.
	--->
	<cffunction name="update">
		<cfargument name="query" required="yes">
		<cfargument name="update " required="yes">
		<cfargument name="options" required="no" default="#{}#" hint="Specify the options like for example `{upsert:true}`">
		
		<cfset var upsert = false>
		<cfset var multi = false>
		<cfif structKeyExists(arguments.options,"upsert") and arguments.options.upsert>
			<cfset upsert = true>
		</cfif>
		<cfif structKeyExists(arguments.options,"multi") and arguments.options.multi>
			<cfset upsert = multi>
		</cfif>
		
		<cfset mongoCollectionupdate("mongo",this._collection,arguments.query,arguments.update,upsert,multi)>
		
	</cffunction>
	
	<!---
		Inserts a document or an array of documents into a collection.
		
		This is equalivent to setting the .data property and calling .save()	
	--->
	<cffunction name="insert">
		<cfargument name="documents">
		
			
		
	</cffunction>
	
	<!---
		Finds the distinct values for a specified field across a single collection and returns the results in an array.
	--->
	<cffunction name="distinct">
		<cfargument name="field">
		<cfargument name="query">
		
		
		
	</cffunction>
	
	<!---
		Aggregate() takes 1...n pipes as arguments. See the [documentation][1] for the way such a pipe should be defined
		
		The function returns a document with two fields:
		- result which holds an array of documents returned by the pipeline
		- ok which holds the value 1, indicating success.
		
		[1]: http://docs.mongodb.org/manual/core/aggregation/
	--->
	<cffunction name="aggregate">
		
		<cfdump var="#MongoCollectionaggregate("mongo",this._collection,arguments)#"><cfabort>
		
	</cffunction>
	
</cfcomponent>