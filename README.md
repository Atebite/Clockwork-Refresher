Clockwork-Refresher
===================

Saving the Developers from spamming server restart.

Install
===================

Put refresher into clockwork/plugins and gmsv_fsw_win32.dl into lua/bin.
The module is only required when you want the code to automatically refresh.

Usage
===================

When installed correctly any changes to the schema or plugins should be automatically applied.
When you didn't install the module, or are running linux, you can use the chat commands "/schemareload" and "/pluginreload  pluginname".
The pluginname is the name of the folder (e.G. 'refresher')

This plugin isn't refreshing Clockwork core files.

Already created items aren't automatically updated. You need to give yourself the item again to test the update.

Variables created in runtime are lost when refreshing because it resets the plugin/schema. Use PLUGIN:Refreshed(OldPlugin) to retrieve variables that you still require.