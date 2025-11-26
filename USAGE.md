# Using Avro Schemas in Other Projects

## Option 1: Git Submodule (Recommended)

Add as a submodule in your project:

```bash
# In your backend/frontend project
git submodule add https://github.com/Rensights/avro-schemas.git schemas/avro
git submodule update --init --recursive
```

Update `pom.xml`:
```xml
<plugin>
    <groupId>org.apache.avro</groupId>
    <artifactId>avro-maven-plugin</artifactId>
    <version>1.11.3</version>
    <executions>
        <execution>
            <phase>generate-sources</phase>
            <goals>
                <goal>schema</goal>
            </goals>
            <configuration>
                <sourceDirectory>${project.basedir}/schemas/avro/schemas</sourceDirectory>
                <outputDirectory>${project.build.directory}/generated-sources/avro</outputDirectory>
            </configuration>
        </execution>
    </executions>
</plugin>
```

## Option 2: Docker Multi-stage Build

In your `Dockerfile`:

```dockerfile
FROM ghcr.io/rensights/avro-schemas:latest AS schemas

FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app
COPY --from=schemas /schemas/schemas /app/schemas/avro
COPY pom.xml .
COPY src ./src
WORKDIR /app/src
RUN mvn clean package -DskipTests
```

## Option 3: Download in CI/CD

In GitHub Actions:

```yaml
- name: Get Avro Schemas
  run: |
    docker pull ghcr.io/rensights/avro-schemas:latest
    docker create --name temp-schemas ghcr.io/rensights/avro-schemas:latest
    docker cp temp-schemas:/schemas/schemas ./schemas/avro
    docker rm temp-schemas
```

## Option 4: Direct Reference (Local Development)

If schemas are in parent directory:

```xml
<sourceDirectory>${project.basedir}/../../schemas/avro</sourceDirectory>
```

## Updating Schemas

When schemas are updated:

**With Submodule:**
```bash
cd schemas/avro
git pull origin main
cd ../..
git add schemas/avro
git commit -m "Update Avro schemas"
```

**With Docker:**
Just rebuild - new image will have latest schemas.

## Versioning

Use specific tags for stability:
- `ghcr.io/rensights/avro-schemas:v1.0.0` - Specific version
- `ghcr.io/rensights/avro-schemas:latest` - Latest from main
- `ghcr.io/rensights/avro-schemas:develop` - Latest from develop

