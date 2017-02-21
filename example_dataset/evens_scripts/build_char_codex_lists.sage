for G in [H for H in evens if H != 'D04']:
	if G == 'D08':
		n = 4
	else:
		n = sage_eval(str(int(eval(G[1:])/2)))
	char_list = [0]*int(n/2+3)
	L = [str(x) for x in char_tables[G][4:,class_codex[G][1]].transpose()[0]]
	for k in range(1,n/2):
		M = [x == str(E(n)^k + E(n)^(n-k)) for x in L]
		if sum(M) != 1:
			print 'Error at n =', n, ' and k =', k, '.'
			break
		char_list[k] = M.index(True) + 4
	L = char_tables[G][1:4,2:4]
	for k in [0,1,2]:
		if L[k,0] == -1 and L[k,1] == 1:
			char_list[n/2] = k+1
		elif L[k,0] == -1 and L[k,1] == -1:
			char_list[n/2+2] = k+1
		elif L[k,0] == 1 and L[k,1] == -1:
			char_list[n/2+1] = k+1
	f = open(G+'_char_list.txt','w')
	f.write(str(char_list))
	f.close()
