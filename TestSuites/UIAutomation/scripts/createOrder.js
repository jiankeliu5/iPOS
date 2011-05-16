#import "../header.js"

test("iPOS - Create Order", function (target, app) {
	var loginView = ipos.behavior.loginView(target, app);
	
	loginView.loginSuccess();
});