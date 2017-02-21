class rescue_sct_finder(object):
	r"""
	In the event sct_finder successfully computes all supercharacter theories
	but fails to complete execution (which can happen for large examples), this
	script attempts to finish computing the various secondary data.
	"""

	def __init__(self, _magma_group_name, _group_tag):
		self._group_tag = _group_tag
		self._magma_group_name = _magma_group_name
		self._has_char_table = True
		self._has_sct_list = True
		self._has_superclass_list = True
		self._has_poset_data = True
		self._has_int_subposet = True
		self._has_characteristic_subposet = True
		self._has_galois_subposet = True
		self._has_automorphic_subposet = True

		# Load the character table.
		try:
			self._character_table = load(self._group_tag+'_char_table.sobj')
		except IOError:
			print "No character table detected.  Try running sct_finder again or giving up."
			return

		# Load the SCT list.
		try:
			f = open(self._group_tag+'_sct_list.txt')
			self._sct_list = [SetPartition(value) for value in eval(f.read())]
			f.close()
		except IOError:
			print "No SCT list detected.  Try running sct_finder again or giving up."
			return

		# Load the superclass list.
		try:
			f = open(self._group_tag+'_superclass_list.txt')
			self._superclass_list = [SetPartition(value) for value in eval(f.read())]
			f.close()
		except IOError:
			self._has_superclass_list = False
			print "No superclass list detected."

		# Load the poset data.
		try:
			self._sct_poset = load(self._group_tag+'_poset_data.sobj')
		except IOError:
			self._has_poset_data = False
			print "No poset data detected."

		# Load the integral subposet.
		try:
			self._int_subposet = load(self._group_tag+'_int_subposet_data.sobj')
		except IOError:
			self._has_int_subposet = False
			print "No integral subposet detected."

		# Load the characteristic subposet.
		try:
			self._characteristic_subposet = load(self._group_tag+'_characteristic_subposet_data.sobj')
		except IOError:
			self._has_characteristic_subposet = False
			print "No characteristic subposet detected."

		# Load the galois subposet.
		try:
			self._galois_subposet = load(self._group_tag+'_galois_subposet_data.sobj')
		except IOError:
			self._has_galois_subposet = False
			print "No galois subposet detected."

		# Load the automorphic subposet.
		try:
			self._automorphic_subposet = load(self._group_tag+'_automorphic_subposet_data.sobj')
		except IOError:
			self._has_automorphic_subposet = False
			print "No automorphic subposet detected."

		self._character_table_inverse = self._character_table.inverse()

	def export_data(self):
		r"""
		exports all of the important data for later analysis (this may also take
		a while).
		"""
		if not self._has_superclass_list:
			for P in self._sct_list:
				self._superclass_list.append(self._get_class_partition(P)) # Build superclasses.
			self._superclass_list_export()
		if not self._has_poset_data:
			self._sct_poset = self._build_sct_poset()
			self._sct_poset_export()
		if not self._has_int_subposet:
			self._int_subposet = self._build_sct_int_subposet()
			self._sct_int_subposet_export()
		if not self._has_characteristic_subposet:
			self._characteristic_subposet = self._build_sct_characteristic_subposet()
			self._sct_characteristic_subposet_export()
		if not self._has_galois_subposet:
			self._galois_subposet = self._build_sct_galois_subposet()
			self._sct_galois_subposet_export()
		if not self._has_automorphic_subposet:
			self._automorphic_subposet = self._build_sct_automorphic_subposet()
			self._sct_automorphic_subposet_export()

	# Private methods.
	def _build_sct_poset(self):
		L = self._sct_list
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

	def _build_sct_int_subposet(self):
		are_integer = self._check_sc_tables_are_integer()
		L = []
		for key in are_integer.keys():
			if are_integer[key]:
				L.append(self._sct_list.index(key))
		return LatticePoset(self._sct_poset.subposet(L))

	def _build_sct_automorphic_subposet(self):
		are_automorphic = self._check_scts_are_automorphic()
		L = []
		for key in are_automorphic.keys():
			if are_automorphic[key]:
				L.append(self._sct_list.index(key))
		return LatticePoset(self._sct_poset.subposet(L))

	def _build_sct_characteristic_subposet(self):
		are_characteristic = self._check_scts_are_characteristic()
		L = []
		for key in are_characteristic.keys():
			if are_characteristic[key]:
				L.append(self._sct_list.index(key)) # blue
		return LatticePoset(self._sct_poset.subposet(L)) # blue

	def _build_sct_galois_subposet(self):
		are_galois = self._check_scts_are_galois()
		L = []
		for key in are_galois.keys():
			if are_galois[key]:
				L.append(self._sct_list.index(key)) # blue
		return LatticePoset(self._sct_poset.subposet(L)) # blue

	def _get_sc_table(self, irr_partition):
		# Given a partition of Irr(G) (induced from a SCT), this returns the supercharacter table.
		char_table = self._character_table
		sc_table = []
		for part in irr_partition:
			sigma = matrix([0]*self._N) # initialize
			for i in part:
				# add chi(1)*chi to sigma for each chi in part
				sigma = sigma + matrix([char_table[i,0]*k for k in char_table[i]])
			sc_table.append(sigma.list())
		# transpose, remove redundant rows, transpose again
		return matrix(self._uniquify(matrix(sc_table).transpose().rows())).transpose() 

	def _field_size(self,sct):
		# This method computes the degree of the splitting field of the character table as an extension of Q.
		sizes = []
		sc_table = self._get_sc_table(sct).change_ring(UniversalCyclotomicField())
		N = sc_table.dimensions()[0]
		for i in range(N):
			for j in range(N):
				c = sc_table[i,j].conductor() # conductor returns the minimal cyclotomic extension of Q containing c
				sizes.append(int(c))
		return lcm(sizes)

	def _uniquify(self, list_of_things):
		# This method removes all repetition from a list while preserving order (something list(Set(--)) does not do).
		irredundant_list = []
		for x in list_of_things:
			if x not in irredundant_list:
				irredundant_list.append(x)
		return irredundant_list

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
		# Given a partition X of Irr(G), this method returns the unique coarsest partition of Cl(G) on which the supercharacters of X are constant.
		partitions = []
		T = self._character_table
		for part in irr_partition:
			sigma = [0]*self._N
			for i in part:
				sigma = [sigma[j] + T[i,0]*T[i,j] for j in range(self._N)]
			partitions.append(self._build_partition(sigma)) # for each supercharacter sigma_X, find the coarsest partition of Classes(G) on which sigma_X is constant.
		class_partition = partitions[0]
		for member in partitions[1:]: # return the infemum over all of the partitions just determined
			class_partition = class_partition*member
		return class_partition

	def _check_sc_tables_are_integer(self):
		# This returns a boolean dictionary whose value on a SCT is True if that SCT has an integral table and False otherwise.
		are_integer = {P : False for P in self._sct_list}
		for sct in self._sct_list:
			if self._field_size(sct) == 1: # CyclotomicField(1) is Q
				are_integer[sct] = True
		return are_integer

	def _is_characteristic_sct(self, partition):
		# Given a partition of Irr(G) corresponding to a supercharacter theory, this method passes to magma to do some magic to determine if that supercharacter theory is characteristic.
		P = str([[x+1 for x in part] for part in partition])
		val =  magma.eval('is_characteristic_sct := function(G, P)\n\
			P := [Sort(part) : part in P];\n\
			A := AutomorphismGroup(G);\n\
			Cl := [c[3] : c in ConjugacyClasses(G)];\n\
			get_class := function(G,x)\n\
			for i in [1..#Cl] do\n\
			if x in Conjugates(G,Cl[i]) then\n\
			return i;\n\
			end if;\n\
			end for;\n\
			end function;\n\
			gens := SetToSequence(Generators(A));\n\
			for x in gens do\n\
			for part in P do\n\
			new_part := Sort([get_class(G,x(Cl[i])) : i in part]);\n\
			if not new_part in P then\n\
			return false;\n\
			end if;\n\
			end for;\n\
			end for;\n\
			return true;\n\
			end function;\n\
			is_characteristic_sct('+self._magma_group_name+','+P+');')
		return eval(val)

	def _check_scts_are_characteristic(self):
		# This returns a boolean dictionary whose value on a SCT is True if that SCT is characteristic and False otherwise.
		are_characteristic = {P : False for P in self._sct_list} # initialize
		for i in range(len(self._sct_list)):
			if self._is_characteristic_sct(self._superclass_list[i]):
				are_characteristic[self._sct_list[i]] = True
		return are_characteristic

	def _check_scts_are_galois(self):
		# This method passes to MAGMA to do some magic to determine which supercharacter theories are Galois.
		S =  magma.eval('AllTableAutoSCT:=function(G)\n\
		CT:=CharacterTable(G);\n\
		K:=CyclotomicField(LCM([CyclotomicOrder(CoefficientField(CT[i])):i in [1..#CT]]));\n\
		n:=CyclotomicOrder(K);\n\
		list:=[];\n\
		all:=[i:i in [1..n-1]];\n\
		for i in [2..n] do\n\
		if Floor(n/i) eq n/i then\n\
		for j in [1.. n/i] do\n\
		Append(~list,i*j);\n\
		end for;\n\
		end if;\n\
		end for;\n\
		all:=SequenceToSet(all);\n\
		list:=SequenceToSet(list);\n\
		L:=Sort(SetToSequence(all diff list));\n\
		P:=PermutationGroup<{1..#CT}|[[Position(CT,GaloisConjugate(CT[i],j)):i in [1..#CT]]:j in L]>;\n\
		sgps:=&cat[[K : K in Conjugates(P,H`subgroup)] : H in Subgroups(P)];\n\
		return SetToSequence(SequenceToSet([Sort([Sort([Orbits(sgps[i])[j,k]:k in [1..#(Orbits(sgps[i])[j])]]):j in [1..#Orbits(sgps[i])]]):i in [1..#sgps]]));\n\
		end function;AllTableAutoSCT('+self._magma_group_name+')')
		S = S.replace('\n','').replace(' ','')
		galois_scts = eval(S)
		galois_scts = [[[x-1 for x in part] for part in P] for P in galois_scts]
		galois_scts = [SetPartition(P) for P in galois_scts]
		are_galois = {P : False for P in self._sct_list} # initialize
		for sct in self._sct_list:
			if sct in galois_scts:
				are_galois[sct] = True
		return are_galois

	def _check_scts_are_automorphic(self):
		# This method passes to MAGMA to do some magic to determine which supercharacter theories are automorphic.
		S =  magma.eval('AllAutomorphicSCT:=function(G)\n\
		A:=AutomorphismGroup(G);\n\
		CT:=CharacterTable(G);\n\
		X:=SequenceToSet(CT);\n\
		Cl:=ConjugacyClasses(G);\n\
		R:=CharacterRing(G);\n\
		gens:=SetToSequence(Generators(A));\n\
		f:=map<CartesianProduct(X,A)->X|x:->R![(map<G->CoefficientField(x[1])|y:->x[1](x[2](y))>)(Cl[i][3]):i in [1..#Cl]]>;\n\
		P:=PermutationGroup<{1..#CT}|[[Position(CT,f(CT[i],gens[j])):i in [1..#CT]]: j in [1..#gens]]>;\n\
		sgps:=&cat[[K : K in Conjugates(P,H`subgroup)] : H in Subgroups(P)];\n\
		return SetToSequence(SequenceToSet([Sort([Sort([Orbits(sgps[i])[j,k]:k in [1..#(Orbits(sgps[i])[j])]]):j in [1..#Orbits(sgps[i])]]):i in [1..#sgps]]));\n\
		end function;\n\
		AllAutomorphicSCT('+self._magma_group_name+')')
		S = S.replace('\n','').replace(' ','')
		automorphic_scts = eval(S)
		automorphic_scts = [[[x-1 for x in part] for part in P] for P in automorphic_scts]
		automorphic_scts = [SetPartition(P) for P in automorphic_scts]
		are_automorphic = {P : False for P in self._sct_list} # initialize
		for sct in self._sct_list:
			if sct in automorphic_scts:
				are_automorphic[sct] = True
		return are_automorphic

	# Methods for vomiting text files all over your current working directory.
	def _superclass_list_export(self):
		f = open(self._group_tag+'_superclass_list.txt','w')
		superclass_list_str = str(self._superclass_list)
		superclass_list_str = superclass_list_str.replace('{','[')
		superclass_list_str = superclass_list_str.replace('}',']')
		f.write(superclass_list_str)
		f.close()

	def _sct_poset_export(self):
		self._sct_poset.save(self._group_tag+'_poset_data')

	def _sct_int_subposet_export(self):
		self._int_subposet.save(self._group_tag+'_int_subposet_data')

	def _sct_characteristic_subposet_export(self):
		self._characteristic_subposet.save(self._group_tag+'_characteristic_subposet_data')

	def _sct_galois_subposet_export(self):
		self._galois_subposet.save(self._group_tag+'_galois_subposet_data')

	def _sct_automorphic_subposet_export(self):
		self._automorphic_subposet.save(self._group_tag+'_automorphic_subposet_data')
