for n in range(3,28):
	if n < 10:
		G = 'Z0' + str(n)
	else:
		G = 'Z' + str(n)
	f = open(G)
	lines = f.readlines()
	f.close()
	L = [lines.index(line) for line in lines if line[0] == '[']
	M = [lines[i + 1] for i in L]

	codex = [0]
	for i in range(n-1):
		codex.append(-1)

	digits = [str(i) for i in range(10)]

	for i in range(n):
		try:
			j = M[i].index(',')
		except ValueError:
			# Only happens when i is 0
			continue
		if i == 0:
			continue
		the_line = M[i][j+2:]
		k = 0
		while the_line[k] in digits:
			k += 1
		the_num = eval(the_line[:k]) - 1
		codex[the_num] = i

	f = open(G + '_codex.txt','w')
	f.write(str(codex))
	f.close()
