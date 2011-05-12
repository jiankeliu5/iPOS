#import "../header.js"

test("iPOS Invalid Login", function (target, app) {
	var loginView = new ipos.behavior.loginView(target, app);
	
	loginView.loginInvalid();
});