ipos.behavior.customerView = function(target, app) {
	var target = target;
	var app = app;
	var testData = ipos.data.values;
	
	function searchCustomer(phone) {
		var window = app.mainWindow(), searchButton = window.buttons()['Search'], phoneTextField = window.textFields()[0];
		
		phoneTextField.setValue(phone);
		searchButton.tap();
		target.delay(1);
	}
	
	function confirm() {
		var window = app.mainWindow(), confirmButton = window.buttons()['Confirm'];
		
		assertTrue(confirmButton instanceof UIAButton, "Expected Confirm Button.");
		
		confirmButton.tap();
		target.delay(1);
	}
	
	return {
		// methods
		selectExisting: function(phone) {
			searchCustomer(phone);
			confirm();
		},
		
		// Assertion methods
		assertOnCustomerSearchView : function() {
			var navBar, searchButton, phoneTextField, window = app.mainWindow();
			
			// Verify Navigation Bar
		    navBar = window.navigationBars()['Customer'];
		    assertTrue(navBar instanceof UIANavigationBar, "Expected a navigation bar!!");
		    assertTrue(navBar.buttons()['Main'] instanceof UIAButton, "Expected a Main Button on navigation bar.");
		    assertTrue(navBar.staticTexts()['Customer'] instanceof UIAStaticText, "Expected a title of 'Customer' on navigation bar.");
		    
			// Phone search field
			phoneTextField = window.textFields()[0];
			assertTrue(phoneTextField instanceof UIATextField, "Expected a phone text field.");
			
			// Search button 
		    searchButton = window.buttons()['Search'];
		    assertTrue(searchButton instanceof UIAButton, "Expected a search button");
		}
	}
};