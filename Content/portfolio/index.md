---
title: Portfolio
---

# Portfolio

## Built with AI coding agents

These projects come from my private monorepo, where I build products with AI coding agents working from specs and tests. Each one is published as its own public repository with its code, tests and README, and checked to build and pass on its own outside the monorepo.

### RexLab

***React***, ***TypeScript***, ***Vite***, ***Gherkin***, ***Vitest***

A dinosaur learning game for children aged 4 to 7, made for an iPad held sideways. Behaviour is specified first in Gherkin (87 feature files) and checked by 130+ Vitest test files.

[Play it](https://rexlab.enoa.ai) · [Source](https://github.com/igor1309/rexlab)

<div align="center">
<a href="https://rexlab.enoa.ai">
<picture>
<source media="(prefers-color-scheme: dark)" srcset="/images/portfolio/rexlab/home-dark.webp">
<img src="/images/portfolio/rexlab/home-light.webp" width="100%" alt="RexLab's home screen with its dinosaur games">
</picture>
</a>
<p align="center"><cite>RexLab's home screen with its dinosaur games.</cite></p>
</div>
<br/>

Posts: [A Dinosaur Lab for Small Hands](/articles/2026/2026-08-01-rexlab-a-dinosaur-lab-for-small-hands/), [640 Scenarios Before Code](/articles/2026/2026-08-08-rexlab-640-scenarios-before-code/), [Tap Safety for Small Hands](/articles/2026/2026-08-15-rexlab-tap-safety-for-small-hands/).

### FolioTell

***SwiftUI***, ***AVSpeechSynthesizer***, ***Swift Testing***, ***Maestro***

An offline iPhone app that reads Markdown and plain-text files aloud. SwiftUI over Apple speech synthesis, with the playback logic in a separate library of pure reducers and effect handlers, 196 Swift Testing tests, and Maestro flows on the simulator.

[Source](https://github.com/igor1309/foliotell)

<div align="center">
<img src="/images/portfolio/foliotell/reader.webp" width="30%" alt="FolioTell reading a Markdown file">
<img src="/images/portfolio/foliotell/playing.webp" width="30%" alt="FolioTell playing it aloud">
<img src="/images/portfolio/foliotell/ru-dark.webp" width="30%" alt="FolioTell reading a Russian poem in dark mode">
<p align="center"><cite>FolioTell: reading a Markdown file, playing it aloud, and a Russian poem in dark mode.</cite></p>
</div>
<br/>

Posts: [An App That Reads Your Notes Aloud](/articles/2026/2026-08-22-foliotell-an-app-that-reads-your-notes-aloud/), [A Speech Synthesizer Behind a Reducer](/articles/2026/2026-08-29-foliotell-a-speech-synthesizer-behind-a-reducer/), [Where Am I in This Text?](/articles/2026/2026-09-05-foliotell-where-am-i-in-this-text/).

### Agister

***Go***

A command-line runner for AI-agent work defined in settings files. Agents, processes and workflows are settings that compose; every run is resolved before it starts, held to its limits and budget, and recorded whole.

[Source](https://github.com/igor1309/agister) · [How a run executes](/agister/run-architecture/) · [How settings resolve](/agister/settings-architecture/)

Posts: [Agent Work as Settings, Not Code](/articles/2026/2026-09-12-agister-agent-work-as-settings-not-code/), [What a Run Leaves Behind](/articles/2026/2026-09-19-agister-what-a-run-leaves-behind/), [A Code Review With a Debate Inside](/articles/2026/2026-09-26-agister-a-code-review-with-a-debate-inside/).

### Agonara

***Node.js***, ***SQLite***

A bring-your-own-agent environment for learning programs. A curator builds a program of topics, concepts, materials and checks; students read it, answer and see where they are weak. Both point the agent they already use at the same HTTP API that serves the `/learn` and `/admin` web UIs.

[Live instance](https://agonara.enoa.ai/learn) · [Source](https://github.com/igor1309/agonara)

<div align="center">
<img src="/images/portfolio/agonara/learn-quick-check.webp" width="70%" alt="An Agonara Quick Check: a student answers a question and sees the result">
<p align="center"><cite>An Agonara Quick Check: a student answers a question and sees the result.</cite></p>
</div>
<br/>

Posts: [A Learning Program Your Own Agent Can Work On](/articles/2026/2026-10-03-agonara-a-learning-program-your-own-agent-can-work-on/), [Drafts Are Not the Program](/articles/2026/2026-10-10-agonara-drafts-are-not-the-program/), [Grading Open Answers with a Model](/articles/2026/2026-10-17-agonara-grading-open-answers-with-a-model/).

## Earlier iOS work

_Most of my iOS work is covered under NDA, but there are a few things I can show here._

All iOS apps support __Dynamic Type__ and __Dark mode__.

### Hole Fill

`Hole Fill` was a take home assignment that I've used to present __ultra-modular design of decoupled composable components__.
For explanation see [this blog post](/articles/2022/2022-08-01-fill-hole/).

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

### CIFilterBrowser

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

### Mobility

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

### Covid-19 Observer

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

### MAXimatica

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
