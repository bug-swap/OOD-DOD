CXX = g++
CXXFLAGS = -std=c++17 -O3 -Wall

all: particle_ood particle_dod

particle_ood: particle_ood.cpp
	$(CXX) $(CXXFLAGS) -o particle_ood particle_ood.cpp

particle_dod: particle_dod.cpp
	$(CXX) $(CXXFLAGS) -o particle_dod particle_dod.cpp

run: all
	@echo "=========================================="
	@echo "Running OOD Implementation..."
	@echo "=========================================="
	./particle_ood
	@echo ""
	@echo "=========================================="
	@echo "Running DOD Implementation..."
	@echo "=========================================="
	./particle_dod

profile: all
	@mkdir -p results
	@echo "Profiling OOD with perf..."
	perf stat -e cache-references,cache-misses,cycles,instructions ./particle_ood 2> results/ood_perf.txt
	@echo "Profiling DOD with perf..."
	perf stat -e cache-references,cache-misses,cycles,instructions ./particle_dod 2> results/dod_perf.txt
	@echo "Results saved to results/"

cachegrind: all
	@mkdir -p results
	@echo "Running cachegrind on OOD..."
	valgrind --tool=cachegrind --cachegrind-out-file=results/ood.out ./particle_ood
	@echo "Running cachegrind on DOD..."
	valgrind --tool=cachegrind --cachegrind-out-file=results/dod.out ./particle_dod
	@echo "Results saved to results/"

clean:
	rm -f particle_ood particle_dod
	rm -rf results/*.out results/*.txt

.PHONY: all run profile cachegrind clean