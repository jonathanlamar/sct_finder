def factorable_plot(G):
	color_dict = {'#2176C7' : [], '#D11C24' : []}
	for i in sct_posets[G]:
		if len([x for x in superclass_lists[G][i] if 1 in x][0]) > 1:
			color_dict['#D11C24'].append(i)
		else:
			color_dict['#2176C7'].append(i)
	P = sct_posets[G].plot(vertex_colors = color_dict)
	Q = text(G+' factorable over Z'+str(int(sage_eval(G[1:])/2)),(0,0),axes=False,color='black')
	(P+Q).show()
