# CHECK GRAMMARLY

Managing _screenshots_ and _app previews_ for your app manually is a pain. You have to provide at least one screenshot for every device size and app previews are optional.

The good thing is that the number of device sizes is smaller than the number of all iPhones and iPads (plus Watches, plus Apple TVs) - take a look at [Screenshot specifications](https://help.apple.com/app-store-connect/#/devd274dd925) and [App preview specifications](https://help.apple.com/app-store-connect/#/dev4e413fcb8), but still it’s 🤯 for manual work.

And don’t forget about localization - the rules apply for every language in you app.

So, it great that fastlane has this covered (i.e. automated) with screenshot and framing.

Too bad it needs UI Tests.