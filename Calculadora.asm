# Macros

# Macro para terminar programa

.macro exit
	li $v0 10
	syscall
.end_macro 

# Macro para imprimir string
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

# Macro para leer strings
.macro read_string(%len)
    li $v0, 8
    move $s7, $a0 # Salva String en $t7
    li $a1, %len
    syscall
.end_macro

# Macro para leer numero
.macro read_int (%register)
	li $v0 5
	syscall
	move %register $v0 # Salva string en el registro pasado como parametro
.end_macro
	
# Macro de imprimir nueva linea
.macro print_newline
    li $v0, 4
    la $a0, newline
    syscall
.end_macro

# Macro para imprimir mensaje de invalid option
.macro invalidInput 
  printString(invalid_option)
.end_macro 


# Data section
.data
    #SPACES
    binary: .space 33 #Reserva 33 espacios para el binario 32 bits + null
    octal: .space 12 #Reserva 12 espacios para el octal 11 + null
    hexadecimal: .space 9 #Reserva 9 espacios para hexadecimal 8 + null
    int_string: .space 20 #Reserva 20 espacios para transformar un entero a string
    int_stringINV: .space 20 #Reserva 20 espacios para transformar un entero a string
    
    #ASCIIZ
    newline: .asciiz "\n"
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

#Primer menu, le pide al usuario que haga escoja en que formato va a estar el numero a convertir
menu1:
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
	
#Muestra opciones de a que tipo de numero se convertira el numero	
 menu2:
 	printString(int_string)
 	print_newline
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
	beq $t1, 7, fin
	bgt $t1,7,invalid
	blez $t1,invalid
 	
 invalid:
 	printString(invalid_option)
 	j menu1
 	
#Convertimos todos a decimal y los guardamos en $t3

intToString:
	bltz $t3 negativo
	li $t6 1 #indice en el string
	li $t7 0
	positivo:
		li $t4 '+'
		sb $t4 int_string($t7)
		b intToString2
	negativo:
		li $t4 '-'
		sb $t4 int_string($t7)
		b intToString2
intToString2:
	# Convertir el número en $t3 a string
    	li $t5, 10     # Divisor para obtener cada dígito
    	div $t3 $t5
    	mfhi $t9       # Obtiene el residuo (el dígito actual)
    	mflo $t3	#se actualiza el valor de $t3 (resultado)
    	addi $t9, $t9, '0'  # Convierte el dígito a su valor ASCII
    	sb $t9 int_stringINV($t7)
    	addi $t7 $t7 1
    	beqz $t3 intToString3
    	b intToString2
    	
intToString3:
	addi $t7 $t7 -1
	lb $t9 int_stringINV($t7)
	sb $t9 int_string($t6)
	addi $t6 $t6 1
	beqz $t7 menu2
	b intToString3
    	
	
#De decimal a decimal
inputDecimalLogic:
	printString(enter_decimal)
	read_int($t2)
	move $t3, $t2
	b intToString

#Logica de Binario a decimal	 
inputBinaryLogic:
	 printString(enter_binary)
    li $v0, 8             
    la $a0, binary        
    li $a1, 32            # Agrega el numero maximo de caracteres a leer
    syscall
    b binaryToDecimal

binaryToDecimal:
    li $t3, 0             # Inicializa $t3 a 0 para no arrastrar ningun valor
    li $t6 0       # Apuntador al string binario
    
binaryToDecimalLoop:
    lb $t5, binary($t6)        # Navegar en el string
    beqz $t5, binaryDone  # Si es nul, exit
    
    sub $t5, $t5, '0'     # Convierte ASCII '0' o '1' a integer
    blt $t5, 0, invalid_binary_char 
    bgt $t5, 1, invalid_binary_char 
    

    # Shift $t3 izquierdo por 1
    sll $t3, $t3, 1       

    # Agrega el binario actual 
    addu $t3, $t3, $t5

    # Siguiente caracter
    addi $t6, $t6, 1      
    j binaryToDecimalLoop

binaryDone:
    b menu2


invalid_binary_char:
    printString(invalid_option)
    j menu1


#Logica para conversion de Octal a decimal
inputOctalLogic:
    printString(enter_octal)
    li $v0, 8          
    la $a0, octal      
    li $a1, 12         # Maximo de caracteres a leer
    syscall
    j octalToDecimal

octalToDecimal:
    la $t6, octal      # Apuntador al string octal
    li $t3, 0          # Inicializamos $t3 a 0 para no arrastrar valores, $t3 sera nuestro resultado
    li $t4, 0          # Contador de loop

OctalToDecimalLoop:
    lb $t5, 0($t6)     # Carga el caracter original del input 
    beqz $t5, menu2    # If null terminator, exit loop
    
    sub $t5, $t5, '0'  # Convierte ASCII '0' o '7' a integer
    blt $t5, 0, invalid_octal_char # Si $t5 < 0, es invalido
    bgt $t5, 7, invalid_octal_char # Si $t5 > 7, es invalido

    # Shift left 3 bits
    sll $t3, $t3, 3    

    # Agregamos el bit actual a la respuesta
    addu $t3, $t3, $t5 

    # Siguiente
    addi $t6, $t6, 1   
    j OctalToDecimalLoop

invalid_octal_char:
    printString(invalid_option) 
    j menu1  

#Logica para convertir de hexadecimal a decimal    
inputHexLogic:
    printString(enter_hexadecimal)
    li $v0, 8           
    la $a0, hexadecimal 
    li $a1, 9           # Maximo de caracteres a leer
    syscall
    j hexToDecimal

hexToDecimal:
    la $t6, hexadecimal # Apuntador al string hexadecimal
    li $t3, 0           # Inicializamos $t3 a cero para no arrastrar ningun valor, $t3 sera el resultado
    li $t4, 0           # Inicializa el counter de loop

hexToDecimalLoop:
    lb $t5, 0($t6)      #  Carga el primer caracter 
    beqz $t5, menu2     
    
    # Convierte ASCII a integer 
    li $t7, 48          # ASCII '0'
    li $t8, 57          # ASCII '9'
    li $t9, 65          # ASCII 'A'
    li $s0, 70          # ASCII 'F'
    li $s1, 97          # ASCII 'a'
    li $s2, 102         # ASCII 'f'

    blt $t5, $t7, invalid_hex_char   # Si caracter < '0'
    bgt $t5, $s2, invalid_hex_char   # Si caracter > 'f'

    # Convierte digito o letra a integer
    blt $t5, $t8, convert_hex_digit  # '0' a '9'
    blt $t5, $s1, convert_hex_upper  # 'A' a 'F'
    sub $t5, $t5, 87                 # 'a' a'f': ASCII - 87 por posiciones del ascii

    j add_hex_to_result

convert_hex_digit:
    sub $t5, $t5, 48   # Convierte '0'-'9' a 0-9
    j add_hex_to_result

convert_hex_upper:
    sub $t5, $t5, 55   # Convierte'A'-'F' a 10-15

add_hex_to_result:
    sll $t3, $t3, 4    # Shift izquierdo resultado  4 bits 
    or $t3, $t3, $t5   # Agrego el bit actual al resultado

    addi $t6, $t6, 1   # Siguiente caracter
    j hexToDecimalLoop

invalid_hex_char:
    printString(invalid_option) 
    j menu1  

fin:

	exit	
