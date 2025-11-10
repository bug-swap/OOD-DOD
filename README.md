# OOD vs DOD Performance Comparison

Comparison of Object-Oriented Design (OOD) vs Data-Oriented Design (DOD) for particle simulations, demonstrating cache performance differences.

Team members: Pratik Pujari, Pimpisut Puttipongkawin

## Quick Start

```bash
# Run the comparison
make run

# Profile with perf
make profile

# Profile with cachegrind
make cachegrind
```

All commands run inside a Docker container with Linux profiling tools.

Refer to `./sample_results` for example outputs and interpretation of the profiling runs.

## Commands

### Run Performance Comparison
```bash
make run
```
Builds the Docker image and runs both implementations, showing execution times.

### CPU Profiling (perf)
```bash
make profile
```
- Measures cache misses, cycles, and instructions
- Results saved to `./results/ood_perf.txt` and `./results/dod_perf.txt`
- Displays results in terminal

### Cache Profiling (valgrind cachegrind)
```bash
make cachegrind
```
- Detailed cache analysis
- Results saved to:
  - `./results/ood.out` and `./results/dod.out` - Cachegrind data files
  - `./results/ood_cachegrind.txt` and `./results/dod_cachegrind.txt` - Full valgrind output
  - `./results/ood_cachegrind_summary.txt` and `./results/dod_cachegrind_summary.txt` - Annotated summaries
- Shows summary in terminal

### Interactive Shell
```bash
make shell
```
Opens a bash shell inside the container for manual exploration.

### View Saved Results
```bash
make results
```
Display previously saved profiling results.

### Clean Up
```bash
make clean
```
Removes Docker image and results directory.

### Help
```bash
make help
```
Shows all available commands.

## Understanding Results

### Perf Output
```bash
cat results/ood_perf.txt
cat results/dod_perf.txt
```

Key metrics:
- **cache-misses**: Lower is better (DOD typically has fewer)
- **cache-miss rate**: Percentage of cache accesses that missed
- **cycles**: Total CPU cycles (lower is better)
- **instructions**: Total instructions executed

### Cachegrind Output

View detailed analysis:
```bash
# In container shell (make shell):
cg_annotate results/ood.out
cg_annotate results/dod.out
```

Key metrics:
- **Ir**: Instruction reads
- **D1mr/D1mw**: L1 data cache misses (read/write)
- **LLmr/LLmw**: Last-level cache misses (read/write)

DOD should show significantly fewer cache misses due to better memory locality.

## Requirements

- **Docker** (required): All profiling runs in containers
- No other dependencies needed on host

## Files

- `Makefile` - Docker workflow commands
- `Dockerfile` - Container with build tools and profilers
- `particle_ood.cpp` - Object-Oriented Design implementation
- `particle_dod.cpp` - Data-Oriented Design implementation
- `results/` - Profiling results (created after running profile/cachegrind)

## How It Works

1. Docker builds a Linux container with `g++`, `perf`, and `valgrind`
2. C++ programs are compiled with `-O3` optimization
3. Profiling tools run inside the container
4. Results are mounted to `./results/` on your host machine
5. No need to install profiling tools on your macOS/Windows system!
