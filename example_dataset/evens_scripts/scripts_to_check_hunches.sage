def nonfact_implies_s_sr_apart(group_tag):
	# This returns true if every nonfactorizable SCT (other than M(G)) has s and sr in separate superclasses.
	if group_tag not in evens or group_tag == 'D04':
		print 'WTF!'
		return False
	implication_is_true = True
	for i in sct_nonfact_subposets[group_tag]:
		if i == sct_posets[group_tag].maximal_elements()[0]:
			continue
		else:
			# get the parts containing s and sr
			part_s = -1
			part_sr = -1
			P = superclass_lists[group_tag][i]
			for part in P:
				if 2 in part:
					part_s = P.index(part)
				if 3 in part:
					part_sr = P.index(part)
			if part_s == part_sr:
				print P
				implication_is_true = False
	return implication_is_true

def can_refine_products_over_r(group_tag):
	# This returns true if every SCT which factors over <r> can be refined be detaching s and rs.
	if group_tag not in evens or group_tag == 'D04':
		print 'WTF!'
		return False
	can_refine = True
	number_of_failures = 0
	prods_over_r = [i for i in sct_posets[group_tag] if Set([2,3]) in superclass_lists[group_tag][i]]
	for j in prods_over_r:
		P = SetPartition([[2],[3]] + [list(part) for part in superclass_lists[group_tag][j] if part != Set([2,3])])
		if P not in superclass_lists[group_tag]:
			can_refine = False
			number_of_failures += 1
			print 'G =', group_tag, 'j =', j, 'P =', P, 'is not in superclass list.'
			break
	print 'number of failures:', number_of_failures
	return can_refine

def s_rs_glued(group_tag, i):
	# This returns true if s and rs lie in the same superclass, and false otherwise.
	P = superclass_lists[group_tag][i]
	for part in P:
		if 2 in part and 3 in part:
			return True
	return False

def s_sr_glued_implies_blue(group_tag):
	# This returns true if every SCT which has s and sr in the same superclass is also factorizable.
	if group_tag not in evens or group_tag == 'D04':
		print 'WTF!'
		return False
	implication_is_true = True
	I = [i for i in sct_posets[group_tag] if s_rs_glued(group_tag,i) and i not in sct_posets[group_tag].maximal_elements()]
	return all([is_any_fact(group_tag, i) for i in I])

def list_of_normals(group_tag, i):
	# This returns the list of all d for which sct number i factors over <r^d>.
	if group_tag not in evens or group_tag == 'D04':
		print 'WTF!'
		return []
	the_list = []
	if group_tag == 'D08':
		n = 4
	else:
		n = sage_eval(str(int(eval(group_tag[1:])/2)))
	divs = [d for d in n.divisors() if d != n]
	for d in divs:
		if is_factorable_1(group_tag,d,i):
			the_list.append(d)
	return the_list

def reflect_plot(group_tag):
	if group_tag not in evens or group_tag == 'D04':
		print 'WTF!'
		return
	color_dict = {'#2176C7' : [], '#D11C24' : []}
	for i in sct_posets[group_tag]:
		if s_rs_glued(group_tag,i):
			color_dict['#2176C7'].append(i)
		else:
			color_dict['#D11C24'].append(i)
	P = sct_posets[group_tag].plot(vertex_colors = color_dict)
	Q = text(group_tag + ' reflections glued', (0,0), axes=False, color='black')
	return P + Q

def reflect_plot_2(group_tag):
	if group_tag not in evens or group_tag == 'D04':
		print 'WTF!'
		return
	color_dict = {'#2176C7' : [], '#D11C24' : [], '#859900' : []}
	for i in sct_posets[group_tag]:
		if s_rs_glued(group_tag,i) and is_factorable_1(group_tag,1,i):
			color_dict['#2176C7'].append(i)
		elif s_rs_glued(group_tag,i) and not is_factorable_1(group_tag,1,i):
			color_dict['#859900'].append(i)
		else:
			color_dict['#D11C24'].append(i)
	P = sct_posets[group_tag].plot(vertex_colors = color_dict)
	Q = text(group_tag + ' reflections glued\nblue = factorizable over <r>\ngreen = not', (0,0), axes=False, color='black')
	return P + Q

load('cyclic_codex.sage')

def inverse_glued(group_tag, i):
	if group_tag not in cyclics:
		print 'WTF!'
		return
	if group_tag[1] == '0':
		n = sage_eval(group_tag[2:])
	else:
		n = sage_eval(group_tag[1:])
	P = superclass_lists[group_tag][i]
	for j in range(1,n):
		k = cyclic_class_codex[group_tag][j]
		l = cyclic_class_codex[group_tag][n-j]
		for part in P:
			if (k in part and l not in part) or (k not in part and l in part):
				return False
	return True

def D2n_invariant_plot(group_tag):
	if group_tag not in cyclics:
		print 'WTF!'
		return
	color_dict = {'#2176C7' : [], '#D11C24' : []}
	for i in sct_posets[group_tag]:
		if inverse_glued(group_tag,i):
			color_dict['#2176C7'].append(i)
		else:
			color_dict['#D11C24'].append(i)
	P = sct_posets[group_tag].plot(vertex_colors = color_dict)
	Q = text(group_tag + ' x~x^(-1) for all x.', (0,0), axes=False, color='black')
	return P + Q

def nonchar_implies_s_rs_not_singletons(group_tag):
	# This returns true if every noncharacteristic SCT has s and rs lying in different parts, at least one of them nontrivial.
	I = [i for i in sct_posets[group_tag] if i not in sct_characteristic_subposets[group_tag]]
	result_holds = True
	for i in I:
		P = superclass_lists[group_tag][i]
		for part in P:
			if 2 in part:
				s_part = part
			if 3 in part:
				rs_part = part
		if s_part == rs_part or (len(s_part) == 1 and len(rs_part) == 1):
			result_holds = False
			break
	return result_holds

def char_implies_srs_or_s_rs(group_tag):
	# This returns true if every characteristic SCT has s and rs glued or both singletons.
	I = [i for i in sct_posets[group_tag] if i in sct_characteristic_subposets[group_tag]]
	result_holds = True
	for i in I:
		P = superclass_lists[group_tag][i]
		for part in P:
			if 2 in part:
				s_part = part
			if 3 in part:
				rs_part = part
		if s_part != rs_part and (len(s_part) > 1 or len(rs_part) > 1):
			result_holds = False
			break
	return result_holds

def char_or_fact_plot(G):
	# Blue if the SCT is either characteristic or factors over one of the subgroups <r^2,s> or <r^2,rs>, red otherwise.
	if G not in evens:
		print 'WTF!'
		return
	color_dict = {'#2176C7' : [], '#D11C24' : [], '#859900' : []}
	for i in sct_posets[G]:
		if i in sct_characteristic_subposets[G]:
			color_dict['#859900'].append(i)
		elif is_factorable_2(G,i) or is_factorable_3(G,i):
			color_dict['#2176C7'].append(i)
		else:
			color_dict['#D11C24'].append(i)
	P = sct_posets[G].plot(vertex_colors = color_dict)
	Q = text(G + ': blue = factorable over <r^2,s> or <r^2,rs>,\ngreen = characteristic.', (0,0), axes=False, color='black')
	return P + Q
	#(P + Q).show()

def split_plot(G):
	# Blue if the SCT clumps r to s and r^2 to rs in distinct parts, Green if the SCT clumps r^2 to s and r to rs in distinct
	# parts.
	if G not in evens:
		print 'WTF!'
		return
	color_dict = {'#2176C7' : [], '#D11C24' : [], '#859900' : []}
	for i in sct_posets[G]:
		K = superclass_lists[G][i]
		for part in K:
			if 2 in part:
				s_part = part
			if 3 in part:
				rs_part = part
		if class_codex[G][1] in s_part and class_codex[G][2] in rs_part and s_part != rs_part:
			color_dict['#2176C7'].append(i)
		elif class_codex[G][1] in rs_part and class_codex[G][2] in s_part and s_part != rs_part:
			color_dict['#859900'].append(i)
		else:
			color_dict['#D11C24'].append(i)
	P = sct_posets[G].plot(vertex_colors = color_dict)
	Q = text(G + ': blue = r ~ s and r^2 ~ rs in different parts.\ngreen = r ~ rs and r^2 ~ s in different parts.', (0,0), axes=False, color='black')
	return P + Q

def min_divs(G, d):
	# Returns true if the supercharacter theory S_d exists, false otherwise.
	codex = class_codex[G]
	K = SetPartition([[0],[2,3]+[codex[k] for k in [m for m in range(1,n/2+1) if m%d != 0]]]+[[codex[k]] for k in range(d,n/2+1,d)])
	return K

def mu1_or_mu2_alone(G, i):
	# Returns true if one of the characters mu1 or mu2 lies in a part by itself in ith supercharacter theory.
	if G[1] == '0':
		n = sage_eval(str(int(eval(G[2:])/2)))
	else:
		n = sage_eval(str(int(eval(G[1:])/2)))
	codex = char_codex[G]
	X = sct_lists[G][i]
	for part in X:
		if codex[n/2] in part:
			mu1_part = part
		if codex[n/2+1] in part:
			mu2_part = part
	return len(mu1_part) == 1 or len(mu2_part) == 1

def mu1_or_mu2_alone_and_other_not(G, i):
	# Returns true if one of the characters mu1 or mu2 lies in a part by itself in ith supercharacter theory and the other does not.
	if G[1] == '0':
		n = sage_eval(str(int(eval(G[2:])/2)))
	else:
		n = sage_eval(str(int(eval(G[1:])/2)))
	codex = char_codex[G]
	X = sct_lists[G][i]
	for part in X:
		if codex[n/2] in part:
			mu1_part = part
		if codex[n/2+1] in part:
			mu2_part = part
	return (len(mu1_part) == 1 and len(mu2_part) > 1) or (len(mu1_part) > 1 and len(mu2_part) == 1)

def mu2_alone_mu1_not(G, i):
	# Returns true if one of the characters mu1 or mu2 lies in a part by itself in ith supercharacter theory and the other does not.
	if G[1] == '0':
		n = sage_eval(str(int(eval(G[2:])/2)))
	else:
		n = sage_eval(str(int(eval(G[1:])/2)))
	codex = char_codex[G]
	X = sct_lists[G][i]
	for part in X:
		if codex[n/2] in part:
			mu1_part = part
		if codex[n/2+1] in part:
			mu2_part = part
	return len(mu1_part) > 1 and len(mu2_part) == 1

def cleave_1(G, i):
	# Returns an integer j, which is the index of the cleaving (1) of i if i glues mu1 and mu2, and -1 otherwise.
	if G[1] == '0':
		n = sage_eval(str(int(eval(G[2:])/2)))
	else:
		n = sage_eval(str(int(eval(G[1:])/2)))
	codex = char_codex[G]
	X = sct_lists[G][i]
	for part in X:
		if codex[n/2] in part:
			mu1_part = part
		if codex[n/2+1] in part:
			mu2_part = part
	if mu1_part != mu2_part:
		return -1
	L = [k for k in mu1_part if k != codex[n/2+1]]
	Y = SetPartition([list(part) for part in X if part != mu1_part]+[[codex[n/2+1]],L])
	if Y in sct_lists[G]:
		j = sct_lists[G].index(Y)
		return sct_lists[G].index(Y)
	else:
		return -1

def cleave_2(G, i):
	# Returns an integer j, which is the index of the cleaving (2) of i if i glues mu1 and mu2, and -1 otherwise.
	if G[1] == '0':
		n = sage_eval(str(int(eval(G[2:])/2)))
	else:
		n = sage_eval(str(int(eval(G[1:])/2)))
	codex = char_codex[G]
	X = sct_lists[G][i]
	for part in X:
		if codex[n/2] in part:
			mu1_part = part
		if codex[n/2+1] in part:
			mu2_part = part
	if mu1_part != mu2_part:
		return -1
	L = [k for k in mu1_part if k != codex[n/2]]
	Y = SetPartition([list(part) for part in X if part != mu1_part]+[[codex[n/2]],L])
	if Y in sct_lists[G]:
		j = sct_lists[G].index(Y)
		return sct_lists[G].index(Y)
	else:
		return -1

def cleave_plot(G):
	# domain of psi_i = green, range of psi_0 = blue or purple, range of psi_1 = red or purple, range of both = purple,
	# white = everything else.
	if G not in evens:
		print 'WTF!'
		return
	#			   green           white           blue            red             purple
	color_dict = {'#859900' : [], '#fdf6e3' : [], '#268bd2' : [], '#dc322f' : [], '#d33682' : []}
	visited_vals = []
	for i in sct_posets[G]:
		j = cleave_1(G,i)
		k = cleave_2(G,i)
		if j != -1:
			if k == -1:
				print 'WTF!'
				return
			else:
				color_dict['#859900'].append(i)
				if j != k:
					color_dict['#268bd2'].append(j)
					color_dict['#dc322f'].append(k)
				else:
					color_dict['#d33682'].append(j)
		else:
			if k != -1:
				print 'WTF!'
				return
			else:
				color_dict['#fdf6e3'].append(i)
	for i in color_dict['#268bd2'] + color_dict['#dc322f'] + color_dict['#d33682']:
		if i in color_dict['#fdf6e3']:
			color_dict['#fdf6e3'].remove(i)
	P = sct_posets[G].plot(vertex_colors = color_dict)
	Q = text(G + ':\ndomain of psi_i = green,\nrange of psi_0 = blue or purple,\nrange of psi_1 = red or purple,\nrange of both = purple\nwhite = everything else', (0,0), axes=False, color='black')
	return P + Q

def simple_cleave_plot(G):
	# cleaved = blue, not cleaved = red
	if G not in evens:
		print 'WTF!'
		return
	#			   blue            red
	color_dict = {'#268bd2' : [], '#dc322f' : []}
	for i in sct_posets[G]:
		j = cleave_1(G,i)
		k = cleave_2(G,i)
		if j != -1:
			if k == -1:
				print 'WTF!'
				return
			else:
				color_dict['#268bd2'].append(j)
				color_dict['#268bd2'].append(k)
		else:
			if k != -1:
				print 'WTF!'
				return
	color_dict['#268bd2'] = list(set(color_dict['#268bd2']))
	color_dict['#dc322f'] = [i for i in sct_posets[G] if i not in color_dict['#268bd2']]
	P = sct_posets[G].plot(vertex_colors = color_dict)
	Q = text(G + ':\nCleaved = blue, not cleaved = red.', (0,0), axes=False, color='black')
	return P + Q

def is_characteristic(G, i):
	# Shorthand
	return i in sct_characteristic_subposets[G]

def is_cleavable(G, i):
	# if SCT i can be cleaved (either by psi_0 or psi_1), this returns True, otherwise False.
	return cleave_1(G,i) != -1

def is_cleaved(G, i):
	# if SCT i lies in the range of either phi_0 or phi_1, this returns True, otherwise False.
	L = []
	for j in sct_posets[G]:
		if cleave_1(G,j) != -1:
			L += [cleave_1(G,j), cleave_2(G,j)]
	return i in L

def parity_check(G, i):
	# If SCT number i has the property that all superclasses of rotations (and only rotations) respect parity (i.e., for all r^k
	# r^l in K, k=l mod 2), return True, else False.
	if G not in evens:
		print 'WTF!'
		return -1
	# Not sure n here is necessary (see below).
	if G[1] == '0':
		n = sage_eval(str(int(eval(G[2:])/2)))
	else:
		n = sage_eval(str(int(eval(G[1:])/2)))
	K = superclass_lists[G][i]
	codex = class_codex[G]
	for part in K:
		if 2 in part or 3 in part:
			continue
		powers_of_r = []
		for j in part:
			if j == 1:
				powers_of_r.append(n/2) # I think I can use the codex as below without this escape.
			else:
				powers_of_r.append(codex.index(j))
		if len(set([k % 2 for k in powers_of_r])) > 1:
			return False
	return True

def cleavable_iff_parity(G):
	# Checks whether cleavability is equivalent to gluing reflections and respecting parity.
	return [is_cleavable(G,i) for i in sct_posets[G]] == [parity_check(G,i) and s_rs_glued(G,i) for i in sct_posets[G]]

def Tp(G,p):
	if G[1] == '0':
		n = sage_eval(str(int(eval(G[2:])/2)))
	else:
		n = sage_eval(str(int(eval(G[1:])/2)))
	divs = [d for d in n.divisors() if is_prime(d)]
	if p not in divs:
		print 'WTF!'
		return
	else:
		codex = class_codex[G]
		return SetPartition([[0],[2,3],[codex[k] for k in range(1,n/2+1) if k%p != 0]]+[[codex[k]] for k in range(p,n/2+1,p)])
	
def is_in_Q(G, i):
	# if the supercharacter theory can have r and rs glued, returns true, else false
	if G[1] == '0':
		n = sage_eval(str(int(eval(G[2:])/2)))
	else:
		n = sage_eval(str(int(eval(G[1:])/2)))
	divs = [d for d in n.divisors() if is_prime(d)]
	K = superclass_lists[G][i]
	codex = class_codex[G]
	is_clumpable = False
	for p in divs:
		Tp = SetPartition([[0],[2,3],[codex[k] for k in range(1,n/2+1) if k%p != 0]]+[[codex[k]] for k in range(p,n/2+1,p)])
		if K*Tp == Tp:
			is_clumpable = True
	return is_clumpable

#def PQR_plot(G):
#	# This plots the characteristic supercharacter theories of G, color-coding the subsets P, Q, and R.
#	#			   green           blue            red             purple
#	color_dict = {'#859900' : [], '#268bd2' : [], '#dc322f' : [], '#d33682' : []}
#	for i in sct_posets[G]:
#		if i in sct_characteristic_subposets[G]:
#			color_dict['#268bd2'].append(i) # blue
#		else:
#			color_dict['#dc322f'].append(i) # red
#	for i in sct_characteristic_subposets[G]:
#		if is_cleaved(G,i) and not is_in_Q(G,i):
#			color_dict['#268bd2'].remove(i)
#			color_dict['#859900'].append(i) # green
#		elif not is_cleaved(G,i) and is_in_Q(G,i):
#			color_dict['#268bd2'].remove(i)
#			color_dict['#d33682'].append(i)
#		elif is_cleaved(G,i) and is_in_Q(G,i):

def characteristic_core(G, i):
	P = sct_posets[G]
	return P.subposet([j for j in sct_characteristic_subposets[G] if P.le(j,i)]).maximal_elements()[0]

def twin(G, i):
	# Returns the (index of the) other element of the orbit of SCT number i.  If SCT i is characteristic, returns i.
	if G not in evens:
		print 'WTF!'
		return
	K = superclass_lists[G][i]
	num_irreps = max([max(part) for part in K]) + 1
	f = range(num_irreps)
	f[2] = 3
	f[3] = 2
	L = SetPartition([[f[i] for i in part] for part in K])
	return superclass_lists[G].index(L)

def nonchar_meets_are_nice(G):
	# returns true if the meet of any two noncharacteristic supercharacter theories is partition-theoretic.
	nonchars = [i for i in sct_posets[G] if i not in sct_characteristic_subposets[G]]
	pairs = Set([Set([i,twin(G,i)]) for i in nonchars])
	P = sct_posets[G]
	are_nice = True
	for pair in pairs:
		if superclass_lists[G][P.meet(pair[0],pair[1])] != superclass_lists[G][pair[0]]*superclass_lists[G][pair[1]]:
			are_nice = False
			break
	return are_nice

def lambda_with_mu0_implies_mu1_alone(G):
	# This requires some explanation.  If, for all supercharacter theories with {mu0}\cup X0 and {mu1}cup X1 as supercharacters,
	# lambda in X0 implies X1 empty, then returns true.  Otherwise false.
	codex = char_codex[G]
	if G[1] == '0':
		n = sage_eval(str(int(eval(G[2:])/2)))
	else:
		n = sage_eval(str(int(eval(G[1:])/2)))
	mu0 = codex[1+n/2]
	mu1 = codex[n/2]
	lam = codex[2+n/2]
	for i in sct_posets[G]:
		X = sct_lists[G][i]
		for part in X:
			if mu0 in part:
				mu0_part = part
			if mu1 in part:
				mu1_part = part
		if lam not in mu0_part:
			continue
		if mu1_part == mu0_part:
			continue
		# At this point, we know mu0 and lambda are together and they are separate from mu1.
		if len(mu1_part) > 1:
			return False
	return True

def is_factorable_over_cyclic_subgroup(G, i):
	if G not in evens or G == 'D04':
		print 'WTF!'
		return
	if G == 'D08':
		n = 4
	else:
		n = sage_eval(str(int(eval(G[1:])/2)))
	divs = [d for d in n.divisors() if d != n]
	return any([is_factorable_1(G,d,i) for d in divs])

def fact_over_cyclic_plot(G):
	if G not in evens or G == 'D04':
		print 'WTF!'
		return
	color_dict = {'#2176C7' : [], '#D11C24' : []}
	if G == 'D08':
		n = 4
	else:
		n = sage_eval(str(int(eval(G[1:])/2)))
	for i in sct_posets[G]:
		if is_factorable_over_cyclic_subgroup(G,i):
			color_dict['#2176C7'].append(i)
		else:
			color_dict['#D11C24'].append(i)
	P = sct_posets[G].plot(vertex_colors = color_dict)
	Q = text(G + ' factorable over a cyclic subgroup', (0,0), axes=False, color='black')
	return P + Q

def normal_sct(G, S):
	if G not in evens or G == 'D04':
		print 'WTF!'
		return
	if G == 'D08':
		n = 4
	else:
		n = sage_eval(str(int(eval(G[1:])/2)))
	elements = ['M0', 'M1', 'G'] + n.divisors()
	relations = [['M0', 'G'], ['M1', 'G'], [1, 'G']]
	for d in n.divisors():
		if d % 2 == 0:
			relations += [[d, 'M0'], [d, 'M1']]
		for e in n.divisors():
			if d % e == 0:
				relations.append([d, e])
	P = LatticePoset([elements, relations])
	if n not in S:
		S.append(n)
	if 'G' not in S:
		S.append('G')
	AS = P.sublattice(S)
	subgroups = {x : [] for x in AS}
	for x in AS:
		if x == 'G':
			subgroups[x] = range(n/2+3)
		elif x == 'M0':
			subgroups[x] = [0,2]+[class_codex[G][k] for k in range(2,n/2+1,2)]
		elif x == 'M1':
			subgroups[x] = [0,3]+[class_codex[G][k] for k in range(2,n/2+1,2)]
		else:
			subgroups[x] = [0]+[class_codex[G][k] for k in range(x,n/2+1,x)]
	for x in AS:
		for y in AS.order_ideal([x]):
			if y == x:
				continue
			for k in subgroups[y]:
				if k in subgroups[x]:
					subgroups[x].remove(k)
	return superclass_lists[G].index(SetPartition([subgroups[x] for x in AS if len(subgroups[x]) > 0]))

def get_normal_scts(G):
	if G not in evens or G == 'D04':
		print 'WTF!'
		return
	if G == 'D08':
		n = 4
	else:
		n = sage_eval(str(int(eval(G[1:]))))
	normal_subs = Set(['M0','M1','G'] + n.divisors())
	normal_scts = []
	for S in normal_subs.subsets(): # UGH!!!!
		k = normal_sct(G,list(S))
		if k not in normal_scts:
			normal_scts.append(k)
	return normal_scts

def normal_plot(G, **options):
	if G not in evens or G == 'D04':
		print 'WTF!'
		return
	color_dict = {'#2176C7' : [], '#D11C24' : []}
	color_dict['#2176C7'] = get_normal_scts(G)
	color_dict['#D11C24'] = [k for k in sct_posets[G] if k not in color_dict['#2176C7']]
	poset = sct_posets[G]
	P = poset.plot(vertex_colors = color_dict, **options)
	Q = text(G+': blue nodes are normal sct,\n red nodes are not.', (0,0), axes = False, color = 'black')
	return P + Q

load('cyclic_codex.sage')
def normal_sct_cyclic(G, S):
	if G not in cyclics:
		print 'WTF!'
		return
	if G[1] == '0':
		n = sage_eval(str(int(eval(G[2:]))))
	else:
		n = sage_eval(str(int(eval(G[1:]))))
	elements = n.divisors()
	relations = []
	for d in n.divisors():
		for e in n.divisors():
			if d % e == 0:
				relations.append([d, e])
	P = LatticePoset([elements, relations])
	if n not in S:
		S.append(n)
	if 1 not in S:
		S.append(1)
	AS = P.sublattice(S)
	subgroups = {x : [] for x in AS}
	for x in AS:
		if x == 1:
			subgroups[x] = range(n)
		else:
			subgroups[x] = [0]+[cyclic_class_codex[G][k] for k in range(x,n,x)]
	for x in AS:
		for y in AS.order_ideal([x]):
			if y == x:
				continue
			for k in subgroups[y]:
				if k in subgroups[x]:
					subgroups[x].remove(k)
	return superclass_lists[G].index(SetPartition([subgroups[x] for x in AS if len(subgroups[x]) > 0]))

def get_normal_scts_cyclic(G):
	if G not in cyclics:
		print 'WTF!'
		return
	if G[1] == '0':
		n = sage_eval(str(int(eval(G[2:]))))
	else:
		n = sage_eval(str(int(eval(G[1:]))))
	normal_subs = Set(n.divisors())
	normal_scts = []
	for S in normal_subs.subsets(): # UGH!!!!
		k = normal_sct_cyclic(G,list(S))
		if k not in normal_scts:
			normal_scts.append(k)
	return normal_scts

def normal_plot_cyclic(G, **options):
	if G not in cyclics:
		print 'WTF!'
		return
	color_dict = {'#2176C7' : [], '#D11C24' : []}
	color_dict['#2176C7'] = get_normal_scts_cyclic(G)
	color_dict['#D11C24'] = [k for k in sct_posets[G] if k not in color_dict['#2176C7']]
	poset = sct_posets[G]
	P = poset.plot(vertex_colors = color_dict, **options)
	Q = text(G+': blue nodes are normal sct,\n red nodes are not.', (0,0), axes = False, color = 'black')
	return P + Q

def norm_sct_from_sct(G, i):
	if G not in cyclics or i not in sct_int_subposets[G]:
		print 'WTF!'
		return
	if G[1] == '0':
		n = sage_eval(str(int(eval(G[2:]))))
	else:
		n = sage_eval(str(int(eval(G[1:]))))
	codex = cyclic_class_codex[G]
	K = [[codex.index(j) for j in part] for part in superclass_lists[G][i]]
	L = []
	for part in K:
		if 0 in part:
			L.append([n]+[j for j in part if j != 0]) # UGH
		else:
			L.append(part)
	return normal_sct_cyclic(G,list(set([gcd(part) for part in L])))
