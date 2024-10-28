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
     # Initialize test register to known value
    li s2, 0           # s2 will store test results (1 if test passed, 0 if failed)
    # Test BLT (branch if less than)
    li s3, -1
    li s4, 10    
    nop
    nop
    nop                # Hazard prevention for branch data load
    blt s3, s4, blt_pass # -1 < 10 should pass
    nop
    nop
    nop                # Wait for branch result
    j blt_fail    
    nop
    nop
    nop                # Wait for branch result
blt_pass:
    addi s2, s2, 1
blt_fail:
    nop
    nop
    nop                # Prevent data hazard for s2

    # Test BGE (branch if greater or equal)
    bge s4, s3, bge_pass # 10 > -1 should pass
    nop
    nop
    nop                # Wait for branch result
    j bge_fail
    nop
    nop
    nop                # Wait for branch result
bge_pass:
    addi s2, s2, 2
bge_fail:
    nop
    nop
    nop

    # Test BLTU (branch if less than, unsigned)
    bltu s4, s3, bltu_pass # 10 < FFFF (-1) should pass
    nop
    nop
    nop                # Wait for branch result
    j bltu_fail
    nop
    nop
    nop                # Wait for branch result
bltu_pass:
    addi s2, s2, 4
bltu_fail:
    nop
    nop
    nop

    # Test BGEU (branch if greater or equal, unsigned)
    bgeu s3, s4, bgeu_pass # FFFF > 10 should pass
    nop
    nop
    nop                # Wait for branch result
    j bgeu_fail
    nop
    nop
    nop                # Wait for branch result
bgeu_pass:
    li s5, 8
    addi s2, s2, 8
bgeu_fail:
    nop
    nop
    nop

    # Test JAL (jump and link)
    jal s6, jal_test   # Jump to jal_test and store return address in s6
    nop
    nop
    nop                # Wait for branch result
    j jal_fail         # If we reach here, JAL failed
    nop
    nop
    nop                # Wait for branch result
jal_test:
    addi s2, s2, 16
    j jal_return
    nop
    nop
    nop
jal_fail:
    j jal_done         # Skip if failed
    nop
    nop
    nop
jal_return:
    # Return from JAL and continue
jal_done:

    # Test JALR (jump and link register)
    auipc s6, 0
    nop
    nop
    nop
    addi s6, s6, 0x34
    nop
    nop
    nop
    #la s6, jalr_test   # Load address of jalr_test into s6
    jalr x1, s6, 0     # Jump to jalr_test, store return address in x1
    nop
    nop
    nop                # Wait for branch result
    j jalr_fail        # If we reach here, JALR failed
    nop
    nop
    nop                # Wait for branch result
jalr_test:
    addi s2, s2, 32
    j jalr_return
    nop
    nop
    nop
jalr_fail:
    j end_test         # Skip if failed
    nop
    nop
    nop
jalr_return:
    # Return from JALR and continue
end_test:

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
