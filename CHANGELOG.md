# Changelog

All notable changes to Gym Rest Timer will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.1] - 2025-11-16

### Added
- TBD



### Added
- Initial project setup with MVVM architecture
- Timer state machine with states: idle, ready, countingDown, finished
- Four preset timer durations: 30s, 60s, 90s, 120s
- Visual countdown with color transitions (orange at 10s, red at 5s)
- Haptic feedback at 10s, 5s, and completion
- Flash animation during countdown (2x per second at thresholds)
- Tap-to-reset functionality during countdown
- Auto-reset to ready state after completion
- Continuous timer that runs even when watch screen is off
- Scrollable selection screen for all timer options
- Comprehensive unit tests for state machine

### Changed
- Refactored from Timer-based to async/await Task-based countdown
- Improved timer accuracy using ContinuousClock
- Enhanced code documentation and comments

### Fixed
- Fixed scrolling issue on timer selection screen
- Fixed timer pausing when watch screen turns off
- Fixed Info.plist UIScene configuration warning

## [1.0.0] - TBD

### Added
- Initial release
- Core timer functionality
- Haptic and visual alerts
- watchOS 10.0+ support

---

## Version History

- **1.0.0** - Initial release (MVP)

## Version Format

This project uses [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible API changes
- **MINOR** version for backwards-compatible functionality additions
- **PATCH** version for backwards-compatible bug fixes

## Release Types

- **Major Release (x.0.0)**: Breaking changes, major feature additions
- **Minor Release (x.y.0)**: New features, backwards-compatible
- **Patch Release (x.y.z)**: Bug fixes, backwards-compatible

