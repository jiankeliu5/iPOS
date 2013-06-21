#import "../header.js"

test("iPOS - Create Order (UOM Convert to Pieces)", function (target, app) {
	var loginView = ipos.behavior.loginView(target, app);
	
	loginView.loginSuccess();
});