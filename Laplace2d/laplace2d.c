/*
 * Copyright (c) 2019, NVIDIA CORPORATION.  All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <math.h> 
#include <stdlib.h>
#include <string.h>

#define OFFSET(x, y, m) (((x)*(m)) + (y))

void initialize(double *__restrict__ A, double *__restrict__ Anew, int m, int n)
{
    int i;
    memset(A, 0, n * m * sizeof(double));
    memset(Anew, 0, n * m * sizeof(double));

    for(i = 0; i < m; i++){
        A[i] = 1.0;
        Anew[i] = 1.0;
    }
}

double calcNext(double *__restrict__ A, double *__restrict__ Anew, int m, int n)
{
    int i,j;
    double error = 0.0;
    for(  j = 1; j < n-1; j++)
    {
        for( i = 1; i < m-1; i++ )
        {
            Anew[OFFSET(j, i, m)] = 0.25 * ( A[OFFSET(j, i+1, m)] + A[OFFSET(j, i-1, m)]
                                           + A[OFFSET(j-1, i, m)] + A[OFFSET(j+1, i, m)]);
            error = fmax( error, fabs(Anew[OFFSET(j, i, m)] - A[OFFSET(j, i , m)]));
        }
    }
    return error;
}
        
void swap(double *__restrict__ A, double *__restrict__ Anew, int m, int n)
{
    int i,j;
    for(  j = 1; j < n-1; j++)
    {
        for( i = 1; i < m-1; i++ )
        {
            A[OFFSET(j, i, m)] = Anew[OFFSET(j, i, m)];    
        }
    }
}

void deallocate(double *__restrict__ A, double *__restrict__ Anew)
{
    free(A);
    free(Anew);
}
