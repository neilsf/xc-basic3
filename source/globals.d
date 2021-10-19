module globals;

/** The target machine */
string target = "c64";
/** Whether to assemble a basic loader */
bool basicLoader = true;
/** Program start address */
int startAddress = -1;
/** Maximum allowed string length */
const int stringMaxLength = 96;