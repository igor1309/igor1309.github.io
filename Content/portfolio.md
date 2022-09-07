# Portfolio

_Most of my work is covered under NDA, but there are few things I can show here_.

All iOS apps support __Dynamic Type__ and __Dark mode__.

## Hole Fill

`Hole Fill` was a take home assignment that I've used to present __ultra-modular design of decoupled composable components__.
For explanation see [this blog post](./articles/2022/2022-08-01-fill-hole/).

> The goal of this task is to build a small image processing library that fills holes in images, along with a small command line utility that uses that library, and answer a few questions.

<div align="center">
<image src="/images/portfolio/fill-hole/terminal.png" width="30%" title="fill-hole terminal command showing help in case of incorrect input.">
<br/>
<p align="center"><cite>fill-hole terminal command showing help in case of incorrect input.</cite></p>
</div>
<br/>

<div align="center">
<image src="/images/portfolio/fill-hole/modules.png" width="100%" title="Top-level view of modules and dependencies">
<br/>
<p align="center"><cite>Top-level view of modules and dependencies.</cite></p>
</div>
<br/>

<div align="center">
<image src="/images/portfolio/fill-hole/components.png" width="100%" title="Detailed view with components">
<br/>
<p align="center"><cite>Detailed view with components.</cite></p>
</div>
<br/>

## CIFilterBrowser

***Core Image***, ***SwiftUI***, ***Combine***

__Core Image__ is [Apple's framework](https://developer.apple.com/documentation/coreimage) for image processing and analysis. It's great and performant but not very friendly, especially for Swift programmers.

One of the framework's pillars is __CIFilter__ image filter. There are 230 filters in 21 categories - one filter could belong to multiple categories. Filters have different customisation options, but API is “Stringly typed” and that is Objective-C’s legacy we have to live with.

I've made an app __CIFilterBrowser__ to make it easier to get into CIFilter details.

<div align="center">
<image src="/images/portfolio/ciFilterBrowser/combined1_3.png" width="100%" title="CIFilterBrowser main screen view options: list and grid, switched with menu">
<br/>
<p align="center"><cite>CIFilterBrowser main screen view options: list and grid, switched with menu.</cite></p>
</div>
<br/>

<div align="center">
<image src="/images/portfolio/ciFilterBrowser/combined4_6.png" width="100%" title="CIFilterBrowser Search filters (names, categories, descriptions), change image for main view, apply filter by category (selection of multiple categories is allowed)">
<br/>
<p align="center"><cite>CIFilterBrowser: search filters (names, categories, descriptions), change image for main view, apply filter by category (selection of multiple categories is allowed).</cite></p>
</div>
<br/>

<div align="center">
<image src="/images/portfolio/ciFilterBrowser/combined7_9.png" width="100%" title="CIFilterBrowser: CIFilter detail view with controls to tweak filter parameters">
<br/>
<p align="center"><cite>CIFilterBrowser: CIFilter detail view with controls to tweak filter parameters.</cite></p>
</div>
<br/>

<br/>
_Coming soon to App Store._
<br/>

<div><details>
<summary>Where to start</summary>
<p>For initial dive in into the CIFilter world I highly recommend <a href="https://www.objc.io/issues/21-camera-and-photos/core-image-intro/">An Introduction to Core Image · objc.io</a> by Warren Moore and <a href="https://developer.apple.com/documentation/coreimage/processing_an_image_using_built-in_filters">Processing an Image Using Built-in Filters</a> in Apple Developer Documentation.</p>
</details></div>
<br/>

## Mobility

*My own* ***Chart Library***, ***SwiftUI***, ***Combine***

An app for the [Apple Mobility Index](https://covid19.apple.com/mobility)
<br/>

<div align="center">
<image src="/images/portfolio/mobility/combined1_3.png" width="100%" title="Mobility Index Bar Chart, Country list and search">
<br/>
<p align="center"><cite>Mobility Index Bar Chart, Country list and search (by country, region/ sub-region or city).</cite></p>
</div>
<br/>

<div align="center">
<image src="/images/portfolio/mobility/combined4_6.png" width="100%" title="Mobility Index Calculation Options, country selection by bar">
<br/>
<p align="center"><cite>Mobility Index Calculation Options, country selection by bar.</cite></p>
</div>
<br/>

<div align="center">
<image src="/images/portfolio/mobility/combined7_9.png" width="100%" title="Country mobility line charts: raw data and 7 days moving average">
<br/>
<p align="center"><cite>Country mobility line charts: raw data and 7 days moving average.</cite></p>
</div>
<br/>

## Covid-19 Observer

*My own* ***Chart Library***, ***MapKit***, ***Core Data***, ***UIKit***, ***SwiftUI***, ***Combine***.

<div align="center">
<image src="/images/portfolio/covid/combined1_3.png" width="100%" title="Covid-19 Observer: global overview, charts with floating legend">
<br/>
<p align="center"><cite>Covid-19 Observer: global overview, charts with floating legend.</cite></p>
</div>
<br/>

<div align="center">
<image src="/images/portfolio/covid/combined4_6.png" width="100%" title="Covid-19 Observer: Map and color settings">
<br/>
<p align="center"><cite>Covid-19 Observer: map and color settings.</cite></p>
</div>
<br/>

<div align="center">
<image src="/images/portfolio/covid/combined7_9.png" width="100%" title="Covid-19 Observer: country data, chart with point inspector">
<br/>
<p align="center"><cite>Covid-19 Observer: country data, chart with point inspector.</cite></p>
</div>
<br/>

<br/>

*Data by John Hopkins University*.

<br/>
<br/>

## MAXimatica

***SwiftUI***, ***Combine***

Pre-school math (Russian only).

<div align="center">
<image src="/images/portfolio/maximatica/combined1_3.png" width="100%" title="MAXImatica: onboarding and mission selection">
<br/>
<p align="center"><cite>MAXImatica: onboarding and mission selection.</cite></p>
</div>
<br/>

<div align="center">
<image src="/images/portfolio/maximatica/combined4_6.png" width="100%" title="MAXImatica: results and history">
<br/>
<p align="center"><cite>MAXImatica: results and history.</cite></p>
</div>
<br/>
