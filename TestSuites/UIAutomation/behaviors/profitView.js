ipos.behavior.profitView = function(target, app) {
	var target = target;
	var app = app;
	var testData = ipos.data.values;
	
	function done() {
		var window = app.mainWindow(), doneButton = window.buttons()['Done'];
		
		doneButton.tap();
		target.delay(1);
	}
	
	return {
		
		// Assertion methods
		assertOnProfitMarginView : function() {
			var doneButton, window = app.mainWindow();
			
			// Search button 
		    doneButton = window.buttons()['Done'];
		    assertTrue(doneButton instanceof UIAButton, "Expected a done button");
		}
	}
};