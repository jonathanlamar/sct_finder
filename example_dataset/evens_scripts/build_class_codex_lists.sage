for n in range(4,43,2):
	G = 'D' + str(2*n)
	f = open(G + '_classes')
	lines = f.readlines()
	f.close()
	L = [lines.index(line) for line in lines if line[0] == '[']
	M = [lines[i + 1] for i in L]

	codex = [0,2,3]
	for i in range(n/2):
		codex.append(-1)

	digits = [str(i) for i in range(10)]

	for i in range((n/2) + 3):
		try:
			j = M[i].index(',')
		except ValueError:
			# Only happens when i is 0
			continue
		if i in [0,2,3]:
			continue
		the_line = M[i][j+2:]
		k = 0
		while the_line[k] in digits:
			k += 1
		the_num = eval(the_line[:k]) - 1
		if the_num > (n/2):
			the_num = n - the_num
		codex[the_num + 2] = i

	f = open(G + '_codex.txt','w')
	f.write(str(codex))
	f.close()
