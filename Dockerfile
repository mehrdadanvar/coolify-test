# ---- Build Stage ----
    FROM oven/bun:1 AS builder

    WORKDIR /app
    
    # Copy manifests
    COPY package.json bun.lockb* ./
    
    # Install dependencies with Bun
    RUN bun install --frozen-lockfile
    
    # Copy all source
    COPY . .
    
    # Build Nuxt (produces .output/)
    RUN bun run build
    
    
    # ---- Runtime Stage ----
    FROM oven/bun:1 AS runner
    
    WORKDIR /app
    
    # Copy only build output + manifests
    COPY --from=builder /app/.output ./.output
    COPY --from=builder /app/package.json bun.lockb* ./
    
    # Install only production dependencies
    RUN bun install --frozen-lockfile --production
    
    # Expose Nuxt port (Coolify will remap)
    EXPOSE 5500
    
    # Run Nitro server with Bun
    CMD ["bun", ".output/server/index.mjs"]
    