def possible_a(n, p):
	L = [a for a in range(2,n-1) if gcd(a,n) == 1 and (a^p) % n == 1]
	for a in L:
		for b in L:
			if b != a and a*b % n == 1:
				L.remove(b)
	return L

def fix_word(in_str, n, p, a):
	# Example input: S = 'x^-1y^-1x^-1', n = 8, p = 2, a = 5
	# Example output: 'x^2y'
	numbers = [str(i) for i in range(10)]
	bases = ['x', 'y']
	# Replace 'x^-1y^-1x^-1' with 'xxxxxxxyxxxxxxx'
	out_str = ''
	for i,s in enumerate(in_str):
		if s in bases:
			if i == len(in_str) - 1:
				out_str += s
				break
			elif in_str[i+1] == '*':
				out_str += s
			elif in_str[i+1] == '^' and in_str[i+2] in numbers:
				j = min([k for k,t in enumerate(in_str) if k > i+1 and t in numbers])
				for k in range(eval(in_str[i+2:j+1])):
					out_str += s
			elif in_str[i+1] == '^' and in_str[i+2] == '-':
				j = min([k for k,t in enumerate(in_str) if k > i+1 and t in numbers])
				if s == 'x':
					for k in range(n-eval(in_str[i+3:j+1])):
						out_str += s
				else:
					for k in range(n-eval(in_str[i+3:j+1])):
						out_str += s
	# TODO: Keep fixing
	return out_str

class_codex = {G : [] for G in SD}
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
			conj_file = open(G + '_conj.txt','r')
			lines = conj_file.readlines()
			conj_file.close()
			x = lines[0][4:-1]
			y = lines[1][4:-1]
			P = PermutationGroup([x,y], canonicalize=False)
			x = P(x)
			y = P(y)
			L = [lines.index(line) + 1 for line in lines if line[0] == '[']
			conj_reps = [P(lines[i][4:-1]) for i in L[1:]]
			codex = ['e']
			for x in conj_reps:
				S = x.word_problem([x,y], display=False)[0]
				S = S.replace('x1','x')
				S = S.replace('x2','y')
				S = fix_word(S, n, p, a) # The word problem algorithm does not return words of the form a^ib^j.
				codex.append(S)
			class_codex[G] = codex
save(class_codex, 'SD_codex')
