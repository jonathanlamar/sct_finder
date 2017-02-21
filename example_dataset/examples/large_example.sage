import time # delete if you want (see below)

def possible_a(n,p):
	L = [a for a in range(2,n-1) if gcd(a,n) == 1 and (a^p) % n == 1]
	for a in L:
		for b in L:
			if b != a and a*b % n == 1:
				L.remove(b)
	return L

for n in range(7,21):
	for p in euler_phi(n).prime_divisors():
		for a in possible_a(n,p):
			magma.eval('A<x> := CyclicGroup('+str(n)+');')
			magma.eval('B<y> := CyclicGroup('+str(p)+');')
			magma.eval('phi := hom<B -> AutomorphismGroup(A) | y :-> hom<A -> A | x :-> x^'+str(a)+'>>;')
			magma_group_name = 'SemidirectProduct(A,B,phi)'
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
			short_group_nickname = 'SD(' + n_str + ',' + p_str + ',' + a_str + ')'
			load('../sct_finder.sage')
			sct_theories = sct_finder(magma_group_name,short_group_nickname)
			start_time = time.time() # delete if you want
			sct_theories.go()
			sct_theories.export_data()
			end_time = time.time() # delete if you want

			# delete this if you want, I just wanted to see timings on some examples - Jon
			f = open(short_group_nickname+'_delete_when_done.txt','a')
			f.write('\nTotal running time: '+str(end_time - start_time)+' seconds.')
			f.close()
