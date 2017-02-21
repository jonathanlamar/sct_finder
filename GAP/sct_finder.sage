class sct_finder(object):
	r"""
	Finds all supercharacter theories of a group, so long as GAP understands
	that group.  This class also has a number of tools for analyzing the lattice
	of all supercharacter theories of the group once it has been computed.

	Example

	># Symmetric group on 7 elements.

	>G = sct_finder('SymmetricGroup(7)','S7')

	>G.go() # Compute SCT(G)

	>G.export_data() # Save everything to the current directory.
	"""
	def __init__(self, _gap_group_name, _group_tag):
		# Initial stuff (including building the character table and related variables).
		self._gap_group_name = _gap_group_name
		self._group_tag = _group_tag
		self._gap_group = gap(_gap_group_name)
		self._sct_list = []
		self._superclass_list = []
		T = self._gap_group.CharacterTable().CharacterTableWithSortedCharacters()
		X = [[eval(str(value).replace('^','**')) for value in x] for x in T.Irr()]
		self._character_table = Matrix(UniversalCyclotomicField(), X)
		self._character_table_inverse = self._character_table.inverse()
		self._N = self._character_table.dimensions()[0] # Number of irreducible characters

	def _initialize_output_file(self):
		# Print some stuff to the "Jon's OCD" text file.
		self._output_file = open(self._group_tag+'_delete_when_done.txt','w')
		self._output_file.write('This is a running tally of supercharacter theories for the purpose of server-run large examples.  This file may be deleted at the conclusion of the script.\n')
		self._output_file.write('Group: '+self._group_tag+'\n')
		self._output_file.write('Supercharacter Theories: \n')
		self._output_file.flush()

	# This method begins the process by calling a recursive algorithm on the appropriate initial givens.
	def go(self):
		r"""
		Call this method to start computing supercharacter theories (this may
		take a long time).
		"""
		self._initialize_output_file()
		self._subsets = [Set([0])] # The only known part of the first partial partition is {1_G}.
		self._previous_supp = [SetPartition([[0], range(1,self._N)])] # That set's support is rather coarse.
		self._build_sct()
		self._terminate_output_file()
		for P in self._sct_list:
			self._superclass_list.append(self._get_class_partition(P))

	def _build_sct(self):
		# This is the main algorithm - A full description is available in the main readme file.
		old_chars = self._get_union(self._subsets)
		new_char = min(Set(range(self._N))-old_chars)
		old_chars = old_chars + Set([new_char])
		block_of_new_char = self._get_index_of_part(self._previous_supp[-1],new_char)
		fresh_chars = self._previous_supp[-1][block_of_new_char] - old_chars
		for A in fresh_chars.subsets():
			partial_partition_is_good = True
			current_supp = self._previous_supp[-1]
			self._subsets.append(A + Set([new_char]))
			for B in self._subsets:
				current_supp = current_supp*self._support_of_product(self._subsets[-1],B)
			for B in self._subsets:
				if Set([self._get_index_of_part(current_supp,j) for j in B]).cardinality() > 1:
					partial_partition_is_good = False
					break
			if partial_partition_is_good:
				if Set(range(self._N)).difference(old_chars.union(self._subsets[-1])).cardinality() == 0:
					self._sct_list.append(SetPartition(self._subsets))
					self._output_file.write(str(len(self._sct_list))+'. '+str(SetPartition(self._subsets))+'\n')
					self._output_file.flush()
					self._subsets.pop()
					continue
				else:
					self._previous_supp.append(current_supp)
					self._build_sct()
					self._subsets.pop()
					self._previous_supp.pop()
			else:
				self._subsets.pop()

	# These are visible methods which return (for the user) some of the hidden variables.
	def character_table(self):
		return self._character_table

	def character_table_inverse(self):
		return self._character_table_inverse

	def sct_list(self):
		return self._sct_list

	def superclass_list(self):
		return self._superclass_list

	def sct_poset(self):
		r"""
		Returns the lattice of all supercharacter theories.
		"""
		L = self.sct_list()
		N = len(L)
		vertices = range(N)
		relations = []
		for i in range(N):
			for j in range(i+1,N):
				if L[i]*L[j] == L[i]:
					relations.append([i,j])
				if L[i]*L[j] == L[j]:
					relations.append([j,i])
		return LatticePoset((vertices,relations))

	def sct_int_subposet(self):
		r"""
		Returns the subposet of integral supercharacter theories.
		"""
		D = self._create_int_color_dict()
		P = self.sct_poset()
		return P.subposet(D['#2176C7']) # blue

	def integral_plot(self, **options):
		r"""
		Plots the poset of supercharacter tables with color-coded vertices: blue
		for those with integral tables, red for those without.
		"""
		color_dict = self._create_int_color_dict()
		return self.sct_poset().plot(vertex_colors = color_dict, **options) # color_dict will color-code the graph, while extra options are passed through

	def export_data(self):
		r"""
		Exports all of the important data for later analysis (this may also take
		a while).
		"""
		self._sct_list_export()
		self._superclass_list_export()
		self._sct_poset_export()
		self._sct_int_subposet_export()
		self._character_table_export()

	# Hidden ancillary methods
	def _get_sc_table(self, irr_partition):
		# Given a partition of Irr(G) (induced from a SCT), this returns the supercharacter table.
		char_table = self._character_table
		sc_table = []
		for part in irr_partition:
			sigma = matrix([0]*self._N)
			for i in part:
				sigma = sigma + matrix([char_table[i,0]*k for k in char_table[i]])
			sc_table.append(sigma.list())
		return matrix(self._uniquify(matrix(sc_table).transpose().rows())).transpose() # transpose, remove redundant rows, transpose again

	def _field_size(self,sct):
		# Returns the degree of the minimal cyclotomic extension of Q containing all of the entries of the character table.
		sizes = []
		sc_table = self._get_sc_table(sct).change_ring(UniversalCyclotomicField())
		N = sc_table.dimensions()[0]
		for i in range(N):
			for j in range(N):
				c = sc_table[i,j].conductor() # conductor returns the minimal cyclotomic extension of Q containing c
				sizes.append(int(c))
		return lcm(sizes)

	def _get_index_of_part(self, partition, element):
		# This finds the index of the part of "partition" containing "element".
		for i, part in enumerate(partition):
			if element in part:
				return i

	def _uniquify(self, list_of_things):
		# This method removes all repetition from a list while preserving order (something list(Set(--)) does not do).
		irredundant_list = []
		for x in list_of_things:
			if x not in irredundant_list:
				irredundant_list.append(x)
		return irredundant_list

	def _get_union(self, list_of_sets):
		# Returns the union of list_of_sets.
		the_union = Set([])
		for A in list_of_sets:
			the_union = the_union + A
		return the_union

	def _build_partition(self, L):
		# Given a list L, this method builds a partition of range(len(L)) determined by the rule i~j iff L[i]==L[j].
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

	def _get_class_partition(self, irr_partition):
		# Given a partition X of Irr(G), this function returns the unique coarsest partition of Classes(G) on which the supercharacters of X are constant.  Once the main loop has finished calculating all of the supercharacter partitions, this function is run to calculate all of the superclass partitions.
		partitions = []
		T = self._character_table
		for part in irr_partition:
			sigma = [0]*self._N # Build the wedderburn sum as a vector of its values on the conjugacy classes.
			for i in part:
				sigma = [sigma[j] + T[i,0]*T[i,j] for j in range(self._N)]
			partitions.append(self._build_partition(sigma)) # for each supercharacter, find the partition of Cl(G) determined by its values.
		class_partition = partitions[0]
		for member in partitions[1:]: # return the infemum over all of the partitions just determined.
			class_partition = class_partition*member
		return class_partition

	def _wedderburn_sum(self, X):
		# Given a subset X of Irr(G) (represented as a list of numbers), this method returns \sum_{\chi\in X}\chi(1)\chi, represented as a row vector.
		sigma = matrix([0] * self._N)
		T = self._character_table
		for i in X:
			sigma = sigma + matrix([T[i,0] * k for k in T[i]])
		return sigma

	def _support_of_product(self, X, Y):
		# Given subsets X,Y of Irr(G), this method returns the unique coarsest partition of Irr(G) such that the elementwise product of the Wedderburn sums of X and Y is contained in the span of the Wedderburn sums of the parts of this partition.
		sigma = self._wedderburn_sum(X).elementwise_product(self._wedderburn_sum(Y)) * self._character_table_inverse # change to the character basis
		cop_list = [sigma[0,i] / self._character_table[i,0] for i in range(self._N)] # divide by character degrees to get in terms of wedderburn basis
		blocks = []
		for coeff in set(cop_list):
			blocks.append([i for i in range(self._N) if cop_list[i] == coeff])
		return SetPartition(blocks)

	def _check_sc_tables_are_integer(self):
		are_integer = {P : False for P in self.sct_list()} # initialize
		for sct in self.sct_list():
			if self._field_size(sct) == 1: # CyclotomicField(1) is Q
				are_integer[sct] = True
		return are_integer

	def _create_int_color_dict(self):
		# The integral_plot method requires a dictionary of this form to determine vertex colors.
		are_integer = self._check_sc_tables_are_integer()
		color_dict = {'#2176C7' : [], '#D11C24' : []} # blue for integer supercharacter table, red otherwise
		for key in are_integer.keys():
			if are_integer[key]:
				color_dict['#2176C7'].append(self.sct_list().index(key)) # blue
			else:
				color_dict['#D11C24'].append(self.sct_list().index(key)) # red
		return color_dict

	def _character_table_export(self):
		self._character_table.save(self._group_tag+'_char_table.sobj')

	def _superclass_list_export(self):
		f = open(self._group_tag+'_superclass_list.txt','w')
		superclass_list_str = str(self.sct_list())
		superclass_list_str = superclass_list_str.replace('{','[')
		superclass_list_str = superclass_list_str.replace('}',']')
		f.write(superclass_list_str)
		f.close()

	def _sct_int_subposet_export(self):
		Q = self.sct_int_subposet()
		Q.save(self._group_tag+'_int_subposet_data')

	def _sct_list_export(self):
		f = open(self._group_tag+'_sct_list.txt','w')
		sct_list_str = str(self.sct_list())
		sct_list_str = sct_list_str.replace('{','[')
		sct_list_str = sct_list_str.replace('}',']')
		f.write(sct_list_str)
		f.close()

	def _sct_poset_export(self):
		P = self.sct_poset()
		P.save(self._group_tag+'_poset_data')

	def _terminate_output_file(self):
		self._output_file.write('The script is now finished.  Above are all of the supercharacter theories.')
		self._output_file.close()
