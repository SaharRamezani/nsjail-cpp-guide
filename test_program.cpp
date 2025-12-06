#include <iostream>
#include <fstream>
#include <unistd.h>
#include <sys/types.h>

int main() {
    std::cout << "=== NsJail Test Program ===" << std::endl;
    std::cout << "Hello from inside the sandbox!" << std::endl;
    
    // Show current user and process info
    std::cout << "\nProcess Information:" << std::endl;
    std::cout << "  PID: " << getpid() << std::endl;
    std::cout << "  UID: " << getuid() << std::endl;
    std::cout << "  GID: " << getgid() << std::endl;
    
    // Try to read a file (demonstrates filesystem isolation)
    std::cout << "\nFilesystem Test:" << std::endl;
    std::ifstream test_file("/etc/hostname");
    if (test_file.is_open()) {
        std::string content;
        std::getline(test_file, content);
        std::cout << "  Hostname: " << content << std::endl;
        test_file.close();
    } else {
        std::cout << "  Could not read /etc/hostname (isolated)" << std::endl;
    }
    
    // Simple computation
    std::cout << "\nComputation Test:" << std::endl;
    int sum = 0;
    for (int i = 1; i <= 100; i++) {
        sum += i;
    }
    std::cout << "  Sum of 1-100: " << sum << std::endl;
    
    std::cout << "\n=== Program Completed Successfully ===" << std::endl;
    
    return 0;
}
