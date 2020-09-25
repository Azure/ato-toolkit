package com.microsoft.c12.denydeploymentstonamespace

test_good_pod_deployment {
	violation == set() 
	with input as {"review": {"name": "good-pod-deployment", "object": {"kind": "pod", "metadata": {"namespace": "some-namespace"}}}} 
	with input.parameters.namespacestodeny as ["default"]
	with input.review.object.metadata.name as "test_good_pod_deployment"
}

test_good_service_deployment {
	violation == set() 
	with input as {"review": {"name": "good-service-deployment", "object": {"kind": "service", "metadata": {"namespace": "some-namespace"}}}} 
	with input.parameters.namespacestodeny as ["default"]
	with input.review.object.metadata.name as "test_good_service_deployment"
}

test_bad_pod_deployment {
	count(violation) == 1 
	with input as {"review": {"name": "bad-pod-deployment", "object": {"kind": "pod", "metadata": {"namespace": "default"}}}} 
	with input.parameters.namespacestodeny as ["default"]
	with input.review.object.metadata.name as "test_bad_pod_deployment"
}

test_bad_service_deployment {
	count(violation) == 1 
	with input as {"review": {"name": "bad-service-deployment", "object": {"kind": "service", "metadata": {"namespace": "default"}}}} 
	with input.parameters.namespacestodeny as ["default"]
	with input.review.object.metadata.name as "test_bad_service_deployment"
}