#include <iostream>
#include <vector>
#include <algorithm>

// Example: Find maximum subarray sum (Kadane's algorithm)
int main() {
    std::cout << "Maximum Subarray Sum Example" << std::endl;
    std::cout << "============================" << std::endl;
    
    std::vector<int> arr = {-2, 1, -3, 4, -1, 2, 1, -5, 4};
    
    std::cout << "Array: ";
    for (int num : arr) {
        std::cout << num << " ";
    }
    std::cout << std::endl;
    
    // Kadane's algorithm
    int max_sum = arr[0];
    int current_sum = arr[0];
    
    for (size_t i = 1; i < arr.size(); i++) {
        current_sum = std::max(arr[i], current_sum + arr[i]);
        max_sum = std::max(max_sum, current_sum);
    }
    
    std::cout << "Maximum subarray sum: " << max_sum << std::endl;
    std::cout << "(Subarray: [4, -1, 2, 1])" << std::endl;
    
    return 0;
}
