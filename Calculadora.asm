# Macros

# Macro to print a string

.macro exit
	li $v0 10
	syscall
.end_macro 


.macro printString %memoryAddress
	li $v0 4
	la $a0 %memoryAddress
	syscall
.end_macro

# Macro para imprimir numero
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

.macro read_int (%register)
	li $v0 5
	syscall
	move %register $v0 #save int on %num
.end_macro
	

.macro print_newline
    li $v0, 4
    la $a0, newline
    syscall
.end_macro

.macro invalidInput 
  printString(invalid_option)
.end_macro 


# Data section
.data
    newline: .asciiz "\n"
    input: .space 20
    output: .space 40
    decimal: .space 20
    binary: .space 33
    octal: .space 12
    hexadecimal: .space 9
    menu_option: .asciiz "Select what you want to transform to: \n"
    
    enter_decimal: .asciiz "Enter a decimal number: "
    enter_binary: .asciiz "Enter a binary number: "
    enter_octal: .asciiz "Enter an octal number: "
    enter_hexadecimal: .asciiz "Enter a hexadecimal number: "
    invalid_option: .asciiz "Invalid option\n"
 
    inputDecimal: .asciiz "1. Decimal\n"
    inputBinary: .asciiz "2. Binary\n"
    inputOctal: .asciiz "3. Octal\n"
    inputHex: .asciiz "4. Hexadecimal\n"
    inputDecimalEm: .asciiz "5. Decimal Empaquetado\n"
    inputFraction: .asciiz "6. Fracionario \n"
    option7: .asciiz "7. Exit\n"
    arrow: .asciiz "----> "
    inputChooseNumber: .asciiz "Please enter the option of the type of number you wish to transform\n"
    

# Code section
.text
menu1:
	#li $t3, 0       # resultado
	printString(inputChooseNumber)
	printString(inputDecimal)
	printString(inputBinary)
	printString(inputOctal)
	printString(inputHex)
	printString(inputDecimalEm)
	printString(option7)
	
	printString(arrow)
	#Guardamos la opcion en $t0 (Tipo de numero del input)
	read_int($t0) 
	#Opciones
	beq $t0, 1, inputDecimalLogic
	beq $t0, 2, inputBinaryLogic
	beq $t0, 3, inputOctalLogic
	beq $t0, 4, inputHexLogic
	#beq $t0, 5, inputDecimalEm
	beq $t0, 7, fin
	blez $t0, invalid
	bgt $t0, 7 invalid
	j menu1
	
 menu2:
 	printString(menu_option)
 	printString(inputDecimal)
	printString(inputBinary)
	printString(inputOctal)
	printString(inputHex)
	printString(inputDecimalEm)
	printString(option7)
	
	printString(arrow)
	#Guardamos la opcion en $t1 (Tipo de numero a convertir)
	read_int($t1) 
	
	#beq $t1, 1, toDecimal
	#beq $t1, 2, toBinary
	#beq $t1, 3, toOctal
	#beq $t1, 4, toHex
	#beq $t1, 5, toDecimalEm
	#beq $t1, 7, exit
 	
 invalid:
 	printString(invalid_option)
 	j menu1
 	
#Convertimos todos a decimal y los guardamos en $t3
inputDecimalLogic:
	printString(enter_decimal)
	read_int($t2)
	move $t3, $t2
	b menu2
	 
inputBinaryLogic:
	 printString(enter_binary)
    li $v0, 8             # syscall for read_string
    la $a0, binary        # Load address to store user input
    li $a1, 32            # Maximum number of characters to read
    syscall
    b binaryToDecimal

binaryToDecimal:
    li $t3, 0             # Initialize $t3 to store decimal result
    la $t6, binary        # Pointer to the input string
    
binaryToDecimalLoop:
    lb $t5, 0($t6)        # Load the current character from binary input
    beqz $t5, binaryDone  # If null terminator, exit loop
    
    sub $t5, $t5, '0'     # Convert ASCII '0' or '1' to integer
    blt $t5, 0, invalid_binary_char # Check if conversion went below 0
    bgt $t5, 1, invalid_binary_char # Check if conversion went above 1

    # Shift $t3 left by 1 (equivalent to multiplying by 2)
    sll $t3, $t3, 1       

    # Add current binary digit to $t3
    addu $t3, $t3, $t5

    # Move to the next character
    addi $t6, $t6, 1      
    j binaryToDecimalLoop

binaryDone:
    b menu2


invalid_binary_char:
    printString(invalid_option) # Print invalid option message
    j menu1

 inputOctalLogic:
    printString(enter_octal)
    li $v0, 8          # Read string syscall
    la $a0, octal      # Address of input buffer
    li $a1, 12         # Maximum length to read (including null terminator)
    syscall
    j octalToDecimal

octalToDecimal:
    la $t6, octal      # Pointer to the input string
    li $t3, 0          # Initialize $t3 to store the decimal result
    li $t4, 0          # Initialize loop counter

OctalToDecimalLoop:
    lb $t5, 0($t6)     # Load the current character from the octal input
    beqz $t5, menu2    # If null terminator, exit loop
    
    sub $t5, $t5, '0'  # Convert ASCII '0' to '7' to integer
    blt $t5, 0, invalid_octal_char # If $t5 < 0, it's an invalid digit
    bgt $t5, 7, invalid_octal_char # If $t5 > 7, it's an invalid digit

    # Shift current result to left by 3 (multiply by 8)
    sll $t3, $t3, 3    

    # Add current digit to the result
    addu $t3, $t3, $t5 

    # Move to the next character
    addi $t6, $t6, 1   
    j OctalToDecimalLoop

invalid_octal_char:
    printString(invalid_option) # Print invalid option message
    j menu1  # Go back to the main menu
    
inputHexLogic:
    printString(enter_hexadecimal)
    li $v0, 8           # Read string syscall
    la $a0, hexadecimal # Address of input buffer
    li $a1, 9           # Maximum length to read (including null terminator)
    syscall
    j hexToDecimal

hexToDecimal:
    la $t6, hexadecimal # Pointer to the input string
    li $t3, 0           # Initialize $t3 to store the decimal result
    li $t4, 0           # Initialize loop counter

hexToDecimalLoop:
    lb $t5, 0($t6)      # Load the current character from the hex input
    beqz $t5, menu2     # If null terminator, exit loop
    
    # Convert ASCII character to integer value
    li $t7, 48          # ASCII '0'
    li $t8, 57          # ASCII '9'
    li $t9, 65          # ASCII 'A'
    li $s0, 70          # ASCII 'F'
    li $s1, 97          # ASCII 'a'
    li $s2, 102         # ASCII 'f'

    blt $t5, $t7, invalid_hex_char   # If character < '0'
    bgt $t5, $s2, invalid_hex_char   # If character > 'f'

    # Convert digit or letter to integer
    blt $t5, $t8, convert_hex_digit  # '0' to '9'
    blt $t5, $s1, convert_hex_upper  # 'A' to 'F'
    sub $t5, $t5, 87                 # 'a' to 'f': ASCII - 87

    j add_hex_to_result

convert_hex_digit:
    sub $t5, $t5, 48   # Convert '0'-'9' to 0-9
    j add_hex_to_result

convert_hex_upper:
    sub $t5, $t5, 55   # Convert 'A'-'F' to 10-15

add_hex_to_result:
    sll $t3, $t3, 4    # Shift current result left by 4 (multiply by 16)
    or $t3, $t3, $t5   # Add the current digit to the result

    addi $t6, $t6, 1   # Move to the next character
    j hexToDecimalLoop

invalid_hex_char:
    printString(invalid_option) # Print invalid option message
    j menu1  # Go back to the main menu

fin:

	exit	