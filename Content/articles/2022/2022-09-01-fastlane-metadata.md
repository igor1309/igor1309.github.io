---
date: 2022-09-01 10:10
description: Check your app metadata against App Store review rules with fastlane
tags: App Store, fastlane
---
# fastlane: Metadata

Apple can reject an app for metadata issues like mentioning other platforms, bad-mouthing Apple, and others. Use `fastlane`'s `precheck` to examine your app for App Store review rules compliance.

```sh
$ bundle exec fastlane precheck
```

`precheck` is an alias for the `check_app_store_metadata`.

Use `Precheckfile` to store your precheck defaults, run `fastlane precheck init` to create one. Set the desired level for the check: `skip`, `warn`, or `error`:

```ruby
# skip checking this metadata
negative_apple_sentiment(level: :skip)

# trigger a warning
curse_words(level: :warn)

# show error and stop after precheck
unreachable_urls(level: :error)

# check for words
custom_text(
    data: ["chrome", "webos"],
    level: :warn
)
```

By default all levels are set to `:error`, so you need to list only those keys that you want to skip or warn.

At the time of writing, _"precheck cannot check In-app purchases with the App Store Connect API Key (yet)"_, but the default is `true`, so it makes sense to change it to `false`.

__Important__: `precheck` does not check `Appfile` for App Store credentials and app identifiers, so you'd need to add them into `Precheckfile`:

```ruby
app_identifier APP_IDENTIFIER
username USERNAME
team_name TEAM_NAME
team_id TEAM_ID
```

Use in `Fastfile`:

```ruby
# run precheck alone
lane :check_metadata do
    precheck
end
```

`precheck` is also integrated with [`deliver`](https://docs.fastlane.tools/actions/deliver/):

```ruby
# Fastfile

lane :production do
    # ...

    # by default deliver will call precheck and warn you of any problems
    # if you want precheck to halt submitting to app review, you can pass
    # precheck_default_rule_level: :error
    deliver(precheck_default_rule_level: :error)

    # ...
end
```

For the full list of the keys to check and more see [precheck - fastlane docs](https://docs.fastlane.tools/actions/precheck/).
