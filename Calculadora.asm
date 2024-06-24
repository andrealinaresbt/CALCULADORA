# Macros
.macro print_string(%reg)
    li $v0, 4
    move $a0, %reg
    syscall
.end_macro

.macro print_int(%num)
    li $v0 1
    move $a0 %num
    syscall
.end_macro

.macro read_string(%len)
    li $v0, 8
    move $s7, $a0 #string saved on $s7
    li $a1, %len
    syscall
.end_macro

.macro read_int %register
	li $v0 5
	syscall
	move %register $v0 #save int on %register
.end_macro
	

.macro print_newline
    li $v0, 4
    la $a0, newline
    syscall
.end_macro

# Data section
.data
    newline: .asciiz "\n"
    input: .space 20
    output: .space 40
    decimal: .space 20
    binary: .space 40
    octal: .space 20
    hexadecimal: .space 20
    menu_option: .asciiz "Select an option:\n"
    option1: .asciiz "1. Decimal to Binary\n"
    option2: .asciiz "2. Decimal to Octal\n"
    option3: .asciiz "3. Decimal to Hexadecimal\n"
    option4: .asciiz "4. Binary to Decimal\n"
    option5: .asciiz "5. Octal to Decimal\n"
    option6: .asciiz "6. Hexadecimal to Decimal\n"
    option7: .asciiz "7. Exit\n"
    enter_decimal: .asciiz "Enter a decimal number: "
    enter_binary: .asciiz "Enter a binary number: "
    enter_octal: .asciiz "Enter an octal number: "
    enter_hexadecimal: .asciiz "Enter a hexadecimal number: "
    invalid_option: .asciiz "Invalid option\n"
    binary_result: .asciiz "Binary: "
    octal_result: .asciiz "Octal: "
    hexadecimal_result: .asciiz "Hexadecimal: "
    decimal_result: .asciiz "Decimal: "
    invalid_inputSTR: .asciiz "Invalid input\n"

# Code section
.text
main:
    # Initialize registers
    la $t0, input
    la $t1, output
    la $t2, decimal
    la $t3, binary
    la $t4, octal
    la $t5, hexadecimal

loop:
    # Print menu
    la $a0, menu_option
    print_string($a0)
    la $a0, option1
    print_string($a0)
    la $a0, option2
    print_string($a0)
    la $a0, option3
    print_string($a0)
    la $a0, option4
    print_string($a0)
    la $a0, option5
    print_string($a0)
    la $a0, option6
    print_string($a0)
    la $a0, option7
    print_string($a0)
    print_newline

    # Read option
    read_int($t7)
   
    # Process option
    beq $t7, 1, decimal_to_binary
    beq $t7, 2, decimal_to_octal
    beq $t7, 3, decimal_to_hexadecimal
    beq $t7, 4, binary_to_decimal
    beq $t7, 5, octal_to_decimal
    beq $t7, 6, hexadecimal_to_decimal
    beq $t7, 7, exit

    # Invalid option
    la $a0, invalid_option
    print_string($a0)
    print_newline
    j loop

decimal_to_binary:
    # Read decimal number
    la $a0, enter_decimal
    print_string($a0)
    read_string(20)

    # Convert decimal to binary
    jal decimal_to_binary_conversion
    j loop

decimal_to_octal:
    # Read decimal number
    la $a0, enter_decimal
    print_string($a0)
    read_string(20)

    # Convert decimal to octal
    jal decimal_to_octal_conversion
    j loop

decimal_to_hexadecimal:
    # Read decimal number
    la $a0, enter_decimal
    print_string($a0)
    read_string(20)

    # Convert decimal to hexadecimal
    jal decimal_to_hexadecimal_conversion
    j loop

binary_to_decimal:
    # Read binary number
    la $a0, enter_binary
    print_string($a0)
    read_string(40)

    # Convert binary to decimal
    jal binary_to_decimal_conversion
    j loop

octal_to_decimal:
    # Read octal number
    la $a0, enter_octal
    print_string($a0)
    read_string(20)

    # Convert octal to decimal
    jal octal_to_decimal_conversion
    j loop

hexadecimal_to_decimal:
    # Read hexadecimal number
    la $a0, enter_hexadecimal
    print_string($a0)
    read_string(20)

    # Convert hexadecimal to decimal
    jal hexadecimal_to_decimal_conversion
    j loop

exit:
    # Exit program
    li $v0, 10
    syscall

# Conversion functions
decimal_to_binary_conversion:
    # Initialize registers
    la $t0, input
    la $t1, binary

    # Convert decimal to binary
    li $t2, 0
loop_decimal_to_binary:
    lb $t3, 0($t0)
    beqz $t3, end_decimal_to_binary
    blt $t3, '0', invalid_input
    bgt $t3, '9', invalid_input
    sub $t3, $t3, '0'
    sll $t2, $t2, 1
    add $t2, $t2, $t3
    addi $t0, $t0, 1
    j loop_decimal_to_binary

end_decimal_to_binary:
    # Print binary result
    li $t0, 0
loop_print_binary:
    sb $t0, 0($t1)
    srl $t2, $t2, 1
    andi $t3, $t2, 1
    beqz $t3, print_zero
    li $t3, '1'
    j print_char
print_zero:
    li $t3, '0'
print_char:
    sb $t3, 0($t1)
    addi $t1, $t1, 1
    bnez $t2, loop_print_binary
    la $a0, binary_result
    print_string($a0)
    la $a0, binary
    print_string($a0)
    print_newline
    j loop

decimal_to_octal_conversion:
    # Initialize registers
    la $t0, input
    la $t1, octal

    # Convert decimal to octal
    li $t2, 0
loop_decimal_to_octal:
    lb $t3, 0($t0)
    beqz $t3, end_decimal_to_octal
    blt $t3, '0', invalid_input
    bgt $t3, '9', invalid_input
    sub $t3, $t3, '0'
    sll $t2, $t2, 1
    add $t2, $t2, $t3
    addi $t0, $t0, 1
    j loop_decimal_to_octal

end_decimal_to_octal:
    # Print octal result
    li $t0, 0
loop_print_octal:
    sb $t0, 0($t1)
    li $t3, 7
    div $t2, $t3
    mfhi $t4
    mflo $t2
    add $t4, $t4, '0'
    sb $t4, 0($t1)
    addi $t1, $t1, 1
    bnez $t2, loop_print_octal
    la $a0, octal_result
    print_string($a0)
    la $a0, octal
    print_string($a0)
    print_newline
    j loop

decimal_to_hexadecimal_conversion:
    # Initialize registers
    la $t0, input
    la $t1, hexadecimal

    # Convert decimal to hexadecimal
    li $t2, 0
loop_decimal_to_hexadecimal:
    lb $t3, 0($t0)
    beqz $t3, end_decimal_to_hexadecimal
    blt $t3, '0', invalid_input
    bgt $t3, '9', invalid_input
    sub $t3, $t3, '0'
    sll $t2, $t2, 1
    add $t2, $t2, $t3
    addi $t0, $t0, 1
    j loop_decimal_to_hexadecimal

end_decimal_to_hexadecimal:
    # Print hexadecimal result
    li $t0, 0
loop_print_hexadecimal:
    sb $t0, 0($t1)
    li $t3, 15
    div $t2, $t3
    mfhi $t4
    mflo $t2
    add $t4, $t4, '0'
    sb $t4, 0($t1)
    addi $t1, $t1, 1
    bnez $t2, loop_print_hexadecimal
    la $a0, hexadecimal_result
    print_string($a0)
    la $a0, hexadecimal
    print_string($a0)
    print_newline
    j loop

binary_to_decimal_conversion:
    # Initialize registers
    la $t0, input
    la $t1, decimal

    # Convert binary to decimal
    li $t2, 0
loop_binary_to_decimal:
    lb $t3, 0($t0)
    beqz $t3, end_binary_to_decimal
    blt $t3, '0', invalid_input
    bgt $t3, '1', invalid_input
    sub $t3, $t3, '0'
    sll $t2, $t2, 1
    add $t2, $t2, $t3
    addi $t0, $t0, 1
    j loop_binary_to_decimal

end_binary_to_decimal:
    # Print decimal result
    li $t1, 10
    div $t2, $t1
    mfhi $t4
    mflo $t2
    add $t4, $t4, '0'
    sb $t4, 0($t1)
    addi $t1, $t1, 1
    bnez $t2, end_binary_to_decimal
    la $a0, decimal_result
    print_string($a0)
    la $a0, decimal
    print_string($a0)
    print_newline
    j loop

octal_to_decimal_conversion:
    # Initialize registers
    la $t0, input
    la $t1, decimal

    # Convert octal to decimal
    li $t2, 0
loop_octal_to_decimal:
    lb $t3, 0($t0)
    beqz $t3, end_octal_to_decimal
    blt $t3, '0', invalid_input
    bgt $t3, '7', invalid_input
    sub $t3, $t3, '0'
    mul $t2, $t2, 8
    add $t2, $t2, $t3
    addi $t0, $t0, 1
    j loop_octal_to_decimal

end_octal_to_decimal:
    # Print decimal result
    li $t1, 10
    div $t2, $t1
    mfhi $t4
    mflo $t2
    add $t4, $t4, '0'
    sb $t4, 0($t1)
    addi $t1, $t1, 1
    bnez $t2, end_octal_to_decimal
    la $a0, decimal_result
    print_string($a0)
    la $a0, decimal
    print_string($a0)
    print_newline
    j loop

hexadecimal_to_decimal_conversion:
    # Initialize registers
    la $t0, input
    la $t1, decimal

    # Convert hexadecimal to decimal
    li $t2, 0
loop_hexadecimal_to_decimal:
    lb $t3, 0($t0)
    beqz $t3, end_hexadecimal_to_decimal
    blt $t3, '0', invalid_input
    bgt $t3, 'f', invalid_input
    sub $t3, $t3, '0'
    mul $t2, $t2, 16
    add $t2, $t2, $t3
    addi $t0, $t0, 1
    j loop_hexadecimal_to_decimal

end_hexadecimal_to_decimal:
    # Print decimal result
    li $t1, 10
    div $t2, $t1
    mfhi $t4
    mflo $t2
    add $t4, $t4, '0'
    sb $t4, 0($t1)
    addi $t1, $t1, 1
    bnez $t2, end_hexadecimal_to_decimal
    la $a0, decimal_result
    print_string($a0)
    la $a0, decimal
    print_string($a0)
    print_newline
    j loop

invalid_input:
    la $a0, invalid_inputSTR
    print_string($a0)
    j loop
