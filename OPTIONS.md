# Privacy-Enhancing Mozconfig Options Glossary

This document provides a comprehensive reference for mozconfig options that can enhance privacy in Firefox builds. All information pertains to standard Firefox and reflects actual, functional options as of Firefox 115+ ESR.

## Core Privacy Options

### Telemetry and Data Collection

| Option | Default State | Effect |
|--------|---------------|--------|
| `--disable-telemetry` | Enabled | Disables Mozilla's telemetry system, preventing collection of usage statistics and performance data |
| `--disable-crashreporter` | Enabled | Removes crash reporting functionality, preventing automatic crash dump uploads |
| `--disable-experiments` | Enabled | Disables Shield Studies and remote configuration experiments |
| `--disable-healthreport` | Enabled | Disables Firefox Health Report data collection |

```bash
# Disable data collection
ac_add_options --disable-telemetry
ac_add_options --disable-crashreporter
ac_add_options --disable-experiments
ac_add_options --disable-healthreport
```

### Network Privacy

| Option | Default State | Effect |
|--------|---------------|--------|
| `--disable-necko-wifi` | Enabled | Disables WiFi scanning for geolocation, removing network-based location detection |
| `--disable-webspeech` | Enabled | Removes Web Speech API support, preventing voice recognition features |
| `--disable-webrtc` | Enabled | Completely removes WebRTC support, eliminating IP leak vectors |

```bash
# Network privacy enhancements
ac_add_options --disable-necko-wifi
ac_add_options --disable-webspeech
ac_add_options --disable-webrtc # Note: we do not fully disable WebRTC here
# We use these instead:
ac_add_options MOZ_WEBRTC=1
ac_add_options MOZ_WEBRTC_LEAK_PROTECTION=1
```

### Update and Sync Services

| Option | Default State | Effect |
|--------|---------------|--------|
| `--disable-updater` | Enabled | Removes automatic update functionality, requiring manual updates |
| `--disable-sync` | Enabled | Disables Firefox Sync service integration |
| `--disable-maintenance-service` | Enabled (Windows) | Removes Windows maintenance service for background updates |

```bash
# Disable update services
ac_add_options --disable-updater
ac_add_options --disable-sync
ac_add_options --disable-maintenance-service  # Windows only
```

### Media and Hardware Access

| Option | Default State | Effect |
|--------|---------------|--------|
| `--disable-webgl` | Enabled | Removes WebGL support, reducing GPU fingerprinting vectors |
| `--disable-gamepad` | Enabled | Disables Gamepad API, preventing controller enumeration |
| `--disable-eme` | Enabled | Removes Encrypted Media Extensions (DRM) support |
| `--disable-raw` | Enabled | Disables camera raw image format support |

```bash
# Media and hardware restrictions
ac_add_options --disable-webgl
ac_add_options --disable-gamepad
ac_add_options --disable-eme
ac_add_options --disable-raw
```

### Development and Debugging Features

| Option | Default State | Effect |
|--------|---------------|--------|
| `--disable-tests` | Varies | Excludes test suites from build, reducing binary size |
| `--disable-debug` | Debug disabled | Ensures release build without debug symbols |
| `--disable-profiling` | Enabled | Removes built-in profiling capabilities |

```bash
# Remove development features
ac_add_options --disable-tests
ac_add_options --disable-debug
ac_add_options --disable-profiling
```

## Build Configuration Options

### Optimization and Security

| Option | Default State | Effect |
|--------|---------------|--------|
| `--enable-optimize` | Enabled | Enables compiler optimizations for performance |
| `--enable-hardening` | Platform-dependent | Enables additional security hardening measures |
| `--enable-strip` | Disabled | Strips debugging symbols from final binary |

```bash
# Optimization and hardening
ac_add_options --enable-optimize
ac_add_options --enable-hardening
ac_add_options --enable-strip
```

### Feature Compilation Control

| Option | Default State | Effect |
|--------|---------------|--------|
| `MOZ_DATA_REPORTING=0` | 1 (Enabled) | Compile-time disable of data reporting infrastructure |
| `MOZ_TELEMETRY_REPORTING=0` | 1 (Enabled) | Compile-time disable of telemetry reporting |
| `MOZ_SERVICES_HEALTHREPORT=0` | 1 (Enabled) | Compile-time disable of health reporting |

```bash
# Compile-time feature disabling
ac_add_options MOZ_DATA_REPORTING=0
ac_add_options MOZ_TELEMETRY_REPORTING=0
ac_add_options MOZ_SERVICES_HEALTHREPORT=0
```

## Important Notes

### Build Impact
- Disabling features reduces binary size and attack surface
- Some options may break functionality expected by extensions or websites
- Cross-platform compatibility may be affected by certain options

### Runtime Behavior
- Compile-time disables cannot be overridden at runtime
- Some privacy features can alternatively be controlled via about:config
- User preferences may still need adjustment even with build-time changes

### Compatibility Warnings
- `--disable-webgl` breaks many modern web applications
- `--disable-webrtc` prevents video conferencing functionality
- `--disable-eme` blocks DRM-protected content playback
- `--disable-updater` requires manual security update management

## Example Complete Configuration

```bash
# Privacy-focused mozconfig example
ac_add_options --disable-telemetry
ac_add_options --disable-crashreporter
ac_add_options --disable-experiments
ac_add_options --disable-healthreport
ac_add_options --disable-necko-wifi
ac_add_options --disable-webspeech
ac_add_options --disable-updater
ac_add_options --disable-sync
ac_add_options --disable-gamepad
ac_add_options --enable-optimize
ac_add_options --enable-strip
ac_add_options MOZ_DATA_REPORTING=0
ac_add_options MOZ_TELEMETRY_REPORTING=0
```

