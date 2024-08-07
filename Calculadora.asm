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

.macro ReverseString %inputAddr
    la $a0, %inputAddr  # Cargar la dirección de la cadena de entrada
    la $a1, output     # Cargar la dirección de la cadena de salida (output)
    
    strlen:
    move $v0, $zero        # Inicializa $v0 a 0 para contar la longitud de la cadena
    move $t0, $a0          # Copia la dirección base de la cadena en $t0
    li $t2 0		#Apuntador a la posicion de output

    strlen_loop:
        lb $t1, ($t0)      # Carga el byte actual de la cadena
        beqz $t1, invLoop   # Salta si encuentra el terminador nulo
        addi $t0, $t0, 1   # Avanza al siguiente byte de la cadena
        addi $v0, $v0, 1   # Incrementa el contador de longitud
        j strlen_loop      # Repite el bucle
        
    invLoop:
    	addi $v0 $v0 -1
    	bltz $v0 endInv
        lb $t3 %inputAddr($v0)
        sb $t3 output($t2)
        addi $t2 $t2 1
        b invLoop
       
    endInv:
    	li $t3 0
        sb $t3 output($t2)
.end_macro


# Data section
.data
    #SPACES
    binary: .space 33 #Reserva 33 espacios para el binario 32 bits + null
    octal: .space 12 #Reserva 12 espacios para el octal 11 + null
    hexadecimal: .space 9 #Reserva 9 espacios para hexadecimal 8 + null
    binaryBCD:   .space 33        # Buffer para almacenar la cadena binaria del número BCD empaquetado
    decimalEm:   .space 10        # Buffer para la representación decimal como string
    int_string: .space 33 #Reserva 20 espacios para transformar un entero a string
    int_stringINV: .space 33 #Reserva 20 espacios para transformar un entero a string
    resultStr : .space 33
    output: .space 33 #esta es la salida usada en el macro ReverseString
    pila: .space 7 #utilizada en decimal => decimal empaquetado
    
    #ASCIIZ
    SimboloMas: .asciiz "+"
    SimboloMenos: .asciiz "-"
    newline: .asciiz "\n"
    menu_option: .asciiz "Select what you want to transform to: \n"
    enter_decimal: .asciiz "Enter a decimal number: "
    enter_binary: .asciiz "Enter a binary number: "
    enter_octal: .asciiz "Enter an octal number: "
    enter_hexadecimal: .asciiz "Enter a hexadecimal number: "
    enter_decimalEm: .asciiz "Enter a packed decimal number: "
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
    result: .asciiz "The resultant number is: "
   
    

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
    beq $t0, 5, inputDecimalEmLogic
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
    
    beq $t1, 1, DecimalToDecimal
    beq $t1, 2, DecimalToBinary
    beq $t1, 3, DecimalToOctal
    beq $t1, 4, DecimalToHex
    beq $t1, 5, DecimalToDecimalEm
    beq $t1, 7, fin
    bgt $t1,7,invalid
    blez $t1,invalid
    
#Conversiones a String
 intToString:
    print_newline
    move $t2, $t3
    li $t7 0
    li $t6 1 #indice en el string
    bltz $t2 negative
    
    positive:
        li $t4 '+'
        sb $t4 int_string($t7)
        b intToString2
    negative:
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
    read_int($t3)
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

# Función para convertir un número octal a decimal, incluyendo números negativos
octalToDecimal:
    la $t6, octal              # Carga la dirección del buffer que contiene el número octal
    li $t3, 0                  # Inicializa $t3 a cero para almacenar el resultado decimal
    li $t7, 0                  # Inicializa $t7 para el loop de conversión
    li $t8, 0                  # Bandera para número negativo (0 = positivo, 1 = negativo)

# Comprobar si es un número negativo
    lb $t5, 0($t6)             # Carga el primer carácter del número octal (como ASCII)
    beq $t5, '-', handle_negative # Si es '-', maneja el número como negativo

    j octalToDecimalLoop       # Salta a la conversión normal si no es negativo

handle_negative:
    li $t8, 1                  # Establece la bandera de número negativo a 1
    addi $t6, $t6, 1           # Avanza al siguiente carácter del string

octalToDecimalLoop:
    lb $t5, 0($t6)             # Carga el valor actual del número octal (como ASCII)
    beqz $t5, check_negative   # Si es el final del string, salta a la verificación de signo
    beq $t5, 10, check_negative# Maneja el caso del salto de línea (ASCII 10)

    sub $t5, $t5, '0'          # Convierte el ASCII a número entero ('0' a '7')
    blt $t5, 0, invalid_octal_char   # Si el número es menor que 0, es inválido
    bgt $t5, 7, invalid_octal_char   # Si el número es mayor que 7, es inválido

    sll $t3, $t3, 3            # Shift left lógico por 3 para multiplicar por 8
    addu $t3, $t3, $t5         # Suma el dígito octal convertido al resultado decimal

    addi $t6, $t6, 1           # Avanza al siguiente carácter del string
    j octalToDecimalLoop       # Salta de nuevo al loop de conversión

check_negative:
    beqz $t8, intToString      # Si la bandera de negativo es 0, salta a la conversión a string
    sub $t3, $zero, $t3        # Si es negativo, invierte el signo del resultado
    j intToString              # Salta a la conversión a string

invalid_octal_char:
    printString(invalid_option)# Imprime mensaje de opción inválida
    j menu1                    # Retorna al menú principal        

inputHexLogic:
    printString(enter_hexadecimal)  # Solicita al usuario que ingrese un número hexadecimal
    li $v0, 8                       # Cargar el servicio del sistema para leer un string
    la $a0, hexadecimal             # Dirección del buffer donde se almacenará el número hexadecimal
    li $a1, 9                       # Longitud máxima del string a leer
    syscall

    # Inicializar registros y banderas
    la $t6, hexadecimal    # Puntero al buffer que contiene el número hexadecimal
    li $t3, 0              # Inicializar $t3 a cero para almacenar el resultado decimal
    li $t4, 0              # Inicializar $t4 para el loop de conversión
    li $t8, 0              # Bandera para número negativo (0 = positivo, 1 = negativo)

    # Comprobar si el número es negativo
    lb $t5, 0($t6)         # Cargar el primer carácter del número hexadecimal (como ASCII)
    beq $t5, '-', handle_negative_input  # Si es '-', manejar el número como negativo

    j hexToDecimal     # Saltar a la conversión normal si no es negativo

handle_negative_input:
    li $t8, 1              # Establecer la bandera de número negativo a 1
    addi $t6, $t6, 1       # Avanzar al siguiente carácter del string
    j hexToDecimal         # Saltar a la conversión normal

# Función para convertir un número hexadecimal a decimal
hexToDecimal:
    # la $t6, hexadecimal            # Carga la dirección del buffer que contiene el número hexadecimal
    li $t3, 0                      # Inicializa $t3 a cero para almacenar el resultado decimal
    li $t4, 0                      # Inicializa $t4 para el loop de conversión

hexToDecimalLoop:
    lb $t5, 0($t6)                 # Carga el valor actual del número hexadecimal (como ASCII)
    beqz $t5, apply_sign           # Si es el final del string, salta a aplicar el signo
    beq $t5, 10, apply_sign        # Maneja el caso del salto de línea (ASCII 10)

    # Conversiones de ASCII a valores enteros
    li $t7, '0'                    # ASCII de '0'
    li $t9, 'A'                    # ASCII de 'A'
    li $s0, 'F'                    # ASCII de 'F'
    li $s1, 'a'                    # ASCII de 'a'
    li $s2, 'f'                    # ASCII de 'f'

    blt $t5, $t7, invalid_hex_char # Si el caracter es menor que '0'
    bgt $t5, $s2, invalid_hex_char # Si el caracter es mayor que 'f'

    # Convierte caracteres '0'-'9'
    blt $t5, '9', convert_hex_digit # '0' a '9'
    # Convierte caracteres 'A'-'F'
    blt $t5, $s1, convert_hex_upper # 'A' a 'F'
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

apply_sign:
    beqz $t8, finish_conversion    # Si la bandera negativa es 0, salta al final
    sub $t3, $zero, $t3            # Aplica el signo negativo

finish_conversion:
    j intToString                  # Salta a la conversión del número a string

invalid_hex_char:
    printString(invalid_option)    # Imprime mensaje de opción inválida
    j menu1                        # Retorna al menú principal

    
# Función para recibir un número BCD binario empaquetado
inputDecimalEmLogic:
    printString(enter_decimalEm)   # Solicita al usuario que ingrese un número BCD binario
    li $v0, 8                      # Cargar el servicio del sistema para leer un string
    la $a0, binaryBCD              # Dirección del buffer donde se almacenará el número BCD binario
    li $a1, 33                     # Longitud máxima del string a leer
    syscall

    la $t6, binaryBCD              # Puntero al buffer que contiene el número BCD binario
    li $t3, 0                      # Inicializa $t3 a cero para almacenar el resultado decimal
    li $t1, 0                      # Inicializa $t1 como el índice del buffer
    li $t4, 0                      # Inicializa $t4 para acumular bits BCD

binaryBCDToDecimalLoop:
    lb $t5, 0($t6)                 # Carga el valor actual del BCD binario (como ASCII)
    beqz $t5, processDigits        # Si es el final del string, salta a procesar los dígitos
    sub $t5, $t5, '0'              # Convierte '0'/'1' a 0/1
    sll $t4, $t4, 1                # Desplaza $t4 a la izquierda (para el próximo bit)
    or $t4, $t4, $t5               # Agrega el bit actual a $t4
    addi $t1, $t1, 1               # Incrementa el índice del buffer
    addi $t6, $t6, 1               # Avanza al siguiente carácter del string
    b binaryBCDToDecimalLoop       # Repite el proceso

processDigits:
    li $t3, 0                      # Inicializa $t3 para almacenar el número decimal
    li $t7, 28                     # Inicializa $t7 para manejar el shift de bits

extractDigits:
    blt $t7, -4, revSigno          # Si el índice es negativo, termina la extracción
    srlv $t5, $t4, $t7             # Desplaza el valor acumulado para obtener 4 bits
    andi $t5, $t5, 0xF             # Máscara para obtener los 4 bits
    add $t3, $t3, $t5              # Añade el dígito al resultado
    bgt $t7, 3, multiply           # Si hay más bits, multiplica por 10 para el próximo dígito
    sub $t7, $t7, 4                # Decrementa el índice del bit
    j extractDigits                # Continua la extracción

multiply:
    mul $t3, $t3, 10               # Multiplica el número acumulado por 10
    sub $t7, $t7, 4                # Decrementa el índice del bit
    j extractDigits                # Repite la extracción

revSigno:
    sll $t5, $t4, 31               # Revisa el bit de signo
    beqz $t5, callIntToString      # Si no es negativo, salta a intToString
    mul $t3, $t3, -1               # Si es negativo, multiplica por -1

callIntToString:
    j intToString                  # Llama a la función para convertir a string
#----------------------------------------------------------------------------------------------------------------------

#DECIMAl to Others
DecimalToDecimal:
	printString(newline)
	printString(result)
	printString(int_string) #ya estaba en decimal, por eso no se hace nada
	b fin

DecimalToBinary:
    # Función para convertir un número decimal en una cadena a binario en complemento a 2
	la $a0 int_string
    # Cargar el signo (+ o -) de la cadena
    lb $t2, 0($a0)
    beq $t2, '+', skip_sign_check
    li $t2, 1   # Si el signo es '-', establecer $t2 a 1 (negativo)
    j sign_checked

skip_sign_check:
    li $t2, 0   # Si el signo es '+', establecer $t2 a 0 (positivo)

sign_checked:
    # Avanzar la dirección de la cadena para apuntar al primer dígito
    addi $a0, $a0, 1

    # Convertir la cadena de dígitos en un número entero en $t1
    li $t1, 0    # Inicializar $t1 a 0 para acumular el número
    li $t3, 10   # Factor de multiplicación para cada dígito decimal
    li $t8, 0    # Inicializar contador de posición de dígito

convert_loop:
    lb $t4, 0($a0)     # Cargar el siguiente carácter de la cadena
    beqz $t4, conversion_done  # Salir del bucle si encontramos el final de la cadena ('\0')
    subi $t4, $t4, 48   # Convertir carácter ASCII a valor decimal (ascii '0' = 48)
    mul $t1, $t1, $t3   # Multiplicar $t1 por 10 (factor de base 10)
    add $t1, $t1, $t4   # Sumar el dígito convertido a $t1
    addi $a0, $a0, 1    # Avanzar al siguiente carácter de la cadena
    addi $t8, $t8, 1    # Incrementar contador de posición de dígito
    j convert_loop      # Volver al inicio del bucle

conversion_done:
    # Verificar si el número es negativo y convertir a complemento a 2 si es necesario
    beq $t2, 0, skip_negate    # Saltar si el número es positivo
    xori $t1, $t1, 0xFFFFFFFF # Negar todos los bits del número
    addi $t1, $t1, 1          # Sumar 1 para obtener el complemento a 2
    j result_ready

skip_negate:
    # Aquí $t1 contiene el número entero positivo convertido

result_ready:
    # Almacenar el número convertido en binario en complemento a 2 en binary_result
    li $t9, 31          # Contador para recorrer los 32 bits del resultado
    la $t8, resultStr   # Dirección del resultado binario

store_binary_loop:
    andi $t3, $t1, 1    # Obtener el bit menos significativo
    addi $t3, $t3, 48   # Convertir el bit a ASCII ('0' o '1')
    sb $t3, 0($t8)      # Almacenar el bit en binary_result
    srl $t1, $t1, 1     # Desplazar a la derecha para obtener el siguiente bit
    addi $t8, $t8, 1    # Avanzar en la dirección del resultado binario
    subi $t9, $t9, 1    # Decrementar el contador
    bgez $t9, store_binary_loop   # Repetir hasta almacenar todos los bits

    # Añadir terminador de cadena al final del resultado binario
    li $t3, '\0'        # Carácter nulo
    sb $t3, 0($t8)      # Almacenar el terminador nulo al final del resultado

    # Añadir terminador de cadena al final del resultado binario
    li $t3, '\0'        # Carácter nulo
    sb $t3, 0($t8)      # Almacenar el terminador nulo al final del resultado  
       
        b PrintResult
		
DecimalToOctal:

	#the decimal number is $t3
    li $t6,0 #remainder
    li $t7,0 #final octal number
    li $t8,1 #placeInNumber
    octalToDecimalLoopOutput:
    	rem $t6, $t3, 8  # Calcula el resto de $t3 dividido por 8 y lo guarda en $t6.
    	div $t3, $t3, 8  # Divide $t3 por 8 (actualiza $t3).
    	mul $t6, $t6, $t8  # Multiplica el resto por el lugar en el número y guarda el resultado en $t6.
    	add $t7, $t7, $t6  # Añade el valor calculado a $t7 (acumula el número octal).
    	mul $t8, $t8, 10  # Multiplica el lugar en el número por 10 (para la siguiente posición decimal).
    	bnez $t3, octalToDecimalLoopOutput  # Si $t3 no es cero, repite el bucle.

	lb $t3 int_string($zero) #signo del numero
	printString(newline)
	printString(result)
	beq $t3 '+' Dec2octPositivo
	b printOctal
	
	Dec2octPositivo:
		printString(SimboloMas)
		b printOctal
	
	printOctal:
		print_int($t7)
    		b fin
	
DecimalToHex:
	la $a0 int_string
    	# Cargar el signo (+ o -) de la cadena
    	lb $t2, 0($a0)
    	beq $t2, '+', PositiveCase
    	b NegativeCase

	PositiveCase:
    		li $t2, '+'   # Si el signo es '+'
    		b sign_checked2
    	NegativeCase:
    		li $t2, '-'   # Si el signo es '-'
    		mul $t3 $t3 -1
    		b sign_checked2

	sign_checked2:
		sb $t2 resultStr($zero)
    
	move $t2, $t3
	li $t0, 8		# counter
	la $t3, resultStr	# where answer will be stored
	addi $t3 $t3 1		# skip sign place
	
	LoopDec2Hex:

		beqz $t0, ExitHex #branch to exit if counter is equal to zero 
		rol $t2, $t2, 4 # rotate 4 bits to the left
		and $t4, $t2, 0xf # mask with 1111
		ble $t4, 9, SumHex   # if less than or equal to nine, branch to sum
		addi $t4, $t4, 55 # if greater than nine, add 55
		
		b EndHex

	SumHex:
		addi $t4, $t4, 48 # add 48 to result


	EndHex:
		sb $t4, 0($t3) #store Hex digit into result
		addi $t3, $t3, 1 #incremet address counter
		addi $t0, $t0, -1 #decrement loop counter
	j LoopDec2Hex
	
	ExitHex:
		printString(newline)
		printString(result)
		printString(resultStr)
	b fin
# Función para convertir un número decimal en formato BCD
# Asume que el número decimal está cargado previamente en $t3 y no desde la entrada del usuario

DecimalToDecimalEm:
    jal DDE

    # Imprimir el número BCD empaquetado
    li $v0, 4             # Servicio para imprimir cadena
    la $a0, newline
    syscall
    jal printBCDLoop

    # Salir del programa
    li $v0, 10            # Servicio para terminar el programa
    syscall

DDE:
    DecimalToBCD:
  # Inicialización de registros necesarios
li $t2, 0        # Byte actual para almacenar BCD
li $t4, 0        # Contador de nibbles

# Bucle para convertir a BCD
decimalToBCDLoop:
    andi $t5, $t3, 0xF     # Obtiene el dígito menos significativo en formato BCD (los últimos 4 bits)
    srl $t3, $t3, 4        # Desplaza $t3 hacia la derecha para el próximo dígito
    sll $t2, $t2, 4        # Desplaza el contenido actual de $t2 hacia la izquierda para hacer espacio
    or $t2, $t2, $t5       # Almacena el dígito en $t2
    addi $t4, $t4, 1       # Incrementa el contador de nibbles
    bnez $t3, decimalToBCDLoop  # Repite si $t3 no es cero

# Asegura que el resultado esté empaquetado en 32 bits con '1111 0000' al final
li $t6, 15               # '1111' en binario, representa el nibble superior en BCD
sll $t6, $t6, 28         # Desplaza '1111 0000' a la posición inicial (28 bits)

or $t2, $t2, $t6         # Combina el resultado BCD con '1111 0000' al final

move $t3, $t2            # Copia el resultado final de BCD de $t2 a $t3

# Impresión del número BCD
# Función para imprimir un número en formato BCD
li $t6, 31               # Inicializa el índice de bits para BCD (31 para 32 bits menos 1)

printBCDLoop:
    bltz $t6, endPrintBCD  # Termina si el índice de bits es menor que 0

    srlv $t7, $t3, $t6     # Desplaza a la derecha para alinear el bit más significativo con el menos significativo
    andi $t7, $t7, 1       # Obtiene el bit menos significativo

    addi $t7, $t7, '0'     # Convierte el bit a su valor ASCII
    move $a0, $t7          # Mueve el valor ASCII a $a0 para impresión
    li $v0, 11             # Servicio para imprimir un carácter
    syscall

    # Inserta un espacio después de cada 4 bits para formatear como nibbles
    rem $t8, $t6, 4
    bnez $t8, skipSpace
    li $a0, ' '            # Imprime un espacio
    li $v0, 11             # Servicio para imprimir un carácter
    syscall

skipSpace:
    subi $t6, $t6, 1       # Decrementa el índice de bits en 1
    j printBCDLoop

endPrintBCD:
    li $v0, 10             # Servicio para terminar el programa
    syscall
    
PrintResult:
	printString(newline)
	printString(result)
	ReverseString(resultStr)
    	printString(output)
    	b fin
    	
fin:
    exit
