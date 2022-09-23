---
date: 2022-08-30 10:10
description: How to create a basic scaffolding for a super modularized app
tags: Supermodular
---
# Supermodular App Scaffolding

Create a new Swift Package in the terminal

```sh
$ mkdir QuoteWatcher
$ cd QuoteWatcher
$ swift package init
```

Initiate Git and commit

```sh
$ git init
$ git add .
$ git commit -am 'Add basic scaffolding for `QuoteWatcher` Swift Package'
```

Open Xcode, create a new `iOS` project `QuoteWatcher` (do not use Core Data, do not include tests)

<br/>
<div align="center">
<img src="../../../images/supermodular/create.png" width="100%" title="Create">
</div>
<br/>

Save to the `QuoteWatcher` folder (do not add to any project or workspace)

<br/>
<div align="center">
<img src="../../../images/supermodular/save.png" width="100%" title="Save">
<br/>
</div>
<br/>


Close the project. Back in the terminal rename `QuoteWatcher` to `App`

```sh
$ mv QuoteWatcher App
```

Commit

```sh
$ git add .
$ git commit -m 'Create `QuoteWatcher` project'
```

Open the project in the Xcode. Drag the folder `QuoteWatcher` into the project

<br/>
<div align="center">
<img src="../../../images/supermodular/drag.png" width="100%" title="Drag">
<br/>
</div>
<br/>

Local Swift Package would be added to the Xcode project.

<br/>
<div align="center">
<img src="../../../images/supermodular/app.png" width="100%" title="App">
<br/>
</div>
<br/>

We'll handle the `App` folder in a moment, but first, let's commit changes to the `App/QuoteWatcher.xcodeproj/project.pbxproj` file

```sh
$ git commit -am 'Add Swift Package to Xcode project'
```

Add an empty Swift Package to hide the `App` folder from the Xcode

<br/>
<details>
<summary>Until syntax lighlighting issue with comments is resolved, use:</summary>
<div>
<br/>
<p>cat > App/Package.swift << ENDOFFILE</p>

<p>// swift-tools-version:5.6</p>

<p>// Leave blank. This is only here so that Xcode doesn't display it.</p>

<p>import PackageDescription</p>

<p>let package = Package(</p>
<p>&emsp;name: "client",</p>
<p>&emsp;products: [],</p>
<p>&emsp;targets: []</p>
<p>)</p>

<p>ENDOFFILE</p>
<div>
</details>
<br/><br/>

```sh
$ cat > App/Package.swift << ENDOFFILE
// swift-tools-version:5.6

// Leave blank. This is only here so that Xcode doesn't display it.

import PackageDescription

let package = Package(
    name: "client",
    products: [],
    targets: []
)
ENDOFFILE
```

Reopen the project in the Xcode. Now the `App` folder is hidden.

<br/>
<div align="center">
<img src="../../../images/supermodular/no-app.png" width="67.625%" title="No app">
<br/>
</div>
<br/>

Commit

```sh
$ git add .
$ git commit -m 'Add empty Swift Package to hide `App` folder from Xcode'
```
