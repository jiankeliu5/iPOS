ipos.behavior.loginView = function(target, app) {
	var target = target;
	var app = app;
	var testData = ipos.data.values;
	
	function login(userName, pwd) {
		var window = app.mainWindow();
		var loginFormCells = window.tableViews()[0].cells();
		var userNameFormCell = loginFormCells["Employee Id"];
		var passwordFormCell = loginFormCells["Password"];
		
		// Now enter text into the fields
		userNameFormCell.tap();
		userNameFormCell.textFields()[0].setValue(userName);
		tapDoneOnKeyboard(app);
		
		passwordFormCell.tap();
		passwordFormCell.secureTextFields()[0].setValue(pwd);
		tapDoneOnKeyboard(app);
		
		//  Needed to ensure we detect the alert
		target.delay(1);
	}
	
	return {
		loginSuccess : function() {
			this.assertOnLoginView();
			login(testData.login123.userName, testData.login123.password);
		},
		
		loginInvalid : function() {
			UIATarget.onAlert = function onAlert(alert) {
				var staticTexts = alert.staticTexts();
				assertNotNull(staticTexts);
				assertTrue(staticTexts.length == 2, "Expected 2 text messages on alert.");
				assertTrue(staticTexts[0].name() == 'iPOS', "Expected alert title to be '" + staticTexts[0].name() + "'.");
				assertTrue(staticTexts[1].name() == 'Login failure.  Please try again.', "Expected login failure message '" + staticTexts[1].name() + "'.");
				
				return false;
			};
			
			this.assertOnLoginView();
			login(testData.login123.userName, 'badPassword');
		},
		
		// Assertion functions
		assertOnLoginView: function() {
			var window = app.mainWindow();
			var loginFormCells = window.tableViews()[0].cells();
			var userNameFormCell = loginFormCells["Employee Id"];
			var passwordFormCell = loginFormCells["Password"];
			
			
			// Assert that the UI components are present
		    assertTrue(window instanceof UIAWindow, "The window was not found");	    
			assertTrue(userNameFormCell instanceof UIATableCell, "The user name table cell was not found.");
			assertTrue(passwordFormCell instanceof UIATableCell, "The password table cell was not found.");
		}
	}
};