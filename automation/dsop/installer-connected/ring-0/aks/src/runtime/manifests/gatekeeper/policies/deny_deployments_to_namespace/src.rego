package com.microsoft.c12.denydeploymentstonamespace


contains_items(haystack, needle) {
  haystack[_] == needle
}

violation[{"msg": msg}] {
  objectnamespace := input.review.object.metadata.namespace
  contains_items(input.parameters.namespacestodeny, objectnamespace)
  msg := sprintf("The deployment of the %v %v targets the %v namespace. This is not allowed. The following namespaces are blocked from user deployments: %v.", [input.review.object.metadata.name, input.review.object.kind, objectnamespace, input.parameters.namespacestodeny])
}

