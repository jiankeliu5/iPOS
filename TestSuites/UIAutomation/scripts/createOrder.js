#import "../header.js"

test("iPOS - Create Order", function (target, app) {
	var testData = ipos.data.values;
	var sku1 = testData.itemBySku.validSku1, sku2 = testData.itemBySku.validSku2;
	var loginView = new ipos.behavior.loginView(target, app);
	var mainView = new ipos.behavior.mainMenuView(target, app);
	var addItemView = new ipos.behavior.addItemView(target, app);
	var customerView = new ipos.behavior.customerView(target, app);
	var cartView = new ipos.behavior.orderCartView(target, app);
    var tenderView = new ipos.behavior.tenderView(target, app);

	// Login to iPOS
	loginView.loginSuccess();
	mainView.assertOnMainView();

	// Search by valid SKU and add it to the cart
	mainView.searchItemByValidSku(sku1);
	target.delay(1);

	// Add the item to the cart
	addItemView.assertOnAddItemView();
	addItemView.addItemToCart(4);
	target.delay(1);

	// We should now be at the order cart view.
	// Add another item (one by sku, one by name)
	// Add an existing customer, and click Create Quote
	cartView.assertOnCartView();
	cartView.assertItemInCart(sku1);

	cartView.searchItemByValidName(testData.itemByName.match);
	target.delay(1);
	addItemView.assertOnSearchResults();
	addItemView.tapItemAtIndex(0);
	target.delay(1);
	addItemView.addItemToCart(14);
	target.delay(1);
	cartView.assertOnCartView();

	// I should have 3 items in the cart
	cartView.assertItemCountInCart(2);

	// lets add the customer
	cartView.tapCustomerButton();
	customerView.assertOnCustomerSearchView();
	customerView.selectExisting(testData.customer.existing);

	// Confirm I am on the cart view
	cartView.assertOnCartView();


	cartView.tapTenderButton();
    tenderView.assertOnTenderView();

    // Do a credit card payment
    tenderView.tapCreditCardButton();
    tenderView.enterPaymentAmount();

    // Let us delay until the credit card is swiped (thus creating the order)
    target.delay(6);

    // Save signature and send e-mail
    tenderView.assertOnSignatureCapture();
    tenderView.sendSignature();

    target.delay(1);
    tenderView.emailReceipt();

	// We are DONE!!
});

test("iPOS - Create Order without Reciept" function(target, app){
     
     var testData = ipos.data.values;
     var sku1 = testData.itemBySku.validSku1, sku2 = testData.itemBySku.validSku2;
     var loginView = new ipos.behavior.loginView(target, app);
     var mainView = new ipos.behavior.mainMenuView(target, app);
     var addItemView = new ipos.behavior.addItemView(target, app);
     var customerView = new ipos.behavior.customerView(target, app);
     var cartView = new ipos.behavior.orderCartView(target, app);
     var tenderView = new ipos.behavior.tenderView(target, app);
     
     // Login to iPOS
     loginView.loginSuccess();
     mainView.assertOnMainView();
     
     // Search by valid SKU and add it to the cart
     mainView.searchItemByValidSku(sku1);
     target.delay(1);
     
     // Add the item to the cart
     addItemView.assertOnAddItemView();
     addItemView.addItemToCart(4);
     target.delay(1);
     
     // We should now be at the order cart view.
     // Add another item (one by sku, one by name)
     // Add an existing customer, and click Create Quote
     cartView.assertOnCartView();
     cartView.assertItemInCart(sku1);
     
     cartView.searchItemByValidName(testData.itemByName.match);
     target.delay(1);
     addItemView.assertOnSearchResults();
     addItemView.tapItemAtIndex(0);
     target.delay(1);
     addItemView.addItemToCart(14);
     target.delay(1);
     cartView.assertOnCartView();
     
     // I should have 3 items in the cart
     cartView.assertItemCountInCart(2);
     
     // lets add the customer
     cartView.tapCustomerButton();
     customerView.assertOnCustomerSearchView();
     customerView.selectExisting(testData.customer.existing);
     
     // Confirm I am on the cart view
     cartView.assertOnCartView();
     
     
     cartView.tapTenderButton();
     tenderView.assertOnTenderView();
     
     // Do a credit card payment
     tenderView.tapCreditCardButton();
     tenderView.enterPaymentAmount();
     
     // Let us delay until the credit card is swiped (thus creating the order)
     target.delay(6);
     
     // Save signature and send e-mail
     tenderView.assertOnSignatureCapture();
     tenderView.sendSignature();
     
     target.delay(1);
     tenderView.exitWithoutReceipt();
     
});