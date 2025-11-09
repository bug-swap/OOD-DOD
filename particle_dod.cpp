#include 
#include 
#include 
#include 
#include 

using namespace std;

// DOD: Separate arrays for each attribute (Structure of Arrays)
class ParticleSystem {
public:
    vector x, y, z;           // positions
    vector vx, vy, vz;        // velocities
    vector ax, ay, az;        // accelerations
    int count;
    
    ParticleSystem(int n) : count(n) {
        x.resize(n); y.resize(n); z.resize(n);
        vx.resize(n); vy.resize(n); vz.resize(n);
        ax.resize(n); ay.resize(n); az.resize(n);
    }
    
    void update(float dt) {
        // Update velocities - process each array sequentially
        for (int i = 0; i < count; i++) vx[i] += ax[i] * dt;
        for (int i = 0; i < count; i++) vy[i] += ay[i] * dt;
        for (int i = 0; i < count; i++) vz[i] += az[i] * dt;
        
        // Update positions
        for (int i = 0; i < count; i++) x[i] += vx[i] * dt;
        for (int i = 0; i < count; i++) y[i] += vy[i] * dt;
        for (int i = 0; i < count; i++) z[i] += vz[i] * dt;
        
        // Boundaries
        for (int i = 0; i < count; i++) {
            if (x[i] < 0 || x[i] > 100) vx[i] *= -0.9f;
        }
        for (int i = 0; i < count; i++) {
            if (y[i] < 0 || y[i] > 100) vy[i] *= -0.9f;
        }
        for (int i = 0; i < count; i++) {
            if (z[i] < 0 || z[i] > 100) vz[i] *= -0.9f;
        }
    }
    
    void applyGravity() {
        for (int i = 0; i < count; i++) {
            ay[i] = -9.8f;
        }
    }
};

int main() {
    const int NUM_PARTICLES = 100000;
    const int ITERATIONS = 1000;
    const float DT = 0.016f;
    
    cout << "DOD Implementation (Structure of Arrays)\n";
    cout << "Particles: " << NUM_PARTICLES << "\n";
    cout << "Iterations: " << ITERATIONS << "\n\n";
    
    // Initialize particles
    mt19937 rng(42);
    uniform_real_distribution dist(0.0f, 100.0f);
    
    ParticleSystem system(NUM_PARTICLES);
    for (int i = 0; i < NUM_PARTICLES; i++) {
        system.x[i] = dist(rng);
        system.y[i] = dist(rng);
        system.z[i] = dist(rng);
        system.vx[i] = system.vy[i] = system.vz[i] = 0;
        system.ax[i] = system.ay[i] = system.az[i] = 0;
    }
    
    // Benchmark
    auto start = chrono::high_resolution_clock::now();
    
    for (int iter = 0; iter < ITERATIONS; iter++) {
        system.applyGravity();
        system.update(DT);
    }
    
    auto end = chrono::high_resolution_clock::now();
    auto duration = chrono::duration_cast(end - start);
    
    cout << "Total time: " << duration.count() << " ms\n";
    cout << "Time per iteration: " << (duration.count() / (float)ITERATIONS) << " ms\n";
    
    // Prevent optimization
    cout << "First particle position: (" << system.x[0] << ", " 
         << system.y[0] << ", " << system.z[0] << ")\n";
    
    return 0;
}