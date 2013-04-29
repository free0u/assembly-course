#include <iostream>
#include <cmath>
#include <fstream>
#include <cstring>
#include <smmintrin.h>
#include <ctime>

using namespace std;

extern "C" void foo(int x, int y);

extern "C" void fdct(float * in, float * out, unsigned int count);
extern "C" void idct(float * in, float * out, unsigned int count);

const float pi = 3.14159265359;

float* coef_f;
float* coef_i;

void dump(float * a)
{
    for (int i = 0; i < 8; ++i)
    {
        for (int j = 0; j < 8; ++j)
        {
            printf("%.3f ", a[i * 8 + j]);
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

float * buffer;

__m128 xxm0, xxm1, xxm2, xxm3;

void fdct_helper(float * row, float * buf_to, float * coef)
{
    xxm0 = _mm_loadu_ps(row);
    xxm1 = _mm_loadu_ps(row + 4);

    //calc_scal(coef + 0, buf_to);
    xxm2 = _mm_loadu_ps(coef + 0);
    xxm3 = _mm_loadu_ps(coef + 4);
    xxm2 = _mm_dp_ps(xxm0, xxm2, 0xff);
    xxm3 = _mm_dp_ps(xxm1, xxm3, 0xff);
    xxm2 = _mm_add_ss(xxm2, xxm3);
    _mm_store_ss(buf_to, xxm2);
    
    //calc_scal(coef + 8, buf_to + 8);
    xxm2 = _mm_loadu_ps(coef + 8);
    xxm3 = _mm_loadu_ps(coef + 12);
    xxm2 = _mm_dp_ps(xxm0, xxm2, 0xff);
    xxm3 = _mm_dp_ps(xxm1, xxm3, 0xff);
    xxm2 = _mm_add_ss(xxm2, xxm3);
    _mm_store_ss(buf_to + 8, xxm2);
    
    
    //calc_scal(coef + 16, buf_to + 16);
    xxm2 = _mm_loadu_ps(coef + 16);
    xxm3 = _mm_loadu_ps(coef + 20);
    xxm2 = _mm_dp_ps(xxm0, xxm2, 0xff);
    xxm3 = _mm_dp_ps(xxm1, xxm3, 0xff);
    xxm2 = _mm_add_ss(xxm2, xxm3);
    _mm_store_ss(buf_to + 16, xxm2);
    
    //calc_scal(coef + 24, buf_to + 24);
    xxm2 = _mm_loadu_ps(coef + 24);
    xxm3 = _mm_loadu_ps(coef + 28);
    xxm2 = _mm_dp_ps(xxm0, xxm2, 0xff);
    xxm3 = _mm_dp_ps(xxm1, xxm3, 0xff);
    xxm2 = _mm_add_ss(xxm2, xxm3);
    _mm_store_ss(buf_to + 24, xxm2);
    
    //calc_scal(coef + 32, buf_to + 32);
    xxm2 = _mm_loadu_ps(coef + 32);
    xxm3 = _mm_loadu_ps(coef + 36);
    xxm2 = _mm_dp_ps(xxm0, xxm2, 0xff);
    xxm3 = _mm_dp_ps(xxm1, xxm3, 0xff);
    xxm2 = _mm_add_ss(xxm2, xxm3);
    _mm_store_ss(buf_to + 32, xxm2);
    
    
    //calc_scal(coef + 40, buf_to + 40);
    xxm2 = _mm_loadu_ps(coef + 40);
    xxm3 = _mm_loadu_ps(coef + 44);
    xxm2 = _mm_dp_ps(xxm0, xxm2, 0xff);
    xxm3 = _mm_dp_ps(xxm1, xxm3, 0xff);
    xxm2 = _mm_add_ss(xxm2, xxm3);
    _mm_store_ss(buf_to + 40, xxm2);   
    
    
    //calc_scal(coef + 48, buf_to + 48);
    xxm2 = _mm_loadu_ps(coef + 48);
    xxm3 = _mm_loadu_ps(coef + 52);
    xxm2 = _mm_dp_ps(xxm0, xxm2, 0xff);
    xxm3 = _mm_dp_ps(xxm1, xxm3, 0xff);
    xxm2 = _mm_add_ss(xxm2, xxm3);
    _mm_store_ss(buf_to + 48, xxm2);
    
    
    //calc_scal(coef + 56, buf_to + 56);
    xxm2 = _mm_loadu_ps(coef + 56);
    xxm3 = _mm_loadu_ps(coef + 60);
    xxm2 = _mm_dp_ps(xxm0, xxm2, 0xff);
    xxm3 = _mm_dp_ps(xxm1, xxm3, 0xff);
    xxm2 = _mm_add_ss(xxm2, xxm3);
    _mm_store_ss(buf_to + 56, xxm2);
    
}




void c_fdct(float * source, float * dest, unsigned int count)
{
    for (int i = 0; i < 8; ++i)
        fdct_helper(source + i * 8, buffer + i, coef_f);
    
    for (int i = 0; i < 8; ++i)
        fdct_helper(buffer + i * 8, dest + i, coef_f);
}

void c_idct(float * source, float * dest, unsigned int count)
{
    for (int i = 0; i < 8; ++i)
        fdct_helper(source + i * 8, buffer + i, coef_i);
    
    for (int i = 0; i < 8; ++i)
        fdct_helper(buffer + i * 8, dest + i, coef_i);
}


long long x_st, x_end, total;


int main()
{
    init_coef();
    buffer = (float*)malloc(64 * sizeof(float));

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
    
    int CNT_TEST = 100000;
    int CNT_MATRIX = 100;
    
    //float * data = (float*)malloc(CNT_MATRIX * 64 * sizeof(float));
    //float * matrix_ans = (float*)malloc(CNT_MATRIX * 64 * sizeof(float));
    
    float data[64 * CNT_MATRIX] __attribute__((aligned(16)));
    float matrix_ans[64 * CNT_MATRIX] __attribute__((aligned(16)));
    
    total = 0;
    for (int test_i = 0; test_i < CNT_TEST; ++test_i)
    {
        for (int i = 0; i < CNT_MATRIX; ++i)
        {
            memmove(data + i * 64, data_source, 64 * sizeof(float));
        }
        
        
        asm("rdtsc" : "=A"(x_st));
        fdct(data, matrix_ans, CNT_MATRIX);
        idct(matrix_ans, data, CNT_MATRIX);
        fdct(data, matrix_ans, CNT_MATRIX);
        asm("rdtsc" : "=A"(x_end));
        
        total += x_end - x_st;
        
    }
    //return 0;
    
    //dump(matrix_ans);
    //dump2(true_ans);
    
    bool correct = true;
    for (int testn = 0; testn < CNT_MATRIX; ++testn)
    {
        for (int i = 0; i < 8; ++i)
        {
            for (int j = 0; j < 8; ++j)
            {
                float d = fabs(matrix_ans[testn * 64 + i * 8 + j] - true_ans[i][j]);
                if (d > 3)
                {
                    correct = false;
                    //printf("%f (%d, %d)\n", d, i, j);
                }
            }
        }
    }
    
    //free(data);
    free(coef_f);
    free(coef_i);
    free(buffer);
    //free(matrix_ans);
    
    cout << endl << (correct ? "ans correct" : "ans wrong") << endl;
    cout << endl << "time: " << total / CNT_TEST / CNT_MATRIX / 3 << endl;
    return 0;
}

















