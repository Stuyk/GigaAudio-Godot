# GigaAudio for Godot 4.3+

Audio Occlusion, Audio Areas, and Audio Depth Areas for your project.

[![GigaBake Video](https://img.youtube.com/vi/YgN4bHHGhKA/0.jpg)](https://www.youtube.com/watch?v=YgN4bHHGhKA)

Tag me on [BlueSky](https://bsky.app/profile/stuyk.bsky.social) if you use this project!

_The above is a video demo if you're confused by what this does. Give it a listen._

## Install

Place all files from the `src` directory into `addons/giga_audio`.

> [!CAUTION]
> Make sure the folder is named **giga_audio**

Enable the plugin through your Project Settings.

## Usage

1. Attach an `AudioTarget` to your Player / CharacterBody3D.
2. Use AudioOccluder3D, AudioArea3D, or AudioDepth3D

Additionally if you use **AudioArea3D** or **AudioDepth3D** you will need to attach a **CollisionShape3D** to them as a child.

Beyond that, each node has individual settings that you can tweak.

Hover over their settings for additional information.

## Changelog

```
1.0.0

- Release
```