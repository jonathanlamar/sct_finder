def fact_upper_ideal(group_tag):
	P = sct_posets[group_tag]
	facts = [i for i in P if is_factorizable(group_tag, i)]
	mins = get_minimal_nonfact_covees(group_tag)
	return P.subposet([i for i in P if i in facts and any([P.le(j,i) for j in mins])])

def nonfact_subposet(group_tag):
	P = sct_posets[group_tag]
	nonfacts = [i for i in P if not is_factorizable(group_tag, i)]
	return P.subposet(nonfacts)
