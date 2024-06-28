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
    int_string: .space 33 #Reserva 20 espacios para transformar un entero a string
    int_stringINV: .space 33 #Reserva 20 espacios para transformar un entero a string
    
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
    bgt $t0, 7, invalid
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
    
#Conversiones a String
 intToString:
    move $t2, $t3
    li $t7 0
    li $t6 1 #indice en el string
    bltz $t2 negativo
    
    positivo:
        li $t4 '+'
        sb $t4 int_string($t7)
        b intToString2
    negativo:
        li $t4 '-'
        sb $t4 int_string($t7)
        mul $t2 $t2 -1
        b intToString2
intToString2:
    # Convertir el número en $t3 a string
        li $t5, 10     # Divisor para obtener cada dígito
        div $t2 $t5
        mfhi $t9       # Obtiene el residuo (el dígito actual)
        mflo $t2    #se actualiza el valor de $t3 (resultado)
        addi $t9, $t9, '0'  # Convierte el dígito a su valor ASCII
        sb $t9 int_stringINV($t7)
        addi $t7 $t7 1
        beqz $t2 intToString3
        b intToString2
        
intToString3:
    addi $t7 $t7 -1
    lb $t9 int_stringINV($t7)
    sb $t9 int_string($t6)
    addi $t6 $t6 1
    beqz $t7 menu2

    b intToString3
        
 invalid:
    printString(invalid_option)
    j menu1
    


    
# Convertimos todos a decimal y los guardamos en $t3
#De decimal a decimal
inputDecimalLogic:
    printString(enter_decimal)
    read_int($t2)
    move $t3, $t2
    b intToString
   
#Binario a decimal 
inputBinaryLogic:
    printString(enter_binary)
    li $v0, 8             
    la $a0, binary        
    li $a1, 32            # Maximo de caracteres a leer
    syscall
    b binaryToDecimal

binaryToDecimal:
    li $t3, 0             # Inicializa $t3 para no arrastrar valores, es el resultado
    la $t6, binary        

binaryToDecimalLoop:
    lb $t5, 0($t6)        # Navega por el string
    beq $t5, '\n', binaryDone  # Fin de la cadena (nuevo línea)
    beqz $t5, binaryDone  # Fin de la cadena (null)

    sub $t5, $t5, '0'     # Convierte ASCII '0' o '1' a integer
    blt $t5, 0, invalid_binary_char # Menor a 0, error
    bgt $t5, 1, invalid_binary_char # Mayor a 1, error

    # Shift left por 1
    sll $t3, $t3, 1       

    # Agrega el numero actual a $t3
    addu $t3, $t3, $t5

    # Siguiente caracter
    addi $t6, $t6, 1      
    j binaryToDecimalLoop

binaryDone:
    b intToString

invalid_binary_char:
    printString(invalid_option) 
    j menu1


# Función para convertir un número octal a decimal
inputOctalLogic:
    printString(enter_octal)   # Solicita al usuario que ingrese un número octal
    li $v0, 8                  # Cargar el servicio del sistema para leer un string
    la $a0, octal              # Dirección del buffer donde se almacenará el número octal
    li $a1, 12                 # Longitud máxima del string a leer
    syscall

    j octalToDecimal           # Salta a la función de conversión de octal a decimal

# Función para convertir un número octal a decimal
octalToDecimal:
    la $t6, octal              # Carga la dirección del buffer que contiene el número octal
    li $t3, 0                  # Inicializa $t3 a cero para almacenar el resultado decimal
    li $t7, 0                  # Inicializa $t7 para el loop de conversión

octalToDecimalLoop:
    lb $t5, 0($t6)             # Carga el valor actual del número octal (como ASCII)
    beqz $t5, intToString      # Si es el final del string, salta a la conversión a string
    beq $t5, 10, intToString   # Maneja el caso del salto de línea (ASCII 10)

    sub $t5, $t5, '0'          # Convierte el ASCII a número entero ('0' a '7')
    blt $t5, 0, invalid_octal_char   # Si el número es menor que 0, es inválido
    bgt $t5, 7, invalid_octal_char   # Si el número es mayor que 7, es inválido

    sll $t3, $t3, 3            # Shift left lógico por 3 para multiplicar por 8
    addu $t3, $t3, $t5         # Suma el dígito octal convertido al resultado decimal

    addi $t6, $t6, 1           # Avanza al siguiente caracter del string
    j octalToDecimalLoop       # Salta de nuevo al loop de conversión

invalid_octal_char:
    printString(invalid_option) # Imprime mensaje de opción inválida
    j menu1                     
        
#Decimal a Hexadecimal
inputHexLogic:
    printString(enter_hexadecimal) # Solicita al usuario que ingrese un número hexadecimal
    li $v0, 8                      # Cargar el servicio del sistema para leer un string
    la $a0, hexadecimal            # Dirección del buffer donde se almacenará el número hexadecimal
    li $a1, 9                      # Longitud máxima del string a leer
    syscall

    j hexToDecimal                 # Salta a la función de conversión de hexadecimal a decimal

# Función para convertir un número hexadecimal a decimal
hexToDecimal:
    la $t6, hexadecimal            # Carga la dirección del buffer que contiene el número hexadecimal
    li $t3, 0                      # Inicializa $t3 a cero para almacenar el resultado decimal
    li $t4, 0                      # Inicializa $t4 para el loop de conversión

hexToDecimalLoop:
    lb $t5, 0($t6)                 # Carga el valor actual del número hexadecimal (como ASCII)
    beqz $t5, intToString          # Si es el final del string, salta a la conversión a string
    beq $t5, 10, intToString       # Maneja el caso del salto de línea (ASCII 10)

    # Conversiones de ASCII a valores enteros
    li $t7, '0'                    # ASCII de '0'
    li $t8, '9'                    # ASCII de '9'
    li $t9, 'A'                    # ASCII de 'A'
    li $s0, 'F'                    # ASCII de 'F'
    li $s1, 'a'                    # ASCII de 'a'
    li $s2, 'f'                    # ASCII de 'f'

    blt $t5, $t7, invalid_hex_char # Si el caracter es menor que '0'
    bgt $t5, $s2, invalid_hex_char # Si el caracter es mayor que 'f'

    # Convierte caracteres '0'-'9'
    blt $t5, $t8, convert_hex_digit  # '0' a '9'
    # Convierte caracteres 'A'-'F'
    blt $t5, $s1, convert_hex_upper  # 'A' a 'F'
    # Convierte caracteres 'a'-'f'
    sub $t5, $t5, 87               # 'a' a 'f': ASCII - 87

    j add_hex_to_result

convert_hex_digit:
    sub $t5, $t5, '0'              # Convierte '0'-'9' a 0-9
    j add_hex_to_result

convert_hex_upper:
    sub $t5, $t5, 55               # Convierte 'A'-'F' a 10-15

add_hex_to_result:
    sll $t3, $t3, 4                # Shift left lógico por 4 para multiplicar por 16
    or $t3, $t3, $t5               # Agrega el dígito hexadecimal convertido al resultado decimal

    addi $t6, $t6, 1               # Avanza al siguiente caracter del string
    j hexToDecimalLoop             # Salta de nuevo al loop de conversión

invalid_hex_char:
    printString(invalid_option)    # Imprime mensaje de opción inválida
    j menu1                        # Retorna al menú principal

fin:
    exit
