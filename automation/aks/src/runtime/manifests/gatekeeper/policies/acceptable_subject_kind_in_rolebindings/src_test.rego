package com.microsoft.c12.acceptablesubjectkindinrolebindings

test_good_rolebinding {
	violation == set() 
	with input as {"review": {"name": "good-rolebinding", "object": {"subjects": [{"kind": "Group", "name": "somegroup"}]}}} 
	with input.parameters.allowedsubjectkinds as ["Group"] 
	with input.review.object.metadata.name as "test_good_rolebinding"
}
test_bad_rolebinding_oneviolation {
	count(violation) == 1 
	with input as {"review": {"name": "bad-rolebinding", "object": {"subjects": [{"kind": "User", "name": "someuser"}]}}} 
	with input.parameters.allowedsubjectkinds as ["Group"] 
	with input.review.object.metadata.name as "test_bad_rolebinding_oneviolation"
}

test_bad_rolebinding_twoviolations {
	count(violation) == 2 
	with input as {"review": {"name": "bad-rolebinding", "object": {"subjects": [{"kind": "User", "name": "someuser"}, {"kind": "ServiceAccount", "name": "someserviceaccount"}]}}} 
	with input.parameters.allowedsubjectkinds as ["Group"] 
	with input.review.object.metadata.name as "test_bad_rolebinding_twoviolations"
}
