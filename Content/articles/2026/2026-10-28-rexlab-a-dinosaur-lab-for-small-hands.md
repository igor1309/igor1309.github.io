---
date: 2026-10-28 12:00
description: RexLab is a dinosaur learning web app for children aged 4 to 7, made for an iPad held sideways. What it is, who it is for, and why it has no backend.
tags: RexLab, React, TypeScript, Kids, Showcase
---

# RexLab: a Dinosaur Lab for Small Hands

Children between four and seven go through a dinosaur phase that is almost a rite of passage. They learn names adults can't pronounce, argue about who was bigger, and want to know what every creature ate. Most apps that try to feed this curiosity are either thin wrappers around ads or so busy with rewards that the dinosaurs become an excuse.

[RexLab](https://rexlab.enoa.ai) is my attempt at the opposite: a calm, focused dinosaur lab that runs in a browser on an iPad held sideways. The source is public at [github.com/igor1309/rexlab](https://github.com/igor1309/rexlab).

## The games

RexLab is a set of small games around one catalogue of creatures:

- **Compare.** Who is heavier, taller, longer? Ten questions a round, with a celebration for a new best score.
- **Ancient reptiles.** A catalogue of 52 dinosaurs, flying and sea reptiles, filtered by what they ate. The facts are checked against natural history museums and Britannica, because children remember what they are told.
- **Skeletons.** Put a skeleton together from its bones, then guess a mystery dinosaur from its bones alone. Finished skeletons go to a museum.
- **Care.** A dinosaur visits hungry, thirsty, dirty or tired; give it what it needs and make a friend.
- **Sort them all.** Drag dinosaurs into baskets: two legs or four, meat or plants, horns, feathers, big or small.
- **Find the pair**, a memory game, and **Dig**, where a child brushes sand away to uncover fossils and treasures.

## Three levels, one app

A four-year-old and a seven-year-old are different users. Every game has three age levels: Hatchling, Explorer and Paleontologist. A parent sets the level once; a child can change it inside a game, and that choice wins until a parent changes the setting again. It sounds like a detail, but it is a whole set of rules about who decides, and it is written down as behaviour before it was code (more on that in the next post).

The app speaks English and Russian, writes text for children in capitals, which is how early readers recognise letters, and has light and dark themes.

## Why there is no backend

RexLab is React 19, TypeScript and Vite, and nothing else. There is no account, no server and no analytics. Progress — best scores, finished skeletons, friends made in Care — stays in the browser's local storage.

This is a deliberate choice for an app for small children. Nothing to sign up for means nothing to leak and nothing to consent to. It also makes the app cheap to host and easy to keep alive: a static site will keep working long after a backend would have needed attention.

## Built for one device, tested on many windows

The target is an iPad in landscape, but "an iPad" is not one size. Safari's toolbar, full-screen mode, the iPad mini and the 13" iPad Pro all give a different window. RexLab's tests open the app at seven real window sizes and check that every screen fits without scrolling. A child should never have to discover that a button is hiding below the fold.

## Built with agents

RexLab was built with AI coding agents working from specifications and tests. The dinosaur, skeleton and item artwork is AI-generated too, and each picture's generator is recorded in a `CREDITS.md` file next to it. The later posts in this series look at how that worked in practice.

Play it at [rexlab.enoa.ai](https://rexlab.enoa.ai); read the code at [github.com/igor1309/rexlab](https://github.com/igor1309/rexlab).
