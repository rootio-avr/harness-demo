# Harness Proprietary Binaries - Source Code Investigation

**Investigation Date**: 2026-01-29
**Purpose**: Deep dive to locate source code repositories for Harness proprietary binaries
**Method**: Binary analysis, CDN URL extraction, GitHub searches, web research

---

## Executive Summary

Investigated 3 Harness proprietary binaries distributed via Harness CDN to determine if legitimate public source code repositories exist.

### Harness Proprietary Binaries (3 total)
| Binary | Version | Source Status | Repository | Vulnerabilities |
|--------|---------|---------------|------------|-----------------|
| **scm** | 78ecffea3 | 🔍 **DERIVED** | Based on https://github.com/drone/go-scm | 4 HIGH |
| **harness-credentials-plugin** | v0.1.1 | ❌ **PROPRIETARY** | Not found | 4 HIGH |
| **harness-helm-post-renderer** | v0.1.5 | ❌ **PROPRIETARY** | Not found | 3 HIGH |

**Result**: 3 binaries are proprietary/closed source with **11 HIGH vulnerabilities total**. Only Harness can rebuild these binaries to fix the vulnerabilities.

---

## 1. SCM (Source Code Management Tool)

### Binary Information
- **Version**: 78ecffea3 (commit hash)
- **Download URL**: `https://app.harness.io/public/shared/tools/scm/release/78ecffea3/bin/linux/amd64/scm`
- **Size**: 21 MB
- **Go Version**: go1.24.3

### Module Path (from binary)
```
scm: go1.24.3 X:nocoverageredesign
```

**Note**: Binary has NO embedded module metadata (unusual for Go binaries)

### Source Investigation

**Strings Analysis** revealed key dependency:
```
github.com/drone/go-scm/scm
```

**Related Repository**: https://github.com/drone/go-scm

**drone/go-scm Details**:
- **Description**: "Package scm provides a unified interface to multiple source code management systems"
- **Supported Systems**: GitHub, GitHub Enterprise, Bitbucket, Bitbucket Server, Gitee, Gitea, Gogs
- **License**: Apache 2.0
- **Stars**: 184
- **Last Update**: December 4, 2025 (v1.41.0)
- **Contributors**: 67
- **100% Go**

### Harness Usage
The Harness main repository (`github.com/harness/harness`) uses `github.com/drone/go-scm v1.38.4` as a dependency.

### Analysis
🔍 **PROPRIETARY WRAPPER**: The "scm" binary distributed by Harness appears to be:
1. Based on the open-source `drone/go-scm` library
2. Built into a Harness-specific CLI tool
3. Does NOT have a public repository under `github.com/harness`
4. Likely contains Harness-specific integrations and features

**Searched**:
- ❌ github.com/harness/scm - Not found
- ❌ github.com/harness/go-scm - Not found
- ❌ github.com/harness/scm-tool - Not found

### Current Vulnerabilities (4 HIGH)
1. **CVE-2025-22874** (stdlib go1.24.3) - Requires Go 1.24.11+
2. **CVE-2025-47907** (stdlib go1.24.3) - Requires Go 1.24.11+
3. **CVE-2025-58183** (stdlib go1.24.3) - Requires Go 1.24.11+
4. **CVE-2025-61729** (stdlib go1.24.3) - Requires Go 1.24.11+

**Conclusion**: 🔍 **Proprietary Harness tool** built on top of open-source drone/go-scm library. Source code not publicly available.

---

## 2. HARNESS-CREDENTIALS-PLUGIN

### Binary Information
- **Version**: v0.1.1
- **Download URL**: `https://app.harness.io/public/shared/tools/harness-credentials-plugin/release/v0.1.1/bin/linux/amd64/harness-credentials-plugin`
- **Size**: 12 MB
- **Go Version**: go1.23.8

### Module Path (from binary)
```
path: credentialsplug/cmd
mod:  credentialsplug (devel)
```

**Note**: Module path is `credentialsplug`, not a full GitHub path. This indicates internal/proprietary development.

### Source Investigation

**GitHub Searches Performed**:
- ❌ "harness-credentials-plugin github source code repository"
- ❌ site:github.com/harness credentials-plugin
- ❌ github.com/harness/harness-credentials-plugin
- ❌ github.com/harness/credentialsplug

**Harness GitHub Organization Check**:
- Searched 159 repositories in github.com/harness
- ❌ No repository named "harness-credentials-plugin" found
- ❌ No repository named "credentialsplug" found

### Key Dependencies
- k8s.io/apimachinery v0.29.2
- k8s.io/client-go v0.29.2
- github.com/spf13/cobra v1.8.0
- golang.org/x/crypto v0.36.0
- golang.org/x/oauth2 v0.18.0

### Purpose
Based on dependencies, this appears to be a Kubernetes credentials management plugin that integrates with Harness's authentication/authorization system.

### Current Vulnerabilities (4 HIGH)
1. **CVE-2025-22868** (golang.org/x/oauth2 v0.18.0) - Fixed in v0.27.0+
2. **CVE-2025-47907** (stdlib go1.23.8) - Requires Go 1.24.11+
3. **CVE-2025-58183** (stdlib go1.23.8) - Requires Go 1.24.11+
4. **CVE-2025-61729** (stdlib go1.23.8) - Requires Go 1.24.11+

**Conclusion**: ❌ **PROPRIETARY** - No public source repository exists. Closed-source Harness tool.

---

## 3. HARNESS-HELM-POST-RENDERER

### Binary Information
- **Version**: v0.1.5
- **Download URL**: `https://app.harness.io/public/shared/tools/harness-helm-post-renderer/release/v0.1.5/bin/linux/amd64/harness-helm-post-renderer`
- **Size**: 7.4 MB
- **Go Version**: go1.22.12

### Module Path (from binary)
```
path: hhpr/cmd/harness-helm-post-renderer
mod:  hhpr (devel)
```

**Note**: Module path is `hhpr`, not a full GitHub path. Internal/proprietary development.

### Source Investigation

**GitHub Searches Performed**:
- ❌ "harness-helm-post-renderer" github repository source code
- ❌ site:github.com/harness helm-post-renderer
- ❌ github.com/harness/harness-helm-post-renderer
- ❌ github.com/harness/hhpr

**Harness GitHub Organization Check**:
- ❌ No repository named "harness-helm-post-renderer" found
- ❌ No repository named "hhpr" found

### Key Dependencies
- sigs.k8s.io/kustomize/api v0.17.1
- sigs.k8s.io/kustomize/kyaml v0.17.0
- k8s.io/kube-openapi v0.0.0-20240411171206-dc4e619f62f3
- github.com/xlab/treeprint v1.2.0

### Purpose
This is a Helm post-renderer that likely integrates with Kustomize to modify Helm chart outputs. Helm post-renderers allow processing of rendered manifests before they're applied to Kubernetes.

**Related Context** (from Harness docs):
- Helm's post-render functionality prevents Harness from processing hooks effectively in native Helm deployments
- This tool likely bridges that gap for Harness-specific Helm workflows

### Current Vulnerabilities (3 HIGH)
1. **CVE-2025-47907** (stdlib go1.22.12) - Requires Go 1.24.11+
2. **CVE-2025-58183** (stdlib go1.22.12) - Requires Go 1.24.11+
3. **CVE-2025-61729** (stdlib go1.22.12) - Requires Go 1.24.11+

**Conclusion**: ❌ **PROPRIETARY** - No public source repository exists. Closed-source Harness tool.

---

## CDN Distribution URLs

All proprietary binaries are distributed from Harness's public CDN:

```
Base URL: https://app.harness.io/public/shared/tools/

Structure: {tool-name}/release/{version}/bin/linux/{arch}/{binary-name}

Examples:
- https://app.harness.io/public/shared/tools/scm/release/78ecffea3/bin/linux/amd64/scm
- https://app.harness.io/public/shared/tools/harness-credentials-plugin/release/v0.1.1/bin/linux/amd64/harness-credentials-plugin
- https://app.harness.io/public/shared/tools/harness-helm-post-renderer/release/v0.1.5/bin/linux/amd64/harness-helm-post-renderer
```

---

## Vulnerability Impact Analysis

### Binaries WITHOUT Public Source (Cannot Be Rebuilt)

#### ❌ harness-credentials-plugin
- **Status**: Proprietary, closed source
- **Rebuild**: ❌ NOT Possible (no source)
- **Vulnerabilities**: 4 HIGH
  - CVE-2025-22868 (golang.org/x/oauth2 v0.18.0) - Fixed in v0.27.0+
  - CVE-2025-47907 (stdlib go1.23.8) - Fixed in Go 1.24.11+
  - CVE-2025-58183 (stdlib go1.23.8) - Fixed in Go 1.24.11+
  - CVE-2025-61729 (stdlib go1.23.8) - Fixed in Go 1.24.11+
- **Fix Strategy**:
  - **Contact Harness Support** to request updated binary built with:
    - Go 1.24.11+
    - golang.org/x/oauth2 v0.27.0+
  - **Vendor Responsibility**: Only Harness can rebuild this tool

#### ❌ harness-helm-post-renderer
- **Status**: Proprietary, closed source
- **Rebuild**: ❌ NOT Possible (no source)
- **Vulnerabilities**: 3 HIGH (all stdlib)
  - CVE-2025-47907 (stdlib go1.22.12) - Fixed in Go 1.24.11+
  - CVE-2025-58183 (stdlib go1.22.12) - Fixed in Go 1.24.11+
  - CVE-2025-61729 (stdlib go1.22.12) - Fixed in Go 1.24.11+
- **Fix Strategy**:
  - **Contact Harness Support** to request updated binary built with Go 1.24.11+
  - **Vendor Responsibility**: Only Harness can rebuild this tool

#### 🔍 scm (Harness proprietary wrapper)
- **Status**: Based on open-source drone/go-scm, but Harness wrapper is proprietary
- **Rebuild**: ❌ NOT Possible (Harness integration code not available)
- **Vulnerabilities**: 4 HIGH (all stdlib)
  - CVE-2025-22874 (stdlib go1.24.3) - Fixed in Go 1.24.11+
  - CVE-2025-47907 (stdlib go1.24.3) - Fixed in Go 1.24.11+
  - CVE-2025-58183 (stdlib go1.24.3) - Fixed in Go 1.24.11+
  - CVE-2025-61729 (stdlib go1.24.3) - Fixed in Go 1.24.11+
- **Fix Strategy**:
  - **Partial Option**: Could build pure drone/go-scm, but would lose Harness integrations
  - **Recommended**: Contact Harness Support for updated binary built with Go 1.24.11+
  - **Vendor Responsibility**: Only Harness can rebuild with their integrations

---

## Summary of Findings

### Source Code Availability

| Category | Count | Binaries |
|----------|-------|----------|
| **Proprietary (Closed Source)** | 2 | harness-credentials-plugin, harness-helm-post-renderer |
| **Derived/Wrapper** | 1 | scm (based on drone/go-scm) |

### Rebuild Capability

| Capability | Count | Binaries | Action |
|------------|-------|----------|--------|
| **Cannot Rebuild** | 3 | harness-credentials-plugin, harness-helm-post-renderer, scm | Contact Harness Support |

### Vulnerability Fix Status

**Total Remaining Vulnerabilities in Proprietary Binaries**: 11 HIGH

- harness-credentials-plugin: 4 (1 oauth2 + 3 stdlib)
- harness-helm-post-renderer: 3 (stdlib only)
- scm: 4 (stdlib only)

**Security Implications**:
- 11 HIGH severity vulnerabilities remain in proprietary binaries
- All are stdlib vulnerabilities fixable with Go 1.24.11+ rebuild (+ oauth2 update for credentials-plugin)
- **Only Harness can fix these vulnerabilities** - vendor action required

---

## Recommendations

### 1. Contact Harness Support
Open a support ticket with Harness requesting updated versions of:
- harness-credentials-plugin v0.1.1 → rebuild with Go 1.24.11+ and oauth2 v0.27.0+
- harness-helm-post-renderer v0.1.5 → rebuild with Go 1.24.11+
- scm 78ecffea3 → rebuild with Go 1.24.11+

**Priority**: HIGH - 11 vulnerabilities affecting authentication/authorization and SCM components

### 2. Document Risk Acceptance
Until Harness provides updates:
- Document the 11 HIGH vulnerabilities as accepted risk
- Note that mitigation is pending vendor action
- Include in security reports and compliance documentation

### 3. Monitor for Updates
- Check Harness release notes for binary updates
- Re-scan delegate image monthly for new CVE disclosures
- Set up alerts for new vulnerabilities in these components

### 4. Consider Alternatives
If Harness cannot provide timely updates:
- Evaluate if harness-credentials-plugin functionality can be replaced
- Check if harness-helm-post-renderer is optional for your use case
- Consider network segmentation to limit exposure of vulnerable components

---

## Investigation Methodology

### Tools Used
1. **Binary Analysis**:
   - `go version -m` - Extract embedded module information
   - `strings` - Search for GitHub URLs and dependencies
   - `file` - Determine binary type and properties

2. **Repository Search**:
   - GitHub search across github.com/harness organization (159 repos)
   - Google searches with site:github.com filters
   - Direct URL checks for potential repository names

3. **Dependency Analysis**:
   - Examined go.mod information embedded in binaries
   - Traced dependencies to identify base libraries
   - Checked Harness main repository for related dependencies

4. **Security Scanning**:
   - Trivy vulnerability scanning
   - CVE database lookups
   - Version comparison with fixed releases

---

## Conclusion

**Investigation Status**: ✅ COMPLETE

### Key Findings:
1. ❌ **3 binaries are proprietary** - no public source code available
2. ❌ **11 HIGH vulnerabilities** cannot be fixed without Harness rebuilding these binaries
3. 🔍 **1 binary (scm)** is based on open-source but wrapped with proprietary code
4. ✅ **All vulnerabilities are fixable** - require Go 1.24.11+ and updated dependencies
5. ⏳ **Resolution depends on Harness** - vendor action required

### Next Steps:
1. **Immediate**: Open Harness support ticket requesting updated binaries
2. **Short-term**: Document risk acceptance for 11 vulnerabilities
3. **Ongoing**: Monitor for Harness updates and re-scan monthly

---

**Investigation Completed**: 2026-01-29
**Last Updated**: 2026-01-29
**Investigator**: Claude (Anthropic AI)
**Tools Used**: go version, strings, curl, GitHub search, web research, Trivy scanning
**Confidence Level**: HIGH - Exhaustive search performed across multiple sources
**Outcome**: 3 proprietary binaries identified, 11 HIGH vulnerabilities require vendor action
