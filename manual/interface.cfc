<!---
	The manual module is a module allowing you to automatically generate a full documentation of your application
	straight from your sourcecode.
	
	How to add the documentation to your code
	=========================================
	Documentation is placed directly inside your code as comments or hints. A comment above a `cfcomponent` tag is
	used as the documentation for the entire component.
	
		<! ---
			PLEASE NOTE: The spaces around this comment tag are used to prevent the comment in which documentation is written from closing
		--- >
		<cfcomponent>
	
	A comment above a `cffunction` is used as the documentation for the function below it.
	
		<! ---
			PLEASE NOTE: The spaces around this comment tag are used to prevent the comment in which documentation is written from closing
		--- >
		<cffunction name="...">
	
	The documentation from cfarguments is extracted straight out of them, so ideally `name`, `required`, `type` and
	`hint` should be specified on all `cfargument` tags.

	Markdown
	========
	Markdown is a special syntax allowing you to add markup to your comments/documentation. Please check
	[the markdown module](../markdown/) for the full documentation on this. The distinguishing feature of markdown
	is that it is just as readable in plaintext form and html.

	Module documentation
	====================
	Generic module documentation should be placed in the interface.cfc file. If no interface.cfc file is present it will default to
	the base interface. Practically this means it's useful to nearly always include a (possibly) empty interface.cfc
	
	Limitations
	===========
	- Documentation can not contain `--- >` (without the space)
	- Documentation will (of course) not look as organized as a handwritten documentation, nor is their any freedom
		to manually overwrite this.
--->
<cfcomponent extends="system.interface">
</cfcomponent>