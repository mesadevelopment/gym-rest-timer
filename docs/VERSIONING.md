# Versioning Guide

This document outlines the versioning strategy for Gym Rest Timer.

## Semantic Versioning

Gym Rest Timer follows [Semantic Versioning 2.0.0](https://semver.org/) (SemVer):

```
MAJOR.MINOR.PATCH
```

### Version Components

- **MAJOR** (x.0.0): Incremented for incompatible API changes or major breaking changes
  - Example: Removing a timer duration option, changing the state machine API
  
- **MINOR** (x.y.0): Incremented for backwards-compatible functionality additions
  - Example: Adding a new timer duration, adding pause/resume functionality
  
- **PATCH** (x.y.z): Incremented for backwards-compatible bug fixes
  - Example: Fixing a timer accuracy issue, fixing a UI bug

## Version Sources

The version number is maintained in multiple places:

1. **VERSION** file (root): Plain text version number (e.g., `1.0.0`)
2. **Xcode Project**: `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in `project.pbxproj`
3. **CHANGELOG.md**: Human-readable change log with version history
4. **Git Tags**: Release tags in format `v1.0.0`

## Version Synchronization

When releasing a new version:

1. Update `VERSION` file
2. Update `MARKETING_VERSION` in Xcode project (or via Xcode UI)
3. Update `CURRENT_PROJECT_VERSION` (build number) if needed
4. Update `CHANGELOG.md` with release notes
5. Create git tag: `git tag -a v1.0.0 -m "Release version 1.0.0"`
6. Push tag: `git push origin v1.0.0`

## Xcode Version Settings

### Marketing Version (CFBundleShortVersionString)
- User-facing version number
- Format: `MAJOR.MINOR.PATCH`
- Example: `1.0.0`
- Location: `MARKETING_VERSION` in project settings

### Current Project Version (CFBundleVersion)
- Build number (increments with each build)
- Format: Integer (e.g., `1`, `2`, `3`)
- Can also use format: `MAJOR.MINOR.PATCH.BUILD`
- Location: `CURRENT_PROJECT_VERSION` in project settings

## Release Workflow

### Pre-Release Checklist

- [ ] All tests passing
- [ ] Code reviewed
- [ ] CHANGELOG.md updated
- [ ] VERSION file updated
- [ ] Xcode project version updated
- [ ] Build number incremented (if needed)
- [ ] Documentation updated

### Release Steps

1. **Update Version Files**
   ```bash
   # Update VERSION file
   echo "1.0.0" > VERSION
   
   # Update CHANGELOG.md with release date
   # Update Xcode project settings
   ```

2. **Create Release Branch** (optional)
   ```bash
   git checkout -b release/1.0.0
   ```

3. **Commit Version Changes**
   ```bash
   git add VERSION CHANGELOG.md
   git commit -m "chore: bump version to 1.0.0"
   ```

4. **Create Git Tag**
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   ```

5. **Push Changes and Tag**
   ```bash
   git push origin main
   git push origin v1.0.0
   ```

6. **Create GitHub Release** (if using GitHub)
   - Use the tag `v1.0.0`
   - Copy relevant section from CHANGELOG.md
   - Attach build artifacts if needed

## Version Naming Conventions

### Pre-Release Versions

- **Alpha**: `1.0.0-alpha.1`, `1.0.0-alpha.2`
- **Beta**: `1.0.0-beta.1`, `1.0.0-beta.2`
- **Release Candidate**: `1.0.0-rc.1`, `1.0.0-rc.2`

### Development Versions

- **Snapshot**: `1.0.0-SNAPSHOT` (for in-development versions)
- **Dev**: `1.0.0-dev` (for development builds)

## watchOS-Specific Considerations

### App Store Versioning

- **Version**: Must match `CFBundleShortVersionString` (Marketing Version)
- **Build**: Must match `CFBundleVersion` (Current Project Version)
- Build number must increment for each App Store submission

### TestFlight Versioning

- Each TestFlight build requires a unique build number
- Version string can remain the same across TestFlight builds
- Build number must always increment

## Examples

### Patch Release (Bug Fix)
```
1.0.0 → 1.0.1
- Fixed timer pausing when screen turns off
- Fixed scrolling issue on selection screen
```

### Minor Release (New Feature)
```
1.0.0 → 1.1.0
- Added custom timer duration option
- Added pause/resume functionality
```

### Major Release (Breaking Change)
```
1.0.0 → 2.0.0
- Redesigned state machine API
- Removed deprecated timer durations
```

## Automation (Future)

Consider automating version management with:

- **fastlane**: For automated version bumping and releases
- **scripts/version-bump.sh**: Custom script for version synchronization
- **GitHub Actions**: For automated version tagging on releases

## References

- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Apple: Versioning Your App](https://developer.apple.com/documentation/xcode/versioning-your-app)

