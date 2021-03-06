ipos.behavior.mainMenuView = function(target, app) {
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
	
	function searchBySku(sku) {
		var window = app.mainWindow();
		var itemBySkuField = window.textFields()[1];
		
		assertTrue (itemBySkuField instanceof UIATextField, "Expected the item by sku text field");
		
		itemBySkuField.setValue(sku);
		tapSearchOnKeyboard(app);
	}
	
	function searchByName(name) {
		var window = app.mainWindow();
		var itemByNameField = window.textFields()[0];
		
		assertTrue (itemByNameField instanceof UIATextField, "Expected the item by name text field");
		
		itemByNameField.setValue(name);
		tapSearchOnKeyboard(app);
	}
	
	return {
		// search by valid SKU
		searchItemByValidSku: function(sku) {
			searchBySku(sku);			
		},
		
		// search by invalid SKU
		searchItemByInvalidSku: function(sku) {
			attachAlertHandler();
			searchBySku(sku);
		},
		
		// search by valid match
		searchItemByValidName: function(name) {
			searchByName(name);
		},
		
		// search by invalid match
		searchItemByInvalidName: function(name) {
			attachAlertHandler();
			searchByName(name);
		},
		
		// Assertion methods
		assertOnMainView : function() {
			var navBar, textFields, buttons, window = app.mainWindow();
			
		    assertTrue(window instanceof UIAWindow, "The window was not found");	 
		    
		    // Verify Navigation Bar
		    navBar = window.navigationBar();
		    
		    assertTrue(navBar instanceof UIANavigationBar, "Expected a navigation bar!!");
		    assertTrue(navBar.buttons()['Logout'] instanceof UIAButton, "Expected a Logout Button on navigation bar.");
		    assertTrue(navBar.staticTexts()['iPOS'] instanceof UIAStaticText, "Expected a title of 'iPOS' on navigation bar.");
		    
		    // 1 static text field
		    assertTrue(window.staticTexts()["-- SCAN ITEM --"] instanceof UIAStaticText, "Expected a 'Scan Item' text.");
		    
		 	// 2 text fields for item searching
			textFields = window.textFields();
			assertTrue(textFields[0].value() == 'Item By Name', "Expected text field for Item By Name search.");
			assertTrue(textFields[1].value() == 'Item By SKU', "Expected text field for Item By SKU search.");
			
			// 2 buttons (Customer and Order Cart)
			buttons = window.buttons();
			assertTrue(buttons['Customer']  instanceof UIAButton, "Expected a customer button.");
			assertTrue(buttons['Order Cart'] instanceof UIAButton, "Expected an Order Cart button.");
		},
		
		
	}
};