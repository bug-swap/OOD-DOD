# OOD vs DOD Performance Comparison - Docker Workflow
.PHONY: all build run profile cachegrind shell clean help

IMAGE_NAME = ood-dod-comparison

# Default target
all: run

# Build the Docker image
build:
	@echo "Building Docker image..."
	docker build -t $(IMAGE_NAME) .

# Run the comparison
run: build
	@echo "Running OOD vs DOD comparison..."
	docker run --rm $(IMAGE_NAME)

# Profile with timing (perf often doesn't work in Docker)
profile: build
	@echo "Running performance profiling with timing..."
	@mkdir -p results
	docker run --rm -v "$$(pwd)/results:/results" $(IMAGE_NAME) /bin/bash -c '\
		echo "=== OOD Performance ===" && \
		/usr/bin/time -f "\nElapsed: %E\nCPU: %P\nMax Memory: %M KB" ./particle_ood 2>&1 | tee /results/ood_perf.txt && \
		echo "" && echo "=== DOD Performance ===" && \
		/usr/bin/time -f "\nElapsed: %E\nCPU: %P\nMax Memory: %M KB" ./particle_dod 2>&1 | tee /results/dod_perf.txt && \
		echo "" && echo "Results saved to ./results/"'
	@echo "View detailed results: cat results/ood_perf.txt results/dod_perf.txt"

# Profile with valgrind cachegrind
cachegrind: build
	@echo "Running cache profiling with valgrind..."
	@mkdir -p results
	docker run --rm -v "$$(pwd)/results:/results" $(IMAGE_NAME) sh -c '\
		valgrind --tool=cachegrind --cachegrind-out-file=/results/ood.out ./particle_ood 2>&1 | tee /results/ood_cachegrind.txt && \
		valgrind --tool=cachegrind --cachegrind-out-file=/results/dod.out ./particle_dod 2>&1 | tee /results/dod_cachegrind.txt && \
		echo "" && echo "=== OOD Cachegrind Summary ===" && \
		cg_annotate /results/ood.out | head -30 | tee -a /results/ood_cachegrind_summary.txt && \
		echo "" && echo "=== DOD Cachegrind Summary ===" && \
		cg_annotate /results/dod.out | head -30 | tee -a /results/dod_cachegrind_summary.txt'
	@echo ""
	@echo "Results saved:"
	@echo "  - Cachegrind data: results/ood.out, results/dod.out"
	@echo "  - Valgrind output: results/ood_cachegrind.txt, results/dod_cachegrind.txt"
	@echo "  - Summaries: results/ood_cachegrind_summary.txt, results/dod_cachegrind_summary.txt"

# Interactive shell
shell: build
	@echo "Starting interactive shell in container..."
	docker run --rm -it --privileged $(IMAGE_NAME) /bin/bash

# View local results
results:
	@if [ -d "results" ]; then \
		echo "=== Perf Results ==="; \
		cat results/*.txt 2>/dev/null || echo "No perf results"; \
		echo ""; \
		echo "=== Cachegrind Files ==="; \
		ls -lh results/*.out 2>/dev/null || echo "No cachegrind results"; \
	else \
		echo "No results directory. Run 'make profile' or 'make cachegrind' first."; \
	fi

# Clean up
clean:
	@echo "Removing Docker image and local results..."
	docker rmi $(IMAGE_NAME) 2>/dev/null || true
	rm -rf results

# Help
help:
	@echo "OOD vs DOD Performance Comparison"
	@echo ""
	@echo "Usage:"
	@echo "  make run          - Build and run performance comparison"
	@echo "  make profile      - CPU profiling with perf (saves to ./results/)"
	@echo "  make cachegrind   - Cache profiling with valgrind (saves to ./results/)"
	@echo "  make shell        - Interactive shell in container"
	@echo "  make results      - View saved profiling results"
	@echo "  make clean        - Remove Docker image and results"
	@echo "  make help         - Show this help message"
