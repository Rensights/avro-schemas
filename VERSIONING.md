# Versioning Guide

This repository uses **Semantic Versioning** (SemVer) for releases. The CI/CD pipeline automatically builds and tags Docker images based on git tags.

## How Versioning Works

### Automatic Image Tags

The CI/CD pipeline creates Docker images with the following tags:

1. **Git Tags** (e.g., `v1.0.0`) → Image: `ghcr.io/rensights/avro-schemas:v1.0.0`
2. **Main Branch** → Image: `ghcr.io/rensights/avro-schemas:latest`
3. **Develop Branch** → Image: `ghcr.io/rensights/avro-schemas:develop`
4. **Commit SHA** → Image: `ghcr.io/rensights/avro-schemas:sha-abc1234`

### Semantic Versioning Format

Use the format: `vMAJOR.MINOR.PATCH`

- **MAJOR** (v1.0.0): Breaking changes to schemas
- **MINOR** (v1.1.0): New schemas or non-breaking additions
- **PATCH** (v1.0.1): Bug fixes, documentation updates

## Creating a Release

### Step 1: Update Schemas

Make your changes to the `.avsc` files in the `schemas/` directory.

### Step 2: Commit and Push

```bash
git add schemas/
git commit -m "Add new User schema fields"
git push origin develop
```

### Step 3: Create a Git Tag

```bash
# For a new major version (breaking changes)
git tag v2.0.0

# For a new minor version (new features)
git tag v1.1.0

# For a patch version (bug fixes)
git tag v1.0.1
```

### Step 4: Push the Tag

```bash
# Push single tag
git push origin v1.0.1

# Or push all tags
git push origin --tags
```

### Step 5: CI/CD Builds Automatically

Once you push the tag, GitHub Actions will:
1. ✅ Validate all schemas
2. ✅ Build Docker image
3. ✅ Tag as `v1.0.1` and `sha-<commit>`
4. ✅ Push to GHCR

## Using Versioned Images

### In Docker

```dockerfile
# Use specific version (recommended for production)
FROM ghcr.io/rensights/avro-schemas:v1.0.1

# Use latest (for development)
FROM ghcr.io/rensights/avro-schemas:latest

# Use develop (for testing)
FROM ghcr.io/rensights/avro-schemas:develop
```

### In Kubernetes

```yaml
apiVersion: v1
kind: Pod
spec:
  initContainers:
    - name: copy-schemas
      image: ghcr.io/rensights/avro-schemas:v1.0.1
      command: ["sh", "-c", "cp -r /schemas /shared"]
      volumeMounts:
        - name: schemas
          mountPath: /shared
```

### In Multi-Stage Builds

```dockerfile
# Stage 1: Copy schemas
FROM ghcr.io/rensights/avro-schemas:v1.0.1 AS schemas

# Stage 2: Use schemas in your app
FROM your-app-base
COPY --from=schemas /schemas /app/schemas
```

## Versioning Best Practices

### ✅ DO

- Use semantic versioning (`v1.0.0`, `v1.1.0`, `v2.0.0`)
- Tag releases after merging to `main`
- Document breaking changes in release notes
- Keep `latest` pointing to the most recent stable release

### ❌ DON'T

- Don't use `latest` in production (use specific versions)
- Don't delete tags (they're permanent)
- Don't skip version numbers (v1.0.0 → v1.0.2 is OK, but v1.0.0 → v1.0.5 is confusing)

## Example Workflow

```bash
# 1. Make changes to schemas
vim schemas/User.avsc

# 2. Commit
git add schemas/User.avsc
git commit -m "Add email field to User schema"
git push origin develop

# 3. Test in develop
# ... test your changes ...

# 4. Merge to main
git checkout main
git merge develop
git push origin main

# 5. Create release tag
git tag v1.1.0
git push origin v1.1.0

# 6. CI/CD automatically builds and pushes:
#    - ghcr.io/rensights/avro-schemas:v1.1.0
#    - ghcr.io/rensights/avro-schemas:latest
#    - ghcr.io/rensights/avro-schemas:sha-<commit>
```

## Checking Available Versions

### List Git Tags

```bash
git tag -l
# v1.0.0
# v1.0.1
# v1.1.0
```

### List Docker Tags (via GHCR)

Visit: https://github.com/Rensights/avro-schemas/pkgs/container/avro-schemas

Or use GitHub CLI:

```bash
gh api repos/Rensights/avro-schemas/packages/container/avro-schemas/versions
```

## Migration Between Versions

When upgrading between major versions:

1. Check release notes for breaking changes
2. Update your code to match new schema structure
3. Test thoroughly
4. Update your Dockerfile/Helm charts to use the new version
5. Deploy and verify

## Questions?

- See `README.md` for general usage
- See `USAGE.md` for integration examples
- Check GitHub Actions logs for build status

