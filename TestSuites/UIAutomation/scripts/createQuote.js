#import "../header.js"

test("iPOS - Create Quote", function (target, app) {
	var loginView = new ipos.behavior.loginView(target, app);
	var mainView = new ipos.behavior.mainMenuView(target, app);
	var addItemView = new ipos.behavior.addItemView(target, app);
	
	// Login to iPOS
	loginView.loginSuccess();
	mainView.assertOnMainView();
	
	// Search by Invalid SKU, then a valid one
	mainView.searchByInvalidSku();
	mainView.searchByValidSku();
	addItemView.assertOnAddItemView();
	
	// Add the item to the cart
	addItemView.addItemToCart(12);
	
	// We should now be at the order cart view
});