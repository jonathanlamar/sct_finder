def possible_a(n,p):
	L = [a for a in range(2,n-1) if gcd(a,n) == 1 and (a^p) % n == 1]
	for a in L:
		for b in L:
			if b != a and a*b % n == 1:
				L.remove(b)
	return L

def index_set(n,p,a):
	if a not in possible_a(n,p):
		return -1
	L = [ell for ell in range(n) if ell % n != (ell*a) % n]
	M = []
	N = []
	for ell in L:
		M.append(min([(ell*a^i)%n for i in range(p)]))
		N.append(Set([(ell*a^i)%n for i in range(p)]))
	M = list(Set(M))
	N = list(Set(N))
	print L
	print M
	print N

def find_all_SD(n):
	# Given n, this method returns all nonabelian and nondihedral semidirect products of Zn with Zp for some prime p dividing the order of Aut(Zn).
	divs = prime_divisors(euler_phi(n))
	SD = []
	for p in divs:
		for a in possible_a(n,p):
			SD.append((n,p,a))
	return SD

SD = [G for G in tags if G[:2] == 'SD']

def get_params(G):
	if G not in SD:
		return -1
	n_str = G[3:5]
	p_str = G[6:8]
	a_str = G[9:11]
	if n_str[0] == '0':
		n = sage_eval(n_str[1:])
	else:
		n = sage_eval(n_str)
	if p_str[0] == '0':
		p = sage_eval(p_str[1:])
	else:
		p = sage_eval(p_str)
	if a_str[0] == '0':
		a = sage_eval(a_str[1:])
	else:
		a = sage_eval(a_str)
	return n, p, a

# If this remains unnamed, safe to delete. - J. 11/28
def foo(G):
	n,p,a = get_params(G)
	print G+'\t'+str(n)+'\t'+str(euler_phi(n))+'\t'+str(p)+'\t'+str(a)+'\t', len(sct_characteristic_subposets[G]) == len(sct_lists[G])

def get_coatoms(G):
	return [i for i in sct_posets[G] if sct_posets[G].covers(i,sct_posets[G].maximal_elements()[0])]

def number_coatoms(G):
	return len(get_coatoms(G))

codex = load('SD_codex.sobj')
def pretty_print(G, i):
	if G not in SD:
		print 'WTF!'
		return
	K = superclass_lists[G][i]
	K_str = '{}'
	for i, part in enumerate(K):
		K_str = K_str[:-1] + '{}' + K_str[-1]
		for j, c in enumerate(part):
			K_str = K_str[:-2] + codex[G][c] + K_str[-2:]
			if j < len(part) - 1:
				K_str = K_str[:-2] + ', ' + K_str[-2:]
		if i < len(K) - 1:
			K_str = K_str[:-1] + ', ' + K_str[-1]
	return K_str
