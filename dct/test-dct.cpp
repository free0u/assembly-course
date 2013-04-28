#include <iostream>
using namespace std;

extern "C" void foo(int x, int y);

int main()
{
    foo(1, 2);
    
    
    return 0;
}
