#include <iostream>
#include <vector>
#include <chrono>
#include <random>
#include <cmath>

using namespace std;

// OOD: Each particle is an object with all its data together
class Particle {
public:
    float x, y, z;           // position
    float vx, vy, vz;        // velocity
    float ax, ay, az;        // acceleration
    
    Particle(float px, float py, float pz) 
        : x(px), y(py), z(pz), vx(0), vy(0), vz(0), ax(0), ay(0), az(0) {}
    
    void update(float dt) {
        // Update velocity
        vx += ax * dt;
        vy += ay * dt;
        vz += az * dt;
        
        // Update position
        x += vx * dt;
        y += vy * dt;
        z += vz * dt;
        
        // Simple boundary
        if (x < 0 || x > 100) vx *= -0.9f;
        if (y < 0 || y > 100) vy *= -0.9f;
        if (z < 0 || z > 100) vz *= -0.9f;
    }
    
    void applyGravity() {
        ay = -9.8f;
    }
};

int main() {
    const int NUM_PARTICLES = 100000;
    const int ITERATIONS = 1000;
    const float DT = 0.016f;
    
    cout << "OOD Implementation (Array of Structures)\n";
    cout << "Particles: " << NUM_PARTICLES << "\n";
    cout << "Iterations: " << ITERATIONS << "\n\n";
    
    // Initialize particles
    mt19937 rng(42);
    uniform_real_distribution<float> dist(0.0f, 100.0f);
    
    vector<Particle> particles;
    particles.reserve(NUM_PARTICLES);
    for (int i = 0; i < NUM_PARTICLES; i++) {
        particles.emplace_back(dist(rng), dist(rng), dist(rng));
    }
    
    // Benchmark
    auto start = chrono::high_resolution_clock::now();
    
    for (int iter = 0; iter < ITERATIONS; iter++) {
        // Apply forces
        for (auto& p : particles) {
            p.applyGravity();
        }
        
        // Update all particles
        for (auto& p : particles) {
            p.update(DT);
        }
    }
    
    auto end = chrono::high_resolution_clock::now();
    auto duration = chrono::duration_cast<chrono::milliseconds>(end - start);
    
    cout << "Total time: " << duration.count() << " ms\n";
    cout << "Time per iteration: " << (duration.count() / (float)ITERATIONS) << " ms\n";
    
    // Prevent optimization
    cout << "First particle position: (" << particles[0].x << ", " 
         << particles[0].y << ", " << particles[0].z << ")\n";
    
    return 0;
}