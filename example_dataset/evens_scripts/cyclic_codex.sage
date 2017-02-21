cyclic_class_codex = {}
for n in range(3,28):
	G = 'Z' + str(n)
	if n == 3:
		G = 'Z03'
		cyclic_class_codex[G] = [0, 1, 2]
	elif n == 4:
		G = 'Z04'
		cyclic_class_codex[G] = [0, 2, 1, 3]
	elif n == 5:
		G = 'Z05'
		cyclic_class_codex[G] = [0, 1, 2, 3, 4]
	elif n == 6:
		G = 'Z06'
		cyclic_class_codex[G] = [0, 4, 2, 1, 3, 5]
	elif n == 7:
		G = 'Z07'
		cyclic_class_codex[G] = [0, 1, 2, 3, 4, 5, 6]
	elif n == 8:
		G = 'Z08'
		cyclic_class_codex[G] = [0, 4, 2, 5, 1, 6, 3, 7]
	elif n == 9:
		G = 'Z09'
		cyclic_class_codex[G] = [0, 3, 4, 1, 5, 6, 2, 7, 8]
	elif n == 10:
		cyclic_class_codex[G] = [0, 6, 2, 7, 3, 1, 4, 8, 5, 9]
	elif n == 11:
		cyclic_class_codex[G] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
	elif n == 12:
		cyclic_class_codex[G] = [0, 8, 6, 4, 2, 9, 1, 10, 3, 5, 7, 11]
	elif n == 13:
		cyclic_class_codex[G] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
	elif n == 14:
		cyclic_class_codex[G] = [0, 8, 2, 9, 3, 10, 4, 1, 5, 11, 6, 12, 7, 13]
	elif n == 15:
		cyclic_class_codex[G] = [0, 7, 8, 3, 9, 1, 4, 10, 11, 5, 2, 12, 6, 13, 14]
	elif n == 16:
		cyclic_class_codex[G] = [0, 8, 4, 9, 2, 10, 5, 11, 1, 12, 6, 13, 3, 14, 7, 15]
	elif n == 17:
		cyclic_class_codex[G] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
	elif n == 18:
		cyclic_class_codex[G] = [0, 12, 6, 4, 7, 13, 2, 14, 8, 1, 9, 15, 3, 16, 10, 5, 11, 17]
	elif n == 19:
		cyclic_class_codex[G] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]
	elif n == 20:
		cyclic_class_codex[G] = [0, 12, 8, 13, 4, 2, 9, 14, 5, 15, 1, 16, 6, 17, 10, 3, 7, 18, 11, 19]
	elif n == 21:
		cyclic_class_codex[G] = [0, 9, 10, 3, 11, 12, 4, 1, 13, 5, 14, 15, 6, 16, 2, 7, 17, 18, 8, 19, 20]
	elif n == 22:
		cyclic_class_codex[G] = [0, 12, 2, 13, 3, 14, 4, 15, 5, 16, 6, 1, 7, 17, 8, 18, 9, 19, 10, 20, 11, 21]
	elif n == 23:
		cyclic_class_codex[G] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]
	elif n == 24:
		cyclic_class_codex[G] = [0, 16, 12, 8, 6, 17, 4, 18, 2, 9, 13, 19, 1, 20, 14, 10, 3, 21, 5, 22, 7, 11, 15, 23]
	elif n == 25:
		cyclic_class_codex[G] = [0, 5, 6, 7, 8, 1, 9, 10, 11, 12, 2, 13, 14, 15, 16, 3, 17, 18, 19, 20, 4, 21, 22, 23, 24]
	elif n == 26:
		cyclic_class_codex[G] = [0, 14, 2, 15, 3, 16, 4, 17, 5, 18, 6, 19, 7, 1, 8, 20, 9, 21, 10, 22, 11, 23, 12, 24, 13, 25]
	elif n == 27:
		cyclic_class_codex[G] = [0, 9, 10, 3, 11, 12, 4, 13, 14, 1, 15, 16, 5, 17, 18, 6, 19, 20, 2, 21, 22, 7, 23, 24, 8, 25, 26]
