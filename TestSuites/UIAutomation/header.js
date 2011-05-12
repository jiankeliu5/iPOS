#import "tuneup/tuneup.js"
#import "namespaces.js"
#import "data/testData.js"
#import "behaviors/behaviors.js"


/**
 * This section defines some common functions for dealing with high level actions, such as keyboard toolbar buttons, etc.
 */
function tapButtonOnKeyboard(app, buttonName) {
	app.windows()[1].toolbar().buttons()[buttonName].tap();
}

function tapDoneOnKeyboard(app) {
	tapButtonOnKeyboard(app, 'Done')
}

function tapSearchOnKeyboard(app) {
	tapButtonOnKeyboard(app, 'Search');
}

function tapCancelOnKeyboard(app) {
	tapButtonOnKeyboard(app, 'Cancel');
}

/**
 * Alert Handlers
 */
UIATarget.onAlert = function onAlert(alert) {
	var staticTexts = alert.staticTexts();
	assertNotNull(staticTexts);
	assertTrue(staticTexts.length == 2, "Expected 2 text messages on alert.");
	assertTrue(staticTexts[0].name() == 'iPOS', "Expected alert title to be '" + staticTexts[0].name() + "'.");
	
	return false;
};


