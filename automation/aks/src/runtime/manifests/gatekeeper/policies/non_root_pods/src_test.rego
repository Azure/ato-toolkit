package com.microsoft.c12.podsnonroot

test_good_pod {
	violation == set() with input as {"review": {"name": "good-pod", "object": {"spec": {"securityContext": {"runAsUser": 100, "runAsNonRoot": true}}}}}
}

test_undefined_user_pod {
	violation == set() with input as {"review": {"name": "good-pod", "object": {"spec": {"securityContext": {"runAsNonRoot": true}} }}}
}

test_undefined_pod {
	count(violation) == 1 with input as {"review": {"name": "bad-pod", "object": {"spec":{} }}}
}

test_undefined_run_as_pod {
	count(violation) == 1 with input as {"review": {"name": "bad-pod", "object": {"spec": {"securityContext": {"runAsUser": 100}} }}}
}

test_root_pod {
	count(violation) == 1 with input as {"review": {"name": "bad-pod", "object": {"spec": {"securityContext": {"runAsUser": 100, "runAsNonRoot": false}}}}}
}

test_pod_user_0 {
	count(violation) = 1 with input as {"review": {"name": "bad-pod", "object": {"spec": {"securityContext": {"runAsUser": 0, "runAsNonRoot": true}}}}}
}

test_root_pod_user_0 {
	count(violation) == 2 with input as {"review": {"name": "bad-pod", "object": {"spec": {"securityContext": {"runAsUser": 0, "runAsNonRoot": false}}}}}
}
