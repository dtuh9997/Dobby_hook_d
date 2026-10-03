module dobby;
//dobby hook c rewrite to dlang
//can use on dlang (betterC)
@nogc nothrow extern (C):
//enum dobby_h; useless on d. wip 
//nogc and nothrow
//use ldc compiler are not dmd or gdc because it may have compat problem i just test it on ldc. 

/*enum dobbyBuildVersion = "c343f74888dffad84d9ad08d9c433456";
enum dobbyHook         = "c8dc3ffa44f22dbd10ccae213dd8b1f8";
enum dobbyInstrument   = "b71e27bca2c362de90c1034f19d839f9";*/
enum _buildVersion  = "c343f74888dffad84d9ad08d9c433456"; //useless do not use
enum _hookHash      = "c8dc3ffa44f22dbd10ccae213dd8b1f8"; //useless do not use
enum _instrumentHash = "b71e27bca2c362de90c1034f19d839f9"; //useless do not use
import core.stdc.stdint;
void log_set_level(int level);
void log_switch_to_syslog();
void log_switch_to_file(const char *path);
enum MemoryOperationError {
    kMemoryOperationSuccess,
    kMemoryOperationError,
    kNotSupportAllocateExecutableMemory,
    kNotEnough,
    kNone
}//alias gaven ce. do not try
//enum PLATFORM_INTERFACE_CODE_PATCH_TOOL_H; wip useless
MemoryOperationError CodePatch(void *address, uint8_t *buffer, uint32_t buffer_size);
alias uintptr_t addr_t;
alias uint32_t addr32_t;
alias uint64_t addr64_t;
version (AArch64) {
    enum ARM64_TMP_REG_NDX_0 = 17;

  align(16) union FPReg {
  ulong[2] q;
  struct { double d1, d2; }
  struct { float f1, f2, f3, f4; }
}
struct NeonRegs { FPReg q0, q1, q2, q3, q4, q5, q6, q7, q8, q9 , q10, q11 , q12, q13, q14, q15, q16, q17, q18, q19, q20, q21, q22, q23, q24, q25, q26, q27, q28, q29, q30, q31; }
union FloatingRegs { FPReg[32] q; NeonRegs regs; }
struct XRegs { uint64_t x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28; }
union GeneralRegs64 { uint64_t[29] x; XRegs regs; }
struct _RegisterContext {
    uint64_t dmmpy_0;         // @0
    uint64_t sp;              // @8
    uint64_t dmmpy_1;         // @16
    GeneralRegs64 general;    // @24 .. @255
    uint64_t fp;              // @256
    uint64_t lr;              // @264
    FloatingRegs floating;    // @272 .. @783
}
alias RegisterContext = _RegisterContext;
static assert(_RegisterContext.sizeof == 784);
static assert(_RegisterContext.floating.offsetof == 272);
static assert(FPReg.alignof == 16);
static assert(_RegisterContext.alignof == 16);
} else version (ARM){
    struct ArmRegs { uint32_t r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12; }
  union GeneralRegs32 { uint32_t[13] r; ArmRegs regs; }

  struct _RegisterContext {
    uint32_t      dummy_0;    // @0
    uint32_t      dummy_1;    // @4
    uint32_t      dummy_2;    // @8
    uint32_t      sp;         // @12
    GeneralRegs32 general;    // @16 .. @67  (13 * 4 = 52)
    uint32_t      lr;         // @68
  }
  alias RegisterContext = _RegisterContext;

  static assert(_RegisterContext.sizeof           == 72);
  static assert(_RegisterContext.alignof          == 4);
  static assert(_RegisterContext.sp.offsetof      == 12);
  static assert(_RegisterContext.general.offsetof == 16);
  static assert(_RegisterContext.lr.offsetof      == 68);
}else version (X86){
   struct GprRegs32 { uint32_t eax, ebx, ecx, edx, ebp, esp, edi, esi; }
  union GeneralRegs86 { GprRegs32 regs; uint32_t[8] raw; }

  struct _RegisterContext {
    uint32_t      dummy_0;    // @0
    uint32_t      esp;        // @4
    uint32_t      dummy_1;    // @8
    uint32_t      flags;      // @12
    GeneralRegs86 general;    // @16 .. @47  (8 * 4 = 32)
  }
  alias RegisterContext = _RegisterContext;

  static assert(_RegisterContext.sizeof           == 48);
  static assert(_RegisterContext.alignof          == 4);
  static assert(_RegisterContext.esp.offsetof     == 4);
  static assert(_RegisterContext.flags.offsetof   == 12);
  static assert(_RegisterContext.general.offsetof == 16);
}else version (X86_64) {
struct GprRegs {                                 
    uint64_t rax, rbx, rcx, rdx, rbp, rsp, rdi, rsi;
    uint64_t r8, r9, r10, r11, r12, r13, r14, r15;
}
union GeneralRegs {                              
    GprRegs regs;
    uint64_t[16] raw;
}
struct _RegisterContext {
    uint64_t dummy_0;      // @0
    uint64_t rsp;          // @8
    GeneralRegs general;   // @16 @143
    uint64_t dummy_1;      // @144
    uint64_t flags;        // @152
}
alias RegisterContext = _RegisterContext;

static assert(_RegisterContext.sizeof == 160);
static assert(_RegisterContext.rsp.offsetof == 8);
static assert(_RegisterContext.dummy_1.offsetof == 144);
static assert(_RegisterContext.flags.offsetof == 152);
}
enum RT_FAILED = -1;
enum RT_SUCCESS = 0;
enum _RetStatus {
    RS_FAILED = -1,
    RS_SUCCESS = 0
}
alias RetStatus = _RetStatus;
struct _HookEntryInfo {
    int hook_id;
    union {
        void *target_address;
        void *function_address;
        void *instruction_address;
    }
}
alias HookEntryInfo = _HookEntryInfo;

/+ 
// disabled on c code idk why... so here is still disabled.
typedef void (*PreCallTy)(RegisterContext *ctx, const HookEntryInfo *info);
typedef void (*PostCallTy)(RegisterContext *ctx, const HookEntryInfo *info);
int DobbyWrap(void *function_address, PreCallTy pre_call, PostCallTy post_call);
+/
//const char *dobbyBuildVersion();
extern(C) const(char)* DobbyBuildVersion();
int DobbyHook(void *address, void *replace_call, void **origin_call);
alias DBICallTy = extern(C) void function(RegisterContext*, const(HookEntryInfo)*); nothrow @nogc
int DobbyInstrument(void *address, DBICallTy dbi_call);
int DobbyDestroy(void *address);
void *DobbySymbolResolver(const char *image_name, const char *symbol_name);
int DobbyGlobalOffsetTableReplace(char *image_name, char *symbol_name, void *fake_func, void **origin_func);
mixin template NearBranchTrampolineAPI() {
    void dobby_enable_near_branch_trampoline();
    void dobby_disable_near_branch_trampoline();
}
version (ARM)       mixin NearBranchTrampolineAPI!();
else version (AArch64) mixin NearBranchTrampolineAPI!();
else version (X86_64)  mixin NearBranchTrampolineAPI!();
//alias void ((*linker_load_callback_t)(const char *image_name, void *handle)); ignore this. broken
alias linker_load_callback_t = extern(C) void function(const(char)* image_name, void* handle);
void dobby_register_image_load_callback(linker_load_callback_t func);
//end 


