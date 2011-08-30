ipos.behavior.orderCartView = function(target, app) {
	var target = target;
	var app = app;
	var testData = ipos.data.values;
	
	function attachAlertHandler() {
		UIATarget.onAlert = function onAlert(alert) {
			var staticTexts = alert.staticTexts();
			assertNotNull(staticTexts);
			assertTrue(staticTexts.length == 2, "Expected 2 text messages on alert.");
			assertTrue(staticTexts[0].name() == 'iPOS', "Expected alert title to be '" + staticTexts[0].name() + "'.");
			assertTrue(staticTexts[1].name() == 'No item(s) found', "Expected message '" + staticTexts[1].name() + "'.");
			return false;
		};
	}
	
	function attachSendQuoteHandler() {
		UIATarget.onAlert = function onAlert(alert) {
			var sendQuoteButton = alert.buttons()[1];
			
			attachConfirmQuoteHandler();
			sendQuoteButton.tap();
			target.delay(1);
			return false;
		};
	}
	
	function attachConfirmQuoteHandler() {
		UIATarget.onAlert = function onAlert(alert) {
			var staticTexts = alert.staticTexts();
			assertNotNull(staticTexts);
			assertTrue(staticTexts.length == 2, "Expected 2 text messages on alert.");
			assertTrue(staticTexts[0].name() == 'iPOS', "Expected alert title to be '" + staticTexts[0].name() + "'.");
			assertTrue(staticTexts[1].name().indexOf('Quote') != -1, "Expected message '" + staticTexts[1].name() + "'.");
			assertTrue(staticTexts[1].name().indexOf('successfully created') != -1, "Expected message '" + staticTexts[1].name() + "'.");
			return false;
		};
	}
	
	function searchBySku(sku) {
		var itemBySkuField;
		
		var window = app.mainWindow(), toolbar = window.toolbar();
		var itemSearchButton = toolbar.buttons()['search'];
		
		itemSearchButton.tap();
		
		target.delay(1);
		
		itemBySkuField = window.textFields()[1];
		itemBySkuField.setValue(sku);
		tapSearchOnKeyboard(app);
	}
	
	function searchByName(name) {
		var itemByNameField;
		
		var window = app.mainWindow(), toolbar = window.toolbar();
		var itemSearchButton = toolbar.buttons()['search'];
		
		itemSearchButton.tap();
		
		target.delay(1);
		
		itemByNameField = window.textFields()[0];
		itemByNameField.setValue(name);
		tapSearchOnKeyboard(app);
	}
	
	return {
		// methods
		searchItemByValidSku: function(sku) {
			searchBySku(sku);
		},
		searchItemByInvalidSku: function(sku) {
			attachAlertHandler();
			searchBySku(sku);
		},
		searchItemByValidName: function(name) {
			searchByName(name);
		},
		searchItemByInvalidName: function(name) {
			attachAlertHandler();
			searchByName(name);
		},
		
		tapCustomerButton: function() {
			var window = app.mainWindow(), toolbar = window.toolbar();
			var customerButton = toolbar.buttons()['customer'];
			
			assertTrue(customerButton instanceof UIAButton, "Expected a customer button.");
			customerButton.tap();
			
			target.delay(1);
		},
		
		tapQuoteButton: function() {
			var window = app.mainWindow(), toolbar = window.toolbar();
			var quoteButton = toolbar.buttons()['quotes black'];
			
			assertTrue(quoteButton instanceof UIAButton, "Expected a quote button.");
			
			attachSendQuoteHandler();
			quoteButton.tap();
			
			target.delay(1);
		},
		
		tapTenderButton: function() {
			var window = app.mainWindow(), toolbar = window.toolbar();
			var tenderButton = toolbar.buttons()['Cash'];
			
			assertTrue(tenderButton instanceof UIAButton, "Expected a tender button.");
			tenderButton.tap();
			
			target.delay(1);
		},
        
        tapProfitButton: function() {
            var window = app.mainWindow();
            var toolbar  = window.toolbar();
            var profitButton = toolbar.buttons()['stats'];
            
            assertTrue(profitButton instanceof UIAButton, "Expected Profit Margin Button");
            profitButton.tap();
            
            target.delay(1);
            
        
        },
		
		// Assertion methods
		assertOnCartView : function() {
			var window = app.mainWindow(), navBar = window.navigationBar(), toolbar = window.toolbar();
			var itemsTitle = navBar.staticTexts()['Items'];
			var editButton = navBar.buttons()['Edit'], suspendButton = navBar.buttons()['Suspend'],
				itemSearchButton = toolbar.buttons()['search'], customerButton = toolbar.buttons()['customer'];
			
			// I have a nav bar right?
			 assertTrue(navBar instanceof UIANavigationBar, "Expected a navigation bar!!");
			 assertTrue (itemsTitle instanceof UIAStaticText, "Expected an Items Title on the nav bar.");
			
			// I should have a visible edit and suspend buttons
			assertTrue (editButton instanceof UIAButton, "Expected an Edit Button");
			assertTrue (suspendButton instanceof UIAButton, "Expected a Suspend Button");
			
			// expect a table view with items
			assertTrue(window.tableViews().length == 1 && window.tableViews()[0] instanceof UIATableView);
			
			// I should have a toolbar with a search item and customer buttons
			assertTrue (toolbar instanceof UIAToolbar, "Expected a toolbar.");
			assertTrue (itemSearchButton instanceof UIAButton, "Expected an Item Search Button");
			assertTrue (customerButton instanceof UIAButton, "Expected a Customer Button");
		},
		
		assertItemInCart: function(sku) {
			var foundItem;
			var window = app.mainWindow(), cartItemsTable = window.tableViews()[0];
			var cartItems = cartItemsTable.cells();
			
			if (cartItems) {
				for (i=0; i < cartItems.length; i++) {
					if (cartItems[i].name().indexOf(sku) != -1) {
						foundItem = cartItems[i];
						break;
					}
				}
			}
			
			assertTrue (foundItem instanceof UIATableCell, "Expected to find the item '" + sku + "'in the cart.");
		},
		
		assertItemCountInCart: function(count) {
			var window = app.mainWindow(), cartItemsTable = window.tableViews()[0];
			var cartItems = cartItemsTable.cells();
			
			assertTrue (count == cartItems.length, "Expected to find '" + count + "' items in the cart.");
		}
	}
};