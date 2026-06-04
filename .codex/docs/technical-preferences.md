# Technical Preferences

## Engine & Language

- **Engine**: Godot 4.6.2
- **Language**: GDScript
- **Build System**: SCons (engine), Godot Export Templates
- **Asset Pipeline**: Godot Import System + custom resource pipeline
- **Primary Project Type**: 2D HD pixel-art, top-down click-defense RPG

> **Mutable design note**: `Primary Project Type`, renderer bias, input focus,
> platform notes, and project-specific technical notes describe the current
> project artifacts. They are not permanent Skill-routing constraints. Re-read
> this file and the current GDD/UX/art documents before using those facts in a
> recommendation.

## Naming Conventions

- **Classes**: PascalCase, for example `CombatTarget`
- **Variables and Functions**: snake_case, for example `current_health` and `apply_damage()`
- **Signals**: snake_case past tense, for example `health_changed`
- **Files**: snake_case matching class, for example `combat_target.gd`
- **Scenes**: PascalCase matching root node, for example `CombatTarget.tscn`
- **Constants**: UPPER_SNAKE_CASE, for example `MAX_TARGETS`
- **Private Members**: underscore prefix, for example `_active_targets`

## Input & Platform

- **Target Platforms**: Multiple platforms; MVP prioritizes PC/Web or PC validation, with mobile considered after core feel is proven
- **Input Methods**: Keyboard/Mouse, Touch
- **Primary Input**: Mouse/Touch pointer interaction
- **Gamepad Support**: None for MVP; revisit only if PC/console controller support becomes a product goal
- **Touch Support**: Partial for MVP; full touch support before any mobile release
- **Platform Notes**: Avoid hover-only interactions. All click targets, tooltips, combat commands, and map controls must have touch-friendly equivalents before mobile work begins.

## Performance Budgets

- **Target Frame Rate**: 60fps
- **Frame Budget**: 16.6ms
- **Renderer Bias**: Prefer Godot 2D and CanvasItem workflows; keep VFX readable and avoid excessive overdraw
- **CPU Budget Notes**: Click handling, target selection, status effects, and wave simulation should be event-driven where possible
- **GPU Budget Notes**: HD pixel art and bright spiritual VFX should be profiled early on low-end integrated GPUs and mobile-class hardware if mobile remains a target

## Testing

- **Recommended Framework**: GUT for GDScript unit and integration tests
- **Manual Test Focus**: Click feel, targeting clarity, map interaction, wave pressure, and build differentiation
- **Automation Priority**: Damage formulas, status effect chains, wave spawning, save data, and unlock conditions

## Forbidden Patterns

[TO BE CONFIGURED]

## Allowed Libraries

[TO BE CONFIGURED]

## Engine Specialists

- **Primary**: godot-specialist
- **Language/Code Specialist**: godot-gdscript-specialist (all .gd files)
- **Shader Specialist**: godot-shader-specialist (.gdshader files, VisualShader resources)
- **UI Specialist**: godot-specialist (no dedicated UI specialist; primary covers Godot UI architecture)
- **Additional Specialists**: godot-gdextension-specialist (GDExtension / native C++ bindings only)
- **Routing Notes**: Invoke primary for architecture decisions, ADR validation, scene/node structure, export setup, and cross-cutting code review. Invoke GDScript specialist for code quality, signal architecture, static typing, and GDScript idioms. Invoke shader specialist for materials, VFX, and rendering. Invoke GDExtension specialist only after profiling proves native code is needed.

### File Extension Routing

| File Extension / Type | Specialist to Spawn |
| --- | --- |
| Game code (.gd files) | godot-gdscript-specialist |
| Shader / material files (.gdshader, VisualShader) | godot-shader-specialist |
| UI / screen files (Control nodes, CanvasLayer) | godot-specialist |
| Scene / prefab / level files (.tscn, .tres) | godot-specialist |
| Native extension / plugin files (.gdextension, C++) | godot-gdextension-specialist |
| General architecture review | godot-specialist |

## Project-Specific Technical Notes

- The player does not have a map avatar; pointer interaction is the primary action model.
- Combat click design must avoid pure hand-speed tests. Prefer target priority, build triggers, cooldown decisions, status chains, and automation relief.
- Map systems should support fixed layout, fog reveal, capability gates, and limited randomized events.
- Runtime architecture should keep content data in typed custom Resources where practical.
- Global autoloads should be rare and documented before implementation.
