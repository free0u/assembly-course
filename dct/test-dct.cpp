#include <iostream>
#include <cmath>
#include <fstream>
#include <cstring>
#include <smmintrin.h>
#include <ctime>

using namespace std;

extern "C" void foo(int x, int y);

const float pi = 3.14159265359;

float* coef_f;
float* coef_i;

void dump(float * a)
{
    for (int i = 0; i < 8; ++i)
    {
        for (int j = 0; j < 8; ++j)
        {
            cout << a[i * 8 + j] << " ";
        }
        cout << endl;
    }
    cout << endl;
}

void dump2(float a[8][8])
{
    for (int i = 0; i < 8; ++i)
    {
        for (int j = 0; j < 8; ++j)
        {
            cout << a[i][j] << " ";
        }
        cout << endl;
    }
    cout << endl;
}



float A_(int val)
{
    if (val == 0)
        return 1.0 / sqrt(2.0);
    return 1;
}

float cos_(int i, int j)
{
    return cos((pi * i * (2 * j  + 1)) / (2 * 8.0));
}

float get_coef_f(int i, int j)
{
    return A_(i) * sqrt(1.0 / 32.0) * cos_(i, j);
}

float get_coef_i(int i, int j)
{
    return A_(j) * sqrt(2.0) * cos_(j, i);
}

void init_coef()
{
    coef_f = (float*)malloc(64 * sizeof(float));
    coef_i = (float*)malloc(64 * sizeof(float));

    for (int i = 0; i < 8; ++i)
    {
        for (int j = 0; j < 8; ++j)
        {
            coef_f[i * 8 + j] = get_coef_f(i, j);
            coef_i[i * 8 + j] = get_coef_i(i, j);
        }
    }
}

float ans[8];
float row[8];

float __attribute__((aligned(16))) printBuf[4];
 
// ======================================================================================================

// void transpose(float a[8][8])
// {
    // for (int i = 0; i < 8; ++i)
        // for (int j = 0; j < i; ++j)
            // swap(a[i][j], a[j][i]);
// }

void print( __m128 a)
{
    _mm_store_ps(printBuf,a);
    cout<<printBuf[0]<<' '<<
    printBuf[1]<<' '<<
    printBuf[2]<<' '<<
    printBuf[3]<<endl;
}



void calc_scal(float a[8], float b[8], float * to)
{
    __m128 a0 = _mm_loadu_ps(a);
    __m128 a1 = _mm_loadu_ps(a + 4);
    __m128 b0 = _mm_loadu_ps(b);
    __m128 b1 = _mm_loadu_ps(b + 4);
    
    __m128 r0 = _mm_dp_ps(a0, b0, 0xff);
    __m128 r1 = _mm_dp_ps(a1, b1, 0xff);
    r0 = _mm_add_ss(r0, r1);
    
    _mm_store_ss(to, r0);
}

float scal_slow(float * a, float * b)
{
    float res = 0;
    for (int i = 0; i < 8; ++i)
        res += a[i] * b[i];
    return res;
}


void fdct_helper(float * row, float * coef)
{
    for (int i = 0; i < 8; ++i) 
    {
        ans[i] = scal_slow(coef + i * 8, row);
        //calc_scal(coef[i], row, ans + i);
        //ans[i] = get_scal_res;
    }
            
    memmove(row, ans, 8 * sizeof(float));
}

void fdct(float * a)
{
    for (int i = 0; i < 8; ++i)
        fdct_helper(a + i * 8, coef_f);

    for (int i = 0; i < 8; ++i)
    {
        for (int j = 0; j < 8; ++j) row[j] = a[j * 8 + i];
        fdct_helper(row, coef_f);
        for (int j = 0; j < 8; ++j) a[j * 8 + i] = row[j];
    }
}

void idct(float * a)
{
    fdct(a);
}






int main()
{
/*     __m128 vek = _mm_set_ps(4.0, 3.0, 2.0, 1.0);
    __m128 vec = _mm_set_ps(1.0, 2.0, 3.0, 4.0);

    cout << get_scal_fast(vek, vek, vec, vec);

    return 0; */



    init_coef();

    float data_source[8][8], true_ans[8][8];

    ifstream in("input.txt");
    ifstream in2("output_true.txt");
    
    for (int i = 0; i < 8; ++i)
    {
        for (int j = 0; j < 8; ++j)
        {
            in >> data_source[i][j];
            in2 >> true_ans[i][j];
        }
    }
    
    int CNT_TEST = 100;
    
    long long x_st, x_end, total = 0;
    float * data = (float*)malloc(64 * sizeof(float));
    for (int test_i = 0; test_i < CNT_TEST; ++test_i)
    {
        memmove(data, data_source, 64 * sizeof(float));
        
        asm("rdtsc" : "=A"(x_st));
        fdct(data);
        asm("rdtsc" : "=A"(x_end));
        
        total += x_end - x_st;
        
        if (test_i == 0)
        {
            //dump(data);
        }
    }
    //return 0;
    
    //dump(data);
    //dump2(true_ans);
    
    bool correct = true;
    for (int i = 0; i < 8; ++i)
    {
        for (int j = 0; j < 8; ++j)
        {
            float d = fabs(data[i * 8 + j] - true_ans[i][j]);
            if (d > 3)
            {
                correct = false;
                //printf("%f (%d, %d)\n", d, i, j);
            }
        }
    }
    free(data);
    free(coef_f);
    free(coef_i);
    
    cout << endl << (correct ? "ans correct" : "ans wrong") << endl;
    cout << endl << "time: " << total / CNT_TEST << endl;
    return 0;
}

















