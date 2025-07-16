;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;                 
            ;Transmision RS-232 por software. 
            ;115200bps, 8 data bits, no parity, 1 stop bit, no flow control,
            ;parte1: transmite por el puerte serie el contenido de la memoria RAM (64 bytes, portid [0-63])
            ;parte2: genera numeros pseudo-aleatorios, bucle contador+interrupcion para transmitir numero.
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;declaracion de constantes y variables
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                  
            	CONSTANT	rs232, FF		; puerto comunicacion serie es el FF
            						; rx es el bit 0 del puerto FF(entrada)
							; tx es el bit 7 del puerto FF(salida), esto es porque
		;el hyperterminal envia primero el LSB, por eso vamos desplazando a la 
		;izquierda al recibir, y al enviar tambien, con lo que enviamos de nuevo
		;el LSB primero como corresponde para que lo entienda el hyperterminal
            	NAMEREG		s1, txreg		;buffer de transmision
            	NAMEREG		s2, rxreg		;buffer de recepcion
		NAMEREG		s3, contbit		;contador de los 8 bits de datos
		NAMEREG		s4, cont1		;contador de retardo1
		NAMEREG		s5, cont2		;contador de retardo2
		NAMEREG		s7, cont_errores	;contador de errores (ahora leído del periférico)
		;
		ADDRESS		00			;el programa se cargara a partir de la dir 00
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;Inicio del programa
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		DISABLE INTERRUPT
start:		CALL		recibe
		ENABLE INTERRUPT
		JUMP start
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;Rutina de recepcion de caracteres
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
recibe:		;esperamos a que se reciba un bit de inicio
		INPUT		rxreg, rs232
		AND		rxreg, 80
		JUMP		NZ, recibe
		CALL		wait_05bit
		;almacenamos los 8 bits de datos
		LOAD		contbit,09
next_rx_bit:	CALL		wait_1bit
		SR0		rxreg
		INPUT		s0, rs232
		AND		s0, 80
		OR		rxreg, s0
		SUB 		contbit, 01
		JUMP		NZ, next_rx_bit
		RETURN
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;Rutina de transmision de caracteres
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
transmite:	;enviamos un bit de inicio
		LOAD		s0, 00
		OUTPUT		s0, rs232
		CALL		wait_1bit
		;enviamos los 8 bits de datos
		LOAD 		contbit, 08
next_tx_bit:	OUTPUT		txreg, rs232
		CALL		wait_1bit
		SR0		txreg
		SUB 		contbit, 01
		JUMP		NZ, next_tx_bit
		;enviamos un bit de parada
		LOAD		s0, FF
		OUTPUT		s0, rs232
		CALL		wait_1bit
		RETURN
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;Rutina espera 1 bit (a 9600bps)
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

wait_1bit:	LOAD 		cont1, 03  
espera2:	LOAD		cont2, 22
espera1:	SUB		cont2, 01
		JUMP		NZ, espera1
		SUB		cont1, 01
		JUMP		NZ, espera2
		RETURN
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;Rutina espera 0,5 bits (bit de inicio, a 9600bps)
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

wait_05bit:	LOAD 		cont1, 03 
espera4:	LOAD		cont2, 10
espera3:	SUB		cont2, 01
		JUMP		NZ, espera3
		SUB		cont1, 01
		JUMP		NZ, espera4
		RETURN
        	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        	; FIN
        	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        	; RUTINA DE ATENCION A LA INTERRUPCION
        	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

inserta_palabra:		
    	    LOAD    s6, 00          ;  indice para la RAM
loop_mensaje:
    	    INPUT   txreg, s6       ; Lee desde RAM[s6] 
    	    ADD     txreg, 00       ; Verifica si es 0
    	    JUMP    Z, fin_mensaje  ; Si es 0, termina el mensaje
    	    CALL    transmite       ; Transmite el car cter
    	    ADD     s6, 01          ; Incrementa  ndice
    	    JUMP    loop_mensaje    ; Repite el bucle
fin_mensaje:
    	    RETURN

envia_letra:
	    LOAD        txreg,0A                   ; Carriage Return
            CALL        transmite
            LOAD        txreg,0D                   ; Line Feed
            CALL        transmite
            LOAD        txreg,4C                   ; "L"
            CALL        transmite
            LOAD        txreg,45                   ; "E"
            CALL        transmite
            LOAD        txreg,54                   ; "T"
            CALL        transmite
            LOAD        txreg,52                   ; "R"
            CALL        transmite
            LOAD        txreg,41                   ; "A"
            CALL        transmite
            LOAD        txreg,3A                   ; ":"
            CALL        transmite
            LOAD        txreg,20                   ; Espacio
            CALL        transmite
	    RETURN

resultado:
	    LOAD        txreg,0A                   ; Carriage Return
            CALL        transmite
            LOAD        txreg,0D                   ; Line Feed
            CALL        transmite
            LOAD        txreg,52                   ; "R"
            CALL        transmite
            LOAD        txreg,45                   ; "E"
            CALL        transmite
            LOAD        txreg,3A                   ; ":"
            CALL        transmite
            LOAD        txreg,20                   ; Espacio
            CALL        transmite
	    RETURN

; Nueva rutina para mostrar mensaje de muchos errores
demasiados_errores:
            LOAD        txreg,0A                   ; Carriage Return
            CALL        transmite
            LOAD        txreg,0D                   ; Line Feed
            CALL        transmite
            LOAD        txreg,4D                   ; "M"
            CALL        transmite
            LOAD        txreg,55                   ; "U"
            CALL        transmite
            LOAD        txreg,43                   ; "C"
            CALL        transmite
            LOAD        txreg,48                   ; "H"
            CALL        transmite
            LOAD        txreg,4F                   ; "O"
            CALL        transmite
            LOAD        txreg,53                   ; "S"
            CALL        transmite
            LOAD        txreg,20                   ; Espacio
            CALL        transmite
            LOAD        txreg,45                   ; "E"
            CALL        transmite
            LOAD        txreg,52                   ; "R"
            CALL        transmite
            LOAD        txreg,52                   ; "R"
            CALL        transmite
            LOAD        txreg,4F                   ; "O"
            CALL        transmite
            LOAD        txreg,52                   ; "R"
            CALL        transmite
            LOAD        txreg,45                   ; "E"
            CALL        transmite
            LOAD        txreg,53                   ; "S"
            CALL        transmite
            LOAD        txreg,21                   ; "!"
            CALL        transmite
            JUMP        start                      ; Reiniciar con nueva palabra

victoria:   
            LOAD        txreg,0A        ; Carriage Return
            CALL        transmite
            LOAD        txreg,0D        ; Line Feed
            CALL        transmite
            LOAD        txreg,57        ; ASCII 'W' = 0x57
            CALL        transmite
            LOAD        txreg,49        ; ASCII 'I' = 0x49
            CALL        transmite
            LOAD        txreg,4E        ; ASCII 'N' = 0x4E
            CALL        transmite
            LOAD        txreg,21        ; ASCII '!' = 0x21
            CALL        transmite
            JUMP        start           ; Reiniciar con nueva palabra

; Nueva rutina para mostrar contador de errores (lee del periférico)
mostrar_errores:
            LOAD        txreg,0A                   ; Carriage Return
            CALL        transmite
            LOAD        txreg,0D                   ; Line Feed
            CALL        transmite
            LOAD        txreg,45                   ; "E"
            CALL        transmite
            LOAD        txreg,52                   ; "R"
            CALL        transmite
            LOAD        txreg,52                   ; "R"
            CALL        transmite
            LOAD        txreg,4F                   ; "O"
            CALL        transmite
            LOAD        txreg,52                   ; "R"
            CALL        transmite
            LOAD        txreg,45                   ; "E"
            CALL        transmite
            LOAD        txreg,53                   ; "S"
            CALL        transmite
            LOAD        txreg,3A                   ; ":"
            CALL        transmite
            LOAD        txreg,20                   ; Espacio
            CALL        transmite
            ; Leer contador de errores del periférico (puerto 0x49)
            INPUT       cont_errores, 49
            LOAD        txreg, cont_errores
            ADD         txreg, 30                  ; Convertir a ASCII (0='0', 1='1', etc.)
            CALL        transmite
            RETURN

check_errores:            
            ; Verificar contador de errores del periférico
            INPUT       cont_errores, 49    ; Leer contador actual del periférico
            CALL        mostrar_errores     ; Mostrar contador actual
            
            ; Verificar si hay demasiados errores (9 o más)
            LOAD        s6, cont_errores
            SUB         s6, 09          ; Comparar con 9
            JUMP        NC, demasiados_errores  ; Si contador >= 9, demasiados errores
            JUMP	    bucle_intentos        ; Si no son 9 errores, continuar

bucle_intentos:            
            ; Ahora probar 4 letras
            CALL        envia_letra
            CALL        recibe           ; Recibe letra a probar
            LOAD        txreg,rxreg     ; Muestra la letra recibida
            CALL        transmite
            OUTPUT      rxreg,45        ; Envía letra al comparador
            CALL        wait_1bit       ; Espera
            OUTPUT      rxreg,46        ; Captura el resultado
            CALL	resultado
            INPUT       txreg,46        ; Lee resultado de comparaciones
            
            ; Enviar resultado al periférico contador de errores (puerto 0x47)
            OUTPUT      txreg, 47       ; El periférico evaluará si incrementar errores
            
            TR          txreg           ; Mostrar resultado en formato hexadecimal
            LOAD        s6,txreg
            CALL        transmite       ; Muestra resultado
            XOR         s6,46           ; valor hex de "F"
            JUMP        Z,victoria      ; Si es F (resultado XOR = 0), ir a victoria
            JUMP        check_errores   ; Verificar solo contador de errores
            
interrup:   DISABLE     INTERRUPT
            LOAD        txreg,00              
            CALL        inserta_palabra
            
            ; Reset contador de errores en el periférico para nueva palabra (esto era debug, lo hacemos por placa)
            ; LOAD        s0, 00
            ; OUTPUT      s0, 48          ; Reset contador de errores (puerto 0x48)
            
            CALL        wait_1bit
            CALL        wait_1bit       ; Espera adicional para estabilizar

            ; Limpiar posible ruido en el buffer de recepción
            ; INPUT       s0, rs232       ; Leer y descartar posible ruido

            ; Recibir las 4 letras de la palabra
            CALL        recibe
            OUTPUT      rxreg,41        ; Guarda letra1
            CALL        wait_1bit

            CALL        recibe  
            OUTPUT      rxreg,42        ; Guarda letra2
            CALL        wait_1bit

            CALL        recibe
            OUTPUT      rxreg,43        ; Guarda letra3
            CALL        wait_1bit

            CALL        recibe
            OUTPUT      rxreg,44        ; Guarda letra4
            CALL        wait_1bit

            JUMP        bucle_intentos

            RETURNI     ENABLE
            ADDRESS     FF
            JUMP        interrup