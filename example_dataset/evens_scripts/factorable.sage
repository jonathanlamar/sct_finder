load('codex.sage')

# Factorable (1) refers to factorable over <r^d> for some divisor d of n.
# Factorable (2) refers to factorable over <r^2, s>.

def is_factorable_1(G, d, i):
	# Returns True for SCTs which factor over <r^d>, False otherwise.
	if G not in evens or G == 'D04':
		print 'WTF!'
		return
	if G[1] == '0':
		n = int(eval(G[2:])/2)
	else:
		n = int(eval(G[1:])/2)
	if d == n or n % d != 0:
		print 'Incompatible divisor.'
		return
	codex = class_codex[G]
	if d % 2 == 0:
		mmNG = SetPartition([[0],[2],[3]]+[[codex[k]] for k in range(d,n/2+1,d)]+[[codex[k] for k in [m for m in range(1,n/2+1) if m % d == l or (n-m) % d == l]] for l in range(1,d/2+1)])
	else:
		mmNG = SetPartition([[0],[2,3]]+[[codex[k]] for k in range(d,n/2+1,d)]+[[codex[k] for k in [m for m in range(1,n/2+1) if m % d == l or (n-m) % d == l]] for l in range(1,(d+1)/2)])
	MMNG = SetPartition([[0],[codex[k] for k in range(d,n/2+1,d)]]+[[2,3]+[codex[k] for k in [l for l in range(1,n/2+1) if l % d != 0]]])
	K = superclass_lists[G][i]
	return K*mmNG == mmNG and K*MMNG == K

def factorable_plot_1(G, d):
	# Blue for SCTs which factor over <r^d>, red otherwise.
	if G not in evens or G == 'D04':
		print "WTF!"
		return
	if G[1] == '0':
		n = int(eval(G[2:])/2)
	else:
		n = int(eval(G[1:])/2)
	if n % d != 0:
		print 'Incompatible divisor.'
		return
	color_dict = {'#2176C7' : [], '#D11C24' : []}
	for i in sct_posets[G]:
		if is_factorable_1(G,d,i):
			color_dict['#2176C7'].append(i)
		else:
			color_dict['#D11C24'].append(i)
	P = sct_posets[G].plot(vertex_colors = color_dict)
	Q = text(G + ' factorable over <r^(' + str(d) + ')>', (0,0), axes=False, color='black')
	return P + Q
	#(P + Q).show()

def is_factorable_2(G, i):
	# Returns True for SCTs which factor over <r^2,s>, False otherwise.
	if G not in evens or G == 'D04':
		print 'WTF!'
		return
	if G[1] == '0':
		n = int(eval(G[2:])/2)
	else:
		n = int(eval(G[1:])/2)
	codex = class_codex[G]
	mmNG = SetPartition([[0],[2]]+[[codex[k]] for k in range(2,n/2+1,2)]+[[3]+[codex[k] for k in range(1,n/2+1,2)]])
	MMNG = SetPartition([[0]]+[[2]+[codex[k] for k in range(2,n/2+1,2)]]+[[3]+[codex[k] for k in range(1,n/2+1,2)]])
	K = superclass_lists[G][i]
	return K*mmNG == mmNG and K*MMNG == K

def factorable_plot_2(G):
	# Blue for SCTs which factor over <r^2,s>, red otherwise.
	if G not in evens or G == 'D04':
		print "WTF!"
		return
	color_dict = {'#2176C7' : [], '#D11C24' : []}
	for i in sct_posets[G]:
		if is_factorable_2(G,i):
			color_dict['#2176C7'].append(i)
		else:
			color_dict['#D11C24'].append(i)
	P = sct_posets[G].plot(vertex_colors = color_dict)
	Q = text(G + ' factorable over <r^2, s>', (0,0), axes=False, color='black')
	return P + Q
	#(P + Q).show()

def is_factorable_3(G, i):
	# Returns True for SCTs which factor over <r^2,rs>, False otherwise.
	if G not in evens or G == 'D04':
		print 'WTF!'
		return
	if G[1] == '0':
		n = int(eval(G[2:])/2)
	else:
		n = int(eval(G[1:])/2)
	codex = class_codex[G]
	mmNG = SetPartition([[0],[3]]+[[codex[k]] for k in range(2,n/2+1,2)]+[[2]+[codex[k] for k in range(1,n/2+1,2)]])
	MMNG = SetPartition([[0]]+[[3]+[codex[k] for k in range(2,n/2+1,2)]]+[[2]+[codex[k] for k in range(1,n/2+1,2)]])
	K = superclass_lists[G][i]
	return K*mmNG == mmNG and K*MMNG == K

def factorable_plot_3(G):
	# Blue for SCTs which factor over <r^2,rs>, red otherwise.
	if G not in evens or G == 'D04':
		print "WTF!"
		return
	color_dict = {'#2176C7' : [], '#D11C24' : []}
	for i in sct_posets[G]:
		if is_factorable_3(G,i):
			color_dict['#2176C7'].append(i)
		else:
			color_dict['#D11C24'].append(i)
	P = sct_posets[G].plot(vertex_colors = color_dict)
	Q = text(G + ' factorable over <r^2, sr>', (0,0), axes=False, color='black')
	return P + Q
	#(P + Q).show()

def is_any_fact(G,i):
	if G not in evens or G == 'D04':
		print 'WTF!'
		return
	if G == 'D08':
		n = 4
	else:
		n = sage_eval(str(int(eval(G[1:])/2)))
	divs = [d for d in n.divisors() if d != n]
	return is_factorable_3(G,i) or is_factorable_2(G,i) or any([is_factorable_1(G,d,i) for d in divs])

def any_fact_plot(G):
	if G not in evens or G == 'D04':
		print 'WTF!'
		return
	color_dict = {'#2176C7' : [], '#D11C24' : []}
	if G == 'D08':
		n = 4
	else:
		n = sage_eval(str(int(eval(G[1:])/2)))
	for i in sct_posets[G]:
		if is_any_fact(G,i):
			color_dict['#2176C7'].append(i)
		else:
			color_dict['#D11C24'].append(i)
	P = sct_posets[G].plot(vertex_colors = color_dict)
	Q = text(G + ' factorable at all', (0,0), axes=False, color='black')
	return P + Q

def any_fact_subposet(G):
	if G not in evens or G == 'D04':
		print 'WTF!'
		return
	if G == 'D08':
		n = 4
	else:
		n = sage_eval(str(int(eval(G[1:])/2)))
	return sct_posets[G].subposet([i for i in sct_posets[G] if is_any_fact(G,i)])

def maxodd_plot(G):
	if G not in evens or G[1] == '0':
		print 'WTF!'
		return
	n = sage_eval(str(int(eval(G[1:])/2)))
	divs = [d for d in n.divisors() if is_odd(d)]
	if len(divs) == 0:
		print 'n is a power of 2'
		return
	m = max(divs)
	return factorable_plot_1(G,m)
