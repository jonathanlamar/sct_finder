# This script contains some useful methods for doing analysis on the posets of supercharacter theories

# just a macro for loading the growing number of examples at once.
import glob
# Instead of manually editing the list, this just gets all of the group tags automatically
filenames = glob.glob("examples/*_poset_data.sobj") # grab all of the filenames of this form in the examples folder
tags = [name[9:][:-16] for name in filenames] # for each, remove the first 9 characters "examples/", THEN remove the last 16 characters "_poset_data.sobj"
	
# load characteristic subposets
sct_characteristic_subposets = {tag : [] for tag in tags}
for tag in tags:
	exec 'sct_characteristic_subposets[tag] = load(\'examples/'+tag+'_characteristic_subposet_data.sobj\')'

# load galois subposets
sct_galois_subposets = {tag : [] for tag in tags}
for tag in tags:
	exec 'sct_galois_subposets[tag] = load(\'examples/'+tag+'_galois_subposet_data.sobj\')'

# load automorphic subposets
sct_automorphic_subposets = {tag : [] for tag in tags}
for tag in tags:
	exec 'sct_automorphic_subposets[tag] = load(\'examples/'+tag+'_automorphic_subposet_data.sobj\')'

# load supercharacter theory lists into a dictionary
sct_lists = {tag : [] for tag in tags}
for tag in tags:
	exec 'f = open(\'examples/'+tag+'_sct_list.txt\',\'r\')'
	sct_lists[tag] = [SetPartition(value) for value in eval(f.read())] # read the file and convert lists of lists into set partitions on the fly
	f.close()

# load superclass lists into a dictionary
superclass_lists = {tag: [] for tag in tags}
for tag in tags:
	exec 'f = open(\'examples/'+tag+'_superclass_list.txt\',\'r\')'
	superclass_lists[tag] = [SetPartition(value) for value in eval(f.read())]
	f.close()

# load posets into a dictionary
sct_posets = {tag : [] for tag in tags}
for tag in tags:
	exec 'sct_posets[tag] = load(\'examples/'+tag+'_poset_data.sobj\')' # loads the saved poset objects

# load integral subposets
sct_int_subposets = {tag : [] for tag in tags}
for tag in tags:
	exec 'sct_int_subposets[tag] = load(\'examples/'+tag+'_int_subposet_data.sobj\')' # subposet of integral supercharacter theories (will throw error if these haven't been computed for all examples)

# load characteristic subposets
sct_characteristic_subposets = {tag : [] for tag in tags}
for tag in tags:
	exec 'sct_characteristic_subposets[tag] = load(\'examples/'+tag+'_characteristic_subposet_data.sobj\')' # subposet of characteristic supercharacter theories (will throw error if these haven't been computed for all examples)

# load character tables
char_tables = {tag : [] for tag in tags}
for tag in tags:
	exec 'char_tables[tag] = load(\'examples/'+tag+'_char_table.sobj\')'

# This is an ancillary method; you probably won't ever use it directly
def uniquify(list_of_things):
	# remove all repetition from a list while preserving order (something list(Set(--)) does not do)
	irredundant_list = []
	for x in list_of_things:
		if x not in irredundant_list:
			irredundant_list.append(x)
	return irredundant_list

# Ancillary method
def build_partition(L):
	# given a list, this builds a partition determined by i~j iff L[i]==L[j]
	partition = []
	fresh_numbers = range(len(L))
	while len(fresh_numbers) > 0:
		i = fresh_numbers[0]
		block = [i]
		for j in fresh_numbers[1:]:
			if L[j] == L[i]:
				block.append(j)
		partition.append(block)
		for j in block:
			fresh_numbers.remove(j)
	return SetPartition(partition)

def get_sc_table(group_tag, irr_partition):
	# Given a partition of Irr(G) (induced from a SCT), this returns the supercharacter table.
	char_table = char_tables[group_tag]
	N = char_table.dimensions()[0]
	sc_table = []
	for part in irr_partition:
		sigma = matrix([0]*N) # initialize
		for i in part:
			sigma = sigma + matrix([char_table[i,0]*k for k in char_table[i]]) # add chi(1)*chi to sigma for each chi in part
		sc_table.append(sigma.list())
	return matrix(uniquify(Matrix(sc_table).transpose().rows())).transpose() # transpose, remove redundant rows, transpose again

def field_size(table):
	# Size of the smallest cyclotomic field containing the table entries
	sizes = []
	N = table.dimensions()[0]
	table = table.change_ring(UniversalCyclotomicField()) # this ensures all entries have the conductor attribute
	for i in range(N):
		for j in range(N):
			c = table[i,j].conductor() # conductor returns the minimal cyclotomic extension of Q containing c
			sizes.append(int(c))
	return lcm(sizes) # the least common multiple of the elements of sizes is the minimal cyclotomic extension of Q containing every element of table

def check_sc_tables_are_integer(group_tag):
	# creates a dictionary indicating which supercharacter theories have integer tables
	sct_list = sct_lists[group_tag]
	are_integer = {partition : False for partition in sct_list} # initialize
	char_table = char_tables[group_tag]
	for sct in sct_list:
		if field_size(get_sc_table(group_tag,sct)) == 1: # CyclotomicField(1) is Q
			are_integer[sct] = True
	return are_integer

def create_int_color_dict(group_tag):
	# creates a color-coding for the nodes of the poset (of supercharacter theories) based on which nodes correspond to theories with integer tables
	are_integer = check_sc_tables_are_integer(group_tag)
	color_dict = {'#2176C7' : [], '#D11C24' : []} # blue for integer supercharacter table, red otherwise
	for key in are_integer.keys():
		if are_integer[key]:
			color_dict['#2176C7'].append(sct_lists[group_tag].index(key))
		else:
			color_dict['#D11C24'].append(sct_lists[group_tag].index(key))
	return color_dict

def integral_plot(group_tag, **options):
	# creates a color coded plot of the poset of supercharacter theories for a group with colors based on integrality
	poset = sct_posets[group_tag]
	color_dict = create_int_color_dict(group_tag)
	P = poset.plot(vertex_colors = color_dict, **options)
	Q = text(group_tag+' integral plot',(0,0),axes=False,color='black')
	return P + Q

def create_characteristic_color_dict(group_tag):
	# creates a color-coding for the nodes of the poset (of supercharacter theories) based on which nodes correspond to characteristic theories
	color_dict = {'#2176C7' : [], '#D11C24' : []} # blue for characteristic supercharacter theory, red otherwise
	for i in range(len(sct_lists[group_tag])):
		if i in list(sct_characteristic_subposets[group_tag]):
			color_dict['#2176C7'].append(i)
		else:
			color_dict['#D11C24'].append(i)
	return color_dict

def characteristic_plot(group_tag, **options):
	# creates a color coded plot of the poset of supercharacter theories for a group with a vertex's color based on whether the corresponding theory is characteristic
	poset = sct_posets[group_tag]
	color_dict = create_characteristic_color_dict(group_tag)
	P = poset.plot(vertex_colors = color_dict, **options)
	Q = text(group_tag+' characteristic plot',(0,0),axes=False,color='black')
	return P + Q

def create_galois_color_dict(group_tag):
	# creates a color-coding for the nodes of the poset (of supercharacter theories) based on which nodes correspond to galois theories
	color_dict = {'#2176C7' : [], '#D11C24' : []} # blue for galois supercharacter theory, red otherwise
	for i in range(len(sct_lists[group_tag])):
		if i in list(sct_galois_subposets[group_tag]):
			color_dict['#2176C7'].append(i)
		else:
			color_dict['#D11C24'].append(i)
	return color_dict

def galois_plot(group_tag, **options):
	# creates a color coded plot of the poset of supercharacter theories for a group with a vertex's color based on whether the corresponding theory is galois
	poset = sct_posets[group_tag]
	color_dict = create_galois_color_dict(group_tag)
	P = poset.plot(vertex_colors = color_dict, **options)
	Q = text(group_tag+' Galois plot',(0,0),axes=False,color='black')
	return P + Q

def create_automorphic_color_dict(group_tag):
	# creates a color-coding for the nodes of the poset (of supercharacter theories) based on which nodes correspond to automorphic theories
	color_dict = {'#2176C7' : [], '#D11C24' : []} # blue for automorphic supercharacter theory, red otherwise
	for i in range(len(sct_lists[group_tag])):
		if i in list(sct_automorphic_subposets[group_tag]):
			color_dict['#2176C7'].append(i)
		else:
			color_dict['#D11C24'].append(i)
	return color_dict

def automorphic_plot(group_tag, **options):
	# creates a color coded plot of the poset of supercharacter theories for a group with a vertex's color based on whether the corresponding theory is automorphic
	poset = sct_posets[group_tag]
	color_dict = create_automorphic_color_dict(group_tag)
	P = poset.plot(vertex_colors = color_dict, **options)
	Q = text(group_tag+' automorphic plot',(0,0),axes=False,color='black')
	return P + Q

def is_refinement(P,Q):
	# returns true if set partition P is a refinement of set partition Q and false otherwise
	return all([not all([not p.issubset(q) for q in Q]) for p in P])

def check_join_closure(group_tag, S):
	# Checks if the join of any two elements in the subposet determined by
	# string P (which may be of the form 'int', 'char', 'aut', or 'gal')
	# coincides with their join in the poset of supercharacter theories.
	P = LatticePoset(sct_posets[group_tag])
	if S == 'int':
		nodes = list(sct_int_subposets[group_tag]) # create_int_color_dict(group_tag)['#2176C7']
	elif S == 'char':
		nodes = list(sct_characteristic_subposets[group_tag]) # create_characteristic_color_dict(group_tag)['#2176C7']
	elif S == 'aut':
		nodes = list(sct_automorphic_subposets[group_tag]) # create_automorphic_color_dict(group_tag)['#2176C7']
	elif S == 'gal':
		nodes = list(sct_galois_subposets[group_tag]) # create_galois_color_dict(group_tag)['#2176C7']
	else:
		print 'bad input'
		return
	L = LatticePoset(P.subposet(nodes))
	is_okay = True
	for i in range(len(nodes)):
		for j in range(i+1,len(nodes)):
			if L.join(nodes[i],nodes[j]) != P.join(nodes[i],nodes[j]):
				is_okay = False
	return is_okay

def check_meet_closure(group_tag, S):
	# Checks if the meet of any two elements in the subposet determined by
	# string S (which may be of the form 'int', 'char', 'aut', or 'gal')
	# coincides with their meet in the poset of supercharacter theories.
	P = LatticePoset(sct_posets[group_tag])
	if S == 'int':
		nodes = list(sct_int_subposets[group_tag]) # create_int_color_dict(group_tag)['#2176C7']
	elif S == 'char':
		nodes = list(sct_characteristic_subposets[group_tag]) # create_characteristic_color_dict(group_tag)['#2176C7']
	elif S == 'aut':
		nodes = list(sct_automorphic_subposets[group_tag]) # create_automorphic_color_dict(group_tag)['#2176C7']
	elif S == 'gal':
		nodes = list(sct_galois_subposets[group_tag]) # create_galois_color_dict(group_tag)['#2176C7']
	else:
		print 'bad input'
		return
	L = LatticePoset(P.subposet(nodes))
	is_okay = True
	for i in range(len(nodes)):
		for j in range(i+1,len(nodes)):
			if L.meet(nodes[i],nodes[j]) != P.meet(nodes[i],nodes[j]):
				is_okay = False
	return is_okay

def create_characteristic_color_dict_2(group_tag):
	# creates a color-coding for the nodes of the poset (of supercharacter theories) based on which nodes correspond to characteristic theories, and the maximal automorphic supercharacter theory is colored green.
	color_dict = {'#2176C7' : [], '#D11C24' : [], '#6C71C4' : [], '#859900' : []} # blue for characteristic supercharacter theory, green for the maximal automorphic, and red otherwise.
	G = list(sct_galois_subposets[group_tag])
	j = sct_automorphic_subposets[group_tag].maximal_elements()[0]
	for i in range(len(sct_lists[group_tag])):
		if i in list(sct_characteristic_subposets[group_tag]) and i != j and i not in G:
			color_dict['#2176C7'].append(i)
		elif i == j:
			color_dict['#6C71C4'].append(i)
		elif i in G:
			color_dict['#859900'].append(i)
		else:
			color_dict['#D11C24'].append(i)
	return color_dict

def characteristic_plot_2(group_tag, **options):
	# creates a color coded plot of the poset of supercharacter theories for a group with a vertex's color based on whether the corresponding theory is characteristic, and the maximal automorphic supercharacter theory colored green.
	poset = sct_posets[group_tag]
	color_dict = create_characteristic_color_dict_2(group_tag)
	P = poset.plot(vertex_colors = color_dict, **options)
	Q = text(group_tag+' extra char. plot',(0,0),axes=False,color='black')
	return P + Q

def create_cuspidal_color_dict(group_tag):
	# creates a color coding dictionary based on cuspidal/not cuspidal
	autos = Set(list(sct_automorphic_subposets[group_tag]))
	ints = Set(list(sct_int_subposets[group_tag]))
	gals = Set(list(sct_galois_subposets[group_tag]))
	chars = Set(list(sct_characteristic_subposets[group_tag]))
	scts = Set(range(len(sct_lists[group_tag])))
	P = sct_posets[group_tag]
	E = P.linear_extension()
	T = P.join_matrix()
	canonical_scts = autos+ints+gals+chars
	non_cuspidal_scts = canonical_scts # this will be expanded
	extras = non_cuspidal_scts # as will this
	while True:
		for i in non_cuspidal_scts:
			extras = extras + Set([E[T[E.index(i),E.index(j)]] for j in non_cuspidal_scts])
		if extras == non_cuspidal_scts: # if join closure
			break
		non_cuspidal_scts = extras
	cuspidal_scts = scts - non_cuspidal_scts
	non_cuspidal_scts = non_cuspidal_scts - canonical_scts
	return {'#2176C7' : cuspidal_scts, '#D33682' : non_cuspidal_scts, '#D11C24' : canonical_scts} # blue for cuspidal supercharacter theory, red otherwise

def cuspidal_plot(group_tag, **options):
	# creates a color-coded plot of supercharacter theories with blue nodes cuspidal
	color_dict = create_cuspidal_color_dict(group_tag)
	the_plot = sct_posets[group_tag].plot(vertex_colors = color_dict, **options)
	the_text = text(group_tag+' cuspidal plot',(0,0),axes=False,color='black')
	return the_plot + the_text

cyclics = [G for G in tags if G[0] == 'Z']
print '"cyclics" == list of all tags for cyclics groups.'
dihedrals = [G for G in tags if G[0] == 'D']
print '"dihedrals" == list of all tags for dihedral groups.'

def get_n(G):
	if G not in dihedrals:
		return -1
	if G[1] == '0':
		return sage_eval(str(eval(G[2:])/2))
	else:
		return sage_eval(str(eval(G[1:])/2))
odds = [G for G in dihedrals if get_n(G) % 2 == 1]
print '"odds" == list of all D2n for n odd.'
evens = [G for G in dihedrals if get_n(G) % 2 == 0]
print '"evens" == list of all D2n for n even.'

SD = [G for G in tags if G[:2] == 'SD']
print '"SD" == list of all tags for semidirect products.\nThe tags look like "SD(n,p,a)" which means Zn*Zp with Zp acting on Zn via y.x=x^a.'
