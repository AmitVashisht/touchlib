#include <cmath>
#include <cstdio>
#include <vector>
#include <iostream>
#include <algorithm>
using namespace std;


int main() {
    int t;
    cin>>t;    
    for(int i = 0; i < t; i++)
        {
        unsigned long long int n;
        int a;
        cin>>n;
        int r = 0;
        if(n == 1)
            {cout<<"Richard"<<endl;}
        else if(n != 1)
            {
              while(n > 1)
              {
                  a = log2 (n);
                  if(pow(2,a) == n)
                    {
                      n = n/2; 
                    }
                  else
                    {
                      n = n - pow(2,a);   
                    }
                  r++;
             }
            cout<<r<<endl;
            if(r%2 == 1)
                {cout<<"Louise"<<endl;}
            else
                {cout<<"Richard"<<endl;}
        }        
    }
    return 0;
}
