# OOD vs DOD Performance Comparison - Docker Workflow
.PHONY: all build run profile cachegrind shell clean help particle array

IMAGE_NAME = ood-dod-comparison

# Default target
all: run

# Build the Docker image
build:
	@echo "Building Docker image..."
	docker build -t $(IMAGE_NAME) .

# Run both experiments
run: build
	@echo "Running OOD vs DOD comparison..."
	docker run --rm $(IMAGE_NAME)

# Run only particle simulation
particle: build
	@echo "Running Particle Simulation comparison..."
	docker run --rm $(IMAGE_NAME) /bin/bash -c '\
		echo "==========================================" && \
		echo "Running OOD Implementation..." && \
		echo "==========================================" && \
		./particle_ood && \
		echo "" && \
		echo "==========================================" && \
		echo "Running DOD Implementation..." && \
		echo "==========================================" && \
		./particle_dod'

# Run only array processing
array: build
	@echo "Running Array Processing comparison..."
	docker run --rm $(IMAGE_NAME) /bin/bash -c '\
		echo "==========================================" && \
		echo "Running OOD Implementation..." && \
		echo "==========================================" && \
		./array_ood && \
		echo "" && \
		echo "==========================================" && \
		echo "Running DOD Implementation..." && \
		echo "==========================================" && \
		./array_dod'

# Profile with timing (perf often doesn't work in Docker)
profile: build
	@echo "Running performance profiling with timing..."
	@mkdir -p results
	docker run --rm -v "$$(pwd)/results:/results" $(IMAGE_NAME) /bin/bash -c '\
		echo "=== PARTICLE SIMULATION ===" && \
		echo "=== OOD Performance ===" && \
		/usr/bin/time -f "\nElapsed: %E\nCPU: %P\nMax Memory: %M KB" ./particle_ood 2>&1 | tee /results/particle_ood_perf.txt && \
		echo "" && echo "=== DOD Performance ===" && \
		/usr/bin/time -f "\nElapsed: %E\nCPU: %P\nMax Memory: %M KB" ./particle_dod 2>&1 | tee /results/particle_dod_perf.txt && \
		echo "" && echo "" && \
		echo "=== ARRAY PROCESSING ===" && \
		echo "=== OOD Performance ===" && \
		/usr/bin/time -f "\nElapsed: %E\nCPU: %P\nMax Memory: %M KB" ./array_ood 2>&1 | tee /results/array_ood_perf.txt && \
		echo "" && echo "=== DOD Performance ===" && \
		/usr/bin/time -f "\nElapsed: %E\nCPU: %P\nMax Memory: %M KB" ./array_dod 2>&1 | tee /results/array_dod_perf.txt && \
		echo "" && echo "Results saved to ./results/"'
	@echo "View detailed results: cat results/*_perf.txt"

# Profile with valgrind cachegrind
cachegrind: build
	@echo "Running cache profiling with valgrind..."
	@mkdir -p results
	docker run --rm -v "$$(pwd)/results:/results" $(IMAGE_NAME) sh -c '\
		echo "Profiling Particle Simulation..." && \
		valgrind --tool=cachegrind --cachegrind-out-file=/results/particle_ood.out ./particle_ood 2>&1 | tee /results/particle_ood_cachegrind.txt && \
		valgrind --tool=cachegrind --cachegrind-out-file=/results/particle_dod.out ./particle_dod 2>&1 | tee /results/particle_dod_cachegrind.txt && \
		echo "" && echo "Profiling Array Processing..." && \
		valgrind --tool=cachegrind --cachegrind-out-file=/results/array_ood.out ./array_ood 2>&1 | tee /results/array_ood_cachegrind.txt && \
		valgrind --tool=cachegrind --cachegrind-out-file=/results/array_dod.out ./array_dod 2>&1 | tee /results/array_dod_cachegrind.txt && \
		echo "" && echo "=== PARTICLE SIMULATION - OOD Cachegrind Summary ===" && \
		cg_annotate /results/particle_ood.out | head -30 | tee -a /results/particle_ood_cachegrind_summary.txt && \
		echo "" && echo "=== PARTICLE SIMULATION - DOD Cachegrind Summary ===" && \
		cg_annotate /results/particle_dod.out | head -30 | tee -a /results/particle_dod_cachegrind_summary.txt && \
		echo "" && echo "=== ARRAY PROCESSING - OOD Cachegrind Summary ===" && \
		cg_annotate /results/array_ood.out | head -30 | tee -a /results/array_ood_cachegrind_summary.txt && \
		echo "" && echo "=== ARRAY PROCESSING - DOD Cachegrind Summary ===" && \
		cg_annotate /results/array_dod.out | head -30 | tee -a /results/array_dod_cachegrind_summary.txt'
	@echo ""
	@echo "Results saved:"
	@echo "  - Cachegrind data: results/particle_*.out, results/array_*.out"
	@echo "  - Valgrind output: results/*_cachegrind.txt"
	@echo "  - Summaries: results/*_cachegrind_summary.txt"

# Interactive shell
shell: build
	@echo "Starting interactive shell in container..."
	docker run --rm -it --privileged $(IMAGE_NAME) /bin/bash

# View local results
results:
	@if [ -d "results" ]; then \
		echo "=== Perf Results ==="; \
		cat results/*_perf.txt 2>/dev/null || echo "No perf results"; \
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
	@echo "  make run          - Build and run both experiments"
	@echo "  make particle     - Run only particle simulation"
	@echo "  make array        - Run only array processing"
	@echo "  make profile      - CPU profiling with perf (saves to ./results/)"
	@echo "  make cachegrind   - Cache profiling with valgrind (saves to ./results/)"
	@echo "  make shell        - Interactive shell in container"
	@echo "  make results      - View saved profiling results"
	@echo "  make clean        - Remove Docker image and results"
	@echo "  make help         - Show this help message"