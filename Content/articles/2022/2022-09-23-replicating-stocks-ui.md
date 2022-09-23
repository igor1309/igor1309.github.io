---
date: 2022-09-23 10:10
description: Replicating Search UI of the Stocks app with SwiftUI `searchable` API
tags: SwiftUI, searchable
---
# Replicating Search UI of the Stocks app

This use case is inspired by Apple‘s Stocks app. There is a local watchlist, which is empty initially, and the user can add assets to this watchlist by searching for the asset, search is performed by typing in the search field. API returns some search results that can be added to the watchlist by tapping on the plus button. If the asset is already in the watchlist, there would be a checkmark instead of a plus button, the checkmark is actually a button, and if the user taps on this button, then this asset would be removed from the watchlist.

This way watchlist could be edited while searching: adding and deleting multiple assets.

So this is a use case for searchable API, but not for the search of local items or items that are already presented in the list, but searching it by querying the API.

## Search suggestions

Search suggestions are active if the watchlist is empty.

## Tokens

The use of tokens is not utilized, the possible idea could be to use tokens as a way to broaden or narrow the search - another dimension in addition to Scope.

<br/>
<div align="center">
<video id="Demo video" width="100%" controls>
        <source src = "../../../images/searchable/searchable_demo.mp4" type = "video/mp4">
    </video><br/>
</div>
<br/>

To see tokens use case switch to the branch `tokens`.

## Structure

<br/>
<div align="center">
<img src="../../../images/searchable/folder_structure.png" width="100%" title="Folder structure">
<br/>
</div>
<br/>

## References

* [dismissSearch](https://developer.apple.com/documentation/swiftui/environmentvalues/dismisssearch)
