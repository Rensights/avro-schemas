# Push Avro Schemas to GitHub

## Step 1: Create GitHub Repository

1. Go to: https://github.com/new
2. Repository name: `avro-schemas`
3. Owner: `Rensights`
4. Description: "Avro schema definitions for Rensights platform"
5. Visibility: Public or Private (your choice)
6. **Do NOT** initialize with README, .gitignore, or license
7. Click "Create repository"

## Step 2: Push Code

```bash
cd services/avro-schemas

# Add remote (if not already added)
git remote add origin https://github.com/Rensights/avro-schemas.git

# Push main branch
git push -u origin main

# Create and push develop branch
git checkout -b develop
git push -u origin develop
```

## Step 3: Configure GitHub Secret

1. Go to: https://github.com/Rensights/avro-schemas/settings/secrets/actions
2. Add secret: `CONTAINER_TOKEN`
   - Value: Your GitHub Personal Access Token with `write:packages` permission

## Step 4: Verify CI/CD

After pushing, check:
- https://github.com/Rensights/avro-schemas/actions

The workflow will:
1. ✅ Validate all .avsc schemas
2. ✅ Build Docker image
3. ✅ Push to GHCR: `ghcr.io/rensights/avro-schemas`

## Image Tags

- `latest` - from main branch
- `develop` - from develop branch  
- `v1.0.0` - from git tags
- `sha-abc123` - from commit SHA

## Usage

Once pushed, other projects can use:

```dockerfile
FROM ghcr.io/rensights/avro-schemas:latest AS schemas
COPY --from=schemas /schemas/schemas /app/schemas/avro
```

Or as Git submodule:
```bash
git submodule add https://github.com/Rensights/avro-schemas.git schemas/avro
```

