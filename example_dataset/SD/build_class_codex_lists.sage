load('scripts_to_check_hunches.sage') # Need possible_a
M = []
for n in range(7,22):
	for p in euler_phi(n).prime_divisors():
		for a in possible_a(n,p):
			if n < 10:
				n_str = '0' + str(n)
			else:
				n_str = str(n)
			if p < 10:
				p_str = '0' + str(p)
			else:
				p_str = str(p)
			if a < 10:
				a_str = '0' + str(a)
			else:
				a_str = str(a)
			G = 'SD(' + n_str + ',' + p_str + ',' + a_str + ')'
			f = open(G + '_conj.txt','r')
			lines = f.readlines()
			f.close()
			L = [lines.index(line) + 1 for line in lines if line[0] == '[']
			M.append((n,p,a,len(L)))
f = open('output.txt','w')
f.write(str(M))
f.close()
			# These lines put the reflections in the codex. We need to put the conjugacy classes of the complement.
			#codex = [0,2,3]
			#for i in range(n/2):
			#	codex.append(-1)

			#digits = [str(i) for i in range(10)]

			#for i in range((n/2) + 3):
			#	try:
			#		j = L[i].index(',')
			#	except ValueError:
			#		# Only happens when i is 0
			#		continue
			#	if i in [0,2,3]:
			#		continue
			#	the_line = L[i][j+2:]
			#	k = 0
			#	while the_line[k] in digits:
			#		k += 1
			#	the_num = eval(the_line[:k]) - 1
			#	if the_num > (n/2):
			#		the_num = n - the_num
			#	codex[the_num + 2] = i

			#f = open(G + '_codex.txt','w')
			#f.write(str(codex))
			#f.close()
