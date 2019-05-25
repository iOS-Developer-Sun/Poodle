//
//  pdl_mach_o_const_symbols.h
//  Poodle
//
//  Created by Poodle on 14-6-27.
//
//

#import "pdl_mach_o_symbols.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    PDL_MACH_O_SYMBOLS_STATE_LOADING,
    PDL_MACH_O_SYMBOLS_STATE_READY,
    PDL_MACH_O_SYMBOLS_STATE_ERROR,
} pdl_mach_o_const_symbols_state;

extern pdl_mach_o_const_symbols_state pdl_const_symbols_current_state(void);
extern struct pdl_mach_o_symbol *pdl_const_symbols(const char *image_name, const char *symbol_name);

#ifdef __cplusplus
}
#endif
