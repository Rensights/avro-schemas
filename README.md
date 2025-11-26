# Rensights Avro Schemas

This repository contains Avro schemas used across Rensights services.

## Structure

```
avro-schemas/
├── schemas/              # Avro schema files (.avsc)
│   ├── user.avsc
│   ├── subscription.avsc
│   └── ...
├── Dockerfile            # Builds schema registry image
├── .github/
│   └── workflows/
│       └── ci-cd.yml     # CI/CD pipeline
└── README.md
```

## Usage

### As a Git Submodule

Add to your project:
```bash
git submodule add https://github.com/Rensights/avro-schemas.git schemas/avro
```

### As a Docker Image

Pull the pre-built schemas:
```dockerfile
FROM ghcr.io/rensights/avro-schemas:latest
COPY --from=ghcr.io/rensights/avro-schemas:latest /schemas /schemas
```

### In Maven Projects

Reference in `pom.xml`:
```xml
<plugin>
    <groupId>org.apache.avro</groupId>
    <artifactId>avro-maven-plugin</artifactId>
    <configuration>
        <sourceDirectory>${project.basedir}/../avro-schemas/schemas</sourceDirectory>
    </configuration>
</plugin>
```

## Building

The schemas are automatically built and pushed to GHCR on every push.

## Versioning

Schemas are versioned using Git tags. Use semantic versioning:
- `v1.0.0` - Initial release
- `v1.1.0` - New schema added
- `v2.0.0` - Breaking changes

