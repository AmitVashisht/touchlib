

#ifndef __TOUCHSCREEN_FILTER_SMOOTHING__
#define __TOUCHSCREEN_FILTER_SMOOTHING__

#include <Filter.h>

class TOUCHLIB_FILTER_EXPORT SmoothingFilter : public Filter
{

public:

    SmoothingFilter(char*);
    ~SmoothingFilter();
    void kernel();

};

#endif // __TOUCHSCREEN_FILTER_SMOOTHING__