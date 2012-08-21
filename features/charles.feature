Feature: Usage of Charles proxy

@startcharles
Scenario: start charles
Description: fail if charles is already running
When I start Charles

@stopcharlesandsavesession
Scenario: stop charles and save the current session
When I stop Charles and save session

@ensurecharlesisrunning
Scenario: start charles

@verifycharlesinforeground
Scenario: Verify that Charles is in foreground
Then I ensure that Charles is in foreground

@askappinforeground
Scenario: Ask which app is in foreground
Then I ask which app is in the foreground

@verifycharlesrunning
Scenario: Verify that charles is running
Then I verify that Charles is running

@networkcallwithcharles
Scenario: start charles
Description: fail if charles is already running
When I start Charles
When I make some example network calls

@startcharlesapplescript
Scenario: start charles with Applescript
Description: Deprecated. start charles using applescript, which doesn't pick up custom settings.
When I start Charles with Applescript

