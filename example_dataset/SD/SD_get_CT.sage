def possible_a(n,p):
	L = [a for a in range(2,n-1) if gcd(a,n) == 1 and (a^p) % n == 1]
	for a in L:
		for b in L:
			if b != a and a*b % n == 1:
				L.remove(b)
	return L

f1 = open('SD_all_CT.txt','w')
for n in range(7,22):
	for p in euler_phi(n).prime_divisors():
		for a in possible_a(n,p):
			magma.eval('A<x> := CyclicGroup('+str(n)+');')
			magma.eval('B<y> := CyclicGroup('+str(p)+');')
			magma.eval('phi := hom<B -> AutomorphismGroup(A) | y :-> hom<A -> A | x :-> x^'+str(a)+'>>;')
			magma.eval('G<g,h> := SemidirectProduct(A,B,phi);')
			order = magma.eval('Order(G);')
			classes = magma.eval('CharacterTable(G);')
			x = magma.eval('g;')
			y = magma.eval('h;')
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
			f2 = open(G + '_CT.txt','w')
			f1.write(G + '\n' + 'x = ' + x + '\ny = ' + y + '\n' + classes)
			f2.write('x = ' + x + '\ny = ' + y + '\n' + classes)
			f2.close()
