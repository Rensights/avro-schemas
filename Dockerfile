FROM alpine:latest

# Install avro-tools for schema validation
RUN apk add --no-cache openjdk17-jre curl && \
    AVRO_VERSION="1.11.3" && \
    echo "Downloading Avro Tools ${AVRO_VERSION}..." && \
    # Try Maven Central first (more reliable) \
    curl -L --fail --retry 3 --retry-delay 5 \
      "https://repo1.maven.org/maven2/org/apache/avro/avro-tools/${AVRO_VERSION}/avro-tools-${AVRO_VERSION}.jar" \
      -o /usr/local/bin/avro-tools.jar || \
    # Fallback to Apache mirror \
    (echo "Maven Central failed, trying Apache mirror..." && \
     curl -L --fail --retry 3 --retry-delay 5 \
       "https://downloads.apache.org/avro/avro-${AVRO_VERSION}/java/avro-tools-${AVRO_VERSION}.jar" \
       -o /usr/local/bin/avro-tools.jar) && \
    # Verify file exists and has reasonable size \
    if [ ! -f /usr/local/bin/avro-tools.jar ]; then \
      echo "❌ Error: avro-tools.jar not found after download"; \
      exit 1; \
    fi && \
    FILE_SIZE=$(stat -c%s /usr/local/bin/avro-tools.jar 2>/dev/null || echo "0") && \
    if [ "$FILE_SIZE" -lt 1000000 ]; then \
      echo "❌ Error: avro-tools.jar too small (${FILE_SIZE} bytes)"; \
      exit 1; \
    fi && \
    # Test that JAR is valid by checking it can be executed \
    java -jar /usr/local/bin/avro-tools.jar 2>&1 | head -1 | grep -q "Avro" || echo "⚠️  Warning: Could not verify JAR, but continuing..." && \
    chmod +x /usr/local/bin/avro-tools.jar && \
    echo "✅ Avro Tools downloaded successfully ($(du -h /usr/local/bin/avro-tools.jar | cut -f1))"

WORKDIR /schemas

# Copy schema files
COPY schemas/ ./schemas/

# Validate schemas (if any exist)
RUN if [ -n "$(ls -A schemas/*.avsc 2>/dev/null)" ]; then \
      echo "Validating Avro schemas..." && \
      mkdir -p /tmp/validate && \
      for schema in schemas/*.avsc; do \
        echo "Validating $(basename $schema)..." && \
        java -jar /usr/local/bin/avro-tools.jar compile schema "$schema" /tmp/validate || { \
          echo "❌ Error: Validation failed for $(basename $schema)"; \
          exit 1; \
        }; \
      done && \
      echo "✅ All schemas validated successfully"; \
    else \
      echo "⚠️  No .avsc files found - skipping validation"; \
    fi

# Keep schemas accessible
VOLUME ["/schemas"]

CMD ["sh", "-c", "echo 'Avro schemas available at /schemas' && ls -la /schemas && sleep infinity"]

