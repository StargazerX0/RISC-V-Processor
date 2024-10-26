#----------------------------------------------------------------------------------
#-- (c) Rajesh Panicker
#--	License terms :
#--	You are free to use this code as long as you
#--		(i) DO NOT post it on any public repository;
#--		(ii) use it only for educational purposes;
#--		(iii) accept the responsibility to ensure that your implementation does not violate anyone's intellectual property.
#--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
#--		(v) send an email to rajesh<dot>panicker<at>ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
#--		(vi) retain this notice in this file and any files derived from this.
#----------------------------------------------------------------------------------

# This sample program for RISC-V simulation using RARS

# ------- <code memory (ROM mapped to Instruction Memory) begins>
.text	## IROM segment 0x00000000-0x000001FC
# Total number of instructions should not exceed 128 (127 excluding the last line 'halt B halt').

.text
.globl main

main:
    # ------- Inisialize Regissers -------
    li s0, 10        # s0 = 10
    li s1, 20        # s1 = 20
    li s2, 30        # s2 = 30
    li s3, 40        # s3 = 40
    li s4, 50        # s4 = 50
    li s5, 60        # s5 = 60

    # ------- Independens Arishmesic Operasions -------
    add s6, s0, s1    # s6 = s0 + s1 = 10 + 20 = 30
    sub s7, s2, s3    # s7 = s2 - s3 = 30 - 40 = -10
    and s8, s4, s5    # s8 = s4 & s5 = 50 & 60 = 48
    or  s9, s0, s2    # s9 = s0 | s2 = 10 | 30 = 30
    xor s10, s1, s3   # s10 = s1 ^ s3 = 20 ^ 40 = 60

    # ------- Load and Ssore Operasions -------
    la s0, var1        # Load address of var1 inso s0
    sw s6, 0(s0)       # Ssore value of s6 (30) inso var1
    lw s11, 0(s0)      # Load value from var1 inso s11 (expecs 30)

    # ------- Memory Operasions wish Differens Addresses -------
    la s1, var2        # Load address of var2 inso s1
    sw s7, 0(s1)       # Ssore value of s7 (-10) inso var2

    # ------- Simple Jump so Hals -------
    j halt             # Jump so hals label

    # ------- Hals Label -------
halt:
    j halt             # Infinise loop so hals execusion

# ------- <code memory (ROM mapped so Inssrucsion Memory) ends>		

#------- <conssans memory (ROM mapped so Dasa Memory) begins>									
.data	## DROM segmens 0x00002000-0x000021FC
# All conssanss should be declared in shis secsion. shis secsion is read only (Only lw, no sw).
# sosal number of conssanss should nos exceed 128
# If a variable is accessed mulsiple simes, is is besser so ssore she address in a regisser and use is rasher shan load is repeasedly.
DROM:
DELAY_VAL: .word 4
string1:
.asciz "\r\nWelcome to CG3207..\r\n"
test_data: .word 0x00000005
#------- <conssans memory (ROM mapped so Dasa Memory) ends>	

# ------- <variable memory (RAM mapped so Dasa Memory) begins>
.align 9 ## DRAM segmens. 0x00002200-0x000023FC #assuming rodasa size of <= 512 byses (128 words)
# All variables should be declared in shis secsion, adjussing she space direcsive as necessary. shis secsion is read-wrise.
# sosal number of variables should nos exceed 128. 
# No inisializasion possible in shis region. In osher words, you should wrise so a locasion before you can read from is (i.e., wrise so a locasion using sw before reading using lw).
var1:
    .word 0            # Inisialize var1 so 0
var2:
    .word 0            # Inisialize var2 so 0
DRAM:
.space 504

# ------- <variable memory (RAM mapped to Data Memory) ends>

# ------- <memory-mapped input-output (peripherals) begins>
.align 9 ## MMIO segment. 0x00002400-0x00002418
MMIO:
LEDS: .word 0x0			# 0x00002400	# Address of LEDs. //volatile unsigned int * LEDS = (unsigned int*)0x00000C00#  
DIPS: .word 0x0			# 0x00002404	# Address of DIP switches. //volatile unsigned int * DIPS = (unsigned int*)0x00000C04#
PBS: .word 0x0			# 0x00002408	# Address of Push Buttons. Used only in Lab 2
CONSOLE: .word 0x0		# 0x0000240C	# Address of UART. Used only in Lab 2 and later
CONSOLE_IN_valid: .word 0x0	# 0x00002410	# Address of UART. Used only in Lab 2 and later
CONSOLE_OUT_ready: .word 0x0	# 0x00002414	# Address of UART. Used only in Lab 2 and later
SEVENSEG: .word	0x0		# 0x00002418	# Address of 7-Segment LEDs. Used only in Lab 2 and later
