#include <iostream>
#include <vector>
#include <chrono>
#include <random>
#include <cmath>

using namespace std;

// DOD: Separate arrays for each attribute (Structure of Arrays)
class DataSystem {
public:
    vector<float> values;
    vector<float> coefficients;
    vector<float> results;
    int count;
    
    DataSystem(int n) : count(n) {
        values.resize(n);
        coefficients.resize(n);
        results.resize(n);
    }
    
    void compute() {
        // Process entire arrays sequentially
        for (int i = 0; i < count; i++) {
            results[i] = (values[i] * coefficients[i]) + sqrt(abs(values[i]));
        }
        for (int i = 0; i < count; i++) {
            results[i] = results[i] * 0.5f + sin(values[i] * 0.01f);
        }
    }
    
    void scale(float factor) {
        for (int i = 0; i < count; i++) {
            values[i] *= factor;
        }
    }
    
    float findMaxSquared() {
        float max_val = 0.0f;
        for (int i = 0; i < count; i++) {
            float squared = values[i] * values[i];
            if (squared > max_val) max_val = squared;
        }
        return max_val;
    }
    
    void normalize(float max_val) {
        if (max_val > 0) {
            float divisor = sqrt(max_val);
            for (int i = 0; i < count; i++) {
                values[i] /= divisor;
            }
        }
    }
};

int main() {
    const int NUM_ELEMENTS = 1000000;
    const int ITERATIONS = 500;
    
    cout << "DOD Array Processing (Structure of Arrays)\n";
    cout << "Elements: " << NUM_ELEMENTS << "\n";
    cout << "Iterations: " << ITERATIONS << "\n\n";
    
    // Initialize elements
    mt19937 rng(42);
    uniform_real_distribution<float> dist(1.0f, 100.0f);
    
    DataSystem system(NUM_ELEMENTS);
    for (int i = 0; i < NUM_ELEMENTS; i++) {
        system.values[i] = dist(rng);
        system.coefficients[i] = dist(rng);
        system.results[i] = 0.0f;
    }
    
    // Benchmark
    auto start = chrono::high_resolution_clock::now();
    
    for (int iter = 0; iter < ITERATIONS; iter++) {
        // Phase 1: Compute results
        system.compute();
        
        // Phase 2: Scale values
        system.scale(0.99f);
        
        // Phase 3: Find max for normalization
        float max_val = system.findMaxSquared();
        
        // Phase 4: Normalize
        system.normalize(max_val);
    }
    
    auto end = chrono::high_resolution_clock::now();
    auto duration = chrono::duration_cast<chrono::milliseconds>(end - start);
    
    cout << "Total time: " << duration.count() << " ms\n";
    cout << "Time per iteration: " << (duration.count() / (float)ITERATIONS) << " ms\n";
    
    // Prevent optimization
    cout << "First element result: " << system.results[0] << "\n";
    cout << "First element value: " << system.values[0] << "\n";
    
    return 0;
}