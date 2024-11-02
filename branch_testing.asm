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

    # Combined Structural, Data, and Control Hazard Test with Initialization



    # Initialization of registers

    li s2, 1                  # Initialize s2 with 1

    li s3, 20                 # Initialize s3 with 20

    la s5, DROM               # Initialize s5 with drom

    li s6, -1                 # Initialize s6 with -1

    li s7, 20                 # Initialize s7 with 20

    li s8, 30                 # Initialize s8 with 30

    li s9, 40                 # Initialize s9 with 40

    li s10, 50                # Initialize s10 with 50



    # Structural Hazard Test

    sw s2, 0(s5)              # Store word from s2 to memory at address (s5 + 0)

    lw s3, 0(s5)              # Load word from memory at address in s5 into s3

    sw s7, 0(s5)              # Store word from s7 to memory at address (s5 + 0)

                               # Creates a structural hazard if using single memory

    # Data Hazard Test

    add s3, s2, s6            # s3 = s2 + s6 (RAW hazard on s2 from previous lw)

    sub s4, s3, s7            # s4 = s3 - s7 (RAW hazard on s3 from previous add)

    mul s5, s8, s3            # s5 = s3 * s8 (RAW hazard on s4 from previous sub)

    sub s6, s3, s9            # s4 = s3 - s9 (RAW hazard on s3 from previous add)





    # Control Hazard Test

    beq s3, x0, branch_label  # Branch to branch_label if s3 == 0 

    add s6, s6, s6            # Should be skipped if branch is taken

    add s7, s7, s7            # Another instruction that should be flushed if branch is taken



branch_label:

    # Code continues here after branch

    add s9, s9, s9            # Target of the branch (executes if branch is taken)

    add s10, s10, s10         # Additional instruction for further pipeline utilization





halt:	

	jal halt		# infinite loop to halt computation. A program should not "terminate" without an operating system to return control to

    nop

    nop

    nop

				# keep halt: jal halt as the last line of your code.



# ------- <code memory (ROM mapped to Instruction Memory) ends>		



#------- <constant memory (ROM mapped to Data Memory) begins>									

.data	## DROM segment 0x00002000-0x000021FC

# All constants should be declared in this section. This section is read only (Only lw, no sw).

# Total number of constants should not exceed 128

# If a variable is accessed multiple times, it is better to store the address in a register and use it rather than load it repeatedly.

DROM:

DELAY_VAL: .word 4

string1:

.asciz "\r\nWelcome to CG3207..\r\n"

test_data: .word 0x00000005



#------- <constant memory (ROM mapped to Data Memory) ends>	



# ------- <variable memory (RAM mapped to Data Memory) begins>

.align 9 ## DRAM segment. 0x00002200-0x000023FC #assuming rodata size of <= 512 bytes (128 words)

# All variables should be declared in this section, adjusting the space directive as necessary. This section is read-write.

# Total number of variables should not exceed 128. 

# No initialization possible in this region. In other words, you should write to a location before you can read from it (i.e., write to a location using sw before reading using lw).

var1:   .space 4 

DRAM:

.space 508



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



# ------- <memory-mapped input-output (peripherals) ends>

