load('codex.sage')
def pretty_print(group_tag, index):
	if group_tag not in evens or group_tag == 'D04':
		print 'WTF!'
		return
	if group_tag[1] == '0':
		n = int(eval(group_tag[2:])/2)
	else:
		n = int(eval(group_tag[1:])/2)
	K = superclass_lists[group_tag][index]
	K_str = '{}'
	for i, part in enumerate(K):
		K_str = K_str[:-1] + '{}' + K_str[-1]
		for j, c in enumerate(part):
			if c == 0:
				c_str = 'e'
			elif c == 1:
				c_str = 'r^' + str(int(n/2))
			elif c == 2:
				c_str = 's'
			elif c == 3:
				c_str = 'sr'
			else:
				c_str = 'r^' + str(class_codex[group_tag].index(c))
			K_str = K_str[:-2] + c_str + K_str[-2:]
			if j < len(part) - 1:
				K_str = K_str[:-2] + ', ' + K_str[-2:]
		if i < len(K) - 1:
			K_str = K_str[:-1] + ', ' + K_str[-1]
	X = sct_lists[group_tag][index]
	X_str = '{}'
	for i, part in enumerate(X):
		X_str = X_str[:-1] + '{}' + X_str[-1]
		for j, c in enumerate(part):
			if c == 0:
				c_str = '1'
			elif c in [1,2,3]:
				d = char_codex[group_tag].index(c)-n/2+1
				if d == 3:
					c_str = 'lambda'
				else:
					c_str = 'mu_' + str(2-d) # ex post facto fix
			else:
				c_str = 'chi_' + str(char_codex[group_tag].index(c))
			X_str = X_str[:-2] + c_str + X_str[-2:]
			if j < len(part) - 1:
				X_str = X_str[:-2] + ', ' + X_str[-2:]
		if i < len(X) - 1:
			X_str = X_str[:-1] + ', ' + X_str[-1]
	return K_str, X_str
