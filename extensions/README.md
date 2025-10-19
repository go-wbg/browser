# WebExtensions Management

This directory manages the WebExtensions that are bundled with the security-hardened Firefox build. Extensions are automatically downloaded and integrated during the CI build process.

## Overview

The extension management system provides:
- **Declarative Configuration**: JSON-based extension definitions
- **Automatic Downloads**: Extensions fetched during build process
- **Caching**: Downloaded extensions cached to avoid redundant downloads
- **Integrity Verification**: Optional SHA256 hash verification
- **Flexibility**: Easy to add, remove, or update extensions

## Directory Structure

```
extensions/
├── README.md           # This file - documentation for managing extensions
├── extensions.json     # Configuration file defining which extensions to include
├── download.sh         # Script to download and prepare extensions
└── cache/              # Downloaded extension files (gitignored)
    └── .gitkeep        # Preserves directory in git
```

## Configuration File: `extensions.json`

The `extensions.json` file defines which extensions to bundle with Firefox builds.

### Structure

```json
{
  "extensions": [
    {
      "id": "extension-id@developer.org",
      "name": "Extension Name",
      "version": "latest",
      "source": "https://addons.mozilla.org/firefox/downloads/latest/extension-name/addon-extension-name-latest.xpi",
      "enabled": true,
      "sha256": "optional_hash_for_verification",
      "description": "Brief description of the extension"
    }
  ],
  "settings": {
    "verify_signatures": true,
    "cache_directory": "extensions/cache",
    "distribution_directory": "config/common/distribution/extensions"
  }
}
```

### Field Definitions

#### Extension Fields

- **`id`** (required): The unique extension ID from the extension's manifest.json
  - Format: Usually `name@developer.org` or `{uuid}`
  - Find it: In AMO URL, manifest.json, or about:debugging in Firefox

- **`name`** (required): Human-readable extension name
  - Used for logging and documentation

- **`version`** (required): Version specification
  - `"latest"`: Always download the latest version
  - Specific version: e.g., `"1.52.0"` (requires version-specific URL)

- **`source`** (required): Direct download URL for the XPI file
  - AMO latest: `https://addons.mozilla.org/firefox/downloads/latest/{slug}/addon-{slug}-latest.xpi`
  - AMO specific version: `https://addons.mozilla.org/firefox/downloads/file/{file-id}/{filename}.xpi`
  - GitHub release: Direct link to XPI asset

- **`enabled`** (required): Whether to include this extension
  - `true`: Download and bundle
  - `false`: Skip (useful for temporarily disabling without removing config)

- **`sha256`** (optional): SHA256 hash for integrity verification
  - If provided, download will be verified against this hash
  - Generate with: `sha256sum extension.xpi`

- **`description`** (optional): Brief description of extension's purpose
  - Useful for documentation and maintenance

#### Settings Fields

- **`verify_signatures`**: Whether to verify Firefox extension signatures (default: true)
- **`cache_directory`**: Where to store downloaded XPI files
- **`distribution_directory`**: Where to place extensions for Firefox build

## Managing Extensions

### Adding a New Extension

1. **Find the extension on AMO** (addons.mozilla.org)
   - Example: https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/

2. **Get the extension ID**
   - Method 1: Install extension, go to `about:debugging#/runtime/this-firefox`, find extension
   - Method 2: Look at AMO page URL or download XPI and check manifest.json
   - Method 3: Check browser console when installing

3. **Get the download URL**
   - For latest version: `https://addons.mozilla.org/firefox/downloads/latest/{slug}/addon-{slug}-latest.xpi`
   - The `{slug}` is from the AMO URL (e.g., "ublock-origin")

4. **Add to extensions.json**
   ```json
   {
     "id": "extension-id@developer.org",
     "name": "Extension Name",
     "version": "latest",
     "source": "https://addons.mozilla.org/firefox/downloads/latest/extension-slug/addon-extension-slug-latest.xpi",
     "enabled": true,
     "description": "What this extension does"
   }
   ```

5. **Test locally**
   ```bash
   bash extensions/download.sh
   ```

6. **Commit changes** (do not commit downloaded XPI files)
   ```bash
   git add extensions/extensions.json
   git commit -m "Add [Extension Name] to bundled extensions"
   ```

### Updating an Extension

#### Automatic Updates (Recommended)
If using `"version": "latest"` in configuration, extensions automatically download the latest version on each build. No action needed.

#### Pinning to Specific Version
1. Find the specific version file ID on AMO
2. Update the `source` URL to the specific file
3. Update the `version` field
4. Optionally add SHA256 hash for verification
5. Clear cached version: `rm extensions/cache/{extension-id}.xpi`

Example:
```json
{
  "id": "uBlock0@raymondhill.net",
  "name": "uBlock Origin",
  "version": "1.52.0",
  "source": "https://addons.mozilla.org/firefox/downloads/file/4123456/ublock_origin-1.52.0.xpi",
  "enabled": true,
  "sha256": "abc123..."
}
```

### Removing an Extension

**Option 1: Disable temporarily**
```json
{
  "id": "extension-id@developer.org",
  "enabled": false
}
```

**Option 2: Remove completely**
Delete the entire extension entry from the `extensions` array.

### Verifying Downloads

After running `download.sh`, check:
```bash
# List cached downloads
ls -lh extensions/cache/

# List distribution copies
ls -lh config/common/distribution/extensions/

# Verify a specific extension
unzip -l extensions/cache/extension-id.xpi
```

## Download Script: `download.sh`

The `download.sh` script automates extension preparation.

### Usage

```bash
# From repository root
bash extensions/download.sh

# The script will:
# 1. Read extensions.json
# 2. Download enabled extensions (or use cache)
# 3. Verify SHA256 hashes if provided
# 4. Copy to distribution directory
```

### Prerequisites

- **jq**: JSON processor
  - Install: `sudo apt-get install jq` (Linux)
  - Install: `brew install jq` (macOS)
  - Install: `choco install jq` (Windows)

- **curl**: Download utility (usually pre-installed)

### Output

```
Processing extensions...
Processing: uBlock Origin
  ID: uBlock0@raymondhill.net
  Source: https://addons.mozilla.org/...
  Downloading...
  Copying to distribution directory...
  ✓ Done

Extension download complete!
Extensions placed in: config/common/distribution/extensions
```

## CI Integration

Extensions are automatically downloaded during GitHub Actions workflows:

```yaml
- name: Download and prepare extensions
  run: |
    sudo apt-get install -y jq
    cd "${GITHUB_WORKSPACE}"
    bash extensions/download.sh
```

Extensions are then copied to the Firefox source during the "Inject configuration files" step.

## Security Considerations

### Extension Selection Criteria

Only include extensions that:
- ✅ Are from trusted developers
- ✅ Are open source (verifiable code)
- ✅ Enhance privacy or security
- ✅ Have regular updates and maintenance
- ✅ Have minimal permissions
- ✅ Don't require accounts or cloud services
- ✅ Are available on official AMO (addons.mozilla.org)

### Source Verification

- **Always use AMO as the source**: Mozilla reviews and signs extensions
- **Consider SHA256 verification**: Pin hash for critical extensions
- **Review permissions**: Check what access extensions request
- **Monitor updates**: Review changelogs for extensions using `"latest"`

### Recommended Extensions

Extensions that align with privacy/security goals:

- **uBlock Origin**: Ad and tracker blocking
  - ID: `uBlock0@raymondhill.net`
  - Source: Open source, widely trusted
  - Permissions: Minimal, necessary for blocking

- **Privacy Badger**: Tracker blocking
  - ID: `jid1-MnnxcxisBPnSXQ@jetpack`
  - Source: EFF (Electronic Frontier Foundation)
  - Permissions: Minimal

- **HTTPS Everywhere**: Force HTTPS connections
  - ID: `https-everywhere@eff.org`
  - Source: EFF
  - Permissions: Minimal

- **NoScript**: JavaScript control
  - ID: `{73a6fe31-595d-460b-a920-fcc0f8843232}`
  - Source: Open source, established developer
  - Note: May require user configuration

### Extensions to Avoid

- ❌ Closed source extensions
- ❌ Extensions requiring accounts
- ❌ Extensions with excessive permissions
- ❌ Extensions from unknown developers
- ❌ Extensions with privacy policy concerns
- ❌ Unmaintained extensions

## Troubleshooting

### Download Fails

**Problem**: Extension fails to download
```
Error: Failed to download extension
```

**Solutions**:
1. Check internet connectivity
2. Verify the `source` URL is correct
3. Check if AMO is accessible
4. Try downloading manually to test URL

### SHA256 Verification Fails

**Problem**: Hash mismatch
```
Error: SHA256 verification failed
```

**Solutions**:
1. Extension was updated - get new hash
2. Download was corrupted - delete cached file and retry
3. Update hash in extensions.json

### Extension Not Appearing in Firefox

**Problem**: Built Firefox doesn't show extension

**Solutions**:
1. Verify extension was copied to distribution directory
2. Check Firefox build logs for errors
3. Ensure extension ID matches filename: `{id}.xpi`
4. Check extension is enabled in extensions.json
5. Try `about:debugging` in built Firefox

### jq Not Found

**Problem**: 
```
Error: jq is required but not installed
```

**Solution**:
```bash
# Linux
sudo apt-get install jq

# macOS
brew install jq

# Windows (with Chocolatey)
choco install jq
```

## Testing

### Local Testing Workflow

1. **Make changes to extensions.json**
2. **Run download script**
   ```bash
   bash extensions/download.sh
   ```
3. **Verify downloads**
   ```bash
   ls -lh extensions/cache/
   ls -lh config/common/distribution/extensions/
   ```
4. **Test in Firefox** (if building locally)
   ```bash
   # After building Firefox
   ./obj-firefox/dist/bin/firefox
   # Navigate to about:addons
   ```

### CI Testing

1. Push changes to trigger workflow
2. Monitor GitHub Actions logs
3. Check "Download and prepare extensions" step
4. Download built artifacts
5. Test built Firefox binary

## Cache Management

The `extensions/cache/` directory stores downloaded XPI files.

### Cache Benefits
- Faster local development (no re-downloads)
- Reduced AMO bandwidth usage
- Offline capability after first download

### Cache Maintenance

```bash
# Clear all cached extensions
rm extensions/cache/*.xpi

# Clear specific extension
rm extensions/cache/extension-id.xpi

# Check cache size
du -sh extensions/cache/
```

### Cache in CI

GitHub Actions doesn't cache between workflow runs by default. Each build downloads fresh copies, ensuring latest versions when using `"version": "latest"`.

## Best Practices

1. **Use latest versions**: Set `"version": "latest"` for automatic security updates
2. **Document why**: Add clear `description` for each extension
3. **Test before committing**: Run `download.sh` locally to verify
4. **Don't commit XPI files**: Keep cache/ in .gitignore
5. **Review regularly**: Periodically review extension list and update rationale
6. **Monitor changes**: Subscribe to extension update notifications
7. **Verify sources**: Always use official AMO links
8. **Consider hashes**: Use SHA256 for critical extensions

## Advanced Usage

### Platform-Specific Extensions

To include different extensions per platform, modify `download.sh` to read platform-specific configs or use conditional logic:

```bash
PLATFORM=$(uname)
if [ "$PLATFORM" == "Linux" ]; then
    # Linux-specific extensions
fi
```

### Extension Preferences

To pre-configure extension settings, create preference files in `config/common/distribution/policies.json` or use user.js overrides.

### Multiple Extension Profiles

Create separate JSON configs for different use cases:
- `extensions-minimal.json`: Only essential privacy extensions
- `extensions-full.json`: Complete privacy and security suite
- `extensions-dev.json`: Development and testing tools

## References

### Mozilla Documentation
- [Extension Distribution](https://extensionworkshop.com/documentation/publish/distribute-sideloading/)
- [Distribution Directory](https://support.mozilla.org/en-US/kb/customizing-firefox-using-autoconfig)
- [Enterprise Policies](https://github.com/mozilla/policy-templates)

### Extension Resources
- [AMO (addons.mozilla.org)](https://addons.mozilla.org/)
- [Extension Workshop](https://extensionworkshop.com/)
- [WebExtensions API](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions)

### Security Resources
- [EFF Privacy Guides](https://www.eff.org/pages/tools)
- [PrivacyTools.io](https://www.privacytools.io/)
- [Firefox Privacy Guide](https://www.privacytools.io/browsers/#firefox)

## Support

For issues related to:
- **Extension management system**: Open issue in this repository
- **Specific extensions**: Contact extension developer or AMO
- **Firefox builds**: See main repository README.md

## License

This extension management system is part of the security-hardened Firefox fork project. See repository LICENSE file for details.

Individual extensions have their own licenses - check each extension's AMO page or repository.
