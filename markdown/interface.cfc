<!---
	Markdown is the syntax used to write the documentation in. The advantage of markdown (over for example html) is that both the sourcecode
	and the generated html manual both are readable. For a full documentation look [here][1] and for a markdown generator/editor [look here][2].
	
	Bold/Italics
	============
	
		*italics*
		**bold**
	
	Lists
	=====
	
		- item 1
		- item 2
		- item 3

	Code
	====
	Inline code
	-----------
	Inline code is useful because it allows you to add escape characters and colour them. It is used in the `<middle>` of a sentence.
	
		The `insert()` function should be used to ...
	
	Codeblocks
	----------
			<p>
				An extra tab should be added before the lines
			</p>
	
	Headings
	========
	
		Header
		======
		
		Sub-heading
		-----------
		
	Links
	=====
	
		This is a [link][1] and a lot of text. Please check the documentation for different ways links can be defined.
		
		[1]: http://www.google.com "And an optional title"
		
	Blockquotes
	===========
	
		> A blockquote
		>
		> Of multiple Paragraphs
	
	[1]: http://daringfireball.net/projects/markdown/basics "Markdown: Basics"
	[2]: http://pagedown.googlecode.com/hg/demo/browser/demo.html "Markdown editor"
--->
<cfcomponent extends="system.interface">
	
	<!---
		The `makeHtml()` function is used to do the translation from markdown to html. Call it with the markdown code as the first argument and that's it.
	--->
	
	<cffunction name="makeHtml">
		<cfargument name="markdown" default="">
		<cfset var html = "">
		<cfscript language="java" jarlist="js.jar">
			import org.mozilla.javascript.*;
			import java.io.*;
			
			org.mozilla.javascript.Context cx = org.mozilla.javascript.Context.enter();
			Scriptable scope = cx.initStandardObjects();
			
			String filename = (String) cf.call("expandpath","./modules/markdown/markdown.converter.js");
			
			BufferedReader br = new BufferedReader(new FileReader(filename));
			try {
				StringBuilder sb = new StringBuilder();
		        String line = br.readLine();
		
		        while (line != null) {
		            sb.append(line);
		            sb.append("\n");
		            line = br.readLine();
		        }
		        
		        String scriptcode = sb.toString();
		        String markdowncode = (String) cf.get("arguments.markdown");
		        
		        try {
		        	Object result = cx.evaluateString(scope, scriptcode, "<cmd>", 1, null);
		        	Object fObj = scope.get("makeHtml", scope);
		        	if (!(fObj instanceof Function)) {
					    System.out.println("f is undefined or not a function.");
					} else {
						Object functionArgs[] = { markdowncode };
						Function f = (Function)fObj;
						NativeObject resultt = (NativeObject) f.call(cx, scope, scope, functionArgs);
						cf.set("resultt",resultt.get("d",resultt));
					}
		        } finally {
					// Exit from the context.
					org.mozilla.javascript.Context.exit();
				}
		        
			} finally {
				br.close();
			}
		</cfscript>
		
		<cfreturn resultt>
	</cffunction>
	
</cfcomponent>