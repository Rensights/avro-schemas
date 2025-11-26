FROM alpine:latest

# Install avro-tools for schema validation
RUN apk add --no-cache openjdk17-jre curl && \
    curl -L https://downloads.apache.org/avro/avro-1.11.3/java/avro-tools-1.11.3.jar -o /usr/local/bin/avro-tools.jar

WORKDIR /schemas

# Copy schema files
COPY schemas/ ./schemas/

# Validate schemas (if any exist)
RUN if [ -n "$(ls -A schemas/*.avsc 2>/dev/null)" ]; then \
      java -jar /usr/local/bin/avro-tools.jar compile schema schemas/*.avsc /tmp/validate && \
      echo "✅ All schemas validated successfully"; \
    else \
      echo "⚠️  No .avsc files found - skipping validation"; \
    fi

# Keep schemas accessible
VOLUME ["/schemas"]

CMD ["sh", "-c", "echo 'Avro schemas available at /schemas' && ls -la /schemas && sleep infinity"]

