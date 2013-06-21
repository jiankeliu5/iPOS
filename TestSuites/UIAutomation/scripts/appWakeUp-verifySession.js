#import "../header.js"

test("iPOS - Verify Session On App Wakeup", function (target, app) {
	
	var window = app.mainWindow();
	var loginFormCells = window.tableViews()[0].cells();
	var userNameFormCell = loginFormCells["Employee Id"];
	var passwordFormCell = loginFormCells["Password"];
	
	
	// Asser that the UI components are present
    assertTrue(window instanceof UIAWindow, "The window was not found");
    
	assertTrue(userNameFormCell instanceof UIATableCell, "The user name table cell was not found.");
	assertTrue(passwordFormCell instanceof UIATableCell, "The password table cell was not found.");
	
	// Now enter text into the fields
	userNameFormCell.tap();
	userNameFormCell.textFields()[0].setValue("123");
	app.windows()[1].toolbar().buttons()["Done"].tap();
	UIATarget.localTarget().delay(1);
	
	passwordFormCell.tap();
	passwordFormCell.secureTextFields()[0].setValue("wrongPassword");
	app.windows()[1].toolbar().buttons()["Done"].tap();
	UIATarget.localTarget().delay(1);
	
	
});