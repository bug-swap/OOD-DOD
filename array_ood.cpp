#include <iostream>
#include <vector>
#include <chrono>
#include <random>
#include <cmath>

using namespace std;

// OOD: Each element wrapped in an object
class DataElement {
public:
    float value;
    float coefficient;
    float result;
    
    DataElement(float v, float c) 
        : value(v), coefficient(c), result(0.0f) {}
    
    void compute() {
        // Perform arithmetic operations
        result = (value * coefficient) + sqrt(abs(value));
        result = result * 0.5f + sin(value * 0.01f);
    }
    
    void scale(float factor) {
        value *= factor;
    }
    
    void normalize(float max_val) {
        if (max_val > 0) {
            value /= max_val;
        }
    }
    
    float getSquared() const {
        return value * value;
    }
};

int main() {
    const int NUM_ELEMENTS = 1000000;
    const int ITERATIONS = 500;
    
    cout << "OOD Array Processing (Array of Structures)\n";
    cout << "Elements: " << NUM_ELEMENTS << "\n";
    cout << "Iterations: " << ITERATIONS << "\n\n";
    
    // Initialize elements
    mt19937 rng(42);
    uniform_real_distribution<float> dist(1.0f, 100.0f);
    
    vector<DataElement> elements;
    elements.reserve(NUM_ELEMENTS);
    for (int i = 0; i < NUM_ELEMENTS; i++) {
        elements.emplace_back(dist(rng), dist(rng));
    }
    
    // Benchmark
    auto start = chrono::high_resolution_clock::now();
    
    for (int iter = 0; iter < ITERATIONS; iter++) {
        // Phase 1: Compute results
        for (auto& e : elements) {
            e.compute();
        }
        
        // Phase 2: Scale values
        for (auto& e : elements) {
            e.scale(0.99f);
        }
        
        // Phase 3: Find max for normalization
        float max_val = 0.0f;
        for (auto& e : elements) {
            float squared = e.getSquared();
            if (squared > max_val) max_val = squared;
        }
        
        // Phase 4: Normalize
        for (auto& e : elements) {
            e.normalize(sqrt(max_val));
        }
    }
    
    auto end = chrono::high_resolution_clock::now();
    auto duration = chrono::duration_cast<chrono::milliseconds>(end - start);
    
    cout << "Total time: " << duration.count() << " ms\n";
    cout << "Time per iteration: " << (duration.count() / (float)ITERATIONS) << " ms\n";
    
    // Prevent optimization
    cout << "First element result: " << elements[0].result << "\n";
    cout << "First element value: " << elements[0].value << "\n";
    
    return 0;
}