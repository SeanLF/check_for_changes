#Check for changes

I've implemented my own (OS X) daemon to check and notify me of changes to my course websites because some professors prefer not to use Blackboard Learn which provides a push notification service on the mobile app.

If you use a Mac, make your own `.plist` (com.example.check-for-changes.plist) and save it under `/Users/You/Library/LaunchAgents/`.

You  will need a [Pushbullet](https://www.pushbullet.com) account to receive notifications. You will receive a link push notification containing the url of the website that changed.

If this script won't execute, run `chmod +x ./check-for-changes.sh`.
