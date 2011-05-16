#import "../header.js"

test("iPOS - Create Order (Price Adjustment)", function (target, app) {
	var loginView = ipos.behavior.loginView(target, app);
	
	loginView.loginSuccess();
});