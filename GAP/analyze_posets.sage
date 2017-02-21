# This script contains some useful methods for doing analysis on the posets of supercharacter theories

# just a macro for loading the growing number of examples at once.
import glob
# Instead of manually editing the list, this just gets all of the group tags automatically
filenames = glob.glob("examples/*_poset_data.sobj") # grab all of the filenames of this form in the examples folder
tags = [name[9:][:-16] for name in filenames] # for each, remove the first 9 characters "examples/", THEN remove the last 16 characters "_poset_data.sobj"
	
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

# load character tables
char_tables = {tag : [] for tag in tags}
for tag in tags:
	exec 'char_tables[tag] = load(\'examples/'+tag+'_char_table.sobj\')'

# functions
def is_good(group_tag, X):
	# tests whether the set X is good, i.e., X lies in its filtration F(X)
	T = char_tables[group_tag]
	S = T^(-1)
	N = T.dimensions()[0]
	sigma = matrix([0]*N)
	for i in X:
		sigma = sigma + matrix([T[i,0]*k for k in T[i]]) # build wedderburn sum
	power_of_sigma = sigma
	for i in range(2,N+1):
		power_of_sigma = power_of_sigma.elementwise_product(sigma) # take higher elementwise powers
		power_other_basis = power_of_sigma*S # convert to character basis
		for j in X[1:]:
			if power_other_basis[0,j]/T[j,0] != power_other_basis[0,X[0]]/T[X[0],0]:
				return False
	return True

def has_lattice_property(list_of_partitions):
	# tests that a list of partitions is closed under the lattice-theoretic meet operation
	for i in range(len(list_of_partitions)):
		for j in range(i+1,len(list_of_partitions)):
			if list_of_partitions[i]*list_of_partitions[j] not in list_of_partitions:
				return False
	return True

# This is an ancillary method; you probably won't ever use it directly
def uniquify(list_of_things):
	# remove all repetition from a list while preserving order (something list(Set(--)) does not do)
	irredundant_list = []
	for x in list_of_things:
		if x not in irredundant_list:
			irredundant_list.append(x)
	return irredundant_list

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

def get_class_partition(group_tag, irr_partition):
	# Given a partition X of Irr(G), this function returns the unique coarsest partition of Classes(G) on which the supercharacters of X are constant.
	partitions = []
	T = char_tables[group_tag]
	N = T.dimensions()[0]
	for part in irr_partition:
		sigma = [0]*N
		for i in part:
			sigma = [sigma[j] + T[i,0]*T[i,j] for j in range(N)]
		partitions.append(build_partition(sigma)) # for each supercharacter sigma_X, find the coarsest partition of Classes(G) on which sigma_X is constant.
	class_partition = partitions[0]
	for member in partitions[1:]: # return the infemum over all of the partitions just determined
		class_partition = class_partition*member
	return class_partition

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
	# creates a color coded plot of the poset of supercharacter theories for a group
	poset = sct_posets[group_tag]
	color_dict = create_int_color_dict(group_tag)
	if poset.list()[0] in ZZ: # If the poset's elements are already the indices of the supercharacter theories, just plot already.  This is a bug fix by Jon (7/1/15).
		return poset.plot(vertex_colors = color_dict, **options)
	lbls = {partition : sct_lists[group_tag].index(partition) for partition in sct_lists[group_tag]} # label each node by its position in the list of scts
	return poset.plot(element_labels = lbls, vertex_colors = color_dict, **options) # color_dict will color-code the graph, while extra options are passed through

def get_common_size_pairs(group_tag1, group_tag2):
	L1 = sct_lists[group_tag1]
	L2 = sct_lists[group_tag2]
	M = []
	for S in L1:
		for T in L2:
			if len(S) == len(T):
				M.append((S,T))
	return M

# The following two functions should be made methods of SCTFinder class.
def class_bad_pairs(group_tag):
	# This finds all of the pairs of partitions of the classes of G whose meet does not correspond to a supercharacter theory
	L = superclass_lists[group_tag]
	bads = []
	for i in range(len(L)):
		for j in range(i+1,len(L)):
			if L[i]*L[j] not in L:
				bads.append([i,j])
	return bads

def char_bad_pairs(group_tag):
	# This finds all of the pairs of partitions of Irr(G) whose meet does not correspond to a supercharacter theory
	L = sct_lists[group_tag]
	bads = []
	for i in range(len(L)):
		for j in range(i+1,len(L)):
			if L[i]*L[j] not in L:
				bads.append([i,j])
	return bads

# This is nifty.
def is_refinement(P,Q):
	# returns true if set partition P is a refinement of set partition Q and false otherwise
	return all([not all([not p.issubset(q) for q in Q]) for p in P])
