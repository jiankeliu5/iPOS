#import "../header.js"

test("iPOS - Create Quote", function (target, app) {
	var loginView = ipos.behavior.loginView(target, app);
	
	loginView.loginSuccess();
});