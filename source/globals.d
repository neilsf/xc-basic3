module globals;

/** The target machine */
string target = "c64";
/** Whether to assemble a basic loader */
bool basicLoader = true;
/** Program start address */
int startAddress = -1;
/** If the program exceeds this limit, compilation will fail */
int topAddress = -1;
/** Maximum allowed string length */
const int stringMaxLength = 96;
/** Whether to compile DATA statements at the current origin */
bool inlineData = false;
/** Whether the program uses custom irq routines */
bool useIrqs = false;
/** Fast IRQ option bypasses saving virtual registers before entering the ISR */
bool fastIrqs = false;
/** Whether the program uses sprite routines */
bool useSprites = false;
/** Whether the program uses sound routines */
bool useSound = false;
