ipos.behavior.tenderView = function(target, app) {
	var target = target;
	var app = app;
	var testData = ipos.data.values;

    function attachPaymentAlertHandler() {
		UIATarget.onAlert = function onAlert(alert) {
			var staticTexts = alert.staticTexts();

            assertNotNull(staticTexts);
			assertTrue(staticTexts.length == 2, "Expected 2 text messages on alert.");
			assertTrue(staticTexts[0].name() == 'iPOS', "Expected alert title to be '" + staticTexts[0].name() + "'.");
			assertTrue(staticTexts[1].name().indexOf('Order') != -1, "Expected message '" + staticTexts[1].name() + "'.");
			assertTrue(staticTexts[1].name().indexOf('successfully processed') != -1, "Expected message '" + staticTexts[1].name() + "'.");
			return false;
		};
    }

        function attachEmailReceiptAlertHandler() {
		UIATarget.onAlert = function onAlert(alert) {
			var staticTexts = alert.staticTexts();

            assertNotNull(staticTexts);
			assertTrue(staticTexts.length == 2, "Expected 2 text messages on alert.");
			assertTrue(staticTexts[0].name() == 'iPOS', "Expected alert title to be '" + staticTexts[0].name() + "'.");
			assertTrue(staticTexts[1].name().indexOf('Receipt e-mailed to customer at') != -1, "Expected message '" + staticTexts[1].name() + "'.");
			return false;
		};
            
	}

    return {

        tapCreditCardButton: function() {
            var ccButton = app.mainWindow().toolbar().buttons()['CreditCard'];

            assertTrue(ccButton instanceof UIAButton, "Expected a Credit Card Toolbar button.");

            ccButton.tap();
            target.delay(1);
        },

        enterPaymentAmount: function() {
            var window = app.mainWindow();
            var balanceDueAmtField = window.staticTexts()[1];
            var amtField = window.textFields()[0];

            // Enter the amount into the field
            amtField.setValue(balanceDueAmtField.name().substring(1));

            // Click done on the keyboard
            tapDoneOnKeyboard(app);
            target.delay(1);
        },

        sendSignature: function() {
            var saveButton = app.mainWindow().toolbar().buttons()['Save'];

            assertTrue(saveButton instanceof UIAButton, "Expected a Save Button");

            attachPaymentAlertHandler();
            saveButton.tap();
            target.delay(1);
        },

        emailReceipt: function() {
            var emailButton = app.mainWindow().buttons()['E-Mail Receipt'];

            assertTrue(emailButton instanceof UIAButton, "Expected an E-Mail Receipt Button");

            attachEmailReceiptAlertHandler();
            emailButton.tap();
            target.delay(1);
        },
        
        exitWithoutReceipt: function() {
        var noEmailButton = app.mainWindow().buttons()['Exit Without Receipt'];
        
        assertTrue(emailButton instanceof UIAButton, "Expected an E-Mail Receipt Button");
        
        attachNoEmailReceiptAlertHandler();
        emailButton.tap();
        target.delay(1);
    },


        // Assertion methods
        assertOnTenderView: function() {
            var window = app.mainWindow(), navBar = window.navigationBar(), toolbar = window.toolbar();
            var tenderTitle = navBar.staticTexts()['Tender'];
            var balanceDueLabel = window.staticTexts()['Balance Due'];
            var ccButton = toolbar.buttons()['CreditCard'];

            // I have a nav bar right?
			 assertTrue(navBar instanceof UIANavigationBar, "Expected a navigation bar!!");
			 assertTrue (tenderTitle instanceof UIAStaticText, "Expected a Tender Title on the nav bar.");

            // Is there Balance Due and does a credit card button exist?
            assertTrue(balanceDueLabel instanceof UIAStaticText, "Expected a balance due label.");
            assertTrue(ccButton instanceof UIAButton, "Expected a Credit Card Toolbar button.");
        },

        assertOnSignatureCapture: function() {
            var window = app.mainWindow();
            var saveButton = window.toolbar().buttons()['Save'];
            var clearButton = window.toolbar().buttons()['Clear'];

            assertTrue(saveButton instanceof UIAButton, "Expected a Save Button");
            assertTrue(clearButton instanceof UIAButton, "Expected a Clear Button");
        }
    }
};
