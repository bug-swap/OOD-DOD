# OOD vs DOD Performance Comparison

Comparative analysis of Object-Oriented Design (OOD) vs Data-Oriented Design (DOD) through two experimental implementations: a particle simulation and an array processing system. This research demonstrates how memory layout impacts cache performance and execution time.

**Team members:** Pratik Pujari, Pimpisut Puttipongkawin

## Quick Start

```bash
# Run both experiments
make run

# Profile with GNU time
make profile

# Profile with cachegrind
make cachegrind
```

All commands run inside a Docker container with Linux profiling tools.

## Experiments

### Experiment 1: Particle Simulation
- **Size:** 100,000 particles over 1,000 iterations
- **OOD Result:** 243ms execution time
- **DOD Result:** 205ms execution time (18.5% faster)
- **Key Finding:** DOD achieved faster execution despite higher cache miss rates through reduced memory traffic (27.3%) and optimized write operations (88.6% fewer write-backs)

### Experiment 2: Array Processing
- **Size:** 1,000,000 elements over 500 iterations
- **OOD Result:** 1,133ms execution time
- **DOD Result:** 1,098ms execution time (3.1% faster)
- **Key Finding:** Modest speedup in compute-bound workload dominated by transcendental functions, but DOD achieved better cache hit rates (4.2% vs 6.3%) and 7.9% instruction reduction

## Commands

### Run Performance Comparison
```bash
make run
```
Builds the Docker image and runs both experiments, showing execution times for all implementations.

### Run Individual Experiments
```bash
# Particle simulation only
make particle

# Array processing only
make array
```

### CPU Profiling (GNU time)
```bash
make profile
```
- Measures execution time, CPU utilization, and memory usage
- Results saved to `./results/particle_*_perf.txt` and `./results/array_*_perf.txt`
- Displays results in terminal

**Sample Output:**
```
Elapsed: 0:00.24
CPU: 100%
Max Memory: 6328 KB
```

### Cache Profiling (valgrind cachegrind)
```bash
make cachegrind
```
- Detailed cache analysis for both experiments
- Results saved to:
  - `./results/particle_*.out` and `./results/array_*.out` - Cachegrind data files
  - `./results/*_cachegrind.txt` - Full valgrind output
  - `./results/*_cachegrind_summary.txt` - Annotated summaries
- Shows summary in terminal

**Key Metrics:**
- **Ir**: Instruction reads
- **D1mr/D1mw**: L1 data cache misses (read/write)
- **LLmr/LLmw**: Last-level cache misses (read/write)

### Interactive Shell
```bash
make shell
```
Opens a bash shell inside the container for manual exploration and profiling.

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

### Key Findings

#### Memory-Bound vs Compute-Bound
- **Particle Simulation (Memory-Bound):** 18.5% speedup - DOD excels when memory bandwidth is the bottleneck
- **Array Processing (Compute-Bound):** 3.1% speedup - DOD benefits limited when computation dominates

#### Cache Behavior Insights
- **Particle Simulation:** DOD had *higher* cache miss rates (13.0% vs 10.0%) but still ran faster due to:
  - Reduced memory traffic (27.3% fewer operations)
  - Optimized write operations (88.6% fewer write-backs)
  - Effective hardware prefetching
  
- **Array Processing:** DOD achieved *better* cache hit rates (4.2% vs 6.3%) and:
  - 33% reduction in cache misses
  - 7.9% instruction reduction
  - 16.5% fewer write operations

#### Write Performance
Both experiments showed DOD's consistent write optimization advantage, demonstrating that sequential write patterns leverage hardware write-combining buffers more effectively than OOD's scattered writes.

### Viewing Detailed Results

#### Perf Output
```bash
cat results/particle_ood_perf.txt
cat results/particle_dod_perf.txt
cat results/array_ood_perf.txt
cat results/array_dod_perf.txt
```

Look for:
- **Elapsed time**: Total execution time
- **CPU utilization**: Should be near 100%
- **Max Memory**: Memory consumption

#### Cachegrind Output
```bash
# In container shell (make shell):
cg_annotate results/particle_ood.out
cg_annotate results/particle_dod.out
cg_annotate results/array_ood.out
cg_annotate results/array_dod.out
```

Compare:
- **D1 miss rate**: L1 data cache miss percentage
- **LL miss rate**: Last-level cache miss percentage
- **Write-backs**: Number of cache line evictions

## Project Structure

```
.
├── Makefile                    # Docker workflow commands
├── Dockerfile                  # Container with build tools and profilers
├── particle_ood.cpp            # Particle simulation - OOD implementation
├── particle_dod.cpp            # Particle simulation - DOD implementation
├── array_ood.cpp               # Array processing - OOD implementation
├── array_dod.cpp               # Array processing - DOD implementation
├── results/                    # Profiling results (created after running)
└── README.md                   # This file
```

## Implementation Details

### Particle Simulation
- **OOD:** Each particle is an object with 9 float attributes (36 bytes)
  - Array of Structures (AoS) layout
  - Methods: update(), applyGravity()
  
- **DOD:** Nine separate arrays for each attribute
  - Structure of Arrays (SoA) layout
  - Sequential processing of complete arrays

### Array Processing
- **OOD:** Each element is a DataElement object with 3 float attributes (12 bytes)
  - Methods: compute(), scale(), normalize(), getSquared()
  
- **DOD:** Three separate arrays (values, coefficients, results)
  - Sequential processing with compute(), scale(), normalize()

Both implementations use identical algorithms with seed=42 for reproducibility.

## Requirements

- **Docker** (required): All profiling runs in containers
- No other dependencies needed on host

## Paper and Source Code

- **Paper:** See `OOAD_Project_First_Draft.pdf` for detailed analysis
- **Source Code:** https://github.com/bug-swap/OOD-DOD
- **Full Results:** Available in `./results/` after running profiling commands

## How It Works

1. Docker builds a Linux container with `g++`, `valgrind`, and GNU `time`
2. C++ programs are compiled with `-O3` optimization
3. Profiling tools run inside the container
4. Results are mounted to `./results/` on your host machine
5. No need to install profiling tools on your macOS/Windows system!

## Conclusions

This project demonstrates that:
1. **DOD is not universally faster** - benefits depend on workload characteristics
2. **Cache hit rates don't tell the whole story** - memory bandwidth and write optimization matter
3. **Object size matters** - larger structures (36 bytes) benefit more from DOD than smaller ones (12 bytes)
4. **Workload type is critical** - memory-bound applications see 6× greater speedup than compute-bound ones
5. **Write operations are consistently optimized** - DOD's sequential writes leverage hardware buffers effectively

Use profiling to determine if DOD is appropriate for your specific applicat