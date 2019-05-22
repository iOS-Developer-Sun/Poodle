
#ifndef PDL_PROGRESS
#define PDL_PROGRESS(progress, from, to) ({__typeof__(progress) __p = (progress);__typeof__(from) __f = (from); __typeof__(to) __t = (to); ((__f) + ((__t) - (__f)) * (__p));})
#endif
