ipos.behavior.addItemView = function(target, app) {
	var target = target;
	var app = app;
	var testData = ipos.data.values;
	
	function addToCart(quantity) {
		var window = app.mainWindow(), buttons = window.buttons();
		var quantityTextField, addButton = buttons['ADD\nTO\nCART'];
		
		addButton.tap();
		
		// Enter quantity
		quantityTextField = window.textFields()[0];
		
		assertTrue(quantityTextField.value() == 'Quantity', "Expected this to be a quantity text field");
		
		quantityTextField.tap();
		quantityTextField.setValue(quantity);
		tapDoneOnKeyboard(app);
	}
	
	function exit() {
		
	}
	
	return {
		// methods
		addItemToCart: function(quantity) {
			addToCart(quantity);
		},
		
		// Assertion methods
		assertOnAddItemView : function() {
			var buttons, window = app.mainWindow();
			
		    assertTrue(window instanceof UIAWindow, "The window was not found");	 
		    		
			// I expect an add to cart button and an exit button
			buttons = window.buttons();
			assertTrue(buttons['ADD\nTO\nCART']  instanceof UIAButton, "Expected an Add To Cart button.");
			assertTrue(buttons['EXIT'] instanceof UIAButton, "Expected an Exit button.");
		}
	}
};