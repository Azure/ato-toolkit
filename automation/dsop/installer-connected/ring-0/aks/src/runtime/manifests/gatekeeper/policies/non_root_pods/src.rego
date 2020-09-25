package com.microsoft.c12.podsnonroot

violation[{"msg": msg, "details": {}}] {
	not input.review.object.spec.securityContext.runAsNonRoot = true
	msg := sprintf("pod %s is running as root", [input.review.name])
}

violation[{"msg": msg, "details": {}}] {
	input.review.object.spec.securityContext.runAsUser == 0
	msg := sprintf("pod %s has a UID of 0", [input.review.name])
}
