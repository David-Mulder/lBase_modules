component extends="system.library"{
	function url(required string page){
		return this.app.config.base.baseurl & arguments.page;
	}
}
