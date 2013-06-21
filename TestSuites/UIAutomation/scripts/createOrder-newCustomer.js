#import "../header.js"

test("iPOS - Create Order (New Customer)", function (target, app) {
	var loginView = ipos.behavior.loginView(target, app);
	
	loginView.loginSuccess();
});