# Security-Hardened Firefox Fork

WIP. MOST OF THIS PROJECT IS NOT DONE YET.

A security-focused Firefox fork designed to be built and distributed through continuous integration (CI) pipelines, providing enhanced privacy protections and security hardening beyond default Firefox configurations.

## Continuous Integration Focus

This project's primary goal is to leverage CI/CD pipelines to automatically build hardened Firefox variants. We will use GitHub Actions to:

- Apply security hardening consistently across builds
- Ensure reproducible build environments
- Automate security testing and verification
- Provide regular binary releases without manual intervention

### CI Build Artifacts

Automated builds will produce ready-to-use binaries for multiple platforms:

- **Linux**: Firefox binaries packaged as `.tar.xz` archives
- **Windows**: Installer packages (`.exe`) and portable `.zip` archives

All builds will be available as GitHub Actions artifacts and can be downloaded from the Actions tab of this repository.

## Security Objectives

The browser will implement multiple layers of protection focused on:

- **Network Isolation**: Preventing information leaks and ensuring all traffic routes through configured proxies
- **Enhanced Sandboxing**: Strengthening process isolation beyond Firefox defaults
- **Anti-Exploitation Hardening**: Maximizing built-in exploit mitigations and reducing attack surface
- **Fingerprinting Resistance**: Reducing identifiable browser characteristics

## Using CI-Built Releases

### Download Latest Build

1. Go to the "Actions" tab in this repository
2. Select the latest successful workflow run
3. Download the artifact for your platform from the "Artifacts" section

### Verify Build Integrity

Each release will include verification hashes to confirm build integrity. Always verify downloads before use.

## Local Build Instructions

While CI is the primary build method, you can build locally for testing:

### Linux

```bash
# Clone the repository
git clone https://github.com/eyedeekay/browser.git
cd browser

# Build using GitHub Actions workflow locally (requires act)
act -j build-linux
```

### Windows

```bash
# Clone the repository
git clone https://github.com/eyedeekay/browser.git
cd browser

# Build using GitHub Actions workflow locally (requires act)
act -j build-windows
```

## Security Principles

This browser fork will follow several key security principles:

1. **Least Privilege**: Components operate with minimal required permissions
2. **Defense in Depth**: Multiple overlapping security mechanisms
3. **Secure by Default**: Security protections enabled without user configuration
4. **Fail Secure**: Error conditions maintain security mechanisms

## Implementation Approach

The hardening will be primarily implemented through:

1. Enhanced user.js configuration
2. Security-focused build options
3. Security-enhanced compiler flags
4. Disabling unnecessary features

## License

This project is licensed under the Mozilla Public License 2.0 - see the [LICENSE](LICENSE) file for details.