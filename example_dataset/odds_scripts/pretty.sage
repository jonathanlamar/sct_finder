class_codex = {}
char_codex = {}
for n in [9, 15, 21, 25, 27, 33, 35, 39, 45]:
	G = 'D' + str(2*n)
	if n == 9:
		class_codex[G] = [0,0,3,1,2,4]
		char_codex[G] = [0,0,3,2,4,1]
	elif n == 15:
		class_codex[G] = [0,0,5,3,6,1,2,4,7]
		char_codex[G] = [0,0,5,3,6,1,4,2,7]
	elif n == 21:
		class_codex[G] = [0,0,7,3,9,6,1,2,4,6,8,10]
		char_codex[G] = [0,0,7,3,9,6,4,5,1,2,10,8]
	elif n == 25:
		class_codex[G] = [0,0,5,15,1,2,3,4,6,7,8,9,11,12]
		char_codex[G] = [0,0,5,10,4,3,2,6,7,11,8,9,12,1]
	elif n == 27:
		class_codex[G] = [0,0,9,3,6,12,1,2,4,5,7,8,10,11,13]
		char_codex[G] = [0,0,9,6,12,3,10,11,7,1,5,13,2,4,8]
	elif n == 33:
		class_codex[G] = [0,0,11,3,6,12,18,24,1,2,4,5,7,8,10,13,14,16]
		char_codex[G] = [0,0,11,3,6,15,12,9,14,7,8,16,2,5,10,1,4,13]
	elif n == 35:
		class_codex[G] = [0,0,7,21,5,16,25,1,2,3,4,6,8,9,11,12,13,16,17]
		char_codex[G] = [0,0,14,7,15,10,5,3,8,2,4,13,1,17,12,9,11,6,16]
	elif n == 39:
		class_codex[G] = [0,0,13,3,6,12,18,24,30,1,2,4,5,7,8,10,11,14,16,17,19]
		char_codex[G] = [0,0,13,15,12,9,3,6,18,4,5,2,7,1,17,8,16,10,11,19,14]
	elif n == 45:
		class_codex[G] = [0,0,15,9,18,5,35,25,3,21,6,12,1,2,4,7,8,11,13,14,16,17,19,22]
		char_codex[G] = [0,0,15,9,18,5,20,10,12,3,6,21,2,4,8,16,1,13,17,22,7,19,14,11]

def pretty_print(group_tag, index):
	n = int(eval(group_tag[1:])/2)
	K = superclass_lists[group_tag][index]
	K_str = '{'
	for i in range(len(K)):
		K_str += '{'
		for j in range(len(K[i])):
			if K[i][j] == 0:
				K_str += 'e'
			elif K[i][j] == 1:
				K_str = K_str[:-1]
				K_str += 's<r> U {'
			else:
				K_str += 'r^'+str(class_codex[group_tag][K[i][j]])+', '
				K_str += 'r^'+str(n-class_codex[group_tag][K[i][j]])
			if j < len(K[i]) - 1 and K[i][j] != 1:
				K_str += ', '
		K_str += '}'
		if i < len(K) - 1:
			K_str += ', '
	K_str += '}'

	X = sct_lists[group_tag][index]
	X_str = '{'
	for i in range(len(X)):
		X_str += '{'
		for j in range(len(X[i])):
			if X[i][j] == 0:
				X_str += '1'
			elif X[i][j] == 1:
				X_str += 'lambda'
			else:
				X_str += 'chi_'+str(char_codex[group_tag][X[i][j]])
			if j < len(X[i]) - 1:
				X_str += ', '
		X_str += '}'
		if i < len(X) - 1:
			X_str += ', '
	X_str += '}'
	return K_str, X_str

def pretty_print2(group_tag, index):
	n = int(eval(group_tag[1:])/2)
	K = superclass_lists[group_tag][index]
	K_str = '{'
	for i in range(len(K)):
		K_str += '{'
		for j in range(len(K[i])):
			if K[i][j] == 0:
				K_str += 'e'
			elif K[i][j] == 1:
				K_str = K_str[:-1]
				K_str += 's<r>'
			else:
				K_str += 'r^'+str(class_codex[group_tag][K[i][j]])+', '
				K_str += 'r^'+str(n-class_codex[group_tag][K[i][j]])
			if j < len(K[i]) - 1:
				K_str += ', '
		if K[i][j] != 1:
			K_str += '}'
		if i < len(K) - 1:
			K_str += ', '
	K_str += '}'

	X = sct_lists[group_tag][index]
	X_str = '{'
	for i in range(len(X)):
		X_str += '{'
		for j in range(len(X[i])):
			if X[i][j] == 0:
				X_str += '1'
			elif X[i][j] == 1:
				X_str += 'lambda'
			else:
				X_str += 'chi_'+str(char_codex[group_tag][X[i][j]])
			if j < len(X[i]) - 1:
				X_str += ', '
		X_str += '}'
		if i < len(X) - 1:
			X_str += ', '
	X_str += '}'
	return K_str, X_str

def tex_pretty_print(group_tag, index):
	n = int(eval(group_tag[1:])/2)
	K = superclass_lists[group_tag][index]
	K_str = '\\big\{'
	for i in range(len(K)):
		K_str += '\{'
		for j in range(len(K[i])):
			if K[i][j] == 0:
				K_str += 'e'
			elif K[i][j] == 1:
				K_str = K_str[:-2]
				K_str += 's\\langle r\\rangle \\cup \{'
			else:
				K_str += 'r^{'+str(class_codex[group_tag][K[i][j]])+'}, '
				K_str += 'r^{'+str(n-class_codex[group_tag][K[i][j]])+'}'
			if j < len(K[i]) - 1 and K[i][j] != 1:
				K_str += ', '
		K_str += '\}'
		if i < len(K) - 1:
			K_str += ', '
	K_str += '\\big\}'

	X = sct_lists[group_tag][index]
	X_str = '\\big\{'
	for i in range(len(X)):
		X_str += '\{'
		for j in range(len(X[i])):
			if X[i][j] == 0:
				X_str += '1'
			elif X[i][j] == 1:
				X_str += '\\lambda'
			else:
				X_str += '\\chi_{'+str(char_codex[group_tag][X[i][j]])+'}'
			if j < len(X[i]) - 1:
				X_str += ', '
		X_str += '\}'
		if i < len(X) - 1:
			X_str += ', '
	X_str += '\\big\}'
	return K_str, X_str
