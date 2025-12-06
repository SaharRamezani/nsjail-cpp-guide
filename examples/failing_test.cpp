#include <fstream>
#include <iostream>

int main() {
    // This will fail - filesystem is read-only!
    std::ofstream file("/etc/test");
    if (!file.is_open()) {
        std::cout << "Success! Protected from writing to /etc" << std::endl;
    }
    return 0;
}